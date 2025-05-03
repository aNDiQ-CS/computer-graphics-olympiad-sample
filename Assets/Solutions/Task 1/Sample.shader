Shader "Olympiad/Sample"
{
	Properties
	{
		[NoScaleOffset]_BaseMap("Texture", 2D) = "white" { }
		_BaseColor("Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}

	HLSLINCLUDE
		#pragma exclude_renderers gles

		#include "SamplePass.hlsl"
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
}