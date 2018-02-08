Shader "Unlit/SampleBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
				float2 offset[4]:TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			//XX_TexelSize，XX纹理的像素相关大小width，height对应纹理的分辨率，x = 1/width, y = 1/height, z = width, w = height
			float4 _MainTex_TexelSize;
			float _BlurRadius;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.offset[0].xy=o.uv.xy+_BlurRadius*_MainTex_TexelSize*float2(1,1);
				o.offset[1].xy=o.uv.xy+_BlurRadius*_MainTex_TexelSize*float2(-1,-1);
				o.offset[2].xy=o.uv.xy+_BlurRadius*_MainTex_TexelSize*float2(1,-1);
				o.offset[3].xy=o.uv.xy+_BlurRadius*_MainTex_TexelSize*float2(-1,1);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				col+=tex2D(_MainTex,i.offset[0]);
				col+=tex2D(_MainTex,i.offset[1]);
				col+=tex2D(_MainTex,i.offset[2]);
				col+=tex2D(_MainTex,i.offset[3]);
				col*=0.2;//除以5 取平均值

				return col;
			}
			ENDCG
		}
	}
}
