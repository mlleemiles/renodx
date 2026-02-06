// AO main

#version 460
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

float _88;

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
    vec4 _GTAOParam0; // radius, scale, thickness, distribution power [4.0000, 1.0000, 1.0000, 1.0000]
    vec4 _GTAOParam1; // thickness bias, ao gamma, frame index, mip bias [2.0000, 2.2000, 49.0000, 3.3000]
    vec4 _GTAOParam2;
    vec4 _GTAOHalfScreenSize;
} _GTAOData;

#define AO_RADIUS             ((shader_injection.ao_radius != 0.0f) ? shader_injection.ao_radius : _GTAOData._GTAOParam0.x)
#define AO_RADIUS_SCALE       ((shader_injection.ao_radius_scale != 0.0f) ? shader_injection.ao_radius_scale : _GTAOData._GTAOParam0.y)
#define AO_FALLOFF_RANGE      ((shader_injection.ao_falloff_range != 0.0f) ? shader_injection.ao_falloff_range : _GTAOData._GTAOParam0.z)
#define AO_DISTRIBUTION_POWER ((shader_injection.ao_distribution_power != 0.0f) ? shader_injection.ao_distribution_power : _GTAOData._GTAOParam0.w)
#define AO_THIN_OCCLUDER      ((shader_injection.ao_thin_occluder != 0.0f) ? shader_injection.ao_thin_occluder : _GTAOData._GTAOParam1.x)
#define AO_GAMMA_GTAO         ((shader_injection.ao_gamma != 0.0f) ? shader_injection.ao_gamma : _GTAOData._GTAOParam1.y)
#define AO_TEMPORAL_FRAME     64u
#define AO_MIP_BIAS           ((shader_injection.ao_mip_bias != 0.0f) ? shader_injection.ao_mip_bias : _GTAOData._GTAOParam1.w)
#define AO_DIRECTION_COUNT    ((shader_injection.ao_direction_count != 0.0f) ? shader_injection.ao_direction_count : 3.0f)
#define AO_STEP_COUNT         ((shader_injection.ao_step_count != 0.0f) ? shader_injection.ao_step_count : 3.0f)
#define AO_NORMAL_ATTENUATION ((shader_injection.ao_normal_attenuation != 0.0f) ? shader_injection.ao_normal_attenuation : 0.05f)
#define AO_THICKNESS          (shader_injection.ao_thickness)
#define AO_USE_BITMASK        (shader_injection.ao_bitmask != 0.0f)

#define XE_GTAO_QWORD_BIT_WIDTH 32
#define XE_GTAO_BITMASK_NUM_BITS float(XE_GTAO_QWORD_BIT_WIDTH * 1)

#define HALF_PI 1.5707963267948966
#define PI 3.1415926535897932
#define TWO_PI 6.2831853071795864

#define XE_GTAO_SCALED_BUFFER_PIXEL_SIZE _GTAOData._GTAOHalfScreenSize.zw

layout(set = 0, binding = 3) uniform sampler s_point_clamp_sampler;
layout(set = 0, binding = 1) uniform texture2D _GBufferTexture1;
layout(set = 0, binding = 2) uniform texture2D _GTAODepthMIPs;
layout(set = 0, binding = 0, r8) uniform writeonly image2D _GTAOOutAOTerm;

// Inputs are screen XY and viewspace depth, output is viewspace position
vec3 XeGTAO_ComputeViewspacePosition( const vec2 screenPos, const float viewspaceDepth )
{
    vec2 _198 = (vec4((screenPos * 2.0) - vec2(1.0), 1.0, 1.0) * ShaderVariablesGlobal._InvProjMatrix).xy * viewspaceDepth;
    vec3 _202 = vec3(_198.x, -_198.y, viewspaceDepth);
    return _202;
}

// http://h14s.p5r.org/2012/09/0x5f3759df.html, [Drobot2014a] Low Level Optimizations for GCN, https://blog.selfshadow.com/publications/s2016-shading-course/activision/s2016_pbs_activision_occlusion.pdf slide 63
float XeGTAO_FastSqrt(float x)
{
    return intBitsToFloat(0x1fbd1df5 + (floatBitsToInt(x) >> 1));
}

