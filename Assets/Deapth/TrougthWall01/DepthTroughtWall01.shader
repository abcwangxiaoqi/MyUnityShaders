Shader "Unlit/DepthTroughtWall01"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_PlayerTex ("Texture", 2D) = "white" {}
		_WallTex ("Texture", 2D) = "white" {}
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
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float player =tex2D(_PlayerTex,i.uv).r;
				float wall=tex2D(_WallTex,i.uv).r;
				
				if(player>0 & wall>0 & player>wall)
				{
					return fixed4(1,0,0,1);
				}
				return tex2D(_MainTex,i.uv);
			}
			ENDCG
		}
	}
}
