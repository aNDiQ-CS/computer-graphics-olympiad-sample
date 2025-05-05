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

#define MAX_IMPACTS 100

struct ImpactData
{
    float3 position;
    float force;
    float time;
};

StructuredBuffer<ImpactData> _ImpactsBuffer;
int _ActiveImpactsCount;

float3 ApplyObjectImpacts(float3 worldPos)
{
    float totalImpact = 0.0;
    
    for (int i = 0; i < _ActiveImpactsCount; i++)
    {
        ImpactData impact = _ImpactsBuffer[i];
        float timeSinceImpact = _Time.y - impact.time;
        
        // Гасим амплитуду до нуля плавно
        float lifeFactor = saturate(1.0 - timeSinceImpact / 2.0);
        if (lifeFactor <= 0.0)
            continue;

        // Физически корректная волновая функция
        float dist = distance(worldPos.xz, impact.position.xz);
        float wave = exp(-pow(dist - timeSinceImpact * 3.0, 2) * 5.0)
                    * sin(10.0 * (dist - timeSinceImpact * 3.0));
        
        totalImpact += wave * impact.force * lifeFactor * _ImpactStrength;
    }
    
    return totalImpact;
}
VertexOutput vert(VertexInput v)
{
    VertexOutput o;
    
    // Базовое смещение
    float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    float noise = voronoi(worldPos.xz * 0.1 + _Time.y * _WaveSpeed);
    float displacement = noise * _WaveAmplitude;
    
    // Применяем воздействия от объектов
    float impactEffect = 0.0;
    if (_ActiveImpactsCount > 0)
    {
        impactEffect = ApplyObjectImpacts(worldPos);
    }
    
    // Комбинируем эффекты
    float combinedDisplacement = (displacement + impactEffect) / (1.0 + _WaveAmplitude * 0.2);
    
    worldPos.y += combinedDisplacement;
    
    // Преобразование и передача данных
    o.vertex = UnityObjectToClipPos(mul(unity_WorldToObject, float4(worldPos, 1.0)));
    o.worldPos = worldPos;
    o.displacement = displacement + impactEffect;    
    
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