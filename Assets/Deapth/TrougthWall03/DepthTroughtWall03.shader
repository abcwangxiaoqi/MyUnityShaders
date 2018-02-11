Shader "Unlit/DepthTroughtWall03"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Intensity("Intensity",Range(0.1,1))=0.5
		_OutLineColor("outlineColor",Color)=(1,1,1,1)
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
			#include "../../CommonCg/MyCgInclude.cginc"

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
			sampler2D _PlayerTex;
			sampler2D _WallTex;
			float4 _MainTex_ST;
			float _Intensity;
			float3 _OutLineColor;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float4 col=tex2D(_MainTex,i.uv);
				float player =getDepth(_PlayerTex,i.uv);
				float wall=getDepth(_WallTex,i.uv);
				float nvfac=tex2D(_PlayerTex,i.uv).w;

				/* 原始代码片段
				if(player>wall & _Intensity>nvfac)
				{
					return float4(_OutLineColor,1);
				}
				return col;
				*/			

				/*改造后片段 用step代替 if 提高性能*/
				float fac=step(player,wall);
				float outlinefac=step(_Intensity,nvfac);	
				float fact=min(1,fac+outlinefac);
				return lerp(float4(_OutLineColor,1),col,fact);		
			}
			ENDCG
		}
	}
}