// input [-1, 1] and output [0, PI], from https://seblagarde.wordpress.com/2014/12/01/inverse-trigonometric-functions-gpu-optimization-for-amd-gcn-architecture/
float XeGTAO_FastACos( float inX )
{ 
    float x = abs(inX); 
    float res = -0.156583 * x + HALF_PI; 
    res *= XeGTAO_FastSqrt(1.0 - x); 
    return (inX >= 0) ? res : PI - res; 
}

uint UpdateSectors(float minHorizon, float maxHorizon, float samplesPerSlice, uint bitmask)
{
    int startHorizon = int(minHorizon * samplesPerSlice);
    int angleHorizon = int(round((maxHorizon - minHorizon) * samplesPerSlice));	//the angle in radian between min and max horizon
	angleHorizon = angleHorizon > 0 ? angleHorizon : 0;

    return bitfieldInsert(bitmask, uint(0xFFFFFFFF), startHorizon, angleHorizon);
}

void ProcessSample(vec3 deltaPosition, vec3 viewVector, float samplingDirection, vec2 N, float samplesPerSlice, inout uint bitmask)
{
    vec3 deltaPositionBackFace = deltaPosition - viewVector * AO_THICKNESS;

    vec2 frontBackHorizon = vec2
    (
        XeGTAO_FastACos(dot(normalize(deltaPosition),         viewVector)),	//radian of angle between view and horizon's frontface
        XeGTAO_FastACos(dot(normalize(deltaPositionBackFace), viewVector))	//radian of angle between view and horizon's backsface
    );

    frontBackHorizon = clamp((samplingDirection * -frontBackHorizon - N + HALF_PI) / PI, 0.0, 1.0);
    frontBackHorizon = samplingDirection >= 0.0f ? frontBackHorizon.yx : frontBackHorizon.xy;
	
	frontBackHorizon = smoothstep(0.0, 1.0, frontBackHorizon); // cosine lobe for AO. Trick by Marty (https://www.martysmods.com/)

    bitmask = UpdateSectors(frontBackHorizon.x, frontBackHorizon.y, samplesPerSlice, bitmask);
}

