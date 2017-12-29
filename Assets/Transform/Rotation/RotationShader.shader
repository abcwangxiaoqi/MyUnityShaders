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
			float _Angle;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			/*float4x4 roundByY(float4 trans)
			{
				return float4x4(
					cos(_Angle),0,sin(_Angle),0,
					0,1,0,0,
					-sin(_Angle),0,cos(_Angle),0,
					0,0,0,1
					)
			}*/
			
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
