#version 450
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

const vec4 _65[9] = vec4[](vec4(-0.00284199998714029788970947265625, 0.0525359995663166046142578125, 0.0, 0.0), vec4(0.0468490011990070343017578125, 0.0607610009610652923583984375, 0.0, 0.0), vec4(0.09228099882602691650390625, 0.0396930016577243804931640625, 0.0, 0.0), vec4(0.11747600138187408447265625, 0.011970999650657176971435546875, 0.0, 0.0), vec4(0.124623000621795654296875, 0.0, 0.0, 0.0), vec4(0.11747600138187408447265625, 0.011970999650657176971435546875, 0.0, 0.0), vec4(0.09228099882602691650390625, 0.0396930016577243804931640625, 0.0, 0.0), vec4(0.0468490011990070343017578125, 0.0607610009610652923583984375, 0.0, 0.0), vec4(-0.00284199998714029788970947265625, 0.0525359995663166046142578125, 0.0, 0.0));

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

layout(set = 0, binding = 4) uniform sampler s_point_clamp_sampler;
layout(set = 0, binding = 5) uniform sampler s_linear_clamp_sampler;
layout(set = 0, binding = 2) uniform texture2D _DepthOfFieldDownCoCTexture;
layout(set = 0, binding = 3) uniform texture2D _DepthOfFieldDownFarColorTexture;
layout(set = 0, binding = 0, rgba16f) uniform writeonly image2D _DepthOfFieldOneComponentVerticalRWTexture0;
layout(set = 0, binding = 1, rgba16f) uniform writeonly image2D _DepthOfFieldOneComponentVerticalRWTexture1;

void main()
{
    vec2 _76 = (vec2(gl_GlobalInvocationID.xy) + vec2(0.5)) * vec2(1.0/shader_injection.render_resolution_x, 1.0/shader_injection.render_resolution_y);
    vec4 _133;
    vec4 _134;
    do
    {
        vec4 _82 = textureLod(sampler2D(_DepthOfFieldDownCoCTexture, s_point_clamp_sampler), _76, 0.0);
        float _83 = _82.y;
        if (_83 == 0.0)
        {
            _133 = vec4(0.0);
            _134 = vec4(0.0);
            break;
        }
        vec2 _88 = vec2(1.0/shader_injection.render_resolution_x, 1.0/shader_injection.render_resolution_y) * (_83 * 0.25);
        vec4 _92 = textureLod(sampler2D(_DepthOfFieldDownFarColorTexture, s_linear_clamp_sampler), _76, 0.0);
        _92.w = clamp(_92.w, 0.0, 1.0);
        vec4 _97;
        vec4 _100;
        _97 = vec4(0.0);
        _100 = vec4(0.0);
        for (int _102 = -4; _102 <= 4; )
        {
            vec4 _114 = textureLod(sampler2D(_DepthOfFieldDownFarColorTexture, s_linear_clamp_sampler), clamp(_76 + (_88 * vec2(float(_102), 0.0)), vec2(9.9999997473787516355514526367188e-05), vec2(0.99989998340606689453125)), 0.0);
            float _116 = clamp(_114.w, 0.0, 1.0);
            vec4 _117 = _114;
            _117.w = _116;
            vec4 _125 = mix(_117, _92, bvec4((_116 == 0.0) || ((_116 * 4.0) < float(abs(_102)))));
            int _126 = _102 + 4;
            _97 += (_125 * _65[_126].y);
            _100 += (_125 * _65[_126].x);
            _102++;
            continue;
        }
        _133 = _97;
        _134 = _100;
        break;
    } while(false);
    imageStore(_DepthOfFieldOneComponentVerticalRWTexture0, ivec2(gl_GlobalInvocationID.xy), _134);
    imageStore(_DepthOfFieldOneComponentVerticalRWTexture1, ivec2(gl_GlobalInvocationID.xy), _133);
}

