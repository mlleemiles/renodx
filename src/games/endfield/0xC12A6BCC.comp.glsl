// SSR Raymarch 2

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

#include "./shared.h"

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

layout(set = 1, binding = 1, std140) uniform type_ScreenSpaceReflectionData
{
    vec4 _SSRParams0;
    vec4 _SSRParams1;
    vec4 _SSRParams2;
    vec4 _SSRParams3;
    vec4 _SSRParams4;
    vec4 _SSRParams5;
    vec4 _SSRPreviousColorPyramidRenderSize;
    vec4 _SSRCurrentColorPyramidRenderSize;
} _ScreenSpaceReflectionData;

layout(set = 0, binding = 6) uniform sampler s_point_clamp_sampler;
layout(set = 0, binding = 3) uniform texture2D _SSRCurrentSceneDepthPyramidTexture;
layout(set = 0, binding = 4) uniform texture2D _SSRNormalRoughnessTexture;
layout(set = 0, binding = 5) uniform texture2D _SSRMotionVectorTexture;
layout(set = 0, binding = 0, rg16) uniform writeonly image2D _SSRRayMarchingHitUVRWTexture;
layout(set = 0, binding = 1, rg16) uniform writeonly image2D _SSRFilterWeightRWTexture;
layout(set = 0, binding = 2, r8) uniform writeonly image2D _SSRFadenessRWTexture;

