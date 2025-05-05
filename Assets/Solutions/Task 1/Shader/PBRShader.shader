Shader"Custom/PBRShader" {
    Properties
	{
		[NoScaleOffset]_BaseMap("Texture", 2D) = "white" { }
		_BaseColor("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_AlbedoMap("Albedo Map", 2D) = "white" {}
		_RoughnessMap ("Roughness Map", 2D) = "white" {}
		_Roughness ("Roughness", Range(0,1)) = 0.5
		_MetallicMap ("Metallic Map", 2D) = "white" {}
		_Metallic ("Metallic", Range(0, 1)) = 0.5		
		_NormalMap ("Normal Map", 2D) = "white" {}
		_NormalScale ("Normal Scale", Range(0, 1)) = 0
		_EnvReflectionIntensity ("Reflection Intensity", Range(0, 1)) = 0.5
	}

    HLSLINCLUDE
		#pragma exclude_renderers gles

		#include "PBRPass.hlsl"
	ENDHLSL

    SubShader
	{
		Tags { "RenderType" = "Opaque" }

		Pass
		{
			Name "PBR Sample Shading Pass"

			HLSLPROGRAM
				#pragma vertex Vertex
				#pragma fragment Fragment
				#pragma target 4.5
			ENDHLSL
		}
	}

FallBack"Diffuse"
}