#ifndef MY_CG_INCLUDE
#define MY_CG_INCLUDE

	float3 normalToClip(float3 normal)
	{
		
        float3 viewNormal= mul((float3x3)UNITY_MATRIX_IT_MV, normal);
		float3 clipNormal=mul((float3x3)UNITY_MATRIX_P, viewNormal);
		return clipNormal;
	}

	//得到位移矩阵
	float4x4 MoveMatrix(float4 trans)
	{
		return float4x4(1,0,0,trans.x,
						0,1,0,trans.y,
						0,0,1,trans.z,
						0,0,0,1
						);
	}

	//缩放矩阵
	float4x4 ScaleMatrix(float4 scale)
	{
		return float4x4(scale.x, 0, 0, 0,
						0, scale.y, 0, 0,
						0, 0, scale.z, 0,
						0, 0, 0, 1
						);
	}

	//绕X轴旋转矩阵
	/*
	绕X旋转矩阵 X表示旋转角度
	1     0    	 0      0
	0	 cosX  -sinX    0
	0    sinX   cosX    0
	0	  0      0      1
	*/
	float4x4 roundXMatrix(float angle)
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
	float4x4 roundYMatrix(float angle)
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
	float4x4 roundZMatrix(float angle)
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
	float4x4 roundMatrix(float3 rot)
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

#endif