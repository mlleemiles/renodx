// AO Temporal accum
#version 450
#extension GL_EXT_samplerless_texture_functions : require
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

layout(set = 1, binding = 0, std140) uniform type_ShaderVariablesGlobal
{
    layout(row_major) mat4 _ViewMatrix;
    layout(row_major) mat4 _InvViewMatrix;
    layout(row_major) mat4 _ProjMatrix;
    layout(row_major) mat4 _InvProjMatrix;
    layout(row_major) mat4 _DeprecatedViewProjMatrix;
    layout(row_major) mat4 _ViewNoTransProjMatrix;
    layout(row_major) mat4 _InvViewProjMatrix;
    layout(row_major) mat4 _DeprecatedNonJitteredViewProjMatrix;
    layout(row_major) mat4 _NonJitteredViewNoTransProjMatrix;
    layout(row_major) mat4 _InvNonJitteredViewProjMatrix;
    layout(row_major) mat4 _InvPretransformMatrix;
    vec4 _WorldSpaceCameraPos_Internal;
    layout(row_major) mat4 _DeprecatedPrevViewProjMatrix;
    layout(row_major) mat4 _PrevViewNoTransProjMatrix;
    layout(row_major) mat4 _DeprecatedPrevNonJitteredViewProjMatrix;
    layout(row_major) mat4 _PrevNonJitteredViewNoTransProjMatrix;
    layout(row_major) mat4 _PrevInvViewProjMatrix;
    layout(row_major) mat4 _PrevNonJitteredInvViewProjMatrix;
    layout(row_major) mat4 _ReprojectionMatrix;
    layout(row_major) mat4 _WiderFoVViewProjMatrix;
    layout(row_major) mat4 _WiderFoVInvViewProjMatrix;
    vec4 _PrevCamPosRWS_Internal;
    vec4 _ScreenSize;
    vec4 _BackBufferSize;
    vec4 _ZBufferParams;
    vec4 _ProjectionParams;
    vec4 unity_OrthoParams;
    vec4 _ScreenParams;
    vec4 _FrustumPlanes[6];
    vec4 _ShadowFrustumPlanes[6];
    vec4 _TaaFrameInfo;
    vec4 _TaaJitterStrength;
    vec4 _Time;
    vec4 _SinTime;
    vec4 _CosTime;
    vec4 unity_DeltaTime;
    vec4 _TimeParameters;
    vec4 _LastTimeParameters;
    float _GlobalMipBias;
    float _GlobalMipBiasPow2;
    float _ProbeExposureScale;
    uint _FrameCount;
    vec4 _ExposureParams;
    ivec4 _BinningBufferOffsets;
    vec4 _EnvironmentGlobalParams0;
    vec4 _GraphicsFeaturesGlobalParam0;
    vec4 _GraphicsFeaturesGlobalParam1;
    vec4 _WindGlobalParams0;
    vec4 _WindGlobalParams2;
    vec4 _CharacterPositionParams0;
    vec4 _CharacterPositionParams1;
    vec4 _CharacterPositionParams2;
    vec4 _CharacterPositionParams3;
    vec4 _CharacterHeightParams;
    vec4 _WindMotorParams0[4];
    vec4 _WindMotorParams1[4];
    vec4 _WindMotorParams2[4];
    vec4 _WindMotorParams3[4];
    vec4 _WindMotorCount;
    vec4 _LastWindGlobalParams0;
    vec4 _LastWindMotorParams0[4];
    vec4 _LastWindMotorParams1[4];
    vec4 _LastWindMotorParams3[4];
    vec4 _FoliageInteractiveParams0;
    vec4 _PrevFoliageInteractiveParams0;
    vec4 _AtmosphereFogParams0;
    vec4 _AtmosphereFogParams1;
    vec4 _AtmosphereFogParams2;
    vec4 _AtmosphereFogParams3;
    vec4 _AtmosphereFogParams4;
    vec4 _AtmosphereFogParams5;
    vec4 _ExponentialFogParams0;
    vec4 _ExponentialFogParams1;
    vec4 _ExponentialFogParams2;
    vec4 _ExponentialFogParams3;
    vec4 _VolumetricFogParams0;
    vec4 _VolumetricFogParams1;
    vec4 _VolumetricFogParams2;
    vec4 _VolumetricFogParams3;
    vec4 _VolumetricFogParams4;
    vec4 _HeightFogFlowNoiseParams0;
    vec4 _HeightFogFlowNoiseParams1;
    vec4 _FogBakeLutRescaleParams;
    vec4 _FogBakeLutEncodeParams;
    vec4 _FogBakeLutYawParams;
    vec4 _CloudShadowParams0;
    vec4 _CloudShadowParams1;
    vec4 _CloudShadowParams2;
    vec4 _CloudShadowParams3;
    vec4 _Style_MatDistCoef;
    vec4 _Style_MatFarAlb0;
    vec4 _Style_MatFarAlb1;
    vec4 _Style_GbFarEms;
    vec4 _Style_GbFarDir;
    vec4 _Style_GbCoef;
    vec4 _VFXParams0;
    vec4 _VFXParams1;
    vec4 _VFXParams2;
    vec4 _CharacterParams0;
    vec4 _CharacterParams1;
    vec4 _CharacterParams2;
    vec4 _CharacterParams3;
    vec4 _CharacterParams4;
    vec4 _CharacterParams5;
    vec4 _CharacterParams6;
    vec4 _CharacterParams7;
    vec4 _CharacterParams8;
    vec4 _CharacterParams9;
    vec4 _CharacterParams10;
    vec4 _CharacterParams11;
    vec4 _CharacterParams12;
    vec4 _CharacterParams13;
    vec4 _CharacterParams14;
    vec4 _CharacterParams15;
    vec4 _InkSimulationWorldToUV;
    vec4 _TerrainDeformParams0;
    vec4 _TerrainDeformParams1;
    vec4 _TerrainClipmapParams0[2];
    vec4 _TerrainClipmapParams1[2];
    float _G_EnableFeatureErosionBlend;
    float _G_EnableFeatureB;
    float _G_EnableFeatureC;
    float _G_EnableFeatureD;
    vec4 _IVParam0;
    vec4 _IVParam1;
    vec4 _IVParam2;
    vec4 _IVDefaultSHAr;
    vec4 _IVDefaultSHAg;
    vec4 _IVDefaultSHAb;
    vec4 _IVV2Param0;
    vec4 _IVV2Param1;
    vec4 _IVV2Param2;
    vec4 _IVV2Param3;
    vec4 _WaterInteractionParams0;
    vec4 _WaterInteractionParams1;
    vec4 _RainWetnessGlobalParam0;
    vec4 _RainWetnessGlobalParam1;
    vec4 _RainWetnessGlobalParam2;
    vec4 _RainWetnessGlobalParam3;
    vec4 _RainWetnessGlobalParam4;
    vec4 _RainWetnessGlobalParam5;
    vec4 _RainWetnessGlobalParam6;
    vec4 _RainWetnessGlobalParam7;
    vec4 _RainWetnessGlobalParam8;
    vec4 _RainWetnessGlobalParam9;
    vec4 _RainWetnessGlobalParam10;
    vec4 _VerticalOcclusionMapParam0;
    vec4 _WaterWetnessMaskParam0;
    vec4 _GpuClothParams;
    vec4 _FoliageOccluderParams0;
    vec4 _FoliageOccluderCameraPosParam;
    vec4 _InteractRaftParams0;
    vec4 _InteractRaftParams1;
    layout(row_major) mat4 _FakePlanarReflectionViewProjMatrix;
    vec4 _FakeSphericalLightSource;
    vec4 _VolumetricComposeParams;
    vec4 _HackTempDataBeforeCPPPlugin[32];
} ShaderVariablesGlobal;

