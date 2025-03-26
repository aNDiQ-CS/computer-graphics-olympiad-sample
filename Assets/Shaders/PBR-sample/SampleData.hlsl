#ifndef SAMPLE_DATA_INCLUDED
#define SAMPLE_DATA_INCLUDED

struct VertexInput
{
	float2 uv : TEXCOORD0;
	float4 positionOS : POSITION;
};

struct VertexOutput
{
	float2 uv : TEXCOORD0;
	float3 positionWS : TEXCOORD1;
	float4 positionCS : SV_POSITION;
};

#endif