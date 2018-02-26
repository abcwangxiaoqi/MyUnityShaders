Shader "Unlit/RimPro"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Diffuse("Diffuse",Color)=(1,1,1,1)
		_RimFact("RimFact",Range(0,1))=0.5
		_RimColor("RimColor",Color)=(1,1,1,1)
		_RimColorTwo("RimColorTwo",Color)=(1,1,1,1)
		_RimColorFact("RimColorFact",Range(0,1))=1
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
			float _RimFact;
			float3 _RimColor;
			float3 _RimColorTwo;
			float3 _Diffuse;
			float _RimColorFact;
			
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
				float3 worldNormal=normalize(i.worldNormal);
				float3 worldPos=i.worldPos;
				float3 viewDir=normalize(UnityWorldSpaceViewDir(i.worldPos));

				float fac=max(0,dot(worldNormal,viewDir));
				float flag=step(_RimFact,fac);				

				_RimColor=lerp(_RimColor,_RimColorTwo,_RimColorFact);
				
			 	float3 diffuse=HalfLambert_DiffLightAmbient(worldNormal,worldPos,_Diffuse,float3(0,0,0));

				fixed4 col = tex2D(_MainTex, i.uv);
				col.xyz=lerp(col,_RimColor,1-flag);

				col.xyz*=diffuse;
				
				return col;
			}
			ENDCG
		}
	}
}
