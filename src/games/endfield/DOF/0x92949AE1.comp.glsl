#version 450
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

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

layout(set = 0, binding = 2) uniform sampler s_point_clamp_sampler;
layout(set = 0, binding = 1) uniform texture2D _DepthOfFieldTileCoCTexture;
layout(set = 0, binding = 0, r32f) uniform writeonly image2D _DepthOfFieldBlurTileCoCRWTexture;

void main()
{
    vec2 _39 = vec2(gl_GlobalInvocationID.xy) + vec2(0.5);
    float _44;
    int _47;
    _44 = 0.0;
    _47 = -1;
    float _45;
    for (; _47 <= 1; _44 = _45, _47++)
    {
        _45 = _44;
        for (int _55 = -1; _55 <= 1; )
        {
            _45 += textureLod(sampler2D(_DepthOfFieldTileCoCTexture, s_point_clamp_sampler), _DepthOfFieldData._DepthOfFieldTileScreenSize.zw * (_39 + vec2(float(_55), float(_47))), 0.0).x;
            _55++;
            continue;
        }
    }
    imageStore(_DepthOfFieldBlurTileCoCRWTexture, ivec2(gl_GlobalInvocationID.xy), vec4(_44 * 0.111111111938953399658203125));
}

