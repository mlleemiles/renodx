#version 450
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

const vec4 _72[9] = vec4[](vec4(-0.00284199998714029788970947265625, 0.0525359995663166046142578125, 0.0, 0.0), vec4(0.0468490011990070343017578125, 0.0607610009610652923583984375, 0.0, 0.0), vec4(0.09228099882602691650390625, 0.0396930016577243804931640625, 0.0, 0.0), vec4(0.11747600138187408447265625, 0.011970999650657176971435546875, 0.0, 0.0), vec4(0.124623000621795654296875, 0.0, 0.0, 0.0), vec4(0.11747600138187408447265625, 0.011970999650657176971435546875, 0.0, 0.0), vec4(0.09228099882602691650390625, 0.0396930016577243804931640625, 0.0, 0.0), vec4(0.0468490011990070343017578125, 0.0607610009610652923583984375, 0.0, 0.0), vec4(-0.00284199998714029788970947265625, 0.0525359995663166046142578125, 0.0, 0.0));

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

layout(set = 0, binding = 6) uniform sampler s_point_clamp_sampler;
layout(set = 0, binding = 7) uniform sampler s_linear_clamp_sampler;
layout(set = 0, binding = 2) uniform texture2D _DepthOfFieldBlurTileCoCTexture;
layout(set = 0, binding = 3) uniform texture2D _DepthOfFieldOneComponentVerticalTexture0;
layout(set = 0, binding = 4) uniform texture2D _DepthOfFieldOneComponentVerticalTexture1;
layout(set = 0, binding = 5) uniform texture2D _DepthOfFieldOneComponentAlphaTexture;
layout(set = 0, binding = 0, rgba16f) uniform writeonly image2D _DepthOfFieldOneComponentHorizontalRWTexture;
layout(set = 0, binding = 1, r32f) uniform writeonly image2D _DepthOfFieldOneComponentAlphaRWTexture;

void main()
{
    vec2 _83 = (vec2(gl_GlobalInvocationID.xy) + vec2(0.5)) * vec2(1.0/shader_injection.render_resolution_x, 1.0/shader_injection.render_resolution_y);
    vec2 _93 = vec2(1.0/shader_injection.render_resolution_x, 1.0/shader_injection.render_resolution_y) * ((textureLod(sampler2D(_DepthOfFieldBlurTileCoCTexture, s_point_clamp_sampler), _83, 0.0).x * _DepthOfFieldData._DepthOfFieldParam1.z) * 0.25);
    float _95;
    vec2 _98;
    vec2 _100;
    vec2 _102;
    vec2 _104;
    _95 = 0.0;
    _98 = vec2(0.0);
    _100 = vec2(0.0);
    _102 = vec2(0.0);
    _104 = vec2(0.0);
    for (int _106 = -4; _106 <= 4; )
    {
        int _114 = _106 + 4;
        vec2 _117 = clamp(_83 + (_93 * vec2(0.0, float(_106))), vec2(9.9999997473787516355514526367188e-05), vec2(0.99989998340606689453125));
        vec4 _121 = textureLod(sampler2D(_DepthOfFieldOneComponentVerticalTexture0, s_linear_clamp_sampler), _117, 0.0);
        vec4 _125 = textureLod(sampler2D(_DepthOfFieldOneComponentVerticalTexture1, s_linear_clamp_sampler), _117, 0.0);
        float _131 = _121.x;
        float _132 = _125.x;
        float _142 = _121.y;
        float _143 = _125.y;
        float _151 = _121.z;
        float _152 = _125.z;
        float _160 = _121.w;
        float _161 = _125.w;
        _95 += textureLod(sampler2D(_DepthOfFieldOneComponentAlphaTexture, s_linear_clamp_sampler), _117, 0.0).x;
        _98 += vec2((_160 * _72[_114].x) - (_161 * _72[_114].y), (_160 * _72[_114].y) + (_161 * _72[_114].x));
        _100 += vec2((_151 * _72[_114].x) - (_152 * _72[_114].y), (_151 * _72[_114].y) + (_152 * _72[_114].x));
        _102 += vec2((_142 * _72[_114].x) - (_143 * _72[_114].y), (_142 * _72[_114].y) + (_143 * _72[_114].x));
        _104 += vec2((_131 * _72[_114].x) - (_132 * _72[_114].y), (_131 * _72[_114].y) + (_132 * _72[_114].x));
        _106++;
        continue;
    }
    imageStore(_DepthOfFieldOneComponentHorizontalRWTexture, ivec2(gl_GlobalInvocationID.xy), vec4(dot(_104, vec2(0.76758301258087158203125, 1.86232101917266845703125)), dot(_102, vec2(0.76758301258087158203125, 1.86232101917266845703125)), dot(_100, vec2(0.76758301258087158203125, 1.86232101917266845703125)), dot(_98, vec2(0.76758301258087158203125, 1.86232101917266845703125))));
    imageStore(_DepthOfFieldOneComponentAlphaRWTexture, ivec2(gl_GlobalInvocationID.xy), vec4(clamp(_95 * 0.1481481492519378662109375, 0.0, 1.0)));
}

