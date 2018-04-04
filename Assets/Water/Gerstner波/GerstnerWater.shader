// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/GerstnerWave"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "black" {}

		// example 1(1个波的高度y)
		/*
		_GAmplitude ("Wave Amplitude", float) = 0.3
		_GFrequency ("Wave Frequency", float) = 1.3
		_GSteepness ("Wave Steepness", float) = 1.0
		_GSpeed ("Wave Speed", float) = 1.2
		_GDirection ("Wave Direction", Vector) = (0.3 ,0.85, 0.85, 0.25)
		*/

		// example 2 (4个波合成的高度y)
		/*
		_GAmplitude ("Wave Amplitude", Vector) = (0.3 ,0.35, 0.25, 0.25)
		_GFrequency ("Wave Frequency", Vector) = (1.3, 1.35, 1.25, 1.25)
		_GSteepness ("Wave Steepness", Vector) = (1.0, 1.0, 1.0, 1.0)
		_GSpeed ("Wave Speed", Vector) = (1.2, 1.375, 1.1, 1.5)
		_GDirectionAB ("Wave Direction", Vector) = (0.3 ,0.85, 0.85, 0.25)
		_GDirectionCD ("Wave Direction", Vector) = (0.1 ,0.9, 0.5, 0.5)
		*/

		_GAmplitude ("Wave Amplitude", Vector) = (0.3 ,0.35, 0.25, 0.25)
		_GFrequency ("Wave Frequency", Vector) = (1.3, 1.35, 1.25, 1.25)
		_GSteepness ("Wave Steepness", Vector) = (1.0, 1.0, 1.0, 1.0)
		_GSpeed ("Wave Speed", Vector) = (1.2, 1.375, 1.1, 1.5)
		_GDirectionAB ("Wave Direction", Vector) = (0.3 ,0.85, 0.85, 0.25)
		_GDirectionCD ("Wave Direction", Vector) = (0.1 ,0.9, 0.5, 0.5)
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

			// example 1 (1个波的高度y)
			/*
			float _GAmplitude;
			float _GFrequency;
			float _GSteepness;
			float _GSpeed;
			Vector _GDirection;
			*/

			// example 2 (4个波合成的高度y)
			/*
			float4 _GAmplitude;
			float4 _GFrequency;
			float4 _GSteepness;
			float4 _GSpeed;
			Vector _GDirectionAB;
			Vector _GDirectionCD;
			*/

			// example 3 (结合GerstnerWave的公式，4个波合成 x,z的偏移，y的高度)
			///*
			float4 _GAmplitude;
			float4 _GFrequency;
			float4 _GSteepness;
			float4 _GSpeed;
			Vector _GDirectionAB;
			Vector _GDirectionCD;
			//*/
			
			// example 1(1个波的高度y)
			/*
			half CalculateWavesY(float3 worldPos)
			{
				half dotDir = dot(_GDirection.xy, worldPos.xz) * _GFrequency;
				half4 TIME = _Time.y * _GSpeed;
				half SIN = sin(dotDir + TIME);
				half y = _GAmplitude * SIN;
				return y;
			}
			*/

			// example 2 (4个波合成的高度y)
			/*
			half CalculateWavesY_4(float3 worldPos)
			{
				half4 dotDir = _GFrequency * half4(dot(_GDirectionAB.xy, worldPos.xz), dot(_GDirectionAB.zw, worldPos.xz), 
					dot(_GDirectionCD.xy, worldPos.xz), dot(_GDirectionCD.zw, worldPos.xz));

				half4 TIME = _Time.yyyy * _GSpeed;
				// 这里sin是针对half4执行的，所有得到的就是sin((dotDir + TIME).x),sin((dotDir + TIME).y)...
				half4 SIN = sin(dotDir + TIME);

				//half y = SIN.x * _GAmplitude.x + SIN.y * _GAmplitude.y + SIN.z * _GAmplitude.z + SIN.w * _GAmplitude.w;
				// 上面的可以用下面的来替换
				half y = dot(_GAmplitude, SIN);

				return y;
			}
			*/

			// example 3 (结合GerstnerWave的公式，4个波合成 x,z的偏移，y的高度)
			///*
			half3 CalculateOffset4(float3 worldPos)
			{
				half4 dotDir = _GFrequency * half4(dot(_GDirectionAB.xy, worldPos.xz), dot(_GDirectionAB.zw, worldPos.xz), 
					dot(_GDirectionCD.xy, worldPos.xz), dot(_GDirectionCD.zw, worldPos.xz));

				half4 TIME = _Time.yyyy * _GSpeed;

				half4 SIN = sin(dotDir + TIME);
				half y = dot(_GAmplitude, SIN);

				half4 COS = cos(dotDir + TIME);

				half4 xDir = half4(_GDirectionAB.x, _GDirectionAB.z, _GDirectionCD.x, _GDirectionCD.z);
				half x = dot(half4(_GSteepness * _GAmplitude * xDir) , COS);

				half4 zDir = half4(_GDirectionAB.y, _GDirectionAB.w, _GDirectionCD.y, _GDirectionCD.w);
				half z = dot(half4(_GSteepness * _GAmplitude * zDir) , COS);

				return half3(x, y, z);

			}
			//*/


			// Unity3D StandAsset的,(结合GerstnerWave的公式，4个波合成 x,z的偏移，y的高度)
			/*
			half3 GerstnerOffset4_Official (half2 xzVtx, half4 steepness, half4 amp, half4 freq, half4 speed, half4 dirAB, half4 dirCD) 
			{
				half3 offsets;
		
				half4 AB = steepness.xxyy * amp.xxyy * dirAB.xyzw;
				half4 CD = steepness.zzww * amp.zzww * dirCD.xyzw;
		
				half4 dotABCD = freq.xyzw * half4(dot(dirAB.xy, xzVtx), dot(dirAB.zw, xzVtx), dot(dirCD.xy, xzVtx), dot(dirCD.zw, xzVtx));
				half4 TIME = _Time.yyyy * speed;
		
				half4 COS = cos (dotABCD + TIME);
				half4 SIN = sin (dotABCD + TIME);
		
				offsets.x = dot(COS, half4(AB.xz, CD.xz));
				offsets.z = dot(COS, half4(AB.yw, CD.yw));
				offsets.y = dot(SIN, amp);

				return offsets;			
			}
			*/

			v2f vert (appdata_full v)
			{
				v2f o;

				// example 1(1个波的高度y)
				/*
				// 传世界的就是有可能面片会缩放
				half3 worldSpaceVertex = mul(_Object2World,(v.vertex)).xyz;
				half3 vtxForAni = (worldSpaceVertex).xyz;
				half y = CalculateWavesY(vtxForAni);
				v.vertex.y += y;
				*/

				// example 2 (4个波合成的高度y)
				/*
				half3 worldSpaceVertex = mul(_Object2World,(v.vertex)).xyz;
				half3 vtxForAni = (worldSpaceVertex).xyz;
				half y = CalculateWavesY_4(vtxForAni);
				v.vertex.y += y;
				*/

				// example 3 (结合GerstnerWave的公式，4个波合成 x,z的偏移，y的高度)
				///*
				half3 worldSpaceVertex = mul(unity_ObjectToWorld,(v.vertex)).xyz;
				half3 vtxForAni = (worldSpaceVertex).xzz;
				//float3 offset = GerstnerOffset4_Official(vtxForAni, _GSteepness, _GAmplitude, _GFrequency, _GSpeed, _GDirectionAB, _GDirectionCD);
				half3 offset = CalculateOffset4(v.vertex);
				v.vertex.xyz += offset.xyz;
				//*/

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
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
