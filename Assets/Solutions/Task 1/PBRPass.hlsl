#ifndef SAMPLE_PASS_INCLUDED
#define SAMPLE_PASS_INCLUDED

#include "PBRData.hlsl"
#include "PBRInput.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GlobalIllumination.hlsl"

#define CALLBACK_COLOR half4(255.0 / 255.0, 0.0 / 255.0, 255.0 / 255.0, 255.0 / 255.0)

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);
TEXTURE2D(_RoughnessMap);
SAMPLER(sampler_RoughnessMap);
TEXTURE2D(_AlbedoMap);
SAMPLER(sampler_AlbedoMap);
TEXTURE2D(_MetallicMap);
SAMPLER(sampler_MetallicMap);
TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);

CBUFFER_START(UnityPerMaterial)
    float4 _BaseColor;
    float _Roughness;
    float _Metallic;
    float _NormalScale;
    float _EnvReflectionIntensity;
CBUFFER_END

float3 ACESFitted(float3 color)
{
    color *= 0.6;
    float a = 2.51;
    float b = 0.03;
    float c = 2.43;
    float d = 0.59;
    float e = 0.14;
    return saturate((color*(a*color + b))/(color*(c*color + d) + e));
}

VertexOutput Vertex(VertexInput vertexInput)
{
    VertexOutput vertexOutput;
    vertexOutput.positionWS = TransformObjectToWorld(vertexInput.positionOS.xyz);
    vertexOutput.positionCS = TransformWorldToHClip(vertexOutput.positionWS);    

    vertexOutput.normalWS = TransformObjectToWorldNormal(vertexInput.normalOS);
    float3 tangentWS = TransformObjectToWorldDir(vertexInput.tangentOS.xyz);
    vertexOutput.tangentWS = float4(tangentWS, vertexInput.tangentOS.w);

    vertexOutput.uv = vertexInput.uv;
    return vertexOutput;
}

half4 Fragment(VertexOutput fragmentInput) : SV_Target
{
    // Сэмплирование текстур
    float4 baseMapColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, fragmentInput.uv);
    float4 albedo = baseMapColor * _BaseColor;
    float roughness = SAMPLE_TEXTURE2D(_RoughnessMap, sampler_RoughnessMap, fragmentInput.uv).r * _Roughness;
    float metallic = SAMPLE_TEXTURE2D(_MetallicMap, sampler_MetallicMap, fragmentInput.uv).r * _Metallic;
    float3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, fragmentInput.uv));
    normalTS.xy *= _NormalScale;

    // Трансформация нормалей
    float3 normalWS = normalize(fragmentInput.normalWS);
    float3 tangentWS = normalize(fragmentInput.tangentWS.xyz);
    float3 bitangentWS = cross(normalWS, tangentWS) * fragmentInput.tangentWS.w;
    float3x3 TBN = float3x3(tangentWS, bitangentWS, normalWS);
    float3 N = normalize(mul(normalTS, TBN));

    // Векторы направления
    float3 V = normalize(_WorldSpaceCameraPos - fragmentInput.positionWS);
    float3 ambient = SampleSH(N);

    // Инициализация освещения
    float3 totalColor = ambient * albedo.rgb;
    
    // Основной источник света
    Light mainLight = GetMainLight();
    float3 L = normalize(mainLight.direction);
    float3 H = normalize(V + L);
    
    // PBR расчеты для основного света
    float NdotL = saturate(dot(N, L));
    float NdotV = saturate(dot(N, V));
    float NdotH = saturate(dot(N, H));
    float VdotH = saturate(dot(V, H));

    float3 F0 = lerp(0.04, albedo.rgb, metallic);
    float3 F = F0 + (1.0 - F0) * pow(1.0 - VdotH, 5.0);
    
    float alpha = roughness * roughness;
    float alphaSq = alpha * alpha;
    float denom = (NdotH * NdotH) * (alphaSq - 1.0) + 1.0;
    float D = alphaSq / (PI * denom * denom);
    
    float k = (alpha + 1.0) * (alpha + 1.0) / 8.0;
    float G = (NdotV / (NdotV * (1.0 - k) + k)) * (NdotL / (NdotL * (1.0 - k) + k));
    
    float3 specular = (D * F * G) / (4.0 * NdotV * NdotL + 1e-5);
    float3 kDiffuse = (1.0 - F) * (1.0 - metallic);
    float3 diffuse = kDiffuse * albedo.rgb / PI * NdotL;
    
    totalColor += (diffuse + specular) * mainLight.color * mainLight.distanceAttenuation;

    // Дополнительные источники света
    uint numAdditionalLights = GetAdditionalLightsCount();
    for(uint i = 0; i < numAdditionalLights; i++)
    {
        Light light = GetAdditionalLight(i, fragmentInput.positionWS);
        #if defined(_LIGHT_TYPE_DIRECTIONAL)
        if(light.lightType == LightType.Directional) continue;
        #endif

        L = normalize(light.direction);
        H = normalize(V + L);
        
        NdotL = saturate(dot(N, L));
        NdotH = saturate(dot(N, H));
        VdotH = saturate(dot(V, H));

        F = F0 + (1.0 - F0) * pow(1.0 - VdotH, 5.0);
        denom = (NdotH * NdotH) * (alphaSq - 1.0) + 1.0;
        D = alphaSq / (PI * denom * denom);
        G = (NdotV / (NdotV * (1.0 - k) + k)) * (NdotL / (NdotL * (1.0 - k) + k));
        specular = (D * F * G) / (4.0 * NdotV * NdotL + 1e-5);
        kDiffuse = (1.0 - F) * (1.0 - metallic);
        diffuse = kDiffuse * albedo.rgb / PI * NdotL;
        
        totalColor += (diffuse + specular) * light.color * light.distanceAttenuation;
    }

    // Image-Based Lighting (Reflection Probes)
    float3 reflection = reflect(-V, N);
    float mip = PerceptualRoughnessToMipmapLevel(roughness);
    float4 encodedIrradiance = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflection, mip);
    float3 iblSpecular = DecodeHDREnvironment(encodedIrradiance, unity_SpecCube0_HDR);
    
    float surfaceReduction = 1.0 / (roughness*roughness + 1.0);
    float3 fresnel = F0 + (1.0 - F0) * exp2((-5.55473 * dot(V, N) - 6.98316) * dot(V, N));
    iblSpecular *= surfaceReduction * fresnel * _EnvReflectionIntensity * metallic;
    
    totalColor += iblSpecular;


    // Постобработка
    totalColor = ACESFitted(totalColor);
    totalColor = LinearToSRGB(totalColor);

    return half4(totalColor * _BaseColor.rgb, albedo.a);
}

#endif