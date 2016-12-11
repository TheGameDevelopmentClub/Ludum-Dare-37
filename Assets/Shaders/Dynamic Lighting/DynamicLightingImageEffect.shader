﻿Shader "Hidden/DynamicLightingImageEffect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_DisplaceTex("Displacement Texture", 2D) = "white" {}
		_Magnitutde("Magnitude", Range(0,0.1)) = 1
		_Enabled("Enable Displacement", Range(0,1)) = 0
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
			sampler2D _DisplaceTex;
			float _Magnitude;
			float _Enabled;

			float4 frag (v2f i) : SV_Target
			{
				float2 disp = tex2D(_DisplaceTex, i.uv).xy;
				disp.y = disp.y - 1;
				disp = ((disp * 2) - 1) * _Magnitude;

				float4 main_col = tex2D(_MainTex, i.uv);
				float2 disp_i = float2(i.uv.x, 1 - i.uv.y);
				float4 disp_col = tex2D(_DisplaceTex, disp_i);
				if (_Enabled == 1.0) {
					main_col *= 1 - disp_col;
				}
				return main_col;
			}
			ENDCG
		}
	}
}
