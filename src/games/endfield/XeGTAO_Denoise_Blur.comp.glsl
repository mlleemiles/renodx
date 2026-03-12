// AO Denoise

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

#include "./shared.h"

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

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
    vec4 _ExponentialFogParams4;
    vec4 _ExponentialFogParams5;
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
    vec4 _VFXParams3;
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
    vec4 _GTAOParam3;
    vec4 _GTAOHalfScreenSize;
} _GTAOData;

layout(set = 0, binding = 2) uniform sampler s_linear_clamp_sampler;
layout(set = 0, binding = 1) uniform texture2D _GTAOBlurAOTermRT;
layout(set = 0, binding = 0, r8) uniform writeonly image2D _GTAOUpsampleAOTermRT;

layout(set = 2, binding = 0, rg8) uniform writeonly image2D _GTAOBlurAOTermOutRT;
layout(set = 2, binding = 1, r32f) uniform writeonly image2D _GTAOPreviousDepthRT;
layout(set = 2, binding = 2, rgb10_a2) uniform writeonly image2D _GTAOPreviousNormalRT;
layout(set = 2, binding = 3) uniform texture2D _GTAOBlurAOTermInRT;
layout(set = 2, binding = 4) uniform texture2D _GTAODepthMIPs;
layout(set = 2, binding = 5) uniform texture2D _GTAOOutNormalFull;

// 18 = 8 core + 5 border on each side
const uint TILE_SIZE   = 18u;
const uint BORDER_SIZE = 5u;

shared float gAO[TILE_SIZE * TILE_SIZE];
shared float gFiltered[TILE_SIZE * TILE_SIZE];
shared float gDepth[TILE_SIZE * TILE_SIZE];

vec3 XeGTAO_ComputeViewspacePosition( const vec2 screenPos, const float viewspaceDepth )
{
    vec2 _198 = (vec4((screenPos * 2.0) - vec2(1.0), 1.0, 1.0) * ShaderVariablesGlobal._InvProjMatrix).xy * viewspaceDepth;
    vec3 _202 = vec3(_198.x, -_198.y, viewspaceDepth);
    return _202;
}

vec3 GetPositionWorld(vec2 screenPos, float viewspaceDepth)
{
	vec3 viewPos = XeGTAO_ComputeViewspacePosition(screenPos, viewspaceDepth);
	return (ShaderVariablesGlobal._InvViewMatrix * vec4(viewPos, 1.0)).xyz;
}

float Weight(float centerDepth, float sampleDepth, float radius)
{
    float v = -abs(sampleDepth - centerDepth) * shader_injection.ao_denoiser_blur_beta - radius;
    return exp(v);
}

bool IsSky( float depth )
{
	return (depth == ShaderVariablesGlobal._ProjectionParams.z);
}

#define DEPTH_THRESHOLD				0.0005
#define NORMAL_THRESHOLD			0.5

