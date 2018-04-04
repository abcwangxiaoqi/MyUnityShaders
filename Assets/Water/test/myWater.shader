Shader "Unlit/myWater"
{
	Properties
	{
		_Indentity("Indentity",Range(0.1, 0.5))=0.1
		_Color("Base Color",Color)=(1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_WaveNoiseTex("WaveNoiseTex (RGB)", 2D) = "white"{}
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "RenderType"="Transparent" }
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
				float4 vertex : POSITION;
			};

			float4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _WaveNoiseTex;
			float _Indentity;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);//MVP 矩阵转换
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//根据噪声贴图 得到偏移的UV
				float2 offsetY = tex2D(_WaveNoiseTex,i.uv.xy + float2(0,_Time.x)).gb;
				float2 offsetX = tex2D(_WaveNoiseTex, i.uv.xy + float2(_Time.x,0)).gb;
				float2 waveOffset = (offsetY + offsetX)/2;//得到正确的uv偏移值 必须在0~1之间 所以要除以2

				float2 ruv = i.uv.xy + waveOffset.xy*_Indentity;

				//也可以用 1-i.uv.y y纹理方向倒过来
				//float2 ruv = float2(i.uv.x,1-i.uv.y) + waveOffset.xy*_Indentity;

				fixed4 col = tex2D(_MainTex, ruv);
				return col;
			}
			ENDCG
		}
	}
}
