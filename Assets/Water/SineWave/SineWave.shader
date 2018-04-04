Shader "Unlit/SineWave"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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

			vector _A;
			vector _Dir;
			vector _Dir1;
			vector _Dir2;
			vector _Dir3;
			vector _W;
			vector _XZ;
			
			v2f vert (appdata v)
			{
				v2f o;
			

				float yoffset=_A[0]*sin(dot(_Dir,v.vertex)*_W[0]+_XZ[0]*_Time.y);
				float yoffset1=_A[1]*sin(dot(_Dir1,v.vertex)*_W[1]+_XZ[1]*_Time.y);
				float yoffset2=_A[2]*sin(dot(_Dir2,v.vertex)*_W[2]+_XZ[2]*_Time.y);
				float yoffset3=_A[3]*sin(dot(_Dir3,v.vertex)*_W[3]+_XZ[3]*_Time.y);
				v.vertex.y+=yoffset;
				v.vertex.y+=yoffset1;
				v.vertex.y+=yoffset2;
				v.vertex.y+=yoffset3;

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
