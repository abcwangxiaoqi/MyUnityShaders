Shader "Unlit/SineWave"
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
		_RefTexture("_RefTexture",2D) = "white"{}
		_RefrTexture("_RefrTexture",2D) = "white"{}
		_RefOffset("_RefOffset",Range(0.01,0.1))=0.02
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
				float4 proj:TEXCOORD3;
			};

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

			
			float4x4 _RefractCameraVP;
			
			v2f vert (appdata v)
			{
				v2f o;		

				float4x4 _Dirs=(_Dir.x,_Dir.y,_Dir.z,_Dir.w,
				_Dir1.x,_Dir1.y,_Dir1.z,_Dir1.w,
				_Dir2.x,_Dir2.y,_Dir2.z,_Dir2.w,
				_Dir3.x,_Dir3.y,_Dir3.z,_Dir3.w);	

				float4 worldpos=mul(unity_ObjectToWorld,v.vertex);

				float yoffset=_A[0]*sin(dot(_Dirs[0],worldpos)*_W[0]+_XZ[0]*_Time.y)
								+_A[1]*sin(dot(_Dirs[1],worldpos)*_W[1]+_XZ[1]*_Time.y)
								+_A[2]*sin(dot(_Dirs[2],worldpos)*_W[2]+_XZ[2]*_Time.y)
								+_A[3]*sin(dot(_Dirs[3],worldpos)*_W[3]+_XZ[3]*_Time.y);

				worldpos.y=yoffset;

				float normalX=_W[0]*_Dir.x*_A*cos(dot(_Dirs[0],worldpos)*_W[0]+_XZ[0]*_Time.y)
								+_W[1]*_Dir1.x*_A*cos(dot(_Dirs[1],worldpos)*_W[1]+_XZ[1]*_Time.y)
								+_W[2]*_Dir2.x*_A*cos(dot(_Dirs[2],worldpos)*_W[2]+_XZ[2]*_Time.y)
								+_W[3]*_Dir3.x*_A*cos(dot(_Dirs[3],worldpos)*_W[3]+_XZ[3]*_Time.y);

				float normalZ=_W[0]*_Dir.z*_A*cos(dot(_Dirs[0],worldpos)*_W[0]+_XZ[0]*_Time.y)
								+_W[1]*_Dir1.z*_A*cos(dot(_Dirs[1],worldpos)*_W[1]+_XZ[1]*_Time.y)
								+_W[2]*_Dir2.z*_A*cos(dot(_Dirs[2],worldpos)*_W[2]+_XZ[2]*_Time.y)
								+_W[3]*_Dir3.z*_A*cos(dot(_Dirs[3],worldpos)*_W[3]+_XZ[3]*_Time.y);

				o.worldPos=worldpos;
				o.worldNormal=float3(-normalX,1,-normalZ);				
				o.vertex = mul(UNITY_MATRIX_VP,worldpos);	

				o.ScreenPos = ComputeScreenPos(o.vertex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 worldNormal=normalize(i.worldNormal);

				float3 worldPos=i.worldPos;

				float3 diffuse=HalfLambert_DiffLightAmbient(worldNormal,worldPos,_Color,float3(0,0,0));			

				float2 offsets =float2(worldNormal.x,worldNormal.z)*_RefOffset;//根据法线 uv扰动

				half4 reflectionColor = tex2D(_RefTexture, (i.ScreenPos.xy/i.ScreenPos.w)+offsets);//反射贴图采样

				diffuse+=reflectionColor;

				float fresnel=getFresnel(0.1,1,worldNormal,worldPos,5);//菲尼尔

				diffuse=lerp(diffuse,float4(1,1,1,1),fresnel);

				return float4(diffuse,0.8);
			}
			ENDCG
		}
	}
}
