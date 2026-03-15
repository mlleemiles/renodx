#version 450
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

const vec4 _68[9] = vec4[](vec4(-0.00284199998714029788970947265625, 0.0525359995663166046142578125, 0.0, 0.0), vec4(0.0468490011990070343017578125, 0.0607610009610652923583984375, 0.0, 0.0), vec4(0.09228099882602691650390625, 0.0396930016577243804931640625, 0.0, 0.0), vec4(0.11747600138187408447265625, 0.011970999650657176971435546875, 0.0, 0.0), vec4(0.124623000621795654296875, 0.0, 0.0, 0.0), vec4(0.11747600138187408447265625, 0.011970999650657176971435546875, 0.0, 0.0), vec4(0.09228099882602691650390625, 0.0396930016577243804931640625, 0.0, 0.0), vec4(0.0468490011990070343017578125, 0.0607610009610652923583984375, 0.0, 0.0), vec4(-0.00284199998714029788970947265625, 0.0525359995663166046142578125, 0.0, 0.0));

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
    vec2 _79 = (vec2(gl_GlobalInvocationID.xy) + vec2(0.5)) * vec2(1.0/shader_injection.render_resolution_x, 1.0/shader_injection.render_resolution_y);
    vec2 _86 = vec2(1.0/shader_injection.render_resolution_x, 1.0/shader_injection.render_resolution_y) * (textureLod(sampler2D(_DepthOfFieldDownCoCTexture, s_point_clamp_sampler), _79, 0.0).y * 0.25);
    vec2 _88;
    vec2 _91;
    vec2 _93;
    vec2 _95;
    _88 = vec2(0.0);
    _91 = vec2(0.0);
    _93 = vec2(0.0);
    _95 = vec2(0.0);
    for (int _97 = -4; _97 <= 4; )
    {
        int _105 = _97 + 4;
        vec2 _108 = clamp(_79 + (_86 * vec2(0.0, float(_97))), vec2(9.9999997473787516355514526367188e-05), vec2(0.99989998340606689453125));
        float _114 = clamp(textureLod(sampler2D(_DepthOfFieldDownFarColorTexture, s_linear_clamp_sampler), _108, 0.0).w, 0.0, 1.0);
        vec2 _122 = mix(_108, _79, bvec2((_114 == 0.0) || ((_114 * 4.0) < float(abs(_97)))));
        vec4 _126 = textureLod(sampler2D(_DepthOfFieldOneComponentVerticalTexture0, s_linear_clamp_sampler), _122, 0.0);
        vec4 _130 = textureLod(sampler2D(_DepthOfFieldOneComponentVerticalTexture1, s_linear_clamp_sampler), _122, 0.0);
        float _131 = _126.x;
        float _132 = _130.x;
        float _142 = _126.y;
        float _143 = _130.y;
        float _151 = _126.z;
        float _152 = _130.z;
        float _160 = _126.w;
        float _161 = _130.w;
        _88 += vec2((_160 * _68[_105].x) - (_161 * _68[_105].y), (_160 * _68[_105].y) + (_161 * _68[_105].x));
        _91 += vec2((_151 * _68[_105].x) - (_152 * _68[_105].y), (_151 * _68[_105].y) + (_152 * _68[_105].x));
        _93 += vec2((_142 * _68[_105].x) - (_143 * _68[_105].y), (_142 * _68[_105].y) + (_143 * _68[_105].x));
        _95 += vec2((_131 * _68[_105].x) - (_132 * _68[_105].y), (_131 * _68[_105].y) + (_132 * _68[_105].x));
        _97++;
        continue;
    }
    imageStore(_DepthOfFieldOneComponentHorizontalRWTexture, ivec2(gl_GlobalInvocationID.xy), vec4(dot(_95, vec2(0.76758301258087158203125, 1.86232101917266845703125)), dot(_93, vec2(0.76758301258087158203125, 1.86232101917266845703125)), dot(_91, vec2(0.76758301258087158203125, 1.86232101917266845703125)), dot(_88, vec2(0.76758301258087158203125, 1.86232101917266845703125))));
}

