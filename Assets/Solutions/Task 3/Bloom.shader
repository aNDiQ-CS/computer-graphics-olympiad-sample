Shader"Custom/Bloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BloomThreshold ("Threshold", Range(0,1)) = 0.8
        _BlurSize ("Blur Size", Float) = 1.0
        _Intensity ("Intensity", Float) = 1.5
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }

        // Pass 0: Brightness Filter
        Pass
        {
            Name"BrightPass"
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment FragBright
            
            #include "BloomPass.hlsl"
            ENDHLSL
        }

        // Pass 1: Horizontal Blur
        Pass
        {
            Name"BlurHorizontal"
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment FragBlur
            
            #include "BloomPass.hlsl"
            ENDHLSL
        }

        // Pass 2: Vertical Blur
        Pass
        {
            Name"BlurVertical"
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment FragBlurVertical
            
            #include "BloomPass.hlsl"
            ENDHLSL
        }

        // Pass 3: Combine
        Pass
        {
            Name"Combine"
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment FragCombine                        
            
            #include "BloomPass.hlsl"
            ENDHLSL
        }
    }
}