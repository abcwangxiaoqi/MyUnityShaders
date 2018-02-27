Shader "Unlit/fresnel"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_fresnelBase("fresnelBase",Range(0.1,1))=1
		_fresnelScale("fresnelScale",Range(0.1,1))=1
		_fresnelIndensity("fresnelIndensity", Range(0, 5)) = 5
		_fresnelColor("fresnelColor",Color)=(1,1,1,1)		
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
			#include "../CommonCg/MyCgInclude.cginc"
			#include "Lighting.cginc"
			

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
				float3 worldPos:TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _fresnelBase;
			float _fresnelScale;
			float _fresnelIndensity;
			float3 _fresnelColor;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal=mul(v.normal,unity_WorldToObject).xyz;
				o.worldPos=mul(unity_ObjectToWorld,v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);

				float3 worldNormal=normalize(i.worldNormal);
				float3 worldPos=i.worldPos;

				float3 diffuse=HalfLambert(worldNormal,worldPos);//半兰伯特光照
				col.xyz*=diffuse;

				float fresnel=getFresnel(_fresnelBase,_fresnelScale,worldNormal,worldPos,_fresnelIndensity);
				col.rgb += lerp(col.rgb, _fresnelColor, fresnel);

				return col;
			}
			ENDCG
		}
	}
}
