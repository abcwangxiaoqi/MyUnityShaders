Shader "Unlit/turnAround"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Main Texture", 2D) = "white" {}
		_RotateSpeed("Rotate Speed", Range(1, 10)) = 5
	}

	SubShader
	{
		tags{ "Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True" }
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			Cull off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			float4 _Color;
			sampler2D _MainTex;
			float _RotateSpeed;

			struct v2f
			{
				float4 pos:POSITION;
				float4 uv:TEXCOORD0;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}

			half4 frag(v2f i) :COLOR
			{
				//以纹理中心为旋转中心
				float2 uv = i.uv.xy - float2(0.5, 0.5);

				//2D旋转矩阵公式
				float speed = pow(_RotateSpeed, 2);
				float x = uv.x * cos(speed * _Time.x) - uv.y * sin(speed * _Time.x);
				float y = uv.x * sin(speed * _Time.x) + uv.y * cos(speed * _Time.x);
				uv = float2(x, y) + float2(0.5, 0.5);
				half4 c = tex2D(_MainTex , uv) * _Color;
				return c;
			}
			ENDCG
		}
	}
}