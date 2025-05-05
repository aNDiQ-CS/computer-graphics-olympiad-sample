#ifndef WAVE_DATA_HLSL
#define WAVE_DATA_HLSL

struct VertexInput
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float2 uv : TEXCOORD0;
};

struct VertexOutput
{
    float4 vertex : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 worldPos : TEXCOORD1;
    float displacement : TEXCOORD2;
    float foamFactor : TEXCOORD3;
};

#endif