/*
正玄波 + 法线细节
*/
Shader "Unlit/SineWaveNormal"
{
	Properties
	{
		_Color("Water Color",Color)=(1,1,1,1)
		_A("振幅",float)=1
		_Dir("运动方向",vector)=(1,1,1,1)
		_W("频率",Range(0,1))=0.1
		_XZ("相位",Range(0,1))=0.1
		_BumpTex("_BumpTex",2D) = "white"{}
		_RefTexture("_RefTexture",2D) = "white"{}
		_RefrTexture("_RefrTexture",2D) = "white"{}
		_RefOffset("_RefOffset",Range(0.01,0.1))=0.02
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
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 worldNormal:NORMAL;
				float3 worldPos:TEXCOORD1;
				float4 ScreenPos:TEXCOORD2;
				float4 refrScreenPos:TEXCOORD3;
			};

			float _A;
			vector _Dir;
			float _W;
			float _XZ;
			float4 _Color;
			sampler2D _RefTexture;
			sampler2D _RefrTexture;
			sampler2D _BumpTex;
			float _RefOffset;

			
			float4x4 _RefractCameraVP;
			
			v2f vert (appdata v)
			{
				v2f o;		

				float4 worldpos=mul(unity_ObjectToWorld,v.vertex);

				float yoffset=_A*sin(dot(_Dir,worldpos)*_W+_XZ*_Time.y);

				worldpos.y=yoffset;

				float normalX=_W*_Dir.x*_A*cos(dot(_Dir,worldpos)*_W+_XZ*_Time.y);

				float normalZ=_W*_Dir.z*_A*cos(dot(_Dir,worldpos)*_W+_XZ*_Time.y);

				o.worldPos=worldpos;
				o.worldNormal=float3(-normalX,1,-normalZ);				
				o.vertex = mul(UNITY_MATRIX_VP,worldpos);	

				o.ScreenPos = ComputeScreenPos(o.vertex);
				o.refrScreenPos=ComputeScreenPos(mul(_RefractCameraVP,worldpos));

				return o;
			}
			
			float3 excuteWorldNormal(float3 worldPos)
			{
				float3 B=float3(0,0,0);

			}

			fixed4 frag (v2f i) : SV_Target
			{
				float3 worldNormal=normalize(i.worldNormal);

				float3 worldPos=i.worldPos;

				float4 diffuse;
				diffuse.xyz=HalfLambert_DiffLightAmbient(worldNormal,worldPos,_Color,float3(0,0,0));			

				float2 offsets =float2(worldNormal.x,worldNormal.z)*_RefOffset;//根据法线 uv扰动

				half4 reflectionColor = tex2D(_RefTexture, (i.ScreenPos.xy/i.ScreenPos.w)+offsets);//反射贴图采样
				half4 refractionColor=tex2D(_RefrTexture,(i.refrScreenPos.xy/i.refrScreenPos.w)+offsets);//折射贴图采样

				float fresnel=getFresnel(0.1,1,worldNormal,worldPos,5);//菲尼尔

				diffuse.xyz+=lerp(refractionColor,reflectionColor,fresnel);//视角越小 反射越强 折射越弱

				return diffuse;
			}
			ENDCG
		}
	}
}