void main()
{	
    uvec3 groupID = gl_WorkGroupID;          // SV_GroupID
    uvec3 threadInGroup = gl_LocalInvocationID; // SV_GroupThreadID
    uvec3 dispatchThread = gl_GlobalInvocationID; // SV_DispatchThreadID
	uvec2 pixel = dispatchThread.xy;
	
	
	float depth = texelFetch(_GTAODepthMIPs, ivec2(pixel), 0).r;
	imageStore(_GTAOPreviousDepthRT, ivec2(pixel), vec4(depth));
	
    float age = texelFetch(_GTAOBlurAOTermInRT, ivec2(pixel), 0).g;
	float ao = texelFetch(_GTAOBlurAOTermInRT, ivec2(pixel), 0).r;
	vec3 normalWorld = texelFetch(_GTAOOutNormalFull, ivec2(pixel), 0).xyz;
	
	imageStore(_GTAOBlurAOTermOutRT, ivec2(pixel), vec4(ao, age, 0.0, 0.0));
	imageStore(_GTAOPreviousNormalRT, ivec2(pixel), vec4(normalWorld, 0.0));
	
	/*
	normalWorld = normalize(normalWorld * 2.0 - 1.0);
	
	if (IsSky(depth))
	{
        imageStore(_GTAOBlurAOTermOutRT, ivec2(pixel), vec4(ao, age, 0.0, 0.0));
		imageStore(_GTAOUpsampleAOTermRT, ivec2(pixel), vec4(ao));
		return;
	}
	*/

    float radius = age * 1389.9 + 1.0;
    radius = 120.0 / radius;
    radius = 1.0 / radius;
	
    uvec2 local = threadInGroup.xy;
    uvec2 groupBase = groupID.xy * 8u;

    uvec2 sharedCenter = local + BORDER_SIZE;
	
	SPIRV_CROSS_UNROLL
    for (uint y = local.y; y < TILE_SIZE; y += 8u)
    {
		SPIRV_CROSS_UNROLL
        for (uint x = local.x; x < TILE_SIZE; x += 8u)
        {
            ivec2 p = ivec2(groupBase) + ivec2(x, y) - ivec2(BORDER_SIZE);
			ivec2 screenSize = ivec2(ShaderVariablesGlobal._ScreenSize.xy);
			p = clamp(p, ivec2(0), ivec2(screenSize - 1));

            float ao    = texelFetch(_GTAOBlurAOTermInRT, p, 0).r;
            float depth = texelFetch(_GTAODepthMIPs, p, 0).r;

            uint idx = y * TILE_SIZE + x;
            gAO[idx]    = ao;
            gDepth[idx] = depth;
        }
    }
	
    groupMemoryBarrier();
    barrier();
	
// --- 3. Pass 1: Horizontal Blur ---
    // FIXED: Loop over Y to process border rows so Pass 2 has data to read.
    {
        // We only process the specific column assigned to this thread (sharedCenter.x),
        // but we process ALL rows (including borders) for that column.
        uint cx = sharedCenter.x;

        SPIRV_CROSS_UNROLL
        for (uint y = local.y; y < TILE_SIZE; y += 8u)
        {
            uint idx = y * TILE_SIZE + cx;
            float centerDepth = gDepth[idx];

            float sum = 0.0;
            float wsum = 0.0;

            SPIRV_CROSS_UNROLL
            for (int i = -2; i <= 2; i++)
            {
                // Reading horizontal neighbors
                // NOTE: 'cx' is 5..12. 'cx+i' is 3..14. This is safe within 0..17 width.
                uint neighborIdx = y * TILE_SIZE + (cx + i);

                float d = gDepth[neighborIdx];
                float a = gAO[neighborIdx];

                float w = Weight(centerDepth, d, radius);

                sum  += a * w;
                wsum += w;
            }

            gFiltered[idx] = sum / wsum;
        }
    }

    groupMemoryBarrier();
    barrier();
    
    // --- 4. Pass 2: Vertical Blur ---
    // (Mostly Unchanged, but now safe to read neighbors)
    {
        uint cx = sharedCenter.x;
        uint cy = sharedCenter.y;
        uint centerIdx = cy * TILE_SIZE + cx;

        float centerDepth = gDepth[centerIdx];

        float sum = 0.0;
        float wsum = 0.0;

        SPIRV_CROSS_UNROLL
        for (int i = -2; i <= 2; i++)
        {
            // Reading vertical neighbors
            // Now safe because Pass 1 populated 'gFiltered' for the border rows
            uint idx = (cy + i) * TILE_SIZE + cx;

            float d = gDepth[idx];
            float a = gFiltered[idx];

            float w = Weight(centerDepth, d, radius);

            sum  += a * w;
            wsum += w;
        }

        float finalAO = sum / wsum;
		imageStore(_GTAOUpsampleAOTermRT, ivec2(pixel), vec4(finalAO));
    }
	
	
/*
	vec2 pixelCenter = vec2(pixel) + vec2(0.5, 0.5);
	vec2 normalizedScreenPos = pixelCenter * ShaderVariablesGlobal._ScreenSize.zw;
	vec3 positionWS = GetPositionWorld( normalizedScreenPos, depth );
	
	
	float accumulatedAmbientOcclusion = 0;
	float accumulatedWeight = 1e-4;
	float ageWeight = exp(-shader_injection.ao_denoiser_blur_beta * age);
	
	accumulatedWeight = 1.0;
	accumulatedAmbientOcclusion = ao;
	
	SPIRV_CROSS_UNROLL
	for (uint i = 0; i < 9; ++i)
	{
		ivec2 sampleOffset;
		sampleOffset.x = int( i % 3 ) - 1;
		sampleOffset.y = int( i / 3 ) - 1;
		
		sampleOffset.xy = ivec2(vec2(sampleOffset) * (ao + 1.0));
		
		ivec2 iSamplePosition = ivec2(pixel.xy) + sampleOffset;
		float sampleLinearDepth = texelFetch(_GTAODepthMIPs, ivec2(iSamplePosition), 0).r;
		
		if (IsSky(sampleLinearDepth)) continue;
		
		vec3 sampleNormalWorld = normalize( texelFetch(_GTAOOutNormalFull, ivec2(iSamplePosition), 0).xyz * 2.0 - 1.0 );
		float sampleOcclusion = texelFetch(_GTAOBlurAOTermInRT, ivec2(iSamplePosition), 0).r;
		
		pixelCenter = vec2(iSamplePosition) + vec2(0.5, 0.5);
		normalizedScreenPos = pixelCenter * ShaderVariablesGlobal._ScreenSize.zw;
		vec3 samplePositionWS = GetPositionWorld( normalizedScreenPos, sampleLinearDepth );
		
		float planeDistance = dot( samplePositionWS - positionWS, normalWorld );
		
		float planeWeight = clamp( 1.0 - abs( planeDistance ) / (max(depth, 0.1) * DEPTH_THRESHOLD), 0.0, 1.0 );
		
		float normalWeight = smoothstep( NORMAL_THRESHOLD, 1.0, clamp( dot( normalWorld, sampleNormalWorld ), 0.0, 1.0 ) );
		
		float weight = normalWeight * planeWeight * ageWeight;
		
		accumulatedAmbientOcclusion += sampleOcclusion * weight;
		accumulatedWeight += weight;
	}
	
	accumulatedAmbientOcclusion /= accumulatedWeight;
	
	imageStore(_GTAOUpsampleAOTermRT, ivec2(pixel), vec4(accumulatedAmbientOcclusion));
*/

}
