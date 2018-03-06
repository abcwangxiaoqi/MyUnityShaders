// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Test"
{
	Properties
	{
		_Value("Value", Range(1, 50)) = 1
	}
		SubShader
	{
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
		float4 vertex : SV_POSITION;
		float2 uv : TEXCOORD0;
	};

	half _Value;

	v2f vert(appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = v.uv;
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		//映射到(-1, 1)，使其中心点为原点
		float2 uv = i.uv * 2 - float2(1, 1);
		float v;

		//v = 1 / abs(_Value * uv.y);//1
		//v = 1 / abs(_Value * (uv.y + uv.x));//2
		//v = 1 / abs(_Value * (uv.y + 2 * uv.x));//3
		v = 1 / abs(_Value * (abs(uv.y) + abs(uv.x)));//4
		//v = 1 / abs(_Value * length(uv));//5
		//v = 1 / abs(_Value * abs(length(uv) - 0.5));//6
		//v = 1 / abs(_Value * abs(uv.x / uv.y));//7 x越小y越大，则越亮

		return fixed4(v, v, v, 1);
	}
		ENDCG
	}
	}
}
