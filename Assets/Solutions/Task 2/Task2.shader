Shader "Custom/WaveOcean"
{
    Properties
    {
        [Header(Wave Settings)]
        _WaveSpeed ("Wave Speed", Range(0,5)) = 1.0
        _WaveAmplitude ("Wave Amplitude", Range(0,5)) = 0.5
        _WaveSteepness ("Wave Steepness", Range(0,1)) = 0.5
    
        [Header(Color Settings)]
        _OceanColor ("Ocean Color", Color) = (0.1, 0.3, 0.6, 1)
        _FoamColor ("Foam Color", Color) = (1,1,1,1)
          
        _DepthGradient ("Depth Gradient", Range(0,5)) = 1.0
        _FoamSmoothness ("Foam Smoothness", Range(0.01,1)) = 0.2
    
        [Header(Noise Control)]
        _CellSize ("Cell Size", Range(0.1, 10)) = 2.0
        _Density ("Density", Range(0.01, 2)) = 1.0
        _NoiseIntensity ("Noise Intensity", Range(0,1)) = 0.3

        [Header(Interaction)]
        _ImpactMap ("Impact Map", 2D) = "white" {}
        _ImpactSize ("Impact Size", Range(0,10)) = 1.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "WaveInput.hlsl"
            #include "WaveData.hlsl"
            #include "WavePass.hlsl"
            
            ENDHLSL
        }
    }
}