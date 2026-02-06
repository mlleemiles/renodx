// AO prefilter mips

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

layout(set = 0, binding = 6) uniform sampler s_point_clamp_sampler;
layout(set = 0, binding = 5) uniform texture2D _SceneDepthTexture;
layout(set = 0, binding = 0, r32f) uniform writeonly image2D _GTAODepthMip0;
layout(set = 0, binding = 1, r32f) uniform writeonly image2D _GTAODepthMip1;
layout(set = 0, binding = 2, r32f) uniform writeonly image2D _GTAODepthMip2;
layout(set = 0, binding = 3, r32f) uniform writeonly image2D _GTAODepthMip3;
layout(set = 0, binding = 4, r32f) uniform writeonly image2D _GTAODepthMip4;

shared float g_scratchDepths[8][8];

void main()
{
    uvec2 _82 = gl_GlobalInvocationID.xy * uvec2(2u);
    vec4 _91 = textureGatherOffset(sampler2D(_SceneDepthTexture, s_point_clamp_sampler), vec2(_82) * _GTAOData._GTAOHalfScreenSize.zw, ivec2(1));
    float _100 = clamp(1.0 / ((ShaderVariablesGlobal._ZBufferParams.z * _91.w) + ShaderVariablesGlobal._ZBufferParams.w), 0.0, 3.4028234663852885981170418348452e+38);
    float _105 = clamp(1.0 / ((ShaderVariablesGlobal._ZBufferParams.z * _91.z) + ShaderVariablesGlobal._ZBufferParams.w), 0.0, 3.4028234663852885981170418348452e+38);
    float _110 = clamp(1.0 / ((ShaderVariablesGlobal._ZBufferParams.z * _91.x) + ShaderVariablesGlobal._ZBufferParams.w), 0.0, 3.4028234663852885981170418348452e+38);
    float _115 = clamp(1.0 / ((ShaderVariablesGlobal._ZBufferParams.z * _91.y) + ShaderVariablesGlobal._ZBufferParams.w), 0.0, 3.4028234663852885981170418348452e+38);
    imageStore(_GTAODepthMip0, ivec2(_82), vec4(_100));
    imageStore(_GTAODepthMip0, ivec2(_82 + uvec2(1u, 0u)), vec4(_105));
    imageStore(_GTAODepthMip0, ivec2(_82 + uvec2(0u, 1u)), vec4(_110));
    imageStore(_GTAODepthMip0, ivec2(_82 + uvec2(1u)), vec4(_115));
    float _125 = max(max(_100, _105), max(_110, _115));
    float _131 = (0.75 * AO_RADIUS) * AO_RADIUS_SCALE;
    float _134 = AO_FALLOFF_RANGE * _131;
    float _137 = (-1.0) / _134;
    float _139 = ((_131 * (1.0 - AO_FALLOFF_RANGE)) / _134) + 1.0;
    float _143 = clamp(((_125 - _100) * _137) + _139, 0.0, 1.0);
    float _147 = clamp(((_125 - _105) * _137) + _139, 0.0, 1.0);
    float _151 = clamp(((_125 - _110) * _137) + _139, 0.0, 1.0);
    float _155 = clamp(((_125 - _115) * _137) + _139, 0.0, 1.0);
    float _166 = ((((_143 * _100) + (_147 * _105)) + (_151 * _110)) + (_155 * _115)) / (((_143 + _147) + _151) + _155);
    imageStore(_GTAODepthMip1, ivec2(gl_GlobalInvocationID.xy), vec4(_166));
    g_scratchDepths[gl_LocalInvocationID.x][gl_LocalInvocationID.y] = _166;
    barrier();
    SPIRV_CROSS_BRANCH
    if (all(equal((gl_LocalInvocationID.xy % uvec2(2u)), uvec2(0u))))
    {
        uint _177 = gl_LocalInvocationID.x + 1u;
        uint _180 = gl_LocalInvocationID.y + 1u;
        float _187 = max(max(g_scratchDepths[gl_LocalInvocationID.x][gl_LocalInvocationID.y], g_scratchDepths[_177][gl_LocalInvocationID.y]), max(g_scratchDepths[gl_LocalInvocationID.x][_180], g_scratchDepths[_177][_180]));
        float _191 = clamp(((_187 - g_scratchDepths[gl_LocalInvocationID.x][gl_LocalInvocationID.y]) * _137) + _139, 0.0, 1.0);
        float _195 = clamp(((_187 - g_scratchDepths[_177][gl_LocalInvocationID.y]) * _137) + _139, 0.0, 1.0);
        float _199 = clamp(((_187 - g_scratchDepths[gl_LocalInvocationID.x][_180]) * _137) + _139, 0.0, 1.0);
        float _203 = clamp(((_187 - g_scratchDepths[_177][_180]) * _137) + _139, 0.0, 1.0);
        float _214 = ((((_191 * g_scratchDepths[gl_LocalInvocationID.x][gl_LocalInvocationID.y]) + (_195 * g_scratchDepths[_177][gl_LocalInvocationID.y])) + (_199 * g_scratchDepths[gl_LocalInvocationID.x][_180])) + (_203 * g_scratchDepths[_177][_180])) / (((_191 + _195) + _199) + _203);
        imageStore(_GTAODepthMip2, ivec2(gl_GlobalInvocationID.xy / uvec2(2u)), vec4(_214));
        g_scratchDepths[gl_LocalInvocationID.x][gl_LocalInvocationID.y] = _214;
    }
    barrier();
    SPIRV_CROSS_BRANCH
    if (all(equal((gl_LocalInvocationID.xy % uvec2(4u)), uvec2(0u))))
    {
        uint _223 = gl_LocalInvocationID.x + 2u;
        uint _226 = gl_LocalInvocationID.y + 2u;
        float _233 = max(max(g_scratchDepths[gl_LocalInvocationID.x][gl_LocalInvocationID.y], g_scratchDepths[_223][gl_LocalInvocationID.y]), max(g_scratchDepths[gl_LocalInvocationID.x][_226], g_scratchDepths[_223][_226]));
        float _237 = clamp(((_233 - g_scratchDepths[gl_LocalInvocationID.x][gl_LocalInvocationID.y]) * _137) + _139, 0.0, 1.0);
        float _241 = clamp(((_233 - g_scratchDepths[_223][gl_LocalInvocationID.y]) * _137) + _139, 0.0, 1.0);
        float _245 = clamp(((_233 - g_scratchDepths[gl_LocalInvocationID.x][_226]) * _137) + _139, 0.0, 1.0);
        float _249 = clamp(((_233 - g_scratchDepths[_223][_226]) * _137) + _139, 0.0, 1.0);
        float _260 = ((((_237 * g_scratchDepths[gl_LocalInvocationID.x][gl_LocalInvocationID.y]) + (_241 * g_scratchDepths[_223][gl_LocalInvocationID.y])) + (_245 * g_scratchDepths[gl_LocalInvocationID.x][_226])) + (_249 * g_scratchDepths[_223][_226])) / (((_237 + _241) + _245) + _249);
        imageStore(_GTAODepthMip3, ivec2(gl_GlobalInvocationID.xy / uvec2(4u)), vec4(_260));
        g_scratchDepths[gl_LocalInvocationID.x][gl_LocalInvocationID.y] = _260;
    }
    barrier();
    SPIRV_CROSS_BRANCH
    if (all(equal((gl_LocalInvocationID.xy % uvec2(8u)), uvec2(0u))))
    {
        uint _269 = gl_LocalInvocationID.x + 4u;
        uint _272 = gl_LocalInvocationID.y + 4u;
        float _279 = max(max(g_scratchDepths[gl_LocalInvocationID.x][gl_LocalInvocationID.y], g_scratchDepths[_269][gl_LocalInvocationID.y]), max(g_scratchDepths[gl_LocalInvocationID.x][_272], g_scratchDepths[_269][_272]));
        float _283 = clamp(((_279 - g_scratchDepths[gl_LocalInvocationID.x][gl_LocalInvocationID.y]) * _137) + _139, 0.0, 1.0);
        float _287 = clamp(((_279 - g_scratchDepths[_269][gl_LocalInvocationID.y]) * _137) + _139, 0.0, 1.0);
        float _291 = clamp(((_279 - g_scratchDepths[gl_LocalInvocationID.x][_272]) * _137) + _139, 0.0, 1.0);
        float _295 = clamp(((_279 - g_scratchDepths[_269][_272]) * _137) + _139, 0.0, 1.0);
        imageStore(_GTAODepthMip4, ivec2(gl_GlobalInvocationID.xy / uvec2(8u)), vec4(((((_283 * g_scratchDepths[gl_LocalInvocationID.x][gl_LocalInvocationID.y]) + (_287 * g_scratchDepths[_269][gl_LocalInvocationID.y])) + (_291 * g_scratchDepths[gl_LocalInvocationID.x][_272])) + (_295 * g_scratchDepths[_269][_272])) / (((_283 + _287) + _291) + _295)));
    }
}

