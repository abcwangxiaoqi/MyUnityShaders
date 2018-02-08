Shader "Unlit/ImageEffect/Outline"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_PlayerMap("PlayerMap (RGB)", 2D) = "white" {}
		_BlurMap("BlurMap (RGB)", 2D) = "white" {}
		_OutlineColor("Outline Color", Color) = (1, 1, 1, 1)
	}

	SubShader
	{
		Pass
		{
			// No culling or depth
			Cull Off ZWrite Off ZTest Always

			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag

			sampler2D _MainTex;
			sampler2D _PlayerMap;
			sampler2D _BlurMap;
			fixed3 _OutlineColor;
			fixed _Intensity;

			struct a2v
			{
				fixed4 vertex : POSITION;
				fixed2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				fixed4 vertex : SV_POSITION;
				fixed2 uv : TEXCOORD0;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord.xy;
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, i.uv);
				fixed4 s = tex2D(_PlayerMap, i.uv);
				fixed4 b = tex2D(_BlurMap, i.uv);

				//扣出描边
				fixed4 o = b - s;

				float aFlag=step(0,o.a);

				//描边部分显示描边 其他显示_MainTex
				o.rgb=lerp(_OutlineColor,c.rgb,aFlag);

				o.a = c.a;

				return o;
			}

			ENDCG
		}
	}

	Fallback off
}
