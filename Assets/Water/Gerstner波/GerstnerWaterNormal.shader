Shader "Unlit/GerstnerWaterNormal"
{
	Properties
	{
		_Color("Water Color",Color)=(1,1,1,1)
		_A("振幅",float)=1
		_Q("_Q",float)=1
		_Dir("运动方向",vector)=(1,1,1,1)
		_W("频率",float)=1
		_XZ("相位",float)=1
		_RefTexture("_RefTexture",2D) = "white"{}
		_RefrTexture("_RefrTexture",2D) = "white"{}
		_BumpTex("_BumpTex",2D)= "white"{}
		_BumpStrength("Bump strength", Range(0.0, 10.0)) = 1.0 
    	_BumpDirection("Bump direction(2 wave)", Vector)=(1,1,1,-1) 
    	_BumpTiling("Bump tiling", Vector)=(0.0625,0.0625,0.0625,0.0625)
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
				float3 worldPos:TEXCOORD1;
				float4 ScreenPos:TEXCOORD2;
				float4 refrScreenPos:TEXCOORD3;
				float4 bumpCoords:TEXCOORD4;
			};

			float _Q;
			float _A;
			vector _Dir;
			float _W;
			float _XZ;
			float4 _Color;
			sampler2D _RefTexture;
			sampler2D _RefrTexture;
			float _RefOffset;
			sampler2D _BumpTex;
			float _BumpStrength; 
        	float4 _BumpDirection; 
        	float4 _BumpTiling;

			float4x4 _RefractCameraVP;
			
			v2f vert (appdata v)
			{
				v2f o;			

				//控制范围 不出现 环形波
				float tempQ=clamp(_Q,0,1/(_W*_A));

				float4 worldPos=mul(unity_ObjectToWorld,v.vertex);

				worldPos.x=worldPos.x+
								tempQ*_A*_Dir.x*cos(_W*dot(_Dir,worldPos)+_XZ*_Time.y);

				worldPos.y=_A*sin(_W*dot(_Dir,worldPos)+_XZ*_Time.y);

				worldPos.z=worldPos.z+
								tempQ*_A*_Dir.z*cos(_W*dot(_Dir,worldPos)+_XZ*_Time.y);

				o.worldPos=worldPos;

				o.vertex=mul(UNITY_MATRIX_VP,worldPos);

				o.ScreenPos = ComputeScreenPos(o.vertex);
				o.refrScreenPos=ComputeScreenPos(mul(_RefractCameraVP,worldPos));	

				o.bumpCoords.xyzw= (worldPos.xzxz + _Time.yyyy * _BumpDirection.xyzw) * _BumpTiling.xyzw;	

				return o;
			}

			float3x3 excuteM(float3 worldPos)
			{
				float co=cos(_W*dot(_Dir,worldPos)+_XZ*_Time.y);
				float so=sin(_W*dot(_Dir,worldPos)+_XZ*_Time.y);
				float WA=_W*_A;

				float3 B;		
				B.x=1-_Q*pow(_Dir.x,2)*WA*so;
				B.z=-_Q*_Dir.x*_Dir.z*WA*so;
				B.y=_Dir.x*WA*co;


				float3 T;	
				T.x=-_Q*_Dir.x*_Dir.y*WA*so;	
				T.z=1-_Q*pow(_Dir.z,2)*WA*so;
				T.y=_Dir.z*WA*co;

				float3 N=cross(B,T);

				float3x3 M={B,N,T};

				M=transpose(M);//因为是正交矩阵 所以逆矩阵==转置矩阵

				return M;//求得 切线空间To时间空间的矩阵
			}
			
			float3 PerPixelNormal(sampler2D bumpMap, float4 coords, float bumpStrength) 
			{
	
				float2 bump = (UnpackNormal(tex2D(bumpMap, coords.xy)) + UnpackNormal(tex2D(bumpMap,coords.zw))) * 0.5;
	
				bump+= (UnpackNormal(tex2D(bumpMap, coords.xy*2))*0.5 + UnpackNormal(tex2D(bumpMap,coords.zw*2))*0.5) * 0.5;
	
				bump+= (UnpackNormal(tex2D(bumpMap, coords.xy*8))*0.5 + UnpackNormal(tex2D(bumpMap,coords.zw*8))*0.5) * 0.5;
	
				float3 worldNormal = float3(0,0,0);
	
				worldNormal.xz= bump.xy * bumpStrength;
	
				worldNormal.y= 1;
	
				return worldNormal;

	
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float3 worldPos=i.worldPos;

				float3x3 B2W=excuteM(i.worldPos);

				float3 bumpNormal = PerPixelNormal(_BumpTex, i.bumpCoords, _BumpStrength);

				float3 worldNormal= normalize( mul(B2W, normalize( bumpNormal)));


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
