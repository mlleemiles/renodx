#version 450
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

const vec4 _70[9] = vec4[](vec4(-0.00284199998714029788970947265625, 0.0525359995663166046142578125, 0.0, 0.0), vec4(0.0468490011990070343017578125, 0.0607610009610652923583984375, 0.0, 0.0), vec4(0.09228099882602691650390625, 0.0396930016577243804931640625, 0.0, 0.0), vec4(0.11747600138187408447265625, 0.011970999650657176971435546875, 0.0, 0.0), vec4(0.124623000621795654296875, 0.0, 0.0, 0.0), vec4(0.11747600138187408447265625, 0.011970999650657176971435546875, 0.0, 0.0), vec4(0.09228099882602691650390625, 0.0396930016577243804931640625, 0.0, 0.0), vec4(0.0468490011990070343017578125, 0.0607610009610652923583984375, 0.0, 0.0), vec4(-0.00284199998714029788970947265625, 0.0525359995663166046142578125, 0.0, 0.0));

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
layout(set = 0, binding = 1) uniform texture2D _DepthOfFieldDownCoCTexture;
layout(set = 0, binding = 2) uniform texture2D _DepthOfFieldDownFarColorTexture;
layout(set = 0, binding = 3) uniform texture2D _DepthOfFieldOneComponentVerticalTexture0;
layout(set = 0, binding = 4) uniform texture2D _DepthOfFieldOneComponentVerticalTexture1;
layout(set = 0, binding = 0, rgba16f) uniform writeonly image2D _DepthOfFieldOneComponentHorizontalRWTexture;

void main()
{
    vec2 _81 = (vec2(gl_GlobalInvocationID.xy) + vec2(0.5)) * vec2(1.0/shader_injection.render_resolution_x, 1.0/shader_injection.render_resolution_y);
    vec2 _91 = vec2(1.0/shader_injection.render_resolution_x, 1.0/shader_injection.render_resolution_y) * ((textureLod(sampler2D(_DepthOfFieldDownCoCTexture, s_point_clamp_sampler), _81, 0.0).y * _DepthOfFieldData._DepthOfFieldParam2.z) * 0.25);
    vec2 _93;
    vec2 _96;
    vec2 _98;
    vec2 _100;
    _93 = vec2(0.0);
    _96 = vec2(0.0);
    _98 = vec2(0.0);
    _100 = vec2(0.0);
    for (int _102 = -4; _102 <= 4; )
    {
        int _110 = _102 + 4;
        vec2 _113 = clamp(_81 + (_91 * vec2(0.0, float(_102))), vec2(9.9999997473787516355514526367188e-05), vec2(0.99989998340606689453125));
        float _119 = clamp(textureLod(sampler2D(_DepthOfFieldDownFarColorTexture, s_linear_clamp_sampler), _113, 0.0).w, 0.0, 1.0);
        vec2 _127 = mix(_113, _81, bvec2((_119 == 0.0) || ((_119 * 4.0) < float(abs(_102)))));
        vec4 _131 = textureLod(sampler2D(_DepthOfFieldOneComponentVerticalTexture0, s_linear_clamp_sampler), _127, 0.0);
        vec4 _135 = textureLod(sampler2D(_DepthOfFieldOneComponentVerticalTexture1, s_linear_clamp_sampler), _127, 0.0);
        float _136 = _131.x;
        float _137 = _135.x;
        float _147 = _131.y;
        float _148 = _135.y;
        float _156 = _131.z;
        float _157 = _135.z;
        float _165 = _131.w;
        float _166 = _135.w;
        _93 += vec2((_165 * _70[_110].x) - (_166 * _70[_110].y), (_165 * _70[_110].y) + (_166 * _70[_110].x));
        _96 += vec2((_156 * _70[_110].x) - (_157 * _70[_110].y), (_156 * _70[_110].y) + (_157 * _70[_110].x));
        _98 += vec2((_147 * _70[_110].x) - (_148 * _70[_110].y), (_147 * _70[_110].y) + (_148 * _70[_110].x));
        _100 += vec2((_136 * _70[_110].x) - (_137 * _70[_110].y), (_136 * _70[_110].y) + (_137 * _70[_110].x));
        _102++;
        continue;
    }
    imageStore(_DepthOfFieldOneComponentHorizontalRWTexture, ivec2(gl_GlobalInvocationID.xy), vec4(dot(_100, vec2(0.76758301258087158203125, 1.86232101917266845703125)), dot(_98, vec2(0.76758301258087158203125, 1.86232101917266845703125)), dot(_96, vec2(0.76758301258087158203125, 1.86232101917266845703125)), dot(_93, vec2(0.76758301258087158203125, 1.86232101917266845703125))));
}

