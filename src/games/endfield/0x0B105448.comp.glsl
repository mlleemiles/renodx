//SSR Raymarch 1

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

layout(set = 1, binding = 2, std140) uniform type_VerticalOcclusionMapTransformCB
{
    layout(row_major) mat4 _WorldToVerticalOcclusionMap;
    vec4 _VerticalOcclusionMapUVScrollingOffset;
} _VerticalOcclusionMapTransformCB;

layout(set = 0, binding = 9) uniform sampler s_point_clamp_sampler;
layout(set = 0, binding = 10) uniform sampler s_linear_clamp_sampler;
layout(set = 0, binding = 11) uniform sampler s_linear_repeat_sampler;
layout(set = 0, binding = 12) uniform samplerShadow s_linear_repeat_compare_sampler;
layout(set = 0, binding = 3) uniform texture2D _SSRCurrentSceneDepthPyramidTexture;
layout(set = 0, binding = 4) uniform texture2D _SSRNormalRoughnessTexture;
layout(set = 0, binding = 5) uniform texture2D _SSRMotionVectorTexture;
layout(set = 0, binding = 6) uniform texture2D _VerticalOcclusionMap;
layout(set = 0, binding = 7) uniform texture3D _RainOcclusionSampleNoise;
layout(set = 0, binding = 8) uniform texture2D _WaterWetnessMaskTexture;
layout(set = 0, binding = 0, rg16) uniform writeonly image2D _SSRRayMarchingHitUVRWTexture;
layout(set = 0, binding = 1, rg16) uniform writeonly image2D _SSRFilterWeightRWTexture;
layout(set = 0, binding = 2, r8) uniform writeonly image2D _SSRFadenessRWTexture;

