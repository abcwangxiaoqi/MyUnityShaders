Shader "Unlit/OcclusionDissolve"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseMap("Noise Map", 2D) = "white"{}
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
				float distance=length(dir);

				float yz=(0.5-distance)*2;//溶解因子

				//距离中心点近的才进行溶解处理  
				//float disolveFactor = (0.5 - distance) * _DissolveThreshold;  
				//采样Dissolve Map  
				//fixed4 dissolveValue = tex2D(_DissolveMap, i.uv);  
				//小于阈值的部分直接discard  
				if ( distance<0.3)  
				{  
					discard;
				}

				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
