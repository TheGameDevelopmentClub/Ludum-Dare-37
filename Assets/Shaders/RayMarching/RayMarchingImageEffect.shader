﻿Shader "Hidden/RayMarchingImageEffect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Intensity("Light Intensity", Range(0,0.8)) = 0
		_AspectRatio("Screen Aspect Ratio", Float) = 1
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
				float4 lightPos: TEXCOORD1;
				float3 coordinate : TEXCOORD2;
			};

			float4 _MainTex_TexelSize;
			float3 _WorldSpaceLightPos;

			v2f vert (appdata v)
			{
				v2f o;
				//o.vertex = mul(UNITY_MATRIX_MVP, v.vertex); //The below code should be equivalent
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				//o.lightPos = ComputeScreenPos(UnityObjectToClipPos(_WorldSpaceLightPos));
				o.coordinate = float4(_WorldSpaceLightPos, 0);
				o.lightPos = ComputeScreenPos(UnityObjectToClipPos(o.coordinate));

				#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y > 0)
					o.uv.y = 1 - o.uv.y;
				#endif

				return o;
			}
			
			sampler2D _MainTex;
			float _Intensity;
			float _AspectRatio;

			bool inside_rect(float2 pos, float4 rect){
				return (pos.x > rect.x && pos < rect.z) && (pos.y > rect.y && pos.y < rect.w);
			}

			float4 march(v2f i) {
				float4 frag_col = tex2D(_MainTex, i.uv);
				return frag_col;
			}

			float4 frag (v2f i) : SV_Target
			{
				float2 lightUV = i.lightPos.xy / i.lightPos.w;
				float4 col = tex2D(_MainTex, i.uv);
				//if (lightUV.x == i.uv.x && lightUV.y == i.uv.y) {
				//if (inside_rect(i.uv, float4(lightUV.x-0.1, lightUV.y-0.1, lightUV.x+0.1, lightUV.y+0.1))){
				
				float2 aspect = float2(1, _AspectRatio);
				float dist = distance(aspect * lightUV, aspect * i.uv);
				if(dist < _Intensity){
					col = float4(1, 1, 1, 0);
					//col = lerp(float4(1, 1, 1, 0), float4(0, 0, 0, 0), dist / _Intensity);
					col *= march(i);
				}
				else {
					col = float4(0, 0, 0, 0);
				}
				//col = float4(i.lightPos.xyz, 0);
				return col;
			}
			ENDCG
		}
	}
}
