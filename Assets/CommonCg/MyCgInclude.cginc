#ifndef MY_CG_INCLUDE
// Upgrade NOTE: excluded shader from OpenGL ES 2.0 because it uses non-square matrices
#pragma exclude_renderers gles
#define MY_CG_INCLUDE

	/*
	获取深度值 
	为什么要1-d ？
	因为 深度越深，越接近黑色，就越趋近于0；深度越潜，越接近白色，就越趋近于1	
	*/
	inline float getDepth(sampler2D Tex,float2 uv)
	{
		return 1-Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(Tex, uv)));
	}

	//视角与法线夹角
	inline float DotViewAndNormal(in float3 worldNormal,in float3 worldPos)
	{
		float3 wNormal=normalize(worldNormal);
		float3 viewDir=normalize(UnityWorldSpaceViewDir(worldPos));
		return dot(wNormal,viewDir);
	}

	inline float3 normalToClip(in float3 normal)
	{
		
        float3 viewNormal= mul((float3x3)UNITY_MATRIX_IT_MV, normal);
		float3 clipNormal=mul((float3x3)UNITY_MATRIX_P, viewNormal);
		return clipNormal;
	}

	/*得到位移矩阵
	1	0	0	TX
	0	1	0	TY
	0	0	1	TZ
	0	0	0	1
	*/
	inline float4x4 MoveMatrix(in float4 trans)
	{
		return float4x4(1,0,0,trans.x,
						0,1,0,trans.y,
						0,0,1,trans.z,
						0,0,0,1
						);
	}

	/*缩放矩阵
		放大缩小矩阵
		SX   0    0    0
		0    SY	 0    0
		0     0   SZ   0
		0     0    0    1
	*/
	inline float4x4 ScaleMatrix(in float4 scale)
	{
		return float4x4(scale.x, 0, 0, 0,
						0, scale.y, 0, 0,
						0, 0, scale.z, 0,
						0, 0, 0, 1
						);
	}

	/*
	2d 旋转矩阵
	*/
	inline float2x2 twoDRoundMatrix(in float angle)
	{
		float rady=radians(angle);
		float sinN=sin(rady);
		float cosN=cos(rady);

		return float2x2(cosN,-sinN,
						sinN,cosN);
	}

	//绕X轴旋转矩阵
	/*
	绕X旋转矩阵 X表示旋转角度
	1     0    	 0      0
	0	 cosX  -sinX    0
	0    sinX   cosX    0
	0	  0      0      1
	*/
	inline float4x4 roundXMatrix(in float angle)
	{
		float rady=radians(angle);
		float sinN=sin(rady);
		float cosN=cos(rady);


		return float4x4(1,0,0,0,
						0,cosN,-sinN,0,
						0,sinN,cosN,0,
						0,0,0,1);
	}	

	//绕Y轴旋转矩阵
	/*
	绕Y旋转矩阵 Y表示旋转角度
	cosY    0    sinY    0
	0       1      0     0
	-sinY   0    cosY    0
	0       0      0     1
	*/
	inline float4x4 roundYMatrix(in float angle)
	{
		float rady=radians(angle);
		float sinN=sin(rady);
		float cosN=cos(rady);


		return float4x4(cosN,0,sinN,0,
						0,1,0,0,
						-sinN,0,cosN,0,
						0,0,0,1);
	}

	//绕Z轴旋转矩阵
	/*
	绕Z旋转矩阵 Z表示旋转角度
	cosZ    -sinZ    0    0
	sinZ     cosZ    0    0
	0          0     1    0
	0          0     0    1
	*/
	inline float4x4 roundZMatrix(in float angle)
	{
		float rady=radians(angle);
		float sinN=sin(rady);
		float cosN=cos(rady);


		return float4x4(cosN,-sinN,0,0,
						sinN,cosN,0,0,
						0,0,1,0,
						0,0,0,1);
	}

	//旋转矩阵
	/*
	绕x,y,z旋转矩阵是上面三个矩阵的相乘得到
	cosYcosZ					-cosYcosZ					sinY				0
	cosXsinZ + sinXsinYcosZ		cosXcosZ - sinXsinYsinZ		-sinXcosY			0
	sinXsinZ - cosXsinYcosZ		sinXcosZ + cosXsinYsinZ		cosXcosY			0
	0							0							0					1
	*/
	inline float4x4 roundMatrix(in float3 rot)
	{
		float radx=radians(rot.x);
		float rady=radians(rot.y);
		float radz=radians(rot.z);

		float sinx=sin(radx);
		float cosx=cos(radx);
		float siny=sin(rady);
		float cosy=cos(rady);
		float sinz=sin(radz);
		float cosz=cos(radz);

		return float4x4(cosy*cosz,-cosy*sinz,siny,0,
						cosx*sinz+sinx*siny*cosz,cosx*cosz-sinx*siny*sinz,-sinx*cosy,0,
						sinx*sinz-cosx*siny*cosz,sinx*cosz+cosx*siny*sinz,cosx*cosy,0,
						0,0,0,1);
				
	}

	//lambert light model
	inline float3 Lambert(in float3 worldNormal,in float3 worldPos)
	{
		worldNormal=normalize(worldNormal);
		float3 worldLightDir=normalize(UnityWorldSpaceLightDir(worldPos));
		fixed3 lambert = max(0.0, dot(worldNormal, worldLightDir));  
		return lambert;
	}

	inline float3 Lambert_DiffLightAmbient(in float3 worldNormal,in float3 worldPos,in float3 diffuse,in float3 ambient)
	{
		float3 lambert=Lambert(worldNormal,worldPos);
		return lambert*diffuse*unity_LightColor0.xyz+ambient;
	}

	//half lambert light model
	inline float3 HalfLambert(in float3 worldNormal,in float3 worldPos)
	{
		worldNormal=normalize(worldNormal);
		float3 worldLightDir=normalize(UnityWorldSpaceLightDir(worldPos));
		fixed3 lambert =  0.5 * dot(worldNormal, worldLightDir) + 0.5;;  
		return lambert;
	}

	inline float3 HalfLambert_DiffLightAmbient(in float3 worldNormal,in float3 worldPos,in float3 diffuse,in float3 ambient)
	{
		float3 lambert=HalfLambert(worldNormal,worldPos);
		return lambert*diffuse*unity_LightColor0.xyz+ambient;
	}

	//unity 自带环境光
	inline float3 unityAmbient(in float3 diffuse)
	{
		return UNITY_LIGHTMODEL_AMBIENT.xyz * diffuse.xyz;
	}

#endif