Shader "Unlit/FrameAnim"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Rows("rows",int)=3
		_Cols("cols",int)=4
		_Speed("speed",Range(1,100))=100
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
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
			int _Rows;
			int _Cols;
			float _Speed;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture

				int cout=floor(_Time.x*_Speed);
				int texCout=_Rows*_Cols;

				int index=cout%texCout;				


				float offsetX=0;
				float offsetY=0;

				float uv=i.uv+float2(offsetX,offsetY);

				fixed4 col = tex2D(_MainTex, uv);
				return col;
			}
			ENDCG
		}
	}
}
