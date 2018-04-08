﻿Shader "Unlit/SineWave"
{
	Properties
	{
		_Color("Water Color",Color)=(1,1,1,1)
		_A("振幅",vector)=(1,1,1,1)
		_Dir("运动方向",vector)=(1,1,1,1)
		_Dir1("运动方向1",vector)=(1,1,1,1)
		_Dir2("运动方向2",vector)=(1,1,1,1)
		_Dir3("运动方向3",vector)=(1,1,1,1)
		_W("频率",vector)=(1,1,1,1)
		_XZ("相位",vector)=(1,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" }
		LOD 100

		Blend SrcAlpha OneMinusSrcAlpha

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
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 normal:NORMAL;
			};

			vector _A;
			vector _Dir;
			vector _Dir1;
			vector _Dir2;
			vector _Dir3;
			vector _W;
			vector _XZ;
			float4 _Color;
			
			v2f vert (appdata v)
			{
				v2f o;		

				float4x4 _Dirs=(_Dir.x,_Dir.y,_Dir.z,_Dir.w,
				_Dir1.x,_Dir1.y,_Dir1.z,_Dir1.w,
				_Dir2.x,_Dir2.y,_Dir2.z,_Dir2.w,
				_Dir3.x,_Dir3.y,_Dir3.z,_Dir3.w);	

				float yoffset=_A[0]*sin(dot(_Dirs[0],v.vertex)*_W[0]+_XZ[0]*_Time.y)
								+_A[1]*sin(dot(_Dirs[1],v.vertex)*_W[1]+_XZ[1]*_Time.y)
								+_A[2]*sin(dot(_Dirs[2],v.vertex)*_W[2]+_XZ[2]*_Time.y)
								+_A[3]*sin(dot(_Dirs[3],v.vertex)*_W[3]+_XZ[3]*_Time.y);

				v.vertex.y=yoffset;

				float normalX=_W[0]*_Dir.x*_A*cos(dot(_Dirs[0],v.vertex)*_W[0]+_XZ[0]*_Time.y)
								+_W[1]*_Dir1.x*_A*cos(dot(_Dirs[1],v.vertex)*_W[1]+_XZ[1]*_Time.y)
								+_W[2]*_Dir2.x*_A*cos(dot(_Dirs[2],v.vertex)*_W[2]+_XZ[2]*_Time.y)
								+_W[3]*_Dir3.x*_A*cos(dot(_Dirs[3],v.vertex)*_W[3]+_XZ[3]*_Time.y);

				float normalZ=_W[0]*_Dir.z*_A*cos(dot(_Dirs[0],v.vertex)*_W[0]+_XZ[0]*_Time.y)
								+_W[1]*_Dir1.z*_A*cos(dot(_Dirs[1],v.vertex)*_W[1]+_XZ[1]*_Time.y)
								+_W[2]*_Dir2.z*_A*cos(dot(_Dirs[2],v.vertex)*_W[2]+_XZ[2]*_Time.y)
								+_W[3]*_Dir3.z*_A*cos(dot(_Dirs[3],v.vertex)*_W[3]+_XZ[3]*_Time.y);

				o.normal=float3(-normalX,1,-normalZ);
				o.vertex = UnityObjectToClipPos(v.vertex);				

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 normal=normalize(i.normal);
				return float4(_Color.xyz,0.5);
			}
			ENDCG
		}
	}
}
