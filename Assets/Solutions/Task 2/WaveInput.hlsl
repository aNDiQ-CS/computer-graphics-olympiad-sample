#ifndef WAVE_INPUT_HLSL
#define WAVE_INPUT_HLSL

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
// Noise functions
float2 random2(float2 st)
{
    st = float2(dot(st, float2(127.1, 311.7)),
                dot(st, float2(269.5, 183.3)));
    return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
}

// Uniforms
float4 _OceanColor;
float4 _FoamColor;
float _Density;       
float _FoamSmoothness;
float _WaveSpeed;
float _WaveAmplitude;
float _CellSize;
float _FoamThreshold;
float _WaveSteepness;
float _DepthGradient;
float _NoiseIntensity;
sampler2D _ImpactMap;
float _ImpactSize;

#endif