layout(set = 1, binding = 1, std140) uniform type_GTAOData
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

layout(set = 2, binding = 0, rg8) uniform writeonly image2D _GTAOCurrentAOTermFullRT;
layout(set = 2, binding = 1) uniform texture2D _GTAOMainAOTermFullRT;
layout(set = 2, binding = 2) uniform texture2D _GTAODepthMIPsFull;
layout(set = 2, binding = 3) uniform texture2D _GTAOOutNormalFull;
layout(set = 2, binding = 4) uniform texture2D _GTAOPreviousAOTermFullRT;
layout(set = 2, binding = 5) uniform texture2D _GTAOPreviousDepthRT;
layout(set = 2, binding = 6) uniform texture2D _GTAOPreviousNormalRT;

#define SCREEN_SIZE ShaderVariablesGlobal._ScreenSize.xy
#define SCREEN_SIZE_RCP ShaderVariablesGlobal._ScreenSize.zw

// Inputs are screen XY and viewspace depth, output is viewspace position
vec3 XeGTAO_ComputeViewspacePosition( const vec2 screenPos, const float viewspaceDepth )
{
    vec2 _198 = (vec4((screenPos * 2.0) - vec2(1.0), 1.0, 1.0) * ShaderVariablesGlobal._InvProjMatrix).xy * viewspaceDepth;
    vec3 _202 = vec3(_198.x, -_198.y, viewspaceDepth);
    return _202;
}

