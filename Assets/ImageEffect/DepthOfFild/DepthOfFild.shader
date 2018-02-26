Shader "Unlit/DepthOfFild"
{
	Properties
	{
		//主纹理
		_MainTex("Base (RGB)", 2D) = "white" {}
		_BlurTex("BlurTex", 2D) = "white" {}
		_FieldDepth("FieldDepth",Range(0.1,1))=0.5
	}

	SubShader
	{
		ZWrite Off
		Blend Off

		//通道1：垂直方向模糊处理通道
		Pass
		{
			ZTest Always
			Cull Off

			CGPROGRAM

			#pragma vertex vert_BlurVertical
			#pragma fragment frag_Blur

			ENDCG
		}

		//通道2：水平方向模糊处理通道 
		Pass
		{
			ZTest Always
			Cull Off

			CGPROGRAM

			#pragma vertex vert_BlurHorizontal
			#pragma fragment frag_Blur

			ENDCG
		}

		//通道3：景深
		Pass
		{
			ZTest Always
			Cull Off

			CGPROGRAM

			#pragma vertex vert_Depthofield
			#pragma fragment frag_Depthofield

			ENDCG
		}
	}


	CGINCLUDE
	#include "UnityCG.cginc"
	#include "../../CommonCg/MyCgInclude.cginc"
	sampler2D _MainTex;
	//UnityCG.cginc中内置的变量，纹理中的单像素尺寸
	uniform half4 _MainTex_TexelSize;
	uniform half _DownSampleValue;

	struct VertexInput
	{
		float4 vertex : POSITION;
		half2 texcoord : TEXCOORD0;
	};	

	//【8】顶点输入结构体 || Vertex Input Struct
	struct VertexOutput_Blur
	{
		float4 pos : SV_POSITION;
		half2 uv : TEXCOORD0;
		half2 offsets[7]:TEXCOORD1;
	};

	struct VertexOutput_Field
	{
		float4 pos : SV_POSITION;
		half2 uv : TEXCOORD0;
	};

	VertexOutput_Blur vert_BlurHorizontal(VertexInput v)
	{
		VertexOutput_Blur o;

		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;

		/*x轴周围点的 uv*/
		o.offsets[0]=o.uv+_MainTex_TexelSize.xy * half2(-3.0, 0.0) * _DownSampleValue;
		o.offsets[1]=o.uv+_MainTex_TexelSize.xy * half2(-2.0, 0.0) * _DownSampleValue;
		o.offsets[2]=o.uv+_MainTex_TexelSize.xy * half2(-1.0, 0.0) * _DownSampleValue;
		o.offsets[3]=o.uv+_MainTex_TexelSize.xy * half2(0.0, 0.0) * _DownSampleValue;
		o.offsets[4]=o.uv+_MainTex_TexelSize.xy * half2(1.0, 0.0) * _DownSampleValue;
		o.offsets[5]=o.uv+_MainTex_TexelSize.xy * half2(2.0, 0.0) * _DownSampleValue;
		o.offsets[6]=o.uv+_MainTex_TexelSize.xy * half2(3.0, 0.0) * _DownSampleValue;
		return o;
	}

	VertexOutput_Blur vert_BlurVertical(VertexInput v)
	{
		VertexOutput_Blur o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord;

		/*y轴周围点的 uv*/
		o.offsets[0]=o.uv+_MainTex_TexelSize.xy * half2(0.0, -3.0) * _DownSampleValue;
		o.offsets[1]=o.uv+_MainTex_TexelSize.xy * half2(0.0, -2.0) * _DownSampleValue;
		o.offsets[2]=o.uv+_MainTex_TexelSize.xy * half2(0.0, -1.0) * _DownSampleValue;
		o.offsets[3]=o.uv+_MainTex_TexelSize.xy * half2(0.0, 0.0) * _DownSampleValue;
		o.offsets[4]=o.uv+_MainTex_TexelSize.xy * half2(0.0, 1.0)* _DownSampleValue;
		o.offsets[5]=o.uv+_MainTex_TexelSize.xy * half2(0.0, 2.0) * _DownSampleValue;
		o.offsets[6]=o.uv+_MainTex_TexelSize.xy * half2(0.0, 3.0) * _DownSampleValue;
		return o;
	}

	half4 frag_Blur(VertexOutput_Blur i) : SV_Target
	{
		half2 uv = i.uv;

		/*高斯模糊 权重分别为 0.0205，0.0855，0.232，0.324，0.232，0.0855，0.0205  所有权重加起来为1*/
		half4 color = 0;
		color+=0.0205*tex2D(_MainTex,i.offsets[0]);
		color+=0.0855*tex2D(_MainTex, i.offsets[1]);
		color+=0.232*tex2D(_MainTex, i.offsets[2]);
		color+=0.324*tex2D(_MainTex, i.offsets[3]);
		color+=0.232*tex2D(_MainTex, i.offsets[4]);
		color+=0.0855*tex2D(_MainTex, i.offsets[5]);
		color+=0.0205*tex2D(_MainTex, i.offsets[6]);
		return color;
	}


	sampler2D _CameraDepthTexture;
	sampler2D _BlurTex;
	float _FieldDepth;
	VertexOutput_Field vert_Depthofield(VertexInput v)
	{
		VertexOutput_Field o;

		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	}


	half4 frag_Depthofield(VertexOutput_Blur i) : SV_Target
	{
		half2 uv = i.uv;
		float camDepth=getDepth(_CameraDepthTexture,uv);

		half4 color = tex2D(_MainTex,uv);
		half4 blur=tex2D(_BlurTex,uv);


		float yz=1-saturate(abs(camDepth-_FieldDepth));

		return lerp(color,blur,yz);
	}
		
	ENDCG

	FallBack Off
}