void main()
{
    vec2 _110 = vec2(ivec2(gl_GlobalInvocationID.xy)) + vec2(0.5);
    vec2 _114 = _110 * _ScreenSpaceReflectionData._SSRParams0.zw;
    vec4 _118 = textureLod(sampler2D(_SSRCurrentSceneDepthPyramidTexture, s_point_clamp_sampler), _114, 0.0);
    float _119 = _118.x;
    float _125 = (ShaderVariablesGlobal._ZBufferParams.z * _119) + ShaderVariablesGlobal._ZBufferParams.w;
    vec2 _128 = (_114 * 2.0) - vec2(1.0);
    float _129 = _128.x;
    vec3 _131 = vec3(_129, _128.y, _119);
    vec4 _134 = vec4(_129, _128.y, _119, 1.0);
    vec4 _135 = _134 * ShaderVariablesGlobal._InvProjMatrix;
    vec3 _139 = _135.xyz / vec3(_135.w);
    _139.y = -_139.y;
    vec4 _146 = textureLod(sampler2D(_SSRNormalRoughnessTexture, s_point_clamp_sampler), _114, 0.0);
    vec2 _149 = (_146.xy * 2.0) - vec2(1.0);
    float _153 = 1.0 - dot(vec2(1.0), abs(_149));
    vec3 _155 = vec3(_149.x, _153, _149.y);
    vec3 _167;
    if (_153 < 0.0)
    {
        vec2 _165 = (vec2(1.0) - abs(_155.zx)) * mix(vec2(-1.0), vec2(1.0), greaterThanEqual(_155.xz, vec2(0.0)));
        _167 = vec3(_165.x, _155.y, _165.y);
    }
    else
    {
        _167 = _155;
    }
    vec3 _168 = normalize(_167);
    float _169 = _146.z;
    float _170 = _169 * _169;
    float _171 = _170 * _170;
    vec3 _181 = _168 * mat3(ShaderVariablesGlobal._ViewMatrix[0].xyz, ShaderVariablesGlobal._ViewMatrix[1].xyz, ShaderVariablesGlobal._ViewMatrix[2].xyz);
    float _190 = max(ceil(_ScreenSpaceReflectionData._SSRParams3.x * shader_injection.ssr_step_scale * clamp(2.0 * exp((-0.070000000298023223876953125) / _125), 0.125, 1.0)), shader_injection.ssr_step_max);
    float _193 = (_169 >= 0.300000011920928955078125) ? (_190 * 0.125) : _190;
	
	
    vec3 _195 = normalize(_139);
    vec4 _203 = vec4(reflect(_195, _181), 0.0) * ShaderVariablesGlobal._ProjMatrix;
    _203.y = -_203.y;
    vec4 _207 = _203 + _134;
    vec3 _212 = (_207.xyz / vec3(_207.w)) - _131;
    vec2 _213 = _131.xy;
    vec2 _214 = _212.xy;
    float _216 = 0.5 * length(_214);
    vec2 _225 = vec2(1.0) - (max(abs(_214 + (_213 * _216)) - vec2(_216), vec2(0.0)) / abs(_214));
    vec3 _230 = _212 * (min(_225.x, _225.y) / _216);
    float _241 = _230.z;
    float _244 = max(abs(_241) / _193, 9.9999997473787516355514526367188e-05);
    vec3 _255 = vec3(_230.xy * vec2(0.5), _241) * (1.0 / _193);
    vec2 _259 = abs(_255.xy * _ScreenSpaceReflectionData._SSRParams0.xy);
    float _262 = max(_259.x, _259.y);
    vec3 _268 = vec3((_213 * vec2(0.5)) + vec2(0.5), _119) + (_255 * ((_262 < 1.0) ? (1.0 / (_262 + 0.001000000047497451305389404296875)) : fract(52.98291778564453125 * fract(dot(_110 + (vec2(2.0829999446868896484375, 4.867000102996826171875) * float(int(_ScreenSpaceReflectionData._SSRParams1.x))), vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    float _276 = _268.z - textureLod(sampler2D(_SSRCurrentSceneDepthPyramidTexture, s_point_clamp_sampler), _268.xy, 0.0).x;
    vec3 _278;
    vec3 _283;
    _278 = _268;
    _283 = vec3(0.0);
    vec3 _279;
    float _285;
    vec3 _363;
    bool _364;
    float _281 = 0.0;
    float _284 = _276;
    for (;;)
    {
        if (_281 < _193)
        {
            vec4 _292 = _278.xyxy + (_255.xyxy * vec4(1.0, 1.0, 2.0, 2.0));
            vec4 _294 = _278.xyxy + (_255.xyxy * vec4(3.0, 3.0, 4.0, 4.0));
            vec4 _324 = (_278.zzzz + (_255.zzzz * vec4(1.0, 2.0, 3.0, 4.0))) - vec4(textureLod(sampler2D(_SSRCurrentSceneDepthPyramidTexture, s_point_clamp_sampler), _292.xy, 0.0).x, textureLod(sampler2D(_SSRCurrentSceneDepthPyramidTexture, s_point_clamp_sampler), _292.zw, 0.0).x, textureLod(sampler2D(_SSRCurrentSceneDepthPyramidTexture, s_point_clamp_sampler), _294.xy, 0.0).x, textureLod(sampler2D(_SSRCurrentSceneDepthPyramidTexture, s_point_clamp_sampler), _294.zw, 0.0).x);
            vec4 _325 = vec4(_244);
            bvec4 _328 = lessThan(abs(_324 + _325), _325);
            SPIRV_CROSS_BRANCH
            if (any(_328))
            {
                float _332 = _324.z;
                bool _334 = _328.z;
                float _338;
                SPIRV_CROSS_FLATTEN
                if (_334)
                {
                    _338 = _324.y;
                }
                else
                {
                    _338 = _332;
                }
                bool _341 = _328.y;
                float _346;
                float _347;
                SPIRV_CROSS_FLATTEN
                if (_341)
                {
                    _346 = _324.y;
                    _347 = _324.x;
                }
                else
                {
                    _346 = _334 ? _332 : _324.w;
                    _347 = _338;
                }
                bool _349 = _328.x;
                float _353;
                SPIRV_CROSS_FLATTEN
                if (_349)
                {
                    _353 = _324.x;
                }
                else
                {
                    _353 = _346;
                }
                float _354 = _349 ? _284 : _347;
                _363 = _278 + (_255 * ((_349 ? 0.0 : (_341 ? 1.0 : (_334 ? 2.0 : 3.0))) + clamp(_354 / (_354 - _353), 0.0, 1.0)));
                _364 = true;
                break;
            }
            _279 = _278 + (_255 * 4.0);
            _285 = _324.w;
            _278 = _279;
            _281 += 4.0;
            _283 = _279;
            _284 = _285;
            continue;
        }
        else
        {
            _363 = _283;
            _364 = false;
            break;
        }
    }
    vec4 _371 = mix(vec4(_363, 0.0), vec4(_363, 1.0), bvec4(_364));
    float _426;
    vec2 _427;
    vec2 _428;
    SPIRV_CROSS_BRANCH
    if (_371.w == 1.0)
    {
        vec2 _376 = _371.xy;
        float _379 = _371.x;
        float _380 = _371.y;
        float _384 = min(1.0 - max(_379, _380), min(_379, _380));
        vec2 _410 = textureLod(sampler2D(_SSRMotionVectorTexture, s_point_clamp_sampler), _376, 0.0).xy;
        vec2 _417 = (abs(_410) * 2.0) - vec2(1.0);
        vec2 _418 = _417 * _417;
        vec2 _424 = ((_418 * _418) * vec2(ivec2(sign(_410 - vec2(0.5))))) * (1.0 - _ScreenSpaceReflectionData._SSRParams2.z);
        _426 = (clamp((_384 > _ScreenSpaceReflectionData._SSRParams1.y) ? 1.0 : (_384 / _ScreenSpaceReflectionData._SSRParams1.y), 0.0, 1.0) * (1.0 - clamp((abs(dot(_181, _195)) * _ScreenSpaceReflectionData._SSRParams1.z) + _ScreenSpaceReflectionData._SSRParams1.w, 0.0, 1.0))) * ((_169 < 0.100000001490116119384765625) ? 1.0 : clamp((100.0 - (1.0 / _125)) * 0.100000001490116119384765625, 0.0, 1.0));
        _427 = _424;
        _428 = _376 - _424;
    }
    else
    {
        _426 = 0.0;
        _427 = vec2(0.0);
        _428 = _114;
    }
    vec2 _433 = textureLod(sampler2D(_SSRMotionVectorTexture, s_point_clamp_sampler), _428, 0.0).xy;
    vec2 _440 = (abs(_433) * 2.0) - vec2(1.0);
    vec2 _441 = _440 * _440;
    float _462 = acos(pow(0.24400000274181365966796875, 1.0 / ((2.0 / _171) + (-1.0))));
    vec4 _465 = _134 * ShaderVariablesGlobal._InvViewProjMatrix;
    vec4 _468 = _465 / vec4(_465.w);
    vec4 _476 = vec4((_371.xy * 2.0) - vec2(1.0), _371.z, 1.0) * ShaderVariablesGlobal._InvViewProjMatrix;
    vec3 _483 = _468.xyz;
    vec3 _485 = normalize(ShaderVariablesGlobal._WorldSpaceCameraPos_Internal.xyz - _483);
    float _486 = distance(ShaderVariablesGlobal._WorldSpaceCameraPos_Internal.xyz, _483);
    vec3 _493 = normalize(cross(mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 0.0, 1.0), bvec3(abs(_168.z) < 0.999000012874603271484375)), _168));
    float _495 = distance(_476 / vec4(_476.w), _468);
    vec3 _499 = cross(_493, _485);
    vec3 _500 = -_485;
    vec3 _504 = vec3(cos(_462));
    float _507 = sin(_462);
    vec3 _511 = ShaderVariablesGlobal._WorldSpaceCameraPos_Internal.xyz - (_485 * _486);
    vec3 _514 = cross(cross(_168, _493), _485);
    vec4 _530 = vec4((ShaderVariablesGlobal._WorldSpaceCameraPos_Internal.xyz - (_485 * (_495 + _486))) - ShaderVariablesGlobal._WorldSpaceCameraPos_Internal.xyz, 1.0) * ShaderVariablesGlobal._ViewNoTransProjMatrix;
    vec2 _538 = (((_530.xy / vec2(_530.w)).xy * 0.5) + vec2(0.5)) * _ScreenSpaceReflectionData._SSRParams0.xy;
    vec4 _544 = vec4((_511 + ((mix(_499 * dot(_499, _500), _500, _504) + (cross(_499, _500) * _507)) * _495)) - ShaderVariablesGlobal._WorldSpaceCameraPos_Internal.xyz, 1.0) * ShaderVariablesGlobal._ViewNoTransProjMatrix;
    vec4 _558 = vec4((_511 + ((mix(_514 * dot(_514, _500), _500, _504) + (cross(_514, _500) * _507)) * _495)) - ShaderVariablesGlobal._WorldSpaceCameraPos_Internal.xyz, 1.0) * ShaderVariablesGlobal._ViewNoTransProjMatrix;
    imageStore(_SSRRayMarchingHitUVRWTexture, ivec2(gl_GlobalInvocationID.xy), _428.xyyy);
    imageStore(_SSRFilterWeightRWTexture, ivec2(gl_GlobalInvocationID.xy), vec2(exp((-length((((_441 * _441) * vec2(ivec2(sign(_433 - vec2(0.5))))) + _427) * ShaderVariablesGlobal._ScreenSize.xy)) * clamp(log(0.0199999995529651641845703125 / _125) + 0.00999999977648258209228515625, 0.0, 1.0)), (_171 <= 9.9999997473787516355514526367188e-05) ? 0.0 : (clamp(log2(sqrt(pow(distance(_538, (((_544.xy / vec2(_544.w)).xy * 0.5) + vec2(0.5)) * _ScreenSpaceReflectionData._SSRParams0.xy), 2.0) + pow(distance(_538, (((_558.xy / vec2(_558.w)).xy * 0.5) + vec2(0.5)) * _ScreenSpaceReflectionData._SSRParams0.xy), 2.0)) * 0.5), 0.0, _ScreenSpaceReflectionData._SSRParams5.y) / _ScreenSpaceReflectionData._SSRParams5.y)).xyyy);
    imageStore(_SSRFadenessRWTexture, ivec2(gl_GlobalInvocationID.xy), vec4(_426));
}

