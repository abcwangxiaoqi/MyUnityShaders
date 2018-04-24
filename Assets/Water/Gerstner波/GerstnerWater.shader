Shader "Unlit/GerstnerWater"
{
	Properties
	{
		_Color("Water Color",Color)=(1,1,1,1)
		_MainTex("_MainTex",2D)="white"{}
		_A("振幅",vector)=(1,1,1,1)
		_Q("_Q",vector)=(1,1,1,1)
		_Dir("运动方向",vector)=(1,1,1,1)
		_Dir1("运动方向1",vector)=(1,1,1,1)
		_Dir2("运动方向2",vector)=(1,1,1,1)
		_Dir3("运动方向3",vector)=(1,1,1,1)
		_W("频率",vector)=(1,1,1,1)
		_XZ("相位",vector)=(1,1,1,1)
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

			vector _Q;
			vector _A;
			vector _Dir;
			vector _Dir1;
			vector _Dir2;
			vector _Dir3;
			vector _W;
			vector _XZ;
			float4 _Color;
			sampler2D _RefTexture;
			sampler2D _RefrTexture;
			float _RefOffset;

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float4x4 _RefractCameraVP;
			
			v2f vert (appdata v)
			{
				v2f o;			

				float4x4 _Dirs=(_Dir.x,_Dir.y,_Dir.z,_Dir.w,
								_Dir1.x,_Dir1.y,_Dir1.z,_Dir1.w,
								_Dir2.x,_Dir2.y,_Dir2.z,_Dir2.w,
								_Dir3.x,_Dir3.y,_Dir3.z,_Dir3.w);	

				//控制范围 不出现 环形波
				float4 tempQ=float4(clamp(_Q[0],0,1/(_W[0]*_A[0])),
									clamp(_Q[1],0,1/(_W[1]*_A[1])),
									clamp(_Q[2],0,1/(_W[2]*_A[2])),
									clamp(_Q[3],0,1/(_W[3]*_A[3])));

				float4 worldPos=mul(unity_ObjectToWorld,v.vertex);

				worldPos.x=worldPos.x+
								tempQ[0]*_A[0]*_Dir.x*cos(_W[0]*dot(_Dir,worldPos)+_XZ[0]*_Time.y);
								+tempQ[1]*_A[1]*_Dirs[1].x*cos(_W[1]*dot(_Dirs[1],worldPos)+_XZ[1]*_Time.y)
								+tempQ[2]*_A[2]*_Dirs[2].x*cos(_W[2]*dot(_Dirs[2],worldPos)+_XZ[2]*_Time.y)
								+tempQ[3]*_A[3]*_Dirs[3].x*cos(_W[3]*dot(_Dirs[3],worldPos)+_XZ[3]*_Time.y);

				worldPos.y=_A[0]*sin(_W[0]*dot(_Dirs[0],worldPos)+_XZ[0]*_Time.y);
								+_A[1]*sin(_W[1]*dot(_Dirs[1],worldPos)+_XZ[1]*_Time.y)
								+_A[2]*sin(_W[2]*dot(_Dirs[2],worldPos)+_XZ[2]*_Time.y)
								+_A[3]*sin(_W[3]*dot(_Dirs[3],worldPos)+_XZ[3]*_Time.y);

				worldPos.z=worldPos.z+
								tempQ[0]*_A[0]*_Dir.z*cos(_W[0]*dot(_Dir,worldPos)+_XZ[0]*_Time.y);
								+tempQ[1]*_A[1]*_Dirs[1].z*cos(_W[1]*dot(_Dirs[1],worldPos)+_XZ[1]*_Time.y)
								+tempQ[2]*_A[2]*_Dirs[2].z*cos(_W[2]*dot(_Dirs[2],worldPos)+_XZ[2]*_Time.y)
								+tempQ[3]*_A[3]*_Dirs[3].z*cos(_W[3]*dot(_Dirs[3],worldPos)+_XZ[3]*_Time.y);

				o.worldPos=worldPos;

				o.vertex=mul(UNITY_MATRIX_VP,worldPos);

				float normalX=_Dirs[0].x*_W[0]*_A[0]*cos(_W[0]*dot(_Dirs[0],worldPos)+_XZ[0]*_Time.y)
								+_Dirs[1].x*_W[1]*_A[1]*cos(_W[1]*dot(_Dirs[1],worldPos)+_XZ[1]*_Time.y)
								+_Dirs[2].x*_W[2]*_A[2]*cos(_W[2]*dot(_Dirs[2],worldPos)+_XZ[2]*_Time.y)
								+_Dirs[3].x*_W[3]*_A[3]*cos(_W[3]*dot(_Dirs[3],worldPos)+_XZ[3]*_Time.y);
				
				float normalY=tempQ[0]*_W[0]*_A[0]*sin(_W[0]*dot(_Dirs[0],worldPos)+_XZ[0]*_Time.y)
								+tempQ[1]*_W[1]*_A[1]*sin(_W[1]*dot(_Dirs[1],worldPos)+_XZ[1]*_Time.y)
								+tempQ[2]*_W[2]*_A[2]*sin(_W[2]*dot(_Dirs[2],worldPos)+_XZ[2]*_Time.y)
								+tempQ[3]*_W[3]*_A[3]*sin(_W[3]*dot(_Dirs[3],worldPos)+_XZ[3]*_Time.y);

				float normalZ=_Dirs[0].z*_W[0]*_A[0]*cos(_W[0]*dot(_Dirs[0],worldPos)+_XZ[0]*_Time.y)
								+_Dirs[1].z*_W[1]*_A[1]*cos(_W[1]*dot(_Dirs[1],worldPos)+_XZ[1]*_Time.y)
								+_Dirs[2].z*_W[2]*_A[2]*cos(_W[2]*dot(_Dirs[2],worldPos)+_XZ[2]*_Time.y)
								+_Dirs[3].z*_W[3]*_A[3]*cos(_W[3]*dot(_Dirs[3],worldPos)+_XZ[3]*_Time.y);

				o.worldNormal=float3(-normalX,1-normalY,-normalZ);

				o.ScreenPos = ComputeScreenPos(o.vertex);
				o.refrScreenPos=ComputeScreenPos(mul(_RefractCameraVP,worldPos));		

				o.uv=TRANSFORM_TEX(v.uv,_MainTex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 worldNormal=normalize(i.worldNormal);

				float3 worldPos=i.worldPos;

				float4 diffuse=tex2D(_MainTex,i.uv);
				diffuse.xyz*=HalfLambert_DiffLightAmbient(worldNormal,worldPos,_Color,float3(0,0,0));			

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
