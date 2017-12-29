/*
平移矩阵
1	0	0	TX
0	1	0	TY
0	0	1	TZ
0	0	0	1


放大缩小矩阵
SX   0    0    0
0    SY	 0    0
0     0   SZ   0
0     0    0    1

*/
Shader "Unlit/TranslationScaleShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Translation("Translation",vector)=(0,0,0,0)
		_Scale("Scale",vector) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque"}
		LOD 100

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

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Translation;
			float4 _Scale;

			//得到位移矩阵
			float4x4 translation(float4 trans)
			{
				return float4x4(1,0,0,trans.x,
								0,1,0,trans.y,
								0,0,1,trans.z,
								0,0,0,1
								);
			}

			//得到大小矩阵
			float4x4 scale(float4 scale)
			{
				return float4x4(scale.x, 0, 0, 0,
					0, scale.y, 0, 0,
					0, 0, scale.z, 0,
					0, 0, 0, 1
					);
			}

			v2f vert (appdata v)
			{
				v2f o;
				v.vertex=mul(translation(_Translation),v.vertex);//左乘位移矩阵
				v.vertex = mul(scale(_Scale), v.vertex);//左乘大小矩阵
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
