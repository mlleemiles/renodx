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

layout(set = 0, binding = 2) uniform sampler s_linear_clamp_sampler;
layout(set = 0, binding = 1) uniform texture2D _DepthOfFieldOneComponentAlphaTexture;
layout(set = 0, binding = 0, r32f) uniform writeonly image2D _DepthOfFieldOneComponentAlphaRWTexture;

void main()
{
    vec2 _39 = vec2(gl_GlobalInvocationID.xy) + vec2(0.5);
    float _44;
    _44 = 0.0;
    for (int _47 = -4; _47 <= 4; )
    {
        _44 += textureLod(sampler2D(_DepthOfFieldOneComponentAlphaTexture, s_linear_clamp_sampler), vec2(1.0/shader_injection.render_resolution_x, 1.0/shader_injection.render_resolution_y) * (_39 + vec2(0.0, float(_47))), 0.0).x;
        _47++;
        continue;
    }
    imageStore(_DepthOfFieldOneComponentAlphaRWTexture, ivec2(gl_GlobalInvocationID.xy), vec4(_44 * 0.111111111938953399658203125));
}

