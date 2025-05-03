Shader"Custom/Task1" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _MetallicMap ("Metallic Map", 2D) = "white" {}
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _RoughnessMap ("Roughness Map", 2D) = "white" {}
        _Roughness ("Roughness", Range(0,1)) = 0.5
    }
    SubShader {       
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf StandardCustom fullforwardshadows
        #pragma target 3.0

        #include "UnityPBSLighting.cginc"

        sampler2D _MainTex;
        sampler2D _NormalMap;
        sampler2D _MetallicMap;
        sampler2D _RoughnessMap;
        half _Metallic;
        half _Roughness;
        fixed4 _Color;

        struct Input
        {
            float2 uv_MainTex;
        };

        inline half4 LightingStandardCustom(SurfaceOutputStandard s, half3 viewDir, UnityGI gi)
        {
            return LightingStandard(s, viewDir, gi);
        }

        void LightingStandardCustom_GI(
                    SurfaceOutputStandard s,
                    UnityGIInput data,
                    inout UnityGI gi
                )
        {
            LightingStandard_GI(s, data, gi);
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
                    // Основной цвет из текстуры
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            
                    // Нормали из карты нормалей
            o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
            
                    // Металличность: комбинация карты и коэффициента
            half metallic = tex2D(_MetallicMap, IN.uv_MainTex).r * _Metallic;
            o.Metallic = metallic;
            
                    // Шероховатость: комбинация карты и коэффициента
            half roughness = tex2D(_RoughnessMap, IN.uv_MainTex).r * _Roughness;
            o.Smoothness = 1.0 - roughness;
            
            o.Alpha = c.a;
        }
        ENDCG
    }
FallBack"Diffuse"
}