vec2 GetPrevUV(vec2 uv, float depth)
{
    vec4 clipPos;
    clipPos.xy = uv * 2.0 - 1.0;
    clipPos.z  = depth * 2.0 - 1.0;
    clipPos.w  = 1.0;

    vec4 prevClip = ShaderVariablesGlobal._ReprojectionMatrix * clipPos;
    prevClip /= prevClip.w;

    return prevClip.xy * 0.5 + 0.5;
}

// Because of point sampler we must do our own sampling, will fix later
vec4 SampleBilinear(texture2D tex, sampler s, vec2 uv) {
    vec2 res = SCREEN_SIZE;
    vec2 st = uv * res - 0.5;
    vec2 iuv = floor(st);
    vec2 fuv = fract(st);

    vec4 a = textureLod(sampler2D(tex, s), (iuv + vec2(0.5, 0.5)) / res, 0.0).xyzw;
    vec4 b = textureLod(sampler2D(tex, s), (iuv + vec2(1.5, 0.5)) / res, 0.0).xyzw;
    vec4 c = textureLod(sampler2D(tex, s), (iuv + vec2(0.5, 1.5)) / res, 0.0).xyzw;
    vec4 d = textureLod(sampler2D(tex, s), (iuv + vec2(1.5, 1.5)) / res, 0.0).xyzw;

    return mix(mix(a, b, fuv.x), mix(c, d, fuv.x), fuv.y);
}

vec4 CatmullRomWeights(float t)
{
    float t2 = t * t;
    float t3 = t2 * t;

    return vec4(
        -0.5*t3 +      t2 - 0.5*t,
         1.5*t3 - 2.5*t2 + 1.0,
        -1.5*t3 + 2.0*t2 + 0.5*t,
         0.5*t3 - 0.5*t2
    );
}

