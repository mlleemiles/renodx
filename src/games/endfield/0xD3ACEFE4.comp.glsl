// SSR Resolve mips

#version 450
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

#include "./shared.h"

const float _74[4][4] = float[][](float[](0.015625, 0.046875, 0.046875, 0.015625), float[](0.046875, 0.140625, 0.140625, 0.046875), float[](0.046875, 0.140625, 0.140625, 0.046875), float[](0.015625, 0.046875, 0.046875, 0.015625));

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

layout(set = 0, binding = 4) uniform sampler s_point_clamp_sampler;
layout(set = 0, binding = 5) uniform sampler s_linear_clamp_sampler;
layout(set = 0, binding = 1) uniform texture2D _SSRCurrentSceneDepthPyramidTexture;
layout(set = 0, binding = 2) uniform texture2D _SSRFilterWeightTexture;
layout(set = 0, binding = 3) uniform texture2D _SSRColorPyramidTexture;
layout(set = 0, binding = 0, r11f_g11f_b10f) uniform writeonly image2D _SSRColorResolveRWTexture;

void main()
{
    vec3 _244;
    do
    {
        vec2 _82 = vec2(ivec2(gl_GlobalInvocationID.xy));
        vec2 _87 = (_82 + vec2(0.5)) * _ScreenSpaceReflectionData._SSRParams0.zw;
        float _99 = 1.0 / ((ShaderVariablesGlobal._ZBufferParams.z * textureLod(sampler2D(_SSRCurrentSceneDepthPyramidTexture, s_point_clamp_sampler), _87, 0.0).x) + ShaderVariablesGlobal._ZBufferParams.w);
        float _107 = textureLod(sampler2D(_SSRFilterWeightTexture, s_point_clamp_sampler), _87, 0.0).y * _ScreenSpaceReflectionData._SSRParams5.y;
        if (_107 < shader_injection.ssr_mip_threshold)
        {
            vec4 _114 = textureLod(sampler2D(_SSRColorPyramidTexture, s_point_clamp_sampler), _87, 0.0);
            _244 = _114.xyz * (1.0 / (1.0 - max(max(_114.x, _114.y), _114.z)));
            break;
        }
        float _124 = floor(_107);
        vec2 _125 = _82 * _ScreenSpaceReflectionData._SSRParams0.zw;
        vec2 _126 = vec2(1.5) * _ScreenSpaceReflectionData._SSRParams0.zw;
        float _127 = pow(2.0, _124);
        vec2 _129 = _125 - (_126 * _127);
        vec2 _130 = _ScreenSpaceReflectionData._SSRParams0.zw * _127;
        float _132;
        vec3 _135;
        int _137;
        _132 = 0.0;
        _135 = vec3(0.0);
        _137 = 0;
        float _133;
        vec3 _136;
        for (; _137 < 4; _132 = _133, _135 = _136, _137++)
        {
            _136 = _135;
            _133 = _132;
            for (int _146 = 0; _146 < 4; )
            {
                vec2 _154 = _129 + (vec2(float(_137), float(_146)) * _130);
                float _174 = _74[_137][_146] * exp(abs((1.0 / ((ShaderVariablesGlobal._ZBufferParams.z * textureLod(sampler2D(_SSRCurrentSceneDepthPyramidTexture, s_point_clamp_sampler), _154, _124).x) + ShaderVariablesGlobal._ZBufferParams.w)) - _99) * (-0.00999999977648258209228515625));
                _136 += (textureLod(sampler2D(_SSRColorPyramidTexture, s_linear_clamp_sampler), _154, _124).xyz * _174);
                _133 += _174;
                _146++;
                continue;
            }
        }
        float _177 = clamp(_124 + 1.0, 0.0, _ScreenSpaceReflectionData._SSRParams5.y);
        float _178 = pow(2.0, _177);
        vec2 _180 = _125 - (_126 * _178);
        vec2 _181 = _ScreenSpaceReflectionData._SSRParams0.zw * _178;
        float _183;
        vec3 _186;
        int _188;
        _183 = 0.0;
        _186 = vec3(0.0);
        _188 = 0;
        float _184;
        vec3 _187;
        for (; _188 < 4; _183 = _184, _186 = _187, _188++)
        {
            _187 = _186;
            _184 = _183;
            for (int _197 = 0; _197 < 4; )
            {
                vec2 _205 = _180 + (vec2(float(_188), float(_197)) * _181);
                float _225 = _74[_188][_197] * exp(abs((1.0 / ((ShaderVariablesGlobal._ZBufferParams.z * textureLod(sampler2D(_SSRCurrentSceneDepthPyramidTexture, s_point_clamp_sampler), _205, _177).x) + ShaderVariablesGlobal._ZBufferParams.w)) - _99) * (-0.00999999977648258209228515625));
                _187 += (textureLod(sampler2D(_SSRColorPyramidTexture, s_linear_clamp_sampler), _205, _177).xyz * _225);
                _184 += _225;
                _197++;
                continue;
            }
        }
        vec3 _235 = mix(_135 / vec3(max(_132, 0.00999999977648258209228515625)), _186 / vec3(max(_183, 0.00999999977648258209228515625)), vec3(_107 - _124));
        _244 = _235 * (1.0 / (1.0 - max(max(_235.x, _235.y), _235.z)));
        break;
    } while(false);
    imageStore(_SSRColorResolveRWTexture, ivec2(gl_GlobalInvocationID.xy), _244.xyzz);
}

