#version 450
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

layout(set = 1, binding = 1, std140) uniform type_DepthOfFieldData
{
    vec4 _DepthOfFieldParam0;
    vec4 _DepthOfFieldParam1;
    vec4 _DepthOfFieldParam2;
    vec4 _DepthOfFieldParam3;
    vec4 _DepthOfFieldDownScreenSize;
    vec4 _DepthOfFieldTileScreenSize;
    vec4 _DepthOfFieldNearStartColor;
    vec4 _DepthOfFieldNearEndColor;
    vec4 _DepthOfFieldFarStartColor;
    vec4 _DepthOfFieldFarEndColor;
} _DepthOfFieldData;

#include "../shared.h"

layout(set = 0, binding = 6) uniform sampler s_point_clamp_sampler;
layout(set = 0, binding = 7) uniform sampler s_linear_clamp_sampler;
layout(set = 0, binding = 2) uniform texture2D _SceneColorTexture;
layout(set = 0, binding = 3) uniform texture2D _DepthOfFieldDownMotionVectorTexture;
layout(set = 0, binding = 4) uniform texture2D _DepthOfFieldDownPreviousSceneColorTexture;
layout(set = 0, binding = 5) uniform texture2D _DepthOfFieldCoCTexture;
layout(set = 0, binding = 0, rg16f) uniform writeonly image2D _DepthOfFieldDownCoCRWTexture;
layout(set = 0, binding = 1, rgba16f) uniform writeonly image2D _DepthOfFieldDownSceneColorRWTexture;

void main()
{
    vec2 _100 = (vec2(gl_GlobalInvocationID.xy) + vec2(0.5)) * vec2(1.0/shader_injection.render_resolution_x, 1.0/shader_injection.render_resolution_y);
    vec2 _135 = (((textureLod(sampler2D(_DepthOfFieldCoCTexture, s_point_clamp_sampler), _100 + (vec2(-0.5) * ShaderVariablesGlobal._ScreenSize.zw), 0.0).xy + textureLod(sampler2D(_DepthOfFieldCoCTexture, s_point_clamp_sampler), _100 + (vec2(0.5, -0.5) * ShaderVariablesGlobal._ScreenSize.zw), 0.0).xy) + textureLod(sampler2D(_DepthOfFieldCoCTexture, s_point_clamp_sampler), _100 + (vec2(-0.5, 0.5) * ShaderVariablesGlobal._ScreenSize.zw), 0.0).xy) + textureLod(sampler2D(_DepthOfFieldCoCTexture, s_point_clamp_sampler), _100 + (vec2(0.5) * ShaderVariablesGlobal._ScreenSize.zw), 0.0).xy) * 0.25;
    float _136 = _135.x;
    float _137 = _135.y;
    vec3 _139;
    vec3 _142;
    vec3 _144;
    _139 = vec3(0.0);
    _142 = vec3(0.0);
    _144 = vec3(0.0);
    vec3 _92[9];
    vec3 _140;
    vec3 _143;
    vec3 _145;
    for (int _146 = -1; _146 <= 1; _139 = _140, _142 = _143, _144 = _145, _146++)
    {
        _143 = _142;
        _145 = _144;
        _140 = _139;
        vec3 _152;
        vec3 _154;
        vec3 _157;
        for (int _155 = -1; _155 <= 1; _143 = _152, _145 = _154, _155++, _140 = _157)
        {
            int _169 = (((_146 + 1) * 3) + _155) + 1;
            _92[_169] = textureLod(sampler2D(_SceneColorTexture, s_linear_clamp_sampler), _100 + (vec2(float(_146), float(_155)) * vec2(1.0/shader_injection.render_resolution_x, 1.0/shader_injection.render_resolution_y)), 0.0).xyz;
            _92[_169] *= (1.0 / (dot(_92[_169], vec3(0.21267290413379669189453125, 0.715152204036712646484375, 0.072175003588199615478515625)) + 1.0));
            if ((_146 == 0) && (_155 == 0))
            {
                _157 = _92[_169];
            }
            else
            {
                _157 = _140;
            }
            _154 = _145 + _92[_169];
            _152 = _143 + (_92[_169] * _92[_169]);
        }
    }
    vec3 _205 = min(_92[1], min(min(_92[3], _92[4]), min(_92[5], _92[7])));
    vec3 _228 = max(_92[1], max(max(_92[3], _92[4]), max(_92[5], _92[7])));
    vec3 _239 = _144 * vec3(0.111111111938953399658203125);
    vec3 _244 = sqrt((_142 * vec3(0.111111111938953399658203125)) - (_239 * _239)) * 1.25;
    vec3 _246 = min((_205 + min(_205, min(min(_92[0], _92[2]), min(_92[6], _92[8])))) * 0.5, _239 - _244);
    vec3 _248 = max((_228 + max(_228, max(max(_92[0], _92[2]), max(_92[6], _92[8])))) * 0.5, _239 + _244);
    bool _249 = _136 > 0.0;
    float _251 = _249 ? (-_136) : _137;
    vec2 _263 = textureLod(sampler2D(_DepthOfFieldDownMotionVectorTexture, s_point_clamp_sampler), _100, 0.0).xy;
    vec2 _270 = (abs(_263) * 2.0) - vec2(1.0);
    vec2 _271 = _270 * _270;
    vec4 _282 = textureLod(sampler2D(_DepthOfFieldDownPreviousSceneColorTexture, s_point_clamp_sampler), _100 - (((_271 * _271) * vec2(ivec2(sign(_263 - vec2(0.5))))) * (1.0 - _DepthOfFieldData._DepthOfFieldParam3.y)), 0.0);
    vec3 _283 = _282.xyz;
    float _284 = _282.w;
    vec3 _300 = (_248 + _246) * 0.5;
    vec3 _303 = _283 - _300;
    vec3 _306 = abs(_303 / max((_248 - _246) * 0.5, vec3(9.9999997473787516355514526367188e-05)));
    float _311 = max(_306.x, max(_306.y, _306.z));
    imageStore(_DepthOfFieldDownCoCRWTexture, ivec2(gl_GlobalInvocationID.xy), _135.xyyy);
    imageStore(_DepthOfFieldDownSceneColorRWTexture, ivec2(gl_GlobalInvocationID.xy), vec4(-min(-mix(_139, mix(_283, _300 + (_303 / vec3(max(_311, 9.9999997473787516355514526367188e-05))), bvec3(_311 > 1.0)), vec3(0.949999988079071044921875 * (((_251 * _284) <= 0.0) ? 0.0 : (exp(abs(_251 - _284) * (-10.0)) * (1.0 - exp((-(_249 ? (_136 * _DepthOfFieldData._DepthOfFieldParam1.z) : (_137 * _DepthOfFieldData._DepthOfFieldParam2.z))) * _DepthOfFieldData._DepthOfFieldParam0.w)))))), vec3(0.0)), _251));
}

