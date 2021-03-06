﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/MyRim2"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_RimColor("RimColor", Color) = (1,1,1,1)
		_RimPower("RimPower", Range(0.001, 1)) = 0.001
	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"  
			#include "UnityCG.cginc"
			#include "../../CommonCg/MyCgInclude.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 normal:NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 worldnormal:TEXCOORD1;
				float3 worldpos:TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _RimColor;
			float _RimPower;
			fixed3 _Color;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldnormal = mul(v.normal, (float3x3)unity_WorldToObject);//世界坐标下的法线
				o.worldpos = mul(unity_ObjectToWorld, v.vertex);//顶点的世界坐标
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldnormal);
				float3 worldPos = i.worldpos;
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				

				fixed4 col = tex2D(_MainTex, i.uv);

				fixed3 diff = HalfLambert_DiffLightAmbient(worldNormal,worldPos,_Color,float3(0,0,0));

				float fac = 1 - max(0, dot(worldNormal, worldViewDir));//得到法线和视角夹角因子
				float wfac = 1 - _RimPower;//得到宽度因子

				float flag=step(wfac,fac);

				col.rgb *=diff.rgb;
				col.rgb=lerp(col,_RimColor,flag);
				
				return col;
			}
		ENDCG
		}
	}
}
