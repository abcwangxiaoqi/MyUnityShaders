#ifndef MY_CG_INCLUDE
#define MY_CG_INCLUDE

	float3 normalToClip(float3 normal)
	{
        float3 worldNor=UnityObjectToWorldNormal(normal);
		float3 clipNor=mul(UNITY_MATRIX_VP,worldNor);
		return normalize(clipNor);
	}

#endif