﻿Shader "Hidden/ImageAverage"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NumberOfIterations("Number of Elements to be Averaged", Int) = 1
		_PreviousTex("Previous Average Texture Computed", 2D) = "black"{}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _PreviousTex;
			int _NumberOfIterations;

			fixed4 frag (v2f i) : SV_Target
			{
				float4 current_val = tex2D(_MainTex, i.uv);
				float4 prev_val = tex2D(_PreviousTex, i.uv);

				float4 col = prev_val + Luminance(current_val/_NumberOfIterations);//prev_val + (current_val / _NumberOfIterations);

				return col;
			}
			ENDCG
		}
	}
}
