Shader "Unlit/TWReplaceShader"
{
	SubShader{
		tags{ "rendertype" = "transparent" }

		pass {
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "unitycg.cginc"
		#include "../../CommonCg/MyCgInclude.cginc"



		struct v2f {
			float4 pos:POSITION;
			float2 depth:TEXCOORD0;
			float3 worldNormal:TEXCOORD1;
			float3 worldPos:TEXCOORD2;
		};


		v2f vert(appdata_base v) {
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.depth = o.pos.zw;
			o.worldNormal=mul(v.normal,unity_WorldToObject).xyz;	
			o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;		
			return o;
		}

		fixed4 frag(v2f IN) :COLOR{

			float depth = Linear01Depth(IN.depth.x/IN.depth.y);
			float3 worldPos=IN.worldPos;
			float3 worldNor=IN.worldNormal;

			//得到法线和视角的夹角因子
			float fac=max(0,DotViewAndNormal(worldNor,worldPos));

			//夹角因子存放在a通道内
			return float4(depth,depth,depth,fac);
		}
		ENDCG
	}
	}
}
