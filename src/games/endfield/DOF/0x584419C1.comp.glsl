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
    vec2 _81 = (vec2(gl_GlobalInvocationID.xy) + vec2(0.5)) * vec2(1.0/shader_injection.render_resolution_x, 1.0/shader_injection.render_resolution_y);
    vec2 _88 = vec2(1.0/shader_injection.render_resolution_x, 1.0/shader_injection.render_resolution_y) * (textureLod(sampler2D(_DepthOfFieldBlurTileCoCTexture, s_point_clamp_sampler), _81, 0.0).x * 0.25);
    float _90;
    vec2 _93;
    vec2 _95;
    vec2 _97;
    vec2 _99;
    _90 = 0.0;
    _93 = vec2(0.0);
    _95 = vec2(0.0);
    _97 = vec2(0.0);
    _99 = vec2(0.0);
    for (int _101 = -4; _101 <= 4; )
    {
        int _109 = _101 + 4;
        vec2 _112 = clamp(_81 + (_88 * vec2(0.0, float(_101))), vec2(9.9999997473787516355514526367188e-05), vec2(0.99989998340606689453125));
        vec4 _116 = textureLod(sampler2D(_DepthOfFieldOneComponentVerticalTexture0, s_linear_clamp_sampler), _112, 0.0);
        vec4 _120 = textureLod(sampler2D(_DepthOfFieldOneComponentVerticalTexture1, s_linear_clamp_sampler), _112, 0.0);
        float _126 = _116.x;
        float _127 = _120.x;
        float _137 = _116.y;
        float _138 = _120.y;
        float _146 = _116.z;
        float _147 = _120.z;
        float _155 = _116.w;
        float _156 = _120.w;
        _90 += textureLod(sampler2D(_DepthOfFieldOneComponentAlphaTexture, s_linear_clamp_sampler), _112, 0.0).x;
        _93 += vec2((_155 * _70[_109].x) - (_156 * _70[_109].y), (_155 * _70[_109].y) + (_156 * _70[_109].x));
        _95 += vec2((_146 * _70[_109].x) - (_147 * _70[_109].y), (_146 * _70[_109].y) + (_147 * _70[_109].x));
        _97 += vec2((_137 * _70[_109].x) - (_138 * _70[_109].y), (_137 * _70[_109].y) + (_138 * _70[_109].x));
        _99 += vec2((_126 * _70[_109].x) - (_127 * _70[_109].y), (_126 * _70[_109].y) + (_127 * _70[_109].x));
        _101++;
        continue;
    }
    imageStore(_DepthOfFieldOneComponentHorizontalRWTexture, ivec2(gl_GlobalInvocationID.xy), vec4(dot(_99, vec2(0.76758301258087158203125, 1.86232101917266845703125)), dot(_97, vec2(0.76758301258087158203125, 1.86232101917266845703125)), dot(_95, vec2(0.76758301258087158203125, 1.86232101917266845703125)), dot(_93, vec2(0.76758301258087158203125, 1.86232101917266845703125))));
    imageStore(_DepthOfFieldOneComponentAlphaRWTexture, ivec2(gl_GlobalInvocationID.xy), vec4(clamp(_90 * 0.1481481492519378662109375, 0.0, 1.0)));
}

