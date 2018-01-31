Shader "Unlit/TranZhuoSe"
{
	SubShader{
		tags{ "queue" = "transparent" }

		pass {
		blend srcalpha oneminussrcalpha
		ztest greater
		zwrite off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "unitycg.cginc"



		struct v2f {
			float4 pos:POSITION;
			float2 uv:TEXCOORD0;
		};


		v2f vert(appdata_base v) {
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			return o;
		}

		fixed4 frag(v2f IN) :COLOR{
			fixed4 color = fixed4(0,0,1,0.5);
			return color;
		}
			ENDCG
	}

	//========================================================
	pass {
		//blend srcalpha oneminussrcalpha
			ztest lequal
			zwrite on

			CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "unitycg.cginc"



		struct v2f {
			float4 pos:POSITION;
			float2 uv:TEXCOORD0;
		};


		v2f vert(appdata_base v) {
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			return o;
		}

		fixed4 frag(v2f IN) :COLOR{
			fixed4 color = fixed4(1,0,1,0.5);
		return color;
		}
			ENDCG
	}

	//========================================================
	}
}
