// PBR_URP.shader
Shader"Custom/PBR_URP"
{
    Properties
    {
        [MainColor] _BaseColor("Color", Color) = (1,1,1,1)
        [MainTexture] _BaseMap("Albedo", 2D) = "white" {}
        
        _NormalMap("Normal Map", 2D) = "bump" {}
        _NormalScale("Normal Scale", Range(0,2)) = 1.0
        
        _MetallicMap("Metallic Map", 2D) = "white" {}
        _Metallic("Metallic", Range(0,1)) = 0.0
        
        _RoughnessMap("Roughness Map", 2D) = "white" {}
        _Roughness("Roughness", Range(0,1)) = 0.5
    }

    SubShader
    {
        #pragma vertex vert
        #pragma fragment frag

        Tags 
        { 
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
        }
        LOD 300

        Pass
        {
            Name "ForwardLit"
            Tags {"LightMode" = "UniversalForward"}

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            // URP includes
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 tangentWS : TEXCOORD2;
                float3 bitangentWS : TEXCOORD3;
                float3 positionWS : TEXCOORD4;
            };

            // Textures
            TEXTURE2D(_BaseMap);
            TEXTURE2D(_NormalMap);
            TEXTURE2D(_MetallicMap);
            TEXTURE2D(_RoughnessMap);
            
            // Samplers
            SAMPLER(sampler_BaseMap);
            
            // Material properties
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            half4 _BaseColor;
            half _NormalScale;
            half _Metallic;
            half _Roughness;
            CBUFFER_END

            Varyingsvert(Attributes input)
            {
                Varyings output;
                
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                
                output.positionCS = vertexInput.positionCS;
                output.positionWS = vertexInput.positionWS;
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                
                output.normalWS = normalInput.normalWS;
                output.tangentWS = normalInput.tangentWS;
                output.bitangentWS = normalInput.bitangentWS;
                
                return output;
            }

            half3 SampleNormal(float2 uv, half scale = 1.0)
            {
                half4 normalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_BaseMap, uv);
                return UnpackNormalScale(normalMap, scale);
            }

            half4 frag(Varyings input) : SV_Target
            {
                            // Get material properties
                half4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv) * _BaseColor;
                half metallic = SAMPLE_TEXTURE2D(_MetallicMap, sampler_BaseMap, input.uv).r * _Metallic;
                half roughness = SAMPLE_TEXTURE2D(_RoughnessMap, sampler_BaseMap, input.uv).r * _Roughness;
                half3 normalTS = SampleNormal(input.uv, _NormalScale);
                
                            // Convert normal from tangent to world space
                float3x3 TBN = float3x3(
                                normalize(input.tangentWS),
                                normalize(input.bitangentWS),
                                normalize(input.normalWS)
                            );
                half3 normalWS = TransformTangentToWorld(normalTS, TBN, true);
                
                            // Light setup
                Light mainLight = GetMainLight();
                half3 lightDir = normalize(mainLight.direction);
                half3 viewDir = GetWorldSpaceNormalizeViewDir(input.positionWS);
                
                            // PBR calculations
                half NdotL = saturate(dot(normalWS, lightDir));
                half3 radiance = mainLight.color * mainLight.distanceAttenuation * NdotL;
                
                            // Simplified BRDF
                half3 F0 = lerp(0.04, albedo.rgb, metallic);
                half3 F = FresnelSchlickRoughness(max(dot(normalWS, viewDir), F0, roughness);
                half3 kD = (1.0 - F) * (1.0 - metallic);
                
                            // Final color
                half3 diffuse = kD * albedo.rgb * radiance;
                half3 specular = F * radiance;
                half3 color = diffuse + specular;
                
                return half4(color, albedo.a);
            }
            ENDHLSL
        }
    }
    
FallBack"Universal Render Pipeline/Lit"
}