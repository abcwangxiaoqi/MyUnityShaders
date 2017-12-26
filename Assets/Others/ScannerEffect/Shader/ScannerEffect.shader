Shader "Unlit/ScannerEffect"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_ScanDistance("Scan Distance", float) = 0
		_ScanWidth("Scan Width", float) = 10
		_ScanColor("Scan Color", Color) = (1, 1, 1, 0)
	}
	SubShader
	{
		Cull Off
		ZWrite Off
		ZTest Always

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
				float2 uv_depth : TEXCOORD1;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv.xy;
				o.uv_depth = v.uv.xy;

				return o;
			}

			sampler2D _MainTex;
			sampler2D _CameraDepthTexture;
			float _ScanDistance;
			float _ScanWidth;
			float4 _ScanColor;


			half4 frag (v2f i) : SV_Target
			{
				half4 col = tex2D(_MainTex, i.uv);

				//获取深度信息
				float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
				float linear01Depth = Linear01Depth(depth);// Z buffer to linear 0..1 depth (0 at eye, 1 at far plane)

				//_ScanDistance 标示目前扫描的距离位置
				//linear01Depth<1 为了防止背景也被扫描
				//0.2 代表扫描的宽度
				if (linear01Depth < _ScanDistance && linear01Depth > _ScanDistance - 0.2 && linear01Depth < 1)
				{
					float diff = 1-(_ScanDistance - linear01Depth) / (0.2);//1-  表示扫描范围 近颜色淡 远颜色深 一个线性的标示
					_ScanColor *= diff;
					return col + _ScanColor;//颜色混合
				}

				return col;
			}
			ENDCG
		}
	}
}
