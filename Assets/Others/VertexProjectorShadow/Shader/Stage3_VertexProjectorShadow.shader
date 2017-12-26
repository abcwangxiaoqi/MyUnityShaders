Shader "Unlit/VertexProjectorShadow"
{
	Properties
	{
		_MainCol("Color", Color) = (0.8,0.8,0.8,1)//自身颜色
		_ShadowCol("Shadow Color" , Color) = (0,0,0,1)//阴影颜色
		_LightDir("Light Diretion" , vector) = (-1,1,0,0.05)//灯光方向
		_ShadowFalloff("Shadow Falloff" , Range(0.01,1)) = 1//阴影衰减
	}
		SubShader
	{
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		LOD 100

		//渲染本身的pass
		Pass
		{
			Name "ForwardBase"

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			fixed4 _MainCol;

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return _MainCol;
			}
			ENDCG
		}

		//阴影pass
		Pass
		{
			Name "Shadow"
			Stencil
			{
				Ref 0
				Comp equal
				Pass incrWrap
				Fail keep
				ZFail keep
			}

				//透明混合模式
				Blend SrcAlpha OneMinusSrcAlpha

				//关闭深度写入
				ZWrite off

				//深度稍微偏移防止阴影与自己穿插
				Offset 1 , 0

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
				};

				struct v2f
				{
					float4 vertex : SV_POSITION;
					float4 color : COLOR;
				};

				float4 _LightDir;
				float4 _ShadowCol;
				float _ShadowFalloff;

				float3 ShadowProjectPos(float4 vertDir)
				{
					float3 shadowPos;

					//得到顶点的世界空间坐标
					float3 wPos = mul(unity_ObjectToWorld , vertDir).xyz;

					//灯光方向
					float3 lightDir = normalize(_LightDir.xyz);

					//阴影的世界空间坐标
					shadowPos.y = _LightDir.w;
					shadowPos.xz = wPos.xz - lightDir.xz * (wPos.y - _LightDir.w) / lightDir.y;

					//低于地面的部分不计算阴影
					shadowPos = lerp(shadowPos , wPos,step(wPos.y - _LightDir.w , 0));

					return shadowPos;
				}


				v2f vert(appdata v)
				{
					v2f o;

					//得到阴影的世界空间坐标
					float3 shadowPos = ShadowProjectPos(v.vertex);

					//转换到裁切空间
					o.vertex = UnityWorldToClipPos(shadowPos);

					//得到中心点世界坐标
					float3 center = float3(unity_ObjectToWorld[0].w , _LightDir.w , unity_ObjectToWorld[2].w);

					//计算阴影衰减
					float falloff = saturate(1 - distance(shadowPos , center) * _ShadowFalloff);

					//阴影颜色
					o.color = _ShadowCol;
					o.color.a = falloff;

					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					return i.color;
				}
				ENDCG
			}

	}
}
