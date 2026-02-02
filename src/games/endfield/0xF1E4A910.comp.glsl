// accum
#version 450
#if defined(GL_EXT_control_flow_attributes)
#extension GL_EXT_control_flow_attributes : require
#define SPIRV_CROSS_FLATTEN [[flatten]]
#define SPIRV_CROSS_BRANCH [[dont_flatten]]
#define SPIRV_CROSS_UNROLL [[unroll]]
#define SPIRV_CROSS_LOOP [[dont_unroll]]
#else
#define SPIRV_CROSS_FLATTEN
#define SPIRV_CROSS_BRANCH
#define SPIRV_CROSS_UNROLL
#define SPIRV_CROSS_LOOP
#endif

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

// 3x3 Neighborhood offsets
const ivec2 kOffsets[9] = ivec2[](
    ivec2(-1, -1), ivec2(0, -1), ivec2(1, -1),
    ivec2(-1, 0),  ivec2(0, 0),  ivec2(1, 0),
    ivec2(-1, 1),  ivec2(0, 1),  ivec2(1, 1)
);

layout(set = 1, binding = 0, std140) uniform type_GTAOData
{
    vec4 _GTAOParam0;
    vec4 _GTAOParam1;
    vec4 _GTAOParam2;
    vec4 _GTAOHalfScreenSize;
} _GTAOData;

layout(set = 0, binding = 5) uniform sampler s_point_clamp_sampler;
layout(set = 0, binding = 1) uniform texture2D _GTAODepthMIPs;
layout(set = 0, binding = 2) uniform texture2D _GTAOMainAOTermRT;
layout(set = 0, binding = 3) uniform texture2D _GTAOMotionVectorRT;
layout(set = 0, binding = 4) uniform texture2D _GTAOPreviousAOTermRT;
layout(set = 0, binding = 0) uniform writeonly image2D _GTAOCurrentAOTermRT;

#define REPROJECTION_WEIGHT_SCALE 20.f
#define DEPTH_REJECTION_STRENGTH 100.0 // Increased for tighter rejection

// Helper to clip history color towards the neighborhood AABB (Variance Clipping)
// This is much more stable than raw Min/Max clamping
float ClipHistory(float history, float current, float mean, float stdDev) {
    float gamma = 1.0; // Stricter = 0.5, Looser = 1.5. 1.0 is a good balance.
    float minB = mean - gamma * stdDev;
    float maxB = mean + gamma * stdDev;

    // Clamp history to the variance box
    return clamp(history, minB, maxB);
}

// Simpler Bilinear fallback if 16-taps is too slow
vec4 SampleBilinear(texture2D tex, sampler s, vec2 uv) {
    vec2 res = _GTAOData._GTAOHalfScreenSize.xy * 2.0;
    vec2 st = uv * res - 0.5;
    vec2 iuv = floor(st);
    vec2 fuv = fract(st);

    vec4 a = textureLod(sampler2D(tex, s), (iuv + vec2(0.5, 0.5)) / res, 0.0).xyzw;
    vec4 b = textureLod(sampler2D(tex, s), (iuv + vec2(1.5, 0.5)) / res, 0.0).xyzw;
    vec4 c = textureLod(sampler2D(tex, s), (iuv + vec2(0.5, 1.5)) / res, 0.0).xyzw;
    vec4 d = textureLod(sampler2D(tex, s), (iuv + vec2(1.5, 1.5)) / res, 0.0).xyzw;

    return mix(mix(a, b, fuv.x), mix(c, d, fuv.x), fuv.y);
}

vec4 XeGTAO_CalculateEdges( const float centerZ, const float leftZ, const float rightZ, const float topZ, const float bottomZ )
{
    vec4 edgesLRTB = vec4( leftZ, rightZ, topZ, bottomZ ) - float(centerZ);

    float slopeLR = (edgesLRTB.y - edgesLRTB.x) * 0.5;
    float slopeTB = (edgesLRTB.w - edgesLRTB.z) * 0.5;
    vec4 edgesLRTBSlopeAdjusted = edgesLRTB + vec4( slopeLR, -slopeLR, slopeTB, -slopeTB );
    edgesLRTB = min( abs( edgesLRTB ), abs( edgesLRTBSlopeAdjusted ) );
    return vec4(clamp( ( 1.25 - edgesLRTB / (centerZ * 0.011) ), 0.0, 1.0 ));
}

// packing/unpacking for edges; 2 bits per edge mean 4 gradient values (0, 0.33, 0.66, 1) for smoother transitions!
float XeGTAO_PackEdges( vec4 edgesLRTB )
{
    // integer version:
    // edgesLRTB = saturate(edgesLRTB) * 2.9.xxxx + 0.5.xxxx;
    // return (((uint)edgesLRTB.x) << 6) + (((uint)edgesLRTB.y) << 4) + (((uint)edgesLRTB.z) << 2) + (((uint)edgesLRTB.w));
    // 
    // optimized, should be same as above
    edgesLRTB = round( clamp( edgesLRTB, 0.0, 1.0 ) * 2.9 );
    return dot( edgesLRTB, vec4( 64.0 / 255.0, 16.0 / 255.0, 4.0 / 255.0, 1.0 / 255.0 ) ) ;
}

