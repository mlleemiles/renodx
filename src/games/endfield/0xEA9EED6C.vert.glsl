#version 450

float _71;

#include "./shared.h"

layout(set = 3, binding = 3, std140) uniform _12_13
{
    vec4 _m0;
    vec4 _m1;
    vec4 _m2;
    vec4 _m3;
    vec4 _m4;
    vec4 _m5;
    vec4 _m6;
    vec4 _m7;
    vec4 _m8;
} _13;

layout(set = 2, binding = 0, std140) uniform _14_15
{
    layout(row_major) mat4 _m0;
    vec4 _m1;
    vec4 _m2;
    vec4 _m3;
} _15;

layout(set = 3, binding = 2, std140) uniform _16_17
{
    vec4 _m0;
    vec4 _m1;
    vec4 _m2;
    vec4 _m3;
    vec4 _m4;
    layout(row_major) mat4 _m5;
    layout(row_major) mat4 _m6;
    layout(row_major) mat4 _m7;
    layout(row_major) mat4 _m8;
    int _m9;
    vec4 _m10;
} _17;

layout(set = 3, binding = 4, std140) uniform _18_19
{
    vec4 _m0;
    vec4 _m1;
    vec4 _m2;
    vec4 _m3;
    vec4 _m4;
    vec4 _m5;
    vec4 _m6;
    vec4 _m7;
    vec4 _m8;
    float _m9;
    float _m10;
    float _m11;
    float _m12;
    float _m13;
    float _m14;
    float _m15;
} _19;

layout(set = 3, binding = 1, std140) uniform _20_21
{
    float _m0;
    float _m1;
    float _m2;
    float _m3;
} _21;

layout(set = 3, binding = 0, std140) uniform _22_23
{
    layout(row_major) mat4 _m0;
    layout(row_major) mat4 _m1;
    layout(row_major) mat4 _m2;
    layout(row_major) mat4 _m3;
    layout(row_major) mat4 _m4;
    layout(row_major) mat4 _m5;
    layout(row_major) mat4 _m6;
    layout(row_major) mat4 _m7;
    layout(row_major) mat4 _m8;
    layout(row_major) mat4 _m9;
    layout(row_major) mat4 _m10;
    vec4 _m11;
} _23;

layout(location = 0) in vec4 _3;
layout(location = 1) in vec4 _4;
layout(location = 2) in vec2 _5;
layout(location = 0) out vec4 _7;
layout(location = 1) out vec2 _8;


void main()
{
    bool _94 = _21._m0 > 0.0;
    vec4 _170;
    vec4 _171;
    vec4 _172;
    vec4 _173;
	
	const vec2 verts[12] = vec2[12](
		vec2(-1167.0001220703, -653.4990234375),
		vec2(-1167.0001220703, -644.4990234375),
		vec2(-1162.0001220703, -644.4990234375),
		vec2(-1162.0001220703, -653.4990234375),
		vec2(-1160.5, -653.4990234375),
		vec2(-1160.5, -640.4990234375),
		vec2(-1155.5, -640.4990234375),
		vec2(-1155.5, -653.4990234375),
		vec2(-1154.0, -653.4990234375),
		vec2(-1154.0, -636.4990234375),
		vec2(-1149.0, -636.4990234375),
		vec2(-1149.0, -653.4990234375)
	);
    
	if (shader_injection.ui_disable_flag != 0.0)
	{
		vec2 vertexDist = abs(verts[gl_VertexIndex] - _3.xy);

		if (dot(vertexDist, vertexDist) < 0.000001)
		{
			return;
		}
	}
	
    
    if (_94)
    {
        _170 = vec4(_23._m8[3].x, _23._m8[3].y, _23._m8[3].z, _23._m8[3].w);
        _171 = vec4(_23._m8[2].x, _23._m8[2].y, _23._m8[2].z, _23._m8[2].w);
        _172 = vec4(_23._m8[1].x, _23._m8[1].y, _23._m8[1].z, _23._m8[1].w);
        _173 = vec4(_23._m8[0].x, _23._m8[0].y, _23._m8[0].z, _23._m8[0].w);
    }
    else
    {
        _170 = vec4(_17._m8[3].x, _17._m8[3].y, _17._m8[3].z, _17._m8[3].w);
        _171 = vec4(_17._m8[2].x, _17._m8[2].y, _17._m8[2].z, _17._m8[2].w);
        _172 = vec4(_17._m8[1].x, _17._m8[1].y, _17._m8[1].z, _17._m8[1].w);
        _173 = vec4(_17._m8[0].x, _17._m8[0].y, _17._m8[0].z, _17._m8[0].w);
    }
    vec4 _179 = vec4(vec3((vec4(_3.xyz, 1.0) * _15._m0).xyz) - (_23._m11.xyz * _21._m0), 1.0) * mat4(_173, _172, _171, _170);
    vec4 _196;
    if (_94)
    {
        vec4 _188 = _179;
        _188.x = _179.x * (1.0 - (_21._m1 * 2.0));
        _188.y = _179.y * (1.0 - (_21._m2 * 2.0));
        _196 = _188;
    }
    else
    {
        _196 = _179;
    }
    vec4 _197 = _196 * 0.5;
    vec2 _206 = vec2(_197.x, _197.y * _13._m5.x) + vec2(_197.w);
    vec4 _233;
    vec4 _234;
    if (_94)
    {
        _233 = vec4(_23._m2[1].x, _23._m2[1].y, _71, _71);
        _234 = vec4(_23._m2[0].x, _23._m2[0].y, _71, _71);
    }
    else
    {
        _233 = vec4(_17._m5[1].x, _17._m5[1].y, _71, _71);
        _234 = vec4(_17._m5[0].x, _17._m5[0].y, _71, _71);
    }
    vec4 _246 = clamp(_19._m4, vec4(-20000000000.0), vec4(20000000000.0));
    vec4 _275 = _4 * _19._m2;
    bool _278 = _19._m12 != 0.0;
    vec3 _283 = _275.xyz * (_278 ? _19._m13 : 1.0);
    vec4 _284 = vec4(_283.x, _283.y, _283.z, _275.w);
    _284.w = _275.w * (_278 ? _19._m14 : 1.0);
    vec4 _293 = _196;
    _293.y = -_196.y;
    gl_Position = _293;
    _7 = _284;
    _8 = (_5 * _19._m5.xy) + _19._m5.zw;
}