void main()
{
    vec2 _143 = vec2(ivec2(gl_GlobalInvocationID.xy)) + vec2(0.5);
    vec2 _147 = _143 * _ScreenSpaceReflectionData._SSRParams0.zw;
    vec4 _151 = textureLod(sampler2D(_SSRCurrentSceneDepthPyramidTexture, s_point_clamp_sampler), _147, 0.0);
    float _152 = _151.x;
    float _158 = (ShaderVariablesGlobal._ZBufferParams.z * _152) + ShaderVariablesGlobal._ZBufferParams.w;
    vec2 _161 = (_147 * 2.0) - vec2(1.0);
    float _162 = _161.x;
    vec3 _164 = vec3(_162, _161.y, _152);
    vec4 _167 = vec4(_162, _161.y, _152, 1.0);
    vec4 _168 = _167 * ShaderVariablesGlobal._InvProjMatrix;
    vec3 _172 = _168.xyz / vec3(_168.w);
    float _174 = -_172.y;
    vec3 _175 = _172;
    _175.y = _174;
    vec4 _179 = textureLod(sampler2D(_SSRNormalRoughnessTexture, s_point_clamp_sampler), _147, 0.0);
    vec2 _182 = (_179.xy * 2.0) - vec2(1.0);
    float _186 = 1.0 - dot(vec2(1.0), abs(_182));
    vec3 _188 = vec3(_182.x, _186, _182.y);
    vec3 _200;
    if (_186 < 0.0)
    {
        vec2 _198 = (vec2(1.0) - abs(_188.zx)) * mix(vec2(-1.0), vec2(1.0), greaterThanEqual(_188.xz, vec2(0.0)));
        _200 = vec3(_198.x, _188.y, _198.y);
    }
    else
    {
        _200 = _188;
    }
    vec3 _201 = normalize(_200);
    float _202 = _179.z;
    vec4 _206 = textureLod(sampler2D(_WaterWetnessMaskTexture, s_linear_clamp_sampler), _147, 0.0);
    vec4 _213 = vec4(_172.x, _174, _172.z, 1.0) * ShaderVariablesGlobal._InvViewMatrix;
    vec3 _214 = _213.xyz;
    float _215 = dot(_201, vec3(0.0, -1.0, 0.0));
    vec3 _270;
    SPIRV_CROSS_BRANCH
    if (ShaderVariablesGlobal._RainWetnessGlobalParam4.x > 0.5)
    {
        float _242 = abs(_201.x);
        float _244 = abs(_201.y);
        float _246 = abs(_201.z);
        vec3 _251 = vec3(_242, _244, _246) * (1.0 / ((_242 + _244) + _246));
        _270 = ((((vec3(0.0, 0.0, 1.0) * _251.x) + (vec3(0.70710599422454833984375, 0.0, 0.70710599422454833984375) * _251.y)) + (vec3(1.0, 0.0, 0.0) * _251.z)) * ((textureLod(sampler3D(_RainOcclusionSampleNoise, s_linear_repeat_sampler), _214 * ShaderVariablesGlobal._RainWetnessGlobalParam7.x, 0.0).x * 2.0) - 1.0)) * mix(ShaderVariablesGlobal._RainWetnessGlobalParam7.z, ShaderVariablesGlobal._RainWetnessGlobalParam7.y, smoothstep(0.699999988079071044921875, 0.949999988079071044921875, abs(_215)));
    }
    else
    {
        _270 = vec3(0.0);
    }
    vec4 _284 = vec4((_214 + ((((_201 * ShaderVariablesGlobal._VerticalOcclusionMapParam0.z) * ShaderVariablesGlobal._RainWetnessGlobalParam3.x) + (vec3(0.0, 1.0, 0.0) * ShaderVariablesGlobal._RainWetnessGlobalParam3.y)) * ((1.0 - clamp(_215, 0.0, 0.89999997615814208984375)) * clamp(smoothstep(0.20000000298023223876953125, 0.100000001490116119384765625, _215), 0.100000001490116119384765625, 1.0)))) + _270, 1.0) * _VerticalOcclusionMapTransformCB._WorldToVerticalOcclusionMap;
    vec2 _287 = (_284.xy * 0.5) + vec2(0.5);
    vec4 _288 = vec4(_287.x, _287.y, _284.z, _284.w);
    _288.y = 1.0 - _287.y;
    float _309;
    SPIRV_CROSS_BRANCH
    if (ShaderVariablesGlobal._RainWetnessGlobalParam4.y > 0.5)
    {
        _309 = textureLod(sampler2DShadow(_VerticalOcclusionMap, s_linear_repeat_compare_sampler), vec3((_288.xy + _VerticalOcclusionMapTransformCB._VerticalOcclusionMapUVScrollingOffset.xy).xy, max(_284.z, 0.00048828125)), 0.0);
    }
    else
    {
        _309 = 1.0;
    }
    vec2 _321 = abs(_213.xz - ShaderVariablesGlobal._WorldSpaceCameraPos_Internal.xz);
    vec2 _335 = _206.xy * (1.0 - mix(mix(ShaderVariablesGlobal._RainWetnessGlobalParam8.w, 1.0, clamp(_201.y, 0.0, 1.0)) * _309, 1.0, smoothstep(0.699999988079071044921875 * ShaderVariablesGlobal._RainWetnessGlobalParam0.w, 0.75 * ShaderVariablesGlobal._RainWetnessGlobalParam0.w, max(_321.x, _321.y))));
    float _336 = _335.x;
    float _337 = 1.0 - _202;
    float _364 = smoothstep(0.0, 0.0500000007450580596923828125, 0.0);
    float _366 = (1.0 - mix(_337, clamp(clamp(mix(0.89999997615814208984375, 0.60000002384185791015625, clamp(clamp((_337 * ShaderVariablesGlobal._RainWetnessGlobalParam0.z) + ShaderVariablesGlobal._RainWetnessGlobalParam0.y, 0.0, 1.0), 0.0, 1.0)) + mix(-0.60000002384185791015625, 0.4000000059604644775390625, sqrt(_337)), 0.0, 1.0), _337, 0.9900000095367431640625), ((ShaderVariablesGlobal._RainWetnessGlobalParam0.x * clamp(2.0 - ShaderVariablesGlobal._RainWetnessGlobalParam0.x, 0.0, 1.0)) * (1.0 - smoothstep(0.20000000298023223876953125, 0.5, _215))) * (1.0 - _336))) * mix(1.0, 0.100000001490116119384765625, _364);
    float _369 = mix(mix(min(1.0, _366), _366, min(_206.x, _206.y)), _202, _336);
    float _370 = _369 * _369;
    float _371 = _370 * _370;
    vec3 _381 = _201 * mat3(ShaderVariablesGlobal._ViewMatrix[0].xyz, ShaderVariablesGlobal._ViewMatrix[1].xyz, ShaderVariablesGlobal._ViewMatrix[2].xyz);
    float _390 = max(ceil(_ScreenSpaceReflectionData._SSRParams3.x * shader_injection.ssr_step_scale * clamp(2.0 * exp((-0.070000000298023223876953125) / _158), 0.125, 1.0)), shader_injection.ssr_step_max);
    float _393 = (_202 >= 0.300000011920928955078125) ? (_390 * 0.125) : _390;
	

	
    vec3 _395 = normalize(_175);
    vec4 _403 = vec4(reflect(_395, _381), 0.0) * ShaderVariablesGlobal._ProjMatrix;
    _403.y = -_403.y;
    vec4 _407 = _403 + _167;
    vec3 _412 = (_407.xyz / vec3(_407.w)) - _164;
    vec2 _413 = _164.xy;
    vec2 _414 = _412.xy;
    float _416 = 0.5 * length(_414);
    vec2 _425 = vec2(1.0) - (max(abs(_414 + (_413 * _416)) - vec2(_416), vec2(0.0)) / abs(_414));
    vec3 _430 = _412 * (min(_425.x, _425.y) / _416);
    float _441 = _430.z;
    float _444 = max(abs(_441) / _393, 9.9999997473787516355514526367188e-05);
    vec3 _455 = vec3(_430.xy * vec2(0.5), _441) * (1.0 / _393);
    vec2 _459 = abs(_455.xy * _ScreenSpaceReflectionData._SSRParams0.xy);
    float _462 = max(_459.x, _459.y);
    vec3 _468 = vec3((_413 * vec2(0.5)) + vec2(0.5), _152) + (_455 * ((_462 < 1.0) ? (1.0 / (_462 + 0.001000000047497451305389404296875)) : fract(52.98291778564453125 * fract(dot(_143 + (vec2(2.0829999446868896484375, 4.867000102996826171875) * float(int(_ScreenSpaceReflectionData._SSRParams1.x))), vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    float _476 = _468.z - textureLod(sampler2D(_SSRCurrentSceneDepthPyramidTexture, s_point_clamp_sampler), _468.xy, 0.0).x;
    vec3 _478;
    vec3 _483;
    _478 = _468;
    _483 = vec3(0.0);
    vec3 _479;
    float _485;
    vec3 _563;
    bool _564;
    float _481 = 0.0;
    float _484 = _476;
    for (;;)
    {
        if (_481 < _393)
        {
            vec4 _492 = _478.xyxy + (_455.xyxy * vec4(1.0, 1.0, 2.0, 2.0));
            vec4 _494 = _478.xyxy + (_455.xyxy * vec4(3.0, 3.0, 4.0, 4.0));
            vec4 _524 = (_478.zzzz + (_455.zzzz * vec4(1.0, 2.0, 3.0, 4.0))) - vec4(textureLod(sampler2D(_SSRCurrentSceneDepthPyramidTexture, s_point_clamp_sampler), _492.xy, 0.0).x, textureLod(sampler2D(_SSRCurrentSceneDepthPyramidTexture, s_point_clamp_sampler), _492.zw, 0.0).x, textureLod(sampler2D(_SSRCurrentSceneDepthPyramidTexture, s_point_clamp_sampler), _494.xy, 0.0).x, textureLod(sampler2D(_SSRCurrentSceneDepthPyramidTexture, s_point_clamp_sampler), _494.zw, 0.0).x);
            vec4 _525 = vec4(_444);
            bvec4 _528 = lessThan(abs(_524 + _525), _525);
            SPIRV_CROSS_BRANCH
            if (any(_528))
            {
                float _532 = _524.z;
                bool _534 = _528.z;
                float _538;
                SPIRV_CROSS_FLATTEN
                if (_534)
                {
                    _538 = _524.y;
                }
                else
                {
                    _538 = _532;
                }
                bool _541 = _528.y;
                float _546;
                float _547;
                SPIRV_CROSS_FLATTEN
                if (_541)
                {
                    _546 = _524.y;
                    _547 = _524.x;
                }
                else
                {
                    _546 = _534 ? _532 : _524.w;
                    _547 = _538;
                }
                bool _549 = _528.x;
                float _553;
                SPIRV_CROSS_FLATTEN
                if (_549)
                {
                    _553 = _524.x;
                }
                else
                {
                    _553 = _546;
                }
                float _554 = _549 ? _484 : _547;
                _563 = _478 + (_455 * ((_549 ? 0.0 : (_541 ? 1.0 : (_534 ? 2.0 : 3.0))) + clamp(_554 / (_554 - _553), 0.0, 1.0)));
                _564 = true;
                break;
            }
            _479 = _478 + (_455 * 4.0);
            _485 = _524.w;
            _478 = _479;
            _481 += 4.0;
            _483 = _479;
            _484 = _485;
            continue;
        }
        else
        {
            _563 = _483;
            _564 = false;
            break;
        }
    }
    vec4 _571 = mix(vec4(_563, 0.0), vec4(_563, 1.0), bvec4(_564));
    float _626;
    vec2 _627;
    vec2 _628;
    SPIRV_CROSS_BRANCH
    if (_571.w == 1.0)
    {
        vec2 _576 = _571.xy;
        float _579 = _571.x;
        float _580 = _571.y;
        float _584 = min(1.0 - max(_579, _580), min(_579, _580));
        vec2 _610 = textureLod(sampler2D(_SSRMotionVectorTexture, s_point_clamp_sampler), _576, 0.0).xy;
        vec2 _617 = (abs(_610) * 2.0) - vec2(1.0);
        vec2 _618 = _617 * _617;
        vec2 _624 = ((_618 * _618) * vec2(ivec2(sign(_610 - vec2(0.5))))) * (1.0 - _ScreenSpaceReflectionData._SSRParams2.z);
        _626 = (clamp((_584 > _ScreenSpaceReflectionData._SSRParams1.y) ? 1.0 : (_584 / _ScreenSpaceReflectionData._SSRParams1.y), 0.0, 1.0) * (1.0 - clamp((abs(dot(_381, _395)) * _ScreenSpaceReflectionData._SSRParams1.z) + _ScreenSpaceReflectionData._SSRParams1.w, 0.0, 1.0))) * ((_369 < 0.100000001490116119384765625) ? 1.0 : clamp((100.0 - (1.0 / _158)) * 0.100000001490116119384765625, 0.0, 1.0));
        _627 = _624;
        _628 = _576 - _624;
    }
    else
    {
        _626 = 0.0;
        _627 = vec2(0.0);
        _628 = _147;
    }
    vec2 _633 = textureLod(sampler2D(_SSRMotionVectorTexture, s_point_clamp_sampler), _628, 0.0).xy;
    vec2 _640 = (abs(_633) * 2.0) - vec2(1.0);
    vec2 _641 = _640 * _640;
    float _662 = acos(pow(0.24400000274181365966796875, 1.0 / ((2.0 / _371) + (-1.0))));
    vec4 _665 = _167 * ShaderVariablesGlobal._InvViewProjMatrix;
    vec4 _668 = _665 / vec4(_665.w);
    vec4 _676 = vec4((_571.xy * 2.0) - vec2(1.0), _571.z, 1.0) * ShaderVariablesGlobal._InvViewProjMatrix;
    vec3 _681 = _668.xyz;
    vec3 _683 = normalize(ShaderVariablesGlobal._WorldSpaceCameraPos_Internal.xyz - _681);
    float _684 = distance(ShaderVariablesGlobal._WorldSpaceCameraPos_Internal.xyz, _681);
    vec3 _691 = normalize(cross(mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 0.0, 1.0), bvec3(abs(_201.z) < 0.999000012874603271484375)), _201));
    float _693 = distance(_676 / vec4(_676.w), _668);
    vec3 _697 = cross(_691, _683);
    vec3 _698 = -_683;
    vec3 _702 = vec3(cos(_662));
    float _705 = sin(_662);
    vec3 _709 = ShaderVariablesGlobal._WorldSpaceCameraPos_Internal.xyz - (_683 * _684);
    vec3 _712 = cross(cross(_201, _691), _683);
    vec4 _728 = vec4((ShaderVariablesGlobal._WorldSpaceCameraPos_Internal.xyz - (_683 * (_693 + _684))) - ShaderVariablesGlobal._WorldSpaceCameraPos_Internal.xyz, 1.0) * ShaderVariablesGlobal._ViewNoTransProjMatrix;
    vec2 _736 = (((_728.xy / vec2(_728.w)).xy * 0.5) + vec2(0.5)) * _ScreenSpaceReflectionData._SSRParams0.xy;
    vec4 _742 = vec4((_709 + ((mix(_697 * dot(_697, _698), _698, _702) + (cross(_697, _698) * _705)) * _693)) - ShaderVariablesGlobal._WorldSpaceCameraPos_Internal.xyz, 1.0) * ShaderVariablesGlobal._ViewNoTransProjMatrix;
    vec4 _756 = vec4((_709 + ((mix(_712 * dot(_712, _698), _698, _702) + (cross(_712, _698) * _705)) * _693)) - ShaderVariablesGlobal._WorldSpaceCameraPos_Internal.xyz, 1.0) * ShaderVariablesGlobal._ViewNoTransProjMatrix;
    imageStore(_SSRRayMarchingHitUVRWTexture, ivec2(gl_GlobalInvocationID.xy), _628.xyyy);
    imageStore(_SSRFilterWeightRWTexture, ivec2(gl_GlobalInvocationID.xy), vec2(exp((-length((((_641 * _641) * vec2(ivec2(sign(_633 - vec2(0.5))))) + _627) * ShaderVariablesGlobal._ScreenSize.xy)) * clamp(log(0.0199999995529651641845703125 / _158) + 0.00999999977648258209228515625, 0.0, 1.0)), (_371 <= 9.9999997473787516355514526367188e-05) ? 0.0 : (clamp(log2(sqrt(pow(distance(_736, (((_742.xy / vec2(_742.w)).xy * 0.5) + vec2(0.5)) * _ScreenSpaceReflectionData._SSRParams0.xy), 2.0) + pow(distance(_736, (((_756.xy / vec2(_756.w)).xy * 0.5) + vec2(0.5)) * _ScreenSpaceReflectionData._SSRParams0.xy), 2.0)) * 0.5), 0.0, _ScreenSpaceReflectionData._SSRParams5.y) / _ScreenSpaceReflectionData._SSRParams5.y)).xyyy);
    imageStore(_SSRFadenessRWTexture, ivec2(gl_GlobalInvocationID.xy), vec4(_626));
}

