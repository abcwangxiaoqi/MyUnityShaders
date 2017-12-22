Shader "Mya/Mya_GridBlend_World_Relative"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}
        _TexBlend("Main Blend" , float) = 1
        _GridTex ("Grid Texture", 2D) = "white" {}
        _GridCol("Grid Color" , Color) = (0,1,1,1)
        _GridBlend("Grid Blend" , float) = 0
        _BlendRange("Blend Range" , Range(0,1)) = 1
	}
	SubShader
	{
		Tags {"Queue" = "Transparent" "RenderType"="Opaque" }
		LOD 100
		Pass
		{
            Name "GRID"
            Cull Off
            ZWrite Off
            Blend One One
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
                float4 pos : SV_POSITION;
				float4 vertex : TEXCOORD1;
			};

			sampler2D _GridTex;
			float4 _GridTex_ST;
            fixed4 _GridCol;
			half _GridBlend, _BlendRange;
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _GridTex);
                float4 center = float4(unity_ObjectToWorld[0].w,unity_ObjectToWorld[1].w,unity_ObjectToWorld[2].w , 1);
                float4 wpos = mul(unity_ObjectToWorld, v.vertex) - center;
                o.vertex =wpos;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_GridTex, i.uv);

				return _GridCol * col * saturate( (i.vertex.y  + _GridBlend)/ _BlendRange);
			}
			ENDCG
		}
        Pass
        {
            ZWrite On
            ColorMask 0
        }
		Pass
		{
            Name "MAIN"
            blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

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
                float4 pos : SV_POSITION;
				float4 vertex : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
            float _TexBlend , _BlendRange , _GridBlend;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float4 center = float4(unity_ObjectToWorld[0].w,unity_ObjectToWorld[1].w,unity_ObjectToWorld[2].w , 1);
                float4 wpos = mul(unity_ObjectToWorld, v.vertex) - center;
                o.vertex =wpos;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return col * saturate( (i.vertex.y + _TexBlend ) /_BlendRange);
			}
			ENDCG
		}


	}
}
