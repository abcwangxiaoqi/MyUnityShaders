/*

2D
旋转矩阵 A表示旋转角度
cosA  -sinA
sinA   cosA

*/

/*

3D
绕X旋转矩阵 X表示旋转角度
1     0    	 0      0
0	 cosX  -sinX    0
0    sinX   cosX    0
0	  0      0      1


绕Y旋转矩阵 Y表示旋转角度
cosY    0    sinY    0
0       1      0     0
-sinY   0    cosY    0
0       0      0     1


绕Z旋转矩阵 Z表示旋转角度
cosZ    -sinZ    0    0
sinZ     cosZ    0    0
0          0     1    0
0          0     0    1


绕x,y,z旋转矩阵是上面三个矩阵的相乘得到
cosYcosZ					-cosYcosZ					sinY				0
cosXsinZ + sinXsinYcosZ		cosXcosZ - sinXsinYsinZ		-sinXcosY			0
sinXsinZ - cosXsinYcosZ		sinXcosZ + cosXsinYsinZ		cosXcosY			0
0							0							0					1

*/
Shader "Unlit/RotationShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Angle("Angle",Range(0,360))=0
		_Rotation("rotation",vector)=(0,0,0,1)
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
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			uniform float _Angle;
			float4 _Rotation;

			float4x4 roundByY()
			{
				float rady=radians(_Angle);
				float sinN=sin(rady);
				float cosN=cos(rady);


				return float4x4(cosN,0,sinN,0,
				0,1,0,0,
				-sinN,0,cosN,0,
				0,0,0,1);
			}

			float4x4 round(float4 rot)
			{
				float radx=radians(rot.x);
				float rady=radians(rot.y);
				float radz=radians(rot.x);

				float sinx=sin(radx);
				float cosx=cos(radx);
				float siny=sin(rady);
				float cosy=cos(rady);
				float sinz=sin(radz);
				float cosz=cos(radz);

				return float4x4(cosy*cosz,-cosy*sinz,siny,0,
				cosx*sinz+sinx*siny*cosz,cosx*cosz-sinx*siny*sinz,-sinx*cosy,0,
				sinx*sinz-cosx*siny*cosz,sinx*cosz+cosx*siny*sinz,cosx*cosy,0,
				0,0,0,1);
				
			}

			v2f vert (appdata v)
			{
				v2f o;

				//v.vertex=mul(round(_Rotation),v.vertex);
				v.vertex=mul(roundByY(),v.vertex);

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