vec4 SampleCatmullRom(texture2D tex, sampler s, vec2 uv)
{
    vec2 res = SCREEN_SIZE;
    vec2 st = uv * res - 0.5;
    vec2 iuv = floor(st);
    vec2 fuv = fract(st);

    vec4 wx = CatmullRomWeights(fuv.x);
    vec4 wy = CatmullRomWeights(fuv.y);

    vec2 base = (iuv + vec2(0.5)) / res;

    vec4 c00 = textureLod(sampler2D(tex, s), base + vec2(-1.0, -1.0) / res, 0.0);
    vec4 c10 = textureLod(sampler2D(tex, s), base + vec2( 0.0, -1.0) / res, 0.0);
    vec4 c20 = textureLod(sampler2D(tex, s), base + vec2( 1.0, -1.0) / res, 0.0);
    vec4 c30 = textureLod(sampler2D(tex, s), base + vec2( 2.0, -1.0) / res, 0.0);

    vec4 c01 = textureLod(sampler2D(tex, s), base + vec2(-1.0,  0.0) / res, 0.0);
    vec4 c11 = textureLod(sampler2D(tex, s), base + vec2( 0.0,  0.0) / res, 0.0);
    vec4 c21 = textureLod(sampler2D(tex, s), base + vec2( 1.0,  0.0) / res, 0.0);
    vec4 c31 = textureLod(sampler2D(tex, s), base + vec2( 2.0,  0.0) / res, 0.0);

    vec4 c02 = textureLod(sampler2D(tex, s), base + vec2(-1.0,  1.0) / res, 0.0);
    vec4 c12 = textureLod(sampler2D(tex, s), base + vec2( 0.0,  1.0) / res, 0.0);
    vec4 c22 = textureLod(sampler2D(tex, s), base + vec2( 1.0,  1.0) / res, 0.0);
    vec4 c32 = textureLod(sampler2D(tex, s), base + vec2( 2.0,  1.0) / res, 0.0);

    vec4 c03 = textureLod(sampler2D(tex, s), base + vec2(-1.0,  2.0) / res, 0.0);
    vec4 c13 = textureLod(sampler2D(tex, s), base + vec2( 0.0,  2.0) / res, 0.0);
    vec4 c23 = textureLod(sampler2D(tex, s), base + vec2( 1.0,  2.0) / res, 0.0);
    vec4 c33 = textureLod(sampler2D(tex, s), base + vec2( 2.0,  2.0) / res, 0.0);

    vec4 col0 = c00*wx.x + c10*wx.y + c20*wx.z + c30*wx.w;
    vec4 col1 = c01*wx.x + c11*wx.y + c21*wx.z + c31*wx.w;
    vec4 col2 = c02*wx.x + c12*wx.y + c22*wx.z + c32*wx.w;
    vec4 col3 = c03*wx.x + c13*wx.y + c23*wx.z + c33*wx.w;

    return col0*wy.x + col1*wy.y + col2*wy.z + col3*wy.w;
}

float ClipHistory(float history, float current, float mean, float stdDev) {
    float gamma = 1.0; // Stricter = 0.5, Looser = 1.5. 1.0 is a good balance.
    float minB = mean - gamma * stdDev;
    float maxB = mean + gamma * stdDev;

    // Clamp history to the variance box
    return clamp(history, minB, maxB);
}

bool IsSky( float depth )
{
	return (depth == ShaderVariablesGlobal._ProjectionParams.z);
}


