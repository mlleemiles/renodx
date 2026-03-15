#version 450
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

const vec4 _66[9] = vec4[](vec4(-0.00284199998714029788970947265625, 0.0525359995663166046142578125, 0.0, 0.0), vec4(0.0468490011990070343017578125, 0.0607610009610652923583984375, 0.0, 0.0), vec4(0.09228099882602691650390625, 0.0396930016577243804931640625, 0.0, 0.0), vec4(0.11747600138187408447265625, 0.011970999650657176971435546875, 0.0, 0.0), vec4(0.124623000621795654296875, 0.0, 0.0, 0.0), vec4(0.11747600138187408447265625, 0.011970999650657176971435546875, 0.0, 0.0), vec4(0.09228099882602691650390625, 0.0396930016577243804931640625, 0.0, 0.0), vec4(0.0468490011990070343017578125, 0.0607610009610652923583984375, 0.0, 0.0), vec4(-0.00284199998714029788970947265625, 0.0525359995663166046142578125, 0.0, 0.0));

layout(set = 1, binding = 0, std140) uniform type_DepthOfFieldData
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

layout(set = 0, binding = 5) uniform sampler s_point_clamp_sampler;
layout(set = 0, binding = 6) uniform sampler s_linear_clamp_sampler;
layout(set = 0, binding = 3) uniform texture2D _DepthOfFieldBlurTileCoCTexture;
layout(set = 0, binding = 4) uniform texture2D _DepthOfFieldDownNearColorTexture;
layout(set = 0, binding = 0, rgba16f) uniform writeonly image2D _DepthOfFieldOneComponentVerticalRWTexture0;
layout(set = 0, binding = 1, rgba16f) uniform writeonly image2D _DepthOfFieldOneComponentVerticalRWTexture1;
layout(set = 0, binding = 2, r32f) uniform writeonly image2D _DepthOfFieldOneComponentAlphaRWTexture;

void main()
{
    vec2 _76 = (vec2(gl_GlobalInvocationID.xy) + vec2(0.5)) * vec2(1.0/shader_injection.render_resolution_x, 1.0/shader_injection.render_resolution_y);
    vec2 _83 = vec2(1.0/shader_injection.render_resolution_x, 1.0/shader_injection.render_resolution_y) * (textureLod(sampler2D(_DepthOfFieldBlurTileCoCTexture, s_point_clamp_sampler), _76, 0.0).x * 0.25);
    float _85;
    vec4 _88;
    vec4 _90;
    _85 = 0.0;
    _88 = vec4(0.0);
    _90 = vec4(0.0);
    vec4 _89;
    vec4 _91;
    float _86;
    for (int _92 = -4; _92 <= 4; _85 = _86, _88 = _89, _90 = _91, _92++)
    {
        vec4 _105 = textureLod(sampler2D(_DepthOfFieldDownNearColorTexture, s_linear_clamp_sampler), clamp(_76 + (_83 * vec2(float(_92), 0.0)), vec2(9.9999997473787516355514526367188e-05), vec2(0.99989998340606689453125)), 0.0);
        float _108 = clamp(-_105.w, 0.0, 1.0);
        vec4 _109 = _105;
        _109.w = _108;
        if (_108 > 0.0)
        {
            _86 = _85 + 1.0;
        }
        else
        {
            _86 = _85;
        }
        int _114 = _92 + 4;
        _91 = _90 + (_109 * _66[_114].x);
        _89 = _88 + (_109 * _66[_114].y);
    }
    imageStore(_DepthOfFieldOneComponentVerticalRWTexture0, ivec2(gl_GlobalInvocationID.xy), _90);
    imageStore(_DepthOfFieldOneComponentVerticalRWTexture1, ivec2(gl_GlobalInvocationID.xy), _88);
    imageStore(_DepthOfFieldOneComponentAlphaRWTexture, ivec2(gl_GlobalInvocationID.xy), vec4(_85));
}

