#ifndef SAMPLE_DATA_INCLUDED
#define SAMPLE_DATA_INCLUDED

struct VertexInput
{
	float2 uv : TEXCOORD0;
	float4 positionOS : POSITION;
	float3 normalOS : NORMAL;
	float4 tangentOS : TANGENT;
};

struct VertexOutput
{
	float2 uv : TEXCOORD0;
	float3 positionWS : TEXCOORD1;
	float4 positionCS : SV_POSITION;
	half3 lightAmount : TEXCOORD2;
	float3 normalWS : TEXCOORD3;
	float4 tangentWS : TEXCOORD4;
};

#endif