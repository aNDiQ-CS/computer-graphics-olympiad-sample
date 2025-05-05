#ifndef BLOOM_PASS_INCLUDED
#define BLOOM_PASS_INCLUDED

#include "BloomInput.hlsl"
#include "BloomData.hlsl"

float CustomLuminance(float3 rgb)
{
    return dot(rgb, float3(0.2126729, 0.7151522, 0.0721750));
}

v2f vert(appdata v)
{
    v2f o;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
    o.vertex = TransformObjectToHClip(v.vertex.xyz);
    o.uv = v.uv;
    return o;
}

// Гауссовская пушечка жиес
float4 GaussianBlur(float2 uv, float2 direction)
{
    float4 color = 0;
    const float weights[5] = { 0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216 };
    
    float2 texelSize = _MainTex_TexelSize.xy * _BlurSize;
    
    UNITY_UNROLL

    for (int i = -2; i <= 2; i++)
    {
        float2 offset = direction * texelSize * i;
        color += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + offset) * weights[abs(i)];
    }
    
    return color;
}

float4 FragBright(v2f i) : SV_Target
{
    float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
    float luminance = CustomLuminance(col.rgb);
    return luminance > _BloomThreshold ? col : 0;
}

// Blur Pass
float4 FragBlur(v2f i) : SV_Target
{
    return GaussianBlur(i.uv, float2(1, 0)); // Horizontal
}

float4 FragBlurVertical(v2f i) : SV_Target
{
    return GaussianBlur(i.uv, float2(0, 1)); // Vertical
}


float4 FragCombine(v2f i) : SV_Target
{
    float4 base = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
    float4 bloom = SAMPLE_TEXTURE2D(_BloomTex, sampler_BloomTex, i.uv);
    
    return float4(base.rgb + bloom.rgb * _Intensity, base.a);
}

#endif