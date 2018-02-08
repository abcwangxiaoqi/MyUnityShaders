Shader "Unlit/OutLineCombin"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_OutLine("OutLine",2D)="white" {}
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
			float4 _MainTex_ST;		
			sampler2D _OutLine;	

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv, _MainTex;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				float depth=getDepth(_OutLine,i.uv);
				fixed4 col = tex2D(_MainTex, i.uv);

				if(depth>0 & depth<1)
				{
					return float4(1,0,0,1);
				}
				return col;
			}
			ENDCG
		}
	}
}
