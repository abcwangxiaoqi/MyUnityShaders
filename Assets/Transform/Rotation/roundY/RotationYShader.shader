/*

3D

绕Y旋转矩阵 Y表示旋转角度
cosY    0    sinY    0
0       1      0     0
-sinY   0    cosY    0
0       0      0     1

*/
Shader "Unlit/RotationYShader"
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

			v2f vert (appdata v)
			{
				v2f o;

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
