Shader "Unlit/turnAround2"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Speed("speed",float)=50
	}
	SubShader
	{
		Tags {"Queue"="Transparent" "RenderType"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		//LOD 100

		Pass
		{
			Cull off
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
			float _Speed;

			float4x4 round()
			{
				float angle=_Time.y*_Speed;
				float radz=radians(angle);
				float sinN=sin(radz);
				float cosN=cos(radz);


				return float4x4(cosN,-sinN,0,0,
				sinN,cosN,0,0,
				0,0,1,0,
				0,0,0,1);				
			}
			
			v2f vert (appdata v)
			{
				v2f o;
				v.vertex=mul(round(),v.vertex);
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