void main()
{
    // 1. Calculate UVs
    vec2 uv = (vec2(gl_GlobalInvocationID.xy) + vec2(0.5)) * _GTAOData._GTAOHalfScreenSize.zw;
	
	vec4 valuesUL = textureGather(
		sampler2D(_GTAODepthMIPs, s_point_clamp_sampler),
		vec2(gl_GlobalInvocationID.xy) * _GTAOData._GTAOHalfScreenSize.zw,
		0
	);

	vec4 valuesBR = textureGatherOffset(
		sampler2D(_GTAODepthMIPs, s_point_clamp_sampler),
		vec2(gl_GlobalInvocationID.xy) * _GTAOData._GTAOHalfScreenSize.zw,
		ivec2(1, 1),
		0
	);
	
    // viewspace Z at the center
    float viewspaceZ  = valuesUL.y; //sourceViewspaceDepth.SampleLevel( depthSampler, normalizedScreenPos, 0 ).x; 

    // viewspace Zs left top right bottom
    const float pixLZ = valuesUL.x;
    const float pixTZ = valuesUL.z;
    const float pixRZ = valuesBR.z;
    const float pixBZ = valuesBR.x;

    vec4 edgesLRTB  = XeGTAO_CalculateEdges( viewspaceZ, pixLZ, pixRZ, pixTZ, pixBZ );
	float edges = XeGTAO_PackEdges(edgesLRTB);

    // 2. Decode Motion Vectors (Preserving your engine's specific encoding logic)
    vec2 encodedMV = textureLod(sampler2D(_GTAOMotionVectorRT, s_point_clamp_sampler), uv, 0.0).xy;
    vec2 mvTmp = (abs(encodedMV) * 2.0) - vec2(1.0);
    vec2 mvSquared = mvTmp * mvTmp;
    vec2 velocity = (mvSquared * mvSquared) * vec2(ivec2(sign(encodedMV - vec2(0.5))));
    vec2 historyUV = uv - velocity;

    // 3. Fetch Data
    vec4 historySample = SampleBilinear(_GTAOPreviousAOTermRT, s_point_clamp_sampler, historyUV);//textureLod(sampler2D(_GTAOPreviousAOTermRT, s_point_clamp_sampler), historyUV, 0.0);
    float historyAO = historySample.x;
    float historyDepth = textureLod(sampler2D(_GTAOPreviousAOTermRT, s_point_clamp_sampler), historyUV, 0.0).y;

	float velocityWeight = exp((-length(velocity * _GTAOData._GTAOHalfScreenSize.xy)) * _GTAOData._GTAOParam2.z);//clamp(1.0 - (speedDelta * REPROJECTION_WEIGHT_SCALE), 0.0, 1.0 );
	//velocityWeight = smoothstep(0.0, 1.0, velocityWeight); 

    // Fetch current depth (Assuming 0.0099... is your specific normalization scale)
    float currentDepthRaw = textureLod(sampler2D(_GTAODepthMIPs, s_point_clamp_sampler), uv, 0.0).x;
    float currentDepth = min(currentDepthRaw * 0.00999999977648258209228515625, 1.0);

    // 4. Sample 3x3 Neighborhood for Variance Calculation
    // We calculate Mean (m1) and Second Moment (m2) to find Variance
    float m1 = 0.0;
    float m2 = 0.0;
    float currentAO = 0.0;

    // Unroll manually or loop
    for (int i = 0; i < 9; i++)
    {
        float sampleAO = textureLod(sampler2D(_GTAOMainAOTermRT, s_point_clamp_sampler), uv + (vec2(kOffsets[i]) * _GTAOData._GTAOHalfScreenSize.zw), 0.0).x;
        
        m1 += sampleAO;
        m2 += sampleAO * sampleAO;

        // Store center pixel (index 4 in your array is 0,0)
        if (i == 4) currentAO = sampleAO;
    }

    m1 /= 9.0; // Mean
    m2 /= 9.0; 
    float sigma = sqrt(max(m2 - m1 * m1, 0.0)); // Standard Deviation

    // 5. Determine History Validity
    float validity = 1.0;

    // Check 1: Off-screen
    if (any(lessThan(historyUV, vec2(0.0))) || any(greaterThan(historyUV, vec2(1.0)))) {
        validity = 0.0;
    } 
    else {
        // Check 2: Depth Disocclusion
        // Relaxed the strict -1000.0 exp decay which causes flashing on slight depth slopes.
        // Using a relative depth comparison is usually safer.
        float depthDiff = abs(currentDepth - historyDepth);
        float depthThreshold = 0.1; // Adjustable sensitivity
        
        if (depthDiff > depthThreshold) {
            validity = 0.0;
        } else {
			//float uvWeight = exp((-length(_98 * _GTAOData._GTAOHalfScreenSize.xy)) * _GTAOData._GTAOParam2.z))
             // Basic exponential falloff for small depth discrepancies
            validity = exp(-depthDiff * DEPTH_REJECTION_STRENGTH) * velocityWeight;
        }
    }

    // 6. Accumulate
    float finalAO;
    
    // Check if temporal accumulation is enabled (Param2.y check from original code)
    if (_GTAOData._GTAOParam2.y == 0.0) {
        finalAO = currentAO;
    } 
    else {
        // A. Clip history to the statistical variance of the new frame
        float clippedHistory = ClipHistory(historyAO, currentAO, m1, sigma);

        // B. Calculate blend factor
        // 0.95 = High temporal stability (less flicker, more trails)
        // 0.80 = Low temporal stability (more flicker, less trails)
        float blendFactor = 0.9 * validity; 

        // C. Mix: Always blend a little bit of currentAO (LERP), don't just clamp history.
        // This mix ensures that even if history is "perfect", we slowly integrate new lighting data.
        finalAO = mix(currentAO, clippedHistory, blendFactor);
    }

    // Output
    // We store 'validity' in the Z channel purely for debugging or next frame if needed, 
    // though usually you want to store linear depth in Y for the next frame's rejection.
    imageStore(_GTAOCurrentAOTermRT, ivec2(gl_GlobalInvocationID.xy), vec4(finalAO, currentDepth, validity, edges));
}