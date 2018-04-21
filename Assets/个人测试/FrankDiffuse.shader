Shader "Unlit/FrankDiffuse"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Color",Color)=(1,1,1,1)
		_SpeColor("_SpecColor",Color)=(1,1,1,1)
		_Gloss("_Gloss",float)=100
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Tags { "LightMode"="ForwardBase" }
		
			CGPROGRAM
			
			#pragma multi_compile_fwdbase	  
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "../CommonCg/MyCgInclude.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 normal:NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv:TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				SHADOW_COORDS(3)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			float4 _SpeColor;
			float _Gloss;

			v2f vert(appdata v) {
			 	v2f o;
			 	o.pos = UnityObjectToClipPos(v.vertex);
			 	
			 	o.worldNormal = UnityObjectToWorldNormal(v.normal);
			 	
			 	o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				 o.uv=TRANSFORM_TEX(v.uv,_MainTex);
			 	
			 	TRANSFER_SHADOW(o);
			 	
			 	return o;
			}
			
				fixed4 frag(v2f i) : SV_Target {

				float3 ablode=tex2D(_MainTex,i.uv);
				float3 worldNormal = normalize(i.worldNormal);

				float3 diffuse=HalfLambert_DiffLight(worldNormal,i.worldPos,_Color);
				
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

			 	float3 specular = BPhongSpec(worldNormal,i.worldPos,_SpeColor.xyz,_Gloss);

				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				
				return float4(ambient + (ablode*diffuse +specular) * atten, 1.0);
			}
			ENDCG
		}
	}
	FallBack "Standard"
}
