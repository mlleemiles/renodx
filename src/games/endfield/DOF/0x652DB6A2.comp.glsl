#version 450
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

vec2 _41;

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
layout(set = 0, binding = 1) uniform texture2D _DepthOfFieldDownCoCTexture;
layout(set = 0, binding = 0, r32f) uniform writeonly image2D _DepthOfFieldTileCoCRWTexture;

void main()
{
    vec2 _50 = (vec2(gl_GlobalInvocationID.xy) + vec2(0.5)) * _DepthOfFieldData._DepthOfFieldTileScreenSize.zw;
    vec2 _51;
    _51.y = -16.0;
    vec4 _53;
    vec2 _56;
    _53 = vec4(0.0);
    _56 = _51;
    vec2 _57;
    vec4 _54;
    vec2 _66;
    for (; _56.y <= 17.0; _57 = _66, _57.y = _66.y + 7.920000553131103515625, _53 = _54, _56 = _57)
    {
        vec2 _62 = _56;
        _62.x = -16.0;
        _54 = _53;
        _66 = _62;
        for (; _66.x <= 17.0; )
        {
            vec2 _67 = _66;
            _67.x = _66.x + 7.920000553131103515625;
            _54 = max(_54, textureGatherOffset(sampler2D(_DepthOfFieldDownCoCTexture, s_point_clamp_sampler), _50 + (_66 * vec2(1.0/shader_injection.render_resolution_x, 1.0/shader_injection.render_resolution_y)), ivec2(0)));
            _66 = _67;
            continue;
        }
    }
    imageStore(_DepthOfFieldTileCoCRWTexture, ivec2(gl_GlobalInvocationID.xy), vec4(max(_53.x, max(_53.y, max(_53.z, _53.w)))));
}

