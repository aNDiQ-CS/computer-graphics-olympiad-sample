#ifndef WAVE_PASS_HLSL
#define WAVE_PASS_HLSL
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"

#include "WaveData.hlsl"
#include "WaveInput.hlsl"

float voronoi(float2 st)
{
    st = st * _CellSize * (1.0/_Density); 
    float2 i_st = floor(st);
    float2 f_st = frac(st);
    
    float m_dist = 1.0;
    [unroll]
    for(int j=-1; j<=1; j++)
    [unroll]
    for(int i=-1; i<=1; i++)
    {
        float2 neighbor = float2(i, j);
        float2 p = random2(i_st + neighbor);
        p = 0.5 + 0.5*sin(_Time.y * _WaveSpeed + 6.2831*p);
        float2 diff = neighbor + p - f_st;
        float dist = length(diff);
        m_dist = min(m_dist, dist);
    }
    return m_dist * 2.0 - 1.0;
}

float4 UnityObjectToClipPos(float3 pos)
{ 
    return mul(UNITY_MATRIX_VP, mul(UNITY_MATRIX_M, float4(pos, 1.0))); 
}


VertexOutput vert(VertexInput v)
{
    VertexOutput o;
    

    float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    
    // Генерируем 3D шум для плавных волн
    float2 noiseUV = worldPos.xz * 0.1 + _Time.y * _WaveSpeed;
    float noise = voronoi(noiseUV);
    
    // Смещение Y
    float displacementY = noise * _WaveAmplitude;
    worldPos.y += displacementY; // Непосредственное изменение Y координаты
      
    float3 displacedVertex = mul(unity_WorldToObject, float4(worldPos, 1.0)).xyz;
    
    // Применяем к вершине
    o.vertex = UnityObjectToClipPos(displacedVertex);
    o.worldPos = worldPos;
    o.displacement = displacementY;
    
    return o;
}

half4 frag(VertexOutput i) : SV_Target
{
    // Многослойный шум для плавности
    float noise1 = voronoi(i.worldPos.xz * 0.5);
    float noise2 = voronoi(i.worldPos.xz * 2.0 + float2(0.5, 0.5));
    float combinedNoise = (noise1 * 0.7 + noise2 * 0.3);

    float foamValue = saturate(i.displacement / _WaveAmplitude * 0.5 + 0.5);
    foamValue += combinedNoise * 0.2;
    
    float foam = smoothstep(
        _FoamThreshold - _FoamSmoothness,
        _FoamThreshold + _FoamSmoothness,
        foamValue
    );

    // Градиентный переход
    half4 col = lerp(
        _OceanColor,
        _FoamColor,
        pow(foam, 2.0) * (1.0 - exp(-foam * 5.0))
    );
    
    return col;
}

#endif