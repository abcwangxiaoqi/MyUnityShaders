// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ReplacementShader" {
	SubShader{
		tags{ "rendertype" = "transparent" }

		pass {
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "unitycg.cginc"



		struct v2f {
			float4 pos:POSITION;
			float2 depth:TEXCOORD0;
		};


		v2f vert(appdata_base v) {
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.depth = o.pos.zw;
			return o;
		}

		fixed4 frag(v2f IN) :COLOR{
			float depth = Linear01Depth(IN.depth.x/IN.depth.y);
			fixed4 color = fixed4(depth,0,0,1);
			return color;
		}
		ENDCG
	}
	}
}