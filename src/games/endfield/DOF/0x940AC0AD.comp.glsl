#version 450
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

const vec4 _67[9] = vec4[](vec4(-0.00284199998714029788970947265625, 0.0525359995663166046142578125, 0.0, 0.0), vec4(0.0468490011990070343017578125, 0.0607610009610652923583984375, 0.0, 0.0), vec4(0.09228099882602691650390625, 0.0396930016577243804931640625, 0.0, 0.0), vec4(0.11747600138187408447265625, 0.011970999650657176971435546875, 0.0, 0.0), vec4(0.124623000621795654296875, 0.0, 0.0, 0.0), vec4(0.11747600138187408447265625, 0.011970999650657176971435546875, 0.0, 0.0), vec4(0.09228099882602691650390625, 0.0396930016577243804931640625, 0.0, 0.0), vec4(0.0468490011990070343017578125, 0.0607610009610652923583984375, 0.0, 0.0), vec4(-0.00284199998714029788970947265625, 0.0525359995663166046142578125, 0.0, 0.0));

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
    vec2 _78 = (vec2(gl_GlobalInvocationID.xy) + vec2(0.5)) * vec2(1.0/shader_injection.render_resolution_x, 1.0/shader_injection.render_resolution_y);
    vec4 _138;
    vec4 _139;
    do
    {
        vec4 _84 = textureLod(sampler2D(_DepthOfFieldDownCoCTexture, s_point_clamp_sampler), _78, 0.0);
        float _85 = _84.y;
        if (_85 == 0.0)
        {
            _138 = vec4(0.0);
            _139 = vec4(0.0);
            break;
        }
        vec2 _93 = vec2(1.0/shader_injection.render_resolution_x, 1.0/shader_injection.render_resolution_y) * ((_85 * _DepthOfFieldData._DepthOfFieldParam2.z) * 0.25);
        vec4 _97 = textureLod(sampler2D(_DepthOfFieldDownFarColorTexture, s_linear_clamp_sampler), _78, 0.0);
        _97.w = clamp(_97.w, 0.0, 1.0);
        vec4 _102;
        vec4 _105;
        _102 = vec4(0.0);
        _105 = vec4(0.0);
        for (int _107 = -4; _107 <= 4; )
        {
            vec4 _119 = textureLod(sampler2D(_DepthOfFieldDownFarColorTexture, s_linear_clamp_sampler), clamp(_78 + (_93 * vec2(float(_107), 0.0)), vec2(9.9999997473787516355514526367188e-05), vec2(0.99989998340606689453125)), 0.0);
            float _121 = clamp(_119.w, 0.0, 1.0);
            vec4 _122 = _119;
            _122.w = _121;
            vec4 _130 = mix(_122, _97, bvec4((_121 == 0.0) || ((_121 * 4.0) < float(abs(_107)))));
            int _131 = _107 + 4;
            _102 += (_130 * _67[_131].y);
            _105 += (_130 * _67[_131].x);
            _107++;
            continue;
        }
        _138 = _102;
        _139 = _105;
        break;
    } while(false);
    imageStore(_DepthOfFieldOneComponentVerticalRWTexture0, ivec2(gl_GlobalInvocationID.xy), _139);
    imageStore(_DepthOfFieldOneComponentVerticalRWTexture1, ivec2(gl_GlobalInvocationID.xy), _138);
}

