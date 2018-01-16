Shader "Unlit/OcclusionDissolve"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseMap("Noise Map", 2D) = "white"{}
		_DissolveRadius("_DissolveRadius",Range(0,1))=0.3//消融半径
		_DissolveThreshold("DissolveThreshold", Range(0,2)) = 0  
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
				float3 normal:NORMAL; 
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 worldNormal:TEXCOORD1;
				float4 screenPos:TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NoiseMap;
			float _DissolveThreshold;
			float _DissolveRadius;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.worldNormal=UnityObjectToWorldNormal(v.normal).xyz;
				o.screenPos=ComputeGrabScreenPos(o.vertex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				float2 screenPos=i.screenPos.xy/i.screenPos.w;

				float2 dir=float2(0.5,0.5)-screenPos;
				float distance=length(dir);// 0~0.5
				
			//	clip(yz);

				//是否大于消融范围
				float sp=step(distance,_DissolveRadius);

				//噪声图 采样
				fixed3 burn = tex2D(_NoiseMap, i.uv).rgb;	
				//根据 噪声r 和 距离范围 clip			
				clip(burn.r - sp*(1-distance/_DissolveRadius));


				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