vec3 XeGTAO_CalculateNormal( const vec4 edgesLRTB, vec3 pixCenterPos, vec3 pixLPos, vec3 pixRPos, vec3 pixTPos, vec3 pixBPos )
{
    // Get this pixel's viewspace normal
    vec4 acceptedNormals  = clamp( vec4( edgesLRTB.x*edgesLRTB.z, edgesLRTB.z*edgesLRTB.y, edgesLRTB.y*edgesLRTB.w, edgesLRTB.w*edgesLRTB.x ) + 0.01, 0.0, 1.0 );

    pixLPos = normalize(pixLPos - pixCenterPos);
    pixRPos = normalize(pixRPos - pixCenterPos);
    pixTPos = normalize(pixTPos - pixCenterPos);
    pixBPos = normalize(pixBPos - pixCenterPos);

    vec3 pixelNormal =  acceptedNormals.x * cross( pixLPos, pixTPos ) +
                        + acceptedNormals.y * cross( pixTPos, pixRPos ) +
                        + acceptedNormals.z * cross( pixRPos, pixBPos ) +
                        + acceptedNormals.w * cross( pixBPos, pixLPos );
    pixelNormal = normalize( pixelNormal );

    return pixelNormal;
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

void main()
{
    uint _103;
    _103 = 0u;
    uint _104;
    uint _99;
    uint _102;
    for (uint _98 = gl_GlobalInvocationID.y, _101 = gl_GlobalInvocationID.x, _105 = 32u; _105 > 0u; _98 = _99, _101 = _102, _103 = _104, _105 /= 2u)
    {
        uint _112 = uint((_101 & _105) > 0u);
        uint _115 = uint((_98 & _105) > 0u);
        _104 = _103 + ((_105 * _105) * ((3u * _112) ^ _115));
        if (_115 == 0u)
        {
            uint _128;
            uint _129;
            if (_112 == 1u)
            {
                _128 = 63u - _98;
                _129 = 63u - _101;
            }
            else
            {
                _128 = _98;
                _129 = _101;
            }
            _99 = _129;
            _102 = _128;
        }
        else
        {
            _99 = _98;
            _102 = _101;
        }
    }
    vec2 _136 = fract(vec2(0.5) + (vec2(0.75487768650054931640625, 0.56984031200408935546875) * float(_103 + (288u * (uint(_GTAOData._GTAOParam1.z) % AO_TEMPORAL_FRAME)))));
    vec2 _137 = vec2(gl_GlobalInvocationID.xy);
    vec2 _142 = (_137 + vec2(0.5)) * _GTAOData._GTAOHalfScreenSize.zw;
	
	vec2 pixCoord = _137;
	
	vec2 normalizedScreenPos = (pixCoord + vec2(0.5)) * XE_GTAO_SCALED_BUFFER_PIXEL_SIZE;
	
    // viewspace Z at the center
    float viewspaceZ  = textureLod(sampler2D(_GTAODepthMIPs, s_point_clamp_sampler), _142, 0.0).x;//textureGather(sampler2D(_GTAODepthMIPs, s_point_clamp_sampler), _137 * _GTAOData._GTAOHalfScreenSize.zw).y; 
	
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
#ifdef XE_GTAO_GENERATE_NORMALS_INPLACE
    // viewspace Z at the center
    float viewspaceZ_Normal  = valuesUL.y; //sourceViewspaceDepth.SampleLevel( depthSampler, normalizedScreenPos, 0 ).x; 

// viewspace Zs left top right bottom
    const float pixLZ = valuesUL.x;
    const float pixTZ = valuesUL.z;
    const float pixRZ = valuesBR.z;
    const float pixBZ = valuesBR.x;
	
    vec4 edgesLRTB  = XeGTAO_CalculateEdges( viewspaceZ, pixLZ, pixRZ, pixTZ, pixBZ );
	
    vec3 CENTER   = XeGTAO_ComputeViewspacePosition( normalizedScreenPos, viewspaceZ_Normal );
    vec3 LEFT     = XeGTAO_ComputeViewspacePosition( normalizedScreenPos + vec2(-1,  0) * _GTAOData._GTAOHalfScreenSize.zw, pixLZ );
    vec3 RIGHT    = XeGTAO_ComputeViewspacePosition( normalizedScreenPos + vec2( 1,  0) * _GTAOData._GTAOHalfScreenSize.zw, pixRZ );

    // FIX: Invert the Y signs here ( -1 becomes 1, and 1 becomes -1 )
    vec3 TOP      = XeGTAO_ComputeViewspacePosition( normalizedScreenPos + vec2( 0,  1) * _GTAOData._GTAOHalfScreenSize.zw, pixTZ );
    vec3 BOTTOM   = XeGTAO_ComputeViewspacePosition( normalizedScreenPos + vec2( 0, -1) * _GTAOData._GTAOHalfScreenSize.zw, pixBZ );

    vec3 viewspaceNormal = XeGTAO_CalculateNormal( edgesLRTB, CENTER, LEFT, RIGHT, TOP, BOTTOM );
	viewspaceNormal.y = -viewspaceNormal.y;
#endif
	
	
    // Move center pixel slightly towards camera to avoid imprecision artifacts due to depth buffer imprecision; offset depends on depth texture format used
    viewspaceZ *= 0.99999;     // this is good for FP32 depth buffer
	
    const vec3 pixCenterPos   = XeGTAO_ComputeViewspacePosition( normalizedScreenPos, viewspaceZ );
    const vec3 viewVec      = normalize(-pixCenterPos);
	
	//normalBufferData
    vec2 _155 = (textureLod(sampler2D(_GBufferTexture1, s_point_clamp_sampler), _142, 0.0).xy * 2.0) - vec2(1.0);
	
    float _159 = 1.0 - dot(vec2(1.0), abs(_155));
    vec3 _161 = vec3(_155.x, _159, _155.y);
    vec3 _173;
    if (_159 < 0.0)
    {
        vec2 _171 = (vec2(1.0) - abs(_161.zx)) * mix(vec2(-1.0), vec2(1.0), greaterThanEqual(_161.xz, vec2(0.0)));
        _173 = vec3(_171.x, _161.y, _171.y);
    }
    else
    {
        _173 = _161;
    }
    vec3 _184 = normalize(_173) * mat3(ShaderVariablesGlobal._ViewMatrix[0].xyz, ShaderVariablesGlobal._ViewMatrix[1].xyz, ShaderVariablesGlobal._ViewMatrix[2].xyz);
    _184.z = -_184.z;
	
	vec3 viewspaceNormal = _184;
	
    const float falloffFrom       = AO_RADIUS * AO_RADIUS_SCALE * (1.0-AO_FALLOFF_RANGE);
	const float falloffRange      = AO_FALLOFF_RANGE * AO_RADIUS * AO_RADIUS_SCALE;

    // fadeout precompute optimisation
    const float falloffMul        = -1.0 / ( falloffRange );
    const float falloffAdd        = falloffFrom / ( falloffRange ) + 1.0;
	
		
	float visibility          = 0.0f;
	uint  occludedSampleCount = 0u;

    // see "Algorithm 1" in https://www.activision.com/cdn/research/Practical_Real_Time_Strategies_for_Accurate_Indirect_Occlusion_NEW%20VERSION_COLOR.pdf
    {
	
		const float noiseSlice  = _136.x;
		const float noiseSample = _136.y;
		
        // quality settings / tweaks / hacks
        const float pixelTooCloseThreshold  = 1.3;      // if the offset is under approx pixel size (pixelTooCloseThreshold), push it out to the minimum distance

        // approx viewspace pixel size at pixCoord; approximation of NDCToViewspace( normalizedScreenPos.xy + ReShade::PixelSize.xy, pixCenterPos.z ).xy - pixCenterPos.xy;
        const vec2 pixelDirRBViewspaceSizeAtCenterZ = XeGTAO_ComputeViewspacePosition(normalizedScreenPos + XE_GTAO_SCALED_BUFFER_PIXEL_SIZE, pixCenterPos.z).xy - pixCenterPos.xy;
		
		float screenspaceRadius   = (AO_RADIUS * AO_RADIUS_SCALE) / pixelDirRBViewspaceSizeAtCenterZ.x;

		
        // fade out for small screen radii 
        visibility += clamp((10 - screenspaceRadius)/100, 0.0, 1.0)*0.5;
		
        // this is the min distance to start sampling from to avoid sampling from the center pixel (no useful data obtained from sampling center pixel)
        const float minS = pixelTooCloseThreshold / screenspaceRadius;
        const float depthScale = (pixCenterPos.z / ShaderVariablesGlobal._ProjectionParams.z);
		
		SPIRV_CROSS_UNROLL
		for( float slice = 0; slice < float(AO_DIRECTION_COUNT); slice++ )
		{
			float sliceK = (slice + noiseSlice) / float(AO_DIRECTION_COUNT);
            float phi = sliceK * PI;
            float cosPhi = cos(phi);
            float sinPhi = sin(phi);
            vec2 omega = vec2(cosPhi, sinPhi);       //float2 on omega causes issues with big radii
			
            // convert to screen units (pixels) for later use
            omega *= screenspaceRadius;
			
            // line 8 from the paper
            const vec3 directionVec = vec3(cosPhi, sinPhi, 0);
			
            // line 9 from the paper
            const vec3 orthoDirectionVec = directionVec - (dot(directionVec, viewVec) * viewVec);

            // line 10 from the paper
            //axisVec is orthogonal to directionVec and viewVec, used to define projectedNormal
            const vec3 axisVec = normalize( cross(orthoDirectionVec, viewVec) );

            // alternative line 9 from the paper
            // float3 orthoDirectionVec = cross( viewVec, axisVec );

            // line 11 from the paper
            vec3 projectedNormalVec = viewspaceNormal - axisVec * dot(viewspaceNormal, axisVec);

            // line 13 from the paper
            float signNorm = float(sign( dot( orthoDirectionVec, projectedNormalVec ) ));

            // line 14 from the paper
            float projectedNormalVecLength = length(projectedNormalVec);
            float cosNorm = float(clamp(dot(projectedNormalVec, viewVec) / projectedNormalVecLength, 0.0, 1.0));

            // line 15 from the paper
            float n = signNorm * XeGTAO_FastACos(cosNorm);
			vec2  N = vec2(n);//vec2((HALF_PI - signNorm * XeGTAO_FastACos(cosNorm)) * (1.0f / PI));

            // this is a lower weight target; not using -1 as in the original paper because it is under horizon, so a 'weight' has different meaning based on the normal
            const float lowHorizonCos0  = cos(n+HALF_PI);
            const float lowHorizonCos1  = cos(n-HALF_PI);

            // lines 17, 18 from the paper, manually unrolled the 'side' loop
            float horizonCos0           = lowHorizonCos0; //-1;
            float horizonCos1           = lowHorizonCos1; //-1;

			uint bitmask = 0u;
			
            SPIRV_CROSS_UNROLL
            for( float step = 0; step < float(AO_STEP_COUNT); step++ )
            {
                // R1 sequence (http://extremelearning.com.au/unreasonable-effectiveness-of-quasirandom-sequences/)
                const float stepBaseNoise = float(slice + step * float(AO_STEP_COUNT)) * 0.6180339887498948482; // <- this should unroll
                float stepNoise = fract(noiseSample + stepBaseNoise);
				
                // approx line 20 from the paper, with added noise
                float s = (step+stepNoise) / float(AO_STEP_COUNT); // + (float2)1e-6f);

                // additional distribution modifier
                s       = pow( s, AO_DISTRIBUTION_POWER );
				
                // avoid sampling center pixel
                s       += minS;
				
                // approx lines 21-22 from the paper, unrolled
                vec2 sampleOffset = s * omega; //* (1.0 -pixCenterPos.z / FFXIV::z_far() * constRadiusMultiplier);
                
                float sampleOffsetLength = length( sampleOffset );
				
                float mipLevel    = clamp( log2( sampleOffsetLength ) - AO_MIP_BIAS, 0.0, 4.0 );
				
				sampleOffset = roundEven(sampleOffset) * XE_GTAO_SCALED_BUFFER_PIXEL_SIZE;
				
				vec2 sampleScreenPos0 = normalizedScreenPos + sampleOffset;
				vec2 sampleScreenPos1 = normalizedScreenPos - sampleOffset;
				
                float SZ0 = textureLod( sampler2D(_GTAODepthMIPs, s_point_clamp_sampler), sampleScreenPos0, mipLevel ).x;
                float SZ1 = textureLod( sampler2D(_GTAODepthMIPs, s_point_clamp_sampler), sampleScreenPos1, mipLevel ).x;
				
                vec3 samplePos0 = XeGTAO_ComputeViewspacePosition( normalizedScreenPos + sampleOffset, SZ0 );
                vec3 samplePos1 = XeGTAO_ComputeViewspacePosition( normalizedScreenPos - sampleOffset, SZ1 );
				
                vec3 sampleDelta0 = (samplePos0 - pixCenterPos);
                vec3 sampleDelta1 = (samplePos1 - pixCenterPos);
				if (AO_USE_BITMASK)
				{
					
					ProcessSample(sampleDelta0, viewVec, -1.0f, N, XE_GTAO_BITMASK_NUM_BITS, bitmask);
					ProcessSample(sampleDelta1, viewVec,  1.0f, N, XE_GTAO_BITMASK_NUM_BITS, bitmask);
				}
				else
				{
				
	                float sampleDist0     = length( sampleDelta0 );
	                float sampleDist1     = length( sampleDelta1 );
					
	                // approx lines 23, 24 from the paper, unrolled
	                vec3 sampleHorizonVec0 = (sampleDelta0 / sampleDist0);
	                vec3 sampleHorizonVec1 = (sampleDelta1 / sampleDist1);
					
	                float falloffBase0    = length( vec3(sampleDelta0.x, sampleDelta0.y, sampleDelta0.z * (1+AO_THIN_OCCLUDER) ) );
	                float falloffBase1    = length( vec3(sampleDelta1.x, sampleDelta1.y, sampleDelta1.z * (1+AO_THIN_OCCLUDER) ) );
	                float weight0         = clamp( falloffBase0 * falloffMul + falloffAdd, 0.0, 1.0 );
	                float weight1         = clamp( falloffBase1 * falloffMul + falloffAdd, 0.0, 1.0 );
					
	                // sample horizon cos
	                float shc0 = dot(sampleHorizonVec0, viewVec);
	                float shc1 = dot(sampleHorizonVec1, viewVec);
	
	                // discard unwanted samples
	                shc0 = mix( lowHorizonCos0, shc0, weight0 ); // this would be more correct but too expensive: cos(lerp( acos(lowHorizonCos0), acos(shc0), weight0 ));
	                shc1 = mix( lowHorizonCos1, shc1, weight1 ); // this would be more correct but too expensive: cos(lerp( acos(lowHorizonCos1), acos(shc1), weight1 ));
					
	                // thickness heuristic - see "4.3 Implementation details, Height-field assumption considerations"
	#if 0   // (disabled, not used) this should match the paper
	                float newhorizonCos0 = max( horizonCos0, shc0 );
	                float newhorizonCos1 = max( horizonCos1, shc1 );
	                horizonCos0 = (horizonCos0 > shc0)?( mix( newhorizonCos0, shc0, AO_THIN_OCCLUDER ) ):( newhorizonCos0 );
	                horizonCos1 = (horizonCos1 > shc1)?( mix( newhorizonCos1, shc1, AO_THIN_OCCLUDER ) ):( newhorizonCos1 );
	#elif 0 // (disabled, not used) this is slightly different from the paper but cheaper and provides very similar results
	                horizonCos0 = mix( max( horizonCos0, shc0 ), shc0, AO_THIN_OCCLUDER );
	                horizonCos1 = mix( max( horizonCos1, shc1 ), shc1, AO_THIN_OCCLUDER );
	#else   // this is a version where thicknessHeuristic is completely disabled
	                horizonCos0 = max( horizonCos0, shc0 );
	                horizonCos1 = max( horizonCos1, shc1 );
	#endif
				}
			}
			if (AO_USE_BITMASK)
			{
				projectedNormalVecLength = mix( projectedNormalVecLength, 1, AO_NORMAL_ATTENUATION );
				float localVisibility = (1.0 - bitCount(bitmask) / (XE_GTAO_BITMASK_NUM_BITS));
				visibility += localVisibility;// * projectedNormalVecLength;
			}
			else
			{
				projectedNormalVecLength = mix( projectedNormalVecLength, 1, AO_NORMAL_ATTENUATION );
				
	            // line ~27, unrolled
	            float h0 = -XeGTAO_FastACos(horizonCos1);
	            float h1 = XeGTAO_FastACos(horizonCos0);
				
	            float iarc0 = (cosNorm + 2.0 * h0 * sin(n)-cos(2.0 * h0-n))/4.0;
	            float iarc1 = (cosNorm + 2.0 * h1 * sin(n)-cos(2.0 * h1-n))/4.0;
	            float localVisibility = projectedNormalVecLength * (iarc0+iarc1);
	            visibility += localVisibility;
	        }
		}
	}
	
	visibility /= float(AO_DIRECTION_COUNT);
	visibility = pow( visibility, AO_GAMMA_GTAO );
	visibility = max( 0.03, visibility ); // disallow total occlusion (which wouldn't make any sense anyhow since pixel is visible but also helps with packing bent normals)
	
	imageStore(_GTAOOutAOTerm, ivec2(gl_GlobalInvocationID.xy), vec4(visibility));
}

