#ifndef BLOOM_INPUT_INCLUDED
#define BLOOM_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);

TEXTURE2D(_BloomTex);
SAMPLER(sampler_BloomTex);
float4 _MainTex_TexelSize;

float _BloomThreshold;
float _BlurSize;
float _Intensity;

#endif