void main()
{
    vec2 uv = (vec2(gl_GlobalInvocationID.xy) + vec2(0.5)) * SCREEN_SIZE_RCP;
	
	float currentDepth = textureLod(sampler2D(_GTAODepthMIPsFull, s_point_clamp_sampler), uv, 0.0).x;
	
	if (IsSky( currentDepth ))
	{
		imageStore(_GTAOCurrentAOTermFullRT, ivec2(gl_GlobalInvocationID.xy), vec4(1.0, 0.0, 0.0, 0.0));
		imageStore(_GTAOCurrentAOTermRT, ivec2(gl_GlobalInvocationID.xy), vec4(0.0));
		return;
	}

    vec2 encodedMV = textureLod(sampler2D(_GTAOMotionVectorRT, s_point_clamp_sampler), uv, 0.0).xy;
    vec2 mvTmp = (abs(encodedMV) * 2.0) - vec2(1.0);
    vec2 mvSquared = mvTmp * mvTmp;
    vec2 velocity = (mvSquared * mvSquared) * vec2(ivec2(sign(encodedMV - vec2(0.5))));
    vec2 prevUV = uv - velocity;//GetPrevUV(uv, currentDepth);//uv - velocity;
	
	float prevAge, prevAO, prevDepth;
	
	prevDepth = textureLod(sampler2D(_GTAOPreviousDepthRT, s_point_clamp_sampler), prevUV, 0.0).x;
	bool isDisocclusion = (currentDepth > prevDepth * 1.0425);
	bool isUVInvalid = (any(lessThan(prevUV, vec2(0.0))) || any(greaterThan(prevUV, vec2(1.0))));
	bool isZeroTime = (texelFetch(_GTAOPreviousAOTermRT, ivec2(0), 0).r == 1.0);
	
    float m1 = 0.0;
    float m2 = 0.0;
    float currentAO = 0.0;
	float sampleAO[9];
	
	float minAO = 9999.0;
	float maxAO = -9999.0;

    SPIRV_CROSS_UNROLL
    for (int i = 0; i < 9; i++)
    {
        sampleAO[i] = textureLod(sampler2D(_GTAOMainAOTermFullRT, s_point_clamp_sampler), uv + (vec2(kOffsets[i]) * SCREEN_SIZE_RCP), 0.0).x;
        
        m1 += sampleAO[i];
        m2 += sampleAO[i] * sampleAO[i];
		
        minAO = min(minAO, sampleAO[i]); // Take min and max
        maxAO = max(maxAO, sampleAO[i]);

        // Store center pixel (index 4 in your array is 0,0)
        if (i == 4) currentAO = sampleAO[i];
    }

    m1 /= 9.0; // Mean
    m2 /= 9.0; 
    float sigma = sqrt(max(m2 - m1 * m1, 0.0));// * 1.25f; // Standard Deviation
	/*
    float minCrossAO = min(sampleAO[1], min(min(sampleAO[3], sampleAO[4]), min(sampleAO[5], sampleAO[7])));
    float minCornerAO = min(min(sampleAO[0], sampleAO[2]), min(sampleAO[6], sampleAO[8]));
    float AOLowerThresh = min((minCrossAO + minCornerAO) * 0.5, m1 - sigma);
	
    float maxCrossAO = max(sampleAO[1], max(max(sampleAO[3], sampleAO[4]), max(sampleAO[5], sampleAO[7])));
    float maxCornerAO = max(max(sampleAO[0], sampleAO[2]), max(sampleAO[6], sampleAO[8]));
    float AOUpperThresh = max((maxCrossAO + maxCornerAO) * 0.5, m1 + sigma);
	*/
	if (isZeroTime)
	{
		prevAge = 0.0;
		prevAO = 1.0;
	}
	else
	{
		if ((!isDisocclusion) && (!isUVInvalid) && (_GTAOData._GTAOParam2.y != 0.0))
		{
			vec4 prevSample = SampleCatmullRom(_GTAOPreviousAOTermFullRT, s_point_clamp_sampler, prevUV);
			prevAO = prevSample.x;
			prevAge = prevSample.y;
			
			// Too many texture fetches
			/*
			vec2 prevLocation = vec2(gl_GlobalInvocationID.xy) - velocity.xy * SCREEN_SIZE;
			ivec2 iCoords = ivec2(floor(prevLocation));
			
			const ivec2 sampleOffsets[4] = { ivec2(0, 0), ivec2(1, 0), ivec2(0, 1), ivec2(1, 1) };
			
			vec3 sampleNormal[4];
			sampleNormal[0] = normalize( texelFetch(_GTAOPreviousNormalRT, ivec2(prevLocation + vec2(sampleOffsets[0])), 0).xyz * 2.0 - 1.0 );
			sampleNormal[1] = normalize( texelFetch(_GTAOPreviousNormalRT, ivec2(prevLocation + vec2(sampleOffsets[1])), 0).xyz * 2.0 - 1.0 );
			sampleNormal[2] = normalize( texelFetch(_GTAOPreviousNormalRT, ivec2(prevLocation + vec2(sampleOffsets[2])), 0).xyz * 2.0 - 1.0 );
			sampleNormal[3] = normalize( texelFetch(_GTAOPreviousNormalRT, ivec2(prevLocation + vec2(sampleOffsets[3])), 0).xyz * 2.0 - 1.0 );
			
			vec3 normalWorld = normalize( texelFetch(_GTAOOutNormalFull, ivec2(gl_GlobalInvocationID.xy), 0).xyz * 2.0 - 1.0 );
			vec4 sampleWeights;
			for (uint i = 0; i < 4; ++i)
			{
				sampleWeights[i] = dot( normalWorld, sampleNormal[i] ) > 0.01 ? 1.0 : 0.0;
			}
			
			vec2 lerpFactors = fract( prevLocation );
			sampleWeights[0] *= (1.0 - lerpFactors.x) * (1.0 - lerpFactors.y);
			sampleWeights[1] *= lerpFactors.x * (1.0 - lerpFactors.y);
			sampleWeights[2] *= (1.0 - lerpFactors.x) * lerpFactors.y;
			sampleWeights[3] *= lerpFactors.x * lerpFactors.y;
			sampleWeights = max(sampleWeights, 0.001);
			
			vec2 prevAOAges[4];
			prevAOAges[0] = texelFetch(_GTAOPreviousAOTermFullRT, iCoords + sampleOffsets[0], 0).xy;
			prevAOAges[1] = texelFetch(_GTAOPreviousAOTermFullRT, iCoords + sampleOffsets[1], 0).xy;
			prevAOAges[2] = texelFetch(_GTAOPreviousAOTermFullRT, iCoords + sampleOffsets[2], 0).xy;
			prevAOAges[3] = texelFetch(_GTAOPreviousAOTermFullRT, iCoords + sampleOffsets[3], 0).xy;
			
			prevAOAges[0] *= sampleWeights[0];
			prevAOAges[1] *= sampleWeights[1];
			prevAOAges[2] *= sampleWeights[2];
			prevAOAges[3] *= sampleWeights[3];
			
			float accumulatedWeight = sampleWeights[0] + sampleWeights[1] + sampleWeights[2] + sampleWeights[3];

			float rAccumulatedWeight = 1.0 / max( accumulatedWeight, 1e-6 );
			prevAge = (prevAOAges[0].y + prevAOAges[1].y + prevAOAges[2].y + prevAOAges[3].y) * rAccumulatedWeight;
			prevAO = (prevAOAges[0].x + prevAOAges[1].x + prevAOAges[2].x + prevAOAges[3].x) * rAccumulatedWeight;
			*/
			
			//Decrease previous age for fast pixels and depth diff
			float velocityWeight = exp((-length(velocity * SCREEN_SIZE)) * _GTAOData._GTAOParam2.z);
			float depthWeight =  exp(abs(min(currentDepth, 100.0) - min(prevDepth, 100.0)) * (-10.0));
			prevAge = clamp(prevAge*clamp(velocityWeight*depthWeight, 0.0, 1.0) + 1.0/7.0, 0.0, 1.0);
			
			/*
			float AOMidThresh = (AOUpperThresh + AOLowerThresh) * 0.5;
			float AODiff = prevAO - AOMidThresh;
			float AODiffNorm = abs(AODiff / ((AOUpperThresh - AOLowerThresh) * 0.5));
			prevAO = mix(prevAO, AOMidThresh + (AODiff / AODiffNorm), bool(AODiffNorm > 1.0));
			*/
			//prevAO = ClipHistory(prevAO, currentAO, m1, sigma);
			prevAO = clamp(prevAO, minAO, maxAO);
		}
		else
		{
			prevAge = 0.0;
			prevAO = 1.0;
		}
	}
	
	float blendFactor = 1.0f / (prevAge * 7.0f + 1.0f);
	float aoDelta = currentAO - prevAO;
	float accumulatedAO = (blendFactor * aoDelta) + prevAO;
	imageStore(_GTAOCurrentAOTermFullRT, ivec2(gl_GlobalInvocationID.xy), vec4(accumulatedAO, prevAge, 0.0, 0.0));
	

	// Always store 0.0, when game clears it, it will become 1.0
    imageStore(_GTAOCurrentAOTermRT, ivec2(gl_GlobalInvocationID.xy), vec4(0.0));
}