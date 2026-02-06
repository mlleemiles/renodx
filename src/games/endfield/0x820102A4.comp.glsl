// AO blur x

#version 450
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(set = 1, binding = 0, std140) uniform type_GTAOData
{
    vec4 _GTAOParam0;
    vec4 _GTAOParam1;
    vec4 _GTAOParam2;
    vec4 _GTAOHalfScreenSize;
} _GTAOData;

layout(set = 0, binding = 4) uniform sampler s_point_clamp_sampler;
layout(set = 0, binding = 1) uniform texture2D _GTAODepthMIPs;
layout(set = 0, binding = 2) uniform texture2D _GTAOMainAOTermRT;
layout(set = 0, binding = 3) uniform texture2D _GTAOBlurAOTermInRT;
layout(set = 0, binding = 0, r8) uniform writeonly image2D _GTAOBlurAOTermOutRT;

// because the dispatch size is width/8, height/8, 1
// we don't have to worry about not fetch surrounding pixels, and do multiple passes

#include "./shared.h"

#define DenoiseBlurBeta shader_injection.ao_denoiser_blur_beta

void XeGTAO_DecodeGatherPartial( const vec4 packedValue, out float outDecoded[4] )
{

    outDecoded[0] = packedValue.x;
	outDecoded[1] = packedValue.y;
	outDecoded[2] = packedValue.z;
	outDecoded[3] = packedValue.w;

}

vec4 XeGTAO_UnpackEdges( float _packedVal )
{
    uint packedVal = uint(_packedVal * 255.5);
    vec4 edgesLRTB;
    edgesLRTB.x = float((packedVal >> 6) & 0x03) / 3.0;          // there's really no need for mask (as it's an 8 bit input) but I'll leave it in so it doesn't cause any trouble in the future
    edgesLRTB.y = float((packedVal >> 4) & 0x03) / 3.0;
    edgesLRTB.z = float((packedVal >> 2) & 0x03) / 3.0;
    edgesLRTB.w = float((packedVal >> 0) & 0x03) / 3.0;

    return clamp( edgesLRTB, 0.0, 1.0 );
}

void XeGTAO_AddSample( float ssaoValue, float edgeValue, inout float sum, inout float sumWeight )
{
    float weight = edgeValue;    

    sum += (weight * ssaoValue);
    sumWeight += weight;
}

void main()
{
	bool finalApply = false;
	
    const float blurAmount = (finalApply)?(DenoiseBlurBeta):(DenoiseBlurBeta/5.0);
    const float diagWeight = 0.85 * 0.5;
	
    float aoTerm[2];   // pixel pixCoordBase and pixel pixCoordBase + int2( 1, 0 )
    vec4 edgesC_LRTB[2];
    float weightTL[2];
    float weightTR[2];
    float weightBL[2];
    float weightBR[2];
	
    // gather edge and visibility quads, used later
    const vec2 gatherCenter = vec2(gl_GlobalInvocationID.xy) * _GTAOData._GTAOHalfScreenSize.zw;
	
	vec4 edgesQ0 = textureGatherOffset(
		sampler2D(_GTAOMainAOTermRT, s_point_clamp_sampler),
		gatherCenter,
		ivec2(0, 0),
		3
	);
	vec4 edgesQ1 = textureGatherOffset(
		sampler2D(_GTAOMainAOTermRT, s_point_clamp_sampler),
		gatherCenter,
		ivec2(2, 0),
		3
	);
	vec4 edgesQ2 = textureGatherOffset(
		sampler2D(_GTAOMainAOTermRT, s_point_clamp_sampler),
		gatherCenter,
		ivec2(1, 2),
		3
	);
	
	float visQ0[4];
	XeGTAO_DecodeGatherPartial
	(
		textureGatherOffset(
			sampler2D(_GTAOBlurAOTermInRT, s_point_clamp_sampler),
			gatherCenter,
			ivec2(0, 0),
			0
		),
		visQ0
	);
	float visQ1[4];
	XeGTAO_DecodeGatherPartial
	(
		textureGatherOffset(
			sampler2D(_GTAOBlurAOTermInRT, s_point_clamp_sampler),
			gatherCenter,
			ivec2(2, 0),
			0
		),
		visQ1
	);
	float visQ2[4];
	XeGTAO_DecodeGatherPartial
	(
		textureGatherOffset(
			sampler2D(_GTAOBlurAOTermInRT, s_point_clamp_sampler),
			gatherCenter,
			ivec2(0, 2),
			0
		),
		visQ2
	);
	float visQ3[4];
	XeGTAO_DecodeGatherPartial
	(
		textureGatherOffset(
			sampler2D(_GTAOBlurAOTermInRT, s_point_clamp_sampler),
			gatherCenter,
			ivec2(2, 2),
			0
		),
		visQ3
	);
	
    for( int side = 0; side < 2; side++ )
    {
        const ivec2 pixCoord = ivec2( gl_GlobalInvocationID.x + side, gl_GlobalInvocationID.y );

        vec4 edgesL_LRTB  = XeGTAO_UnpackEdges( (side==0)?(edgesQ0.x):(edgesQ0.y) );
        vec4 edgesT_LRTB  = XeGTAO_UnpackEdges( (side==0)?(edgesQ0.z):(edgesQ1.w) );
        vec4 edgesR_LRTB  = XeGTAO_UnpackEdges( (side==0)?(edgesQ1.x):(edgesQ1.y) );
        vec4 edgesB_LRTB  = XeGTAO_UnpackEdges( (side==0)?(edgesQ2.w):(edgesQ2.z) );
		
		edgesC_LRTB[side]     = XeGTAO_UnpackEdges( (side==0)?(edgesQ0.y):(edgesQ1.x) );
		
        // Edges aren't perfectly symmetrical: edge detection algorithm does not guarantee that a left edge on the right pixel will match the right edge on the left pixel (although
        // they will match in majority of cases). This line further enforces the symmetricity, creating a slightly sharper blur. Works real nice with TAA.
        edgesC_LRTB[side] *= vec4( edgesL_LRTB.y, edgesR_LRTB.x, edgesT_LRTB.w, edgesB_LRTB.z );
		
#if 1   // this allows some small amount of AO leaking from neighbours if there are 3 or 4 edges; this reduces both spatial and temporal aliasing
        const float leak_threshold = 2.5;
		const float leak_strength = 0.5;
        float edginess = (clamp(4.0 - leak_threshold - dot( edgesC_LRTB[side], vec4(1.0) ), 0.0, 1.0) / (4.0-leak_threshold)) * leak_strength;
        edgesC_LRTB[side] = clamp( edgesC_LRTB[side] + edginess, 0.0, 1.0 );
#endif

        // for diagonals; used by first and second pass
        weightTL[side] = diagWeight * (edgesC_LRTB[side].x * edgesL_LRTB.z + edgesC_LRTB[side].z * edgesT_LRTB.x);
        weightTR[side] = diagWeight * (edgesC_LRTB[side].z * edgesT_LRTB.y + edgesC_LRTB[side].y * edgesR_LRTB.z);
        weightBL[side] = diagWeight * (edgesC_LRTB[side].w * edgesB_LRTB.x + edgesC_LRTB[side].x * edgesL_LRTB.w);
        weightBR[side] = diagWeight * (edgesC_LRTB[side].y * edgesR_LRTB.w + edgesC_LRTB[side].w * edgesB_LRTB.y);
		
        // first pass
        float ssaoValue     = (side==0)?(visQ0[1]):(visQ1[0]);
        float ssaoValueL    = (side==0)?(visQ0[0]):(visQ0[1]);
        float ssaoValueT    = (side==0)?(visQ0[2]):(visQ1[3]);
        float ssaoValueR    = (side==0)?(visQ1[0]):(visQ1[1]);
        float ssaoValueB    = (side==0)?(visQ2[2]):(visQ3[3]);
        float ssaoValueTL   = (side==0)?(visQ0[3]):(visQ0[2]);
        float ssaoValueBR   = (side==0)?(visQ3[3]):(visQ3[2]);
        float ssaoValueTR   = (side==0)?(visQ1[3]):(visQ1[2]);
        float ssaoValueBL   = (side==0)?(visQ2[3]):(visQ2[2]);
		
        float sumWeight = blurAmount;
        float sum = ssaoValue * sumWeight;
		
        XeGTAO_AddSample( ssaoValueL, edgesC_LRTB[side].x, sum, sumWeight );
        XeGTAO_AddSample( ssaoValueR, edgesC_LRTB[side].y, sum, sumWeight );
        XeGTAO_AddSample( ssaoValueT, edgesC_LRTB[side].z, sum, sumWeight );
        XeGTAO_AddSample( ssaoValueB, edgesC_LRTB[side].w, sum, sumWeight );

        XeGTAO_AddSample( ssaoValueTL, weightTL[side], sum, sumWeight );
        XeGTAO_AddSample( ssaoValueTR, weightTR[side], sum, sumWeight );
        XeGTAO_AddSample( ssaoValueBL, weightBL[side], sum, sumWeight );
        XeGTAO_AddSample( ssaoValueBR, weightBR[side], sum, sumWeight );

        aoTerm[side] = sum / sumWeight;
		imageStore(_GTAOBlurAOTermOutRT, pixCoord, vec4(aoTerm[side]));
	}

/*
    vec2 _49 = (vec2(gl_GlobalInvocationID.xy) + vec2(0.5)) * _GTAOData._GTAOHalfScreenSize.zw;
    float _57 = clamp((1.0 - textureLod(sampler2D(_GTAOMainAOTermRT, s_point_clamp_sampler), _49, 0.0).z * 4.0) * 2.0, 0.0, 1.0);
	
    vec4 _61 = textureLod(sampler2D(_GTAODepthMIPs, s_point_clamp_sampler), _49, 0.0);
	
	float motionVecLength = textureLod(sampler2D(_GTAOMainAOTermRT, s_point_clamp_sampler), _49, 0.0).w;
	
    float _62 = _61.x;
    float _64;
    float _67;
    _64 = 0.0;
    _67 = 0.0;
    for (float _69 = -3.0; _69 <= 3.0; )
    {
        vec2 _75 = ((vec2(1.0, 0.0) * _69) * _GTAOData._GTAOHalfScreenSize.zw) * _57;
		
		float zdiff = abs(textureLod(sampler2D(_GTAODepthMIPs, s_point_clamp_sampler), _49 + _75, 0.0).x - _62);
		
		float sampleZ = textureLod(sampler2D(_GTAODepthMIPs, s_point_clamp_sampler), __49 + _75, 0.0).x;
		float zDiffFactor = pow( 1.0 / (1.0 + abs(sampleZ / _62 - 1.0)), 80.f);
		
		float motionVecLengthSamp = textureLod(sampler2D(_GTAOMainAOTermRT, s_point_clamp_sampler),_49 + _75, 0.0).w;
		
		float vDiff = abs(motionVecLength - motionVecLengthSamp);
		float vDiffFacotr = clamp(exp(-vDiff/0.2), 0.0, 1.0);
		
        float _92 = zDiffFactor * vDiffFacotr;//1.0 - clamp(zdiff, 0.0, 1.0);
        _64 += _92;
        _67 += (textureLod(sampler2D(_GTAOBlurAOTermInRT, s_point_clamp_sampler), _49 + _75, 0.0).x * _92);
        _69 += 1.0;
        continue;
    }
    imageStore(_GTAOBlurAOTermOutRT, ivec2(gl_GlobalInvocationID.xy), vec4(_67 / max(_64, 9.9999997473787516355514526367188e-05)));
*/
}

