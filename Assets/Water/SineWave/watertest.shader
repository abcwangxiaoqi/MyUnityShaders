// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Water/SeaWaveTest" {
Properties 
{
 
    _Skybox("Skybox",Cube)=""{}
 
    _BumpTex("Bump Texture", 2D) = "white"{}
 
    _BumpStrength("Bump strength", Range(0.0, 10.0)) = 1.0
 
    _BumpDirection("Bump direction(2 wave)", Vector)=(1,1,1,-1)
 
    _BumpTiling("Bump tiling", Vector)=(0.0625,0.0625,0.0625,0.0625)
 
    _ReflOffset("reflectionoffset", Range(0, 1))=0.8
 
}
 
SubShader 
{
 
    Tags{ "RenderType"="Opaque""LightMode"="ForwardBase"}
 
    LOD 100
 
  
 
    Pass
 
    {
 
        CGPROGRAM
 
        #pragma vertex vert
 
        #pragma fragment frag
 
        #pragma multi_compile_fwdbase
 
                           
 
        #include"UnityCG.cginc"
 
  
 
        struct appdata
 
        {
 
            float4 vertex : POSITION;
 
            float2 uv : TEXCOORD0;
 
        };
 
  
 
        struct v2f 
        {
 
            float3 screenPos:TEXCOORD0;
 
            float4 bumpCoords:TEXCOORD1;
 
            float3 worldPos:TEXCOORD2;
 
            float4 vertex : SV_POSITION;
 
        };
 
                           
 
        //gerstnerwave params.defined in GerstnerWave.cs
 
        float4 _QA;
 
        float4 _A;
 
        float4 _S;
 
        float4 _Dx;
 
        float4 _Dz;
 
        float4 _W;
 
        //
 
        sampler2D _ReflTexture;
 
        samplerCUBE _Skybox;
 
        //bumptex
 
        sampler2D _BumpTex;
 
        float _BumpStrength;
 
        float4 _BumpDirection;
 
        float4 _BumpTiling;


 
                           
 
        float _ReflOffset;
 
 
        float3 CalculateWavesDisplacement(float3 vert)
 
        {
 
            float3 pos = float3(0,0,0);
 
            float4 phase = _Dx*vert.x+_Dz*vert.z+_S*_Time.y;
 
            float4 sinp=float4(0,0,0,0), cosp=float4(0,0,0,0);
 
            sincos(_W*phase,sinp, cosp);
 
  
 
            pos.x= dot(_QA*_Dx, cosp);
 
            pos.z= dot(_QA*_Dz, cosp);
 
            pos.y= dot(_A, sinp);
 
  
 
            return pos;
 
        }
 
        float3 CalculateWavesNormal(float3 vert)
 
        {
 
            float3 nor = float3(0,0,0);
 
            float4 phase = _Dx*vert.x+_Dz*vert.z+_S*_Time.y;
 
            float4 sinp=float4(0,0,0,0), cosp=float4(0,0,0,0);
 
            sincos(_W*phase,sinp, cosp);
 
  
 
            nor.x= -dot(_W*_A*_Dx, cosp);
 
            nor.z= -dot(_W*_A*_Dz, cosp);
 
            nor.y= 1-dot(_QA*_W, sinp);
 
  
 
            nor= normalize(nor);
 
  
 
            return nor;
 
        }
 
        float3 CalculateWavesDisplacementNormal(float3 vert, out float3 nor)
 
        {
 
            float3 pos = float3(0,0,0);
 
            float4 phase = _Dx*vert.x+_Dz*vert.z+_S*_Time.y;
 
            float4 sinp=float4(0,0,0,0), cosp=float4(0,0,0,0);
 
            sincos(_W*phase,sinp, cosp);
 
  
 
            pos.x= dot(_QA*_Dx, cosp);
 
            pos.z= dot(_QA*_Dz, cosp);
 
            pos.y= dot(_A, sinp);
 
  
 
            nor.x= -dot(_W*_A*_Dx, cosp);
 
            nor.z= -dot(_W*_A*_Dz, cosp);
 
            nor.y= 1-dot(_QA*_W, sinp);
 
  
 
            nor= normalize(nor);
 
  
 
            return pos;
 
        }
 
        void CalculateWavesBinormalTangent(float3 vert, out float3 binormal, out float3 tangent)
 
        {
 
            float4 phase = _Dx*vert.x+_Dz*vert.z+_S*_Time.y;
 
                                    
 
            float4 sinp=float4(0,0,0,0), cosp=float4(0,0,0,0);
 
                                    
 
            sincos(_W*phase,sinp, cosp);
 
  
 
            binormal= float3(0,0,0);
 
            binormal.x= 1-dot(_QA, _Dx*sinp*_Dx*_W);
 
            binormal.z= -dot(_QA, _Dz*sinp*_Dz*_W);
 
            binormal.y= dot(_A, _Dx*cosp*_W);
 
                                    
 
            tangent= float3(0,0,0);
 
            tangent.x= -dot(_QA, _Dx*sinp*_Dz*_W);
 
            tangent.z= 1-dot(_QA, _Dz*sinp*_Dz*_W);
 
            tangent.y= dot(_A, _Dz*cosp*_W);
 
  
 
            binormal= normalize(binormal);
 
            tangent= normalize(tangent);
 
        }
 
                           
 
        float3 PerPixelNormal(sampler2D bumpMap, float4 coords, float bumpStrength)
 
        {
 
            float2 bump = (UnpackNormal(tex2D(bumpMap, coords.xy)) + UnpackNormal(tex2D(bumpMap,coords.zw))) * 0.5;
 
            bump+= (UnpackNormal(tex2D(bumpMap, coords.xy*2))*0.5 + UnpackNormal(tex2D(bumpMap,coords.zw*2))*0.5) * 0.5;
 
            bump+= (UnpackNormal(tex2D(bumpMap, coords.xy*8))*0.5 + UnpackNormal(tex2D(bumpMap,coords.zw*8))*0.5) * 0.5;
 
            float3 worldNormal = float3(0,0,0);
 
            worldNormal.xz= bump.xy * bumpStrength;
 
            worldNormal.y= 1;
 
            return worldNormal;

 
        }
 
  
        v2f vert (appdata v)
 
        {
 
             v2f o;
 
             float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
 
             float3 disPos = CalculateWavesDisplacement(worldPos);
 
             worldPos= worldPos+disPos;
 
             v.vertex.xyz= mul(unity_WorldToObject, float4(worldPos, 1));
 
             o.vertex= UnityObjectToClipPos(v.vertex);
 
             o.screenPos= ComputeScreenPos(o.vertex).xyw;
 
             o.worldPos= worldPos;
 
             o.bumpCoords.xyzw= (worldPos.xzxz + _Time.yyyy * _BumpDirection.xyzw) * _BumpTiling.xyzw;
 
             return o;
 
         }
 
                           
 
         float4 frag (v2f i) : SV_Target
 
         {
 
              float3 viewVector = normalize(i.worldPos - _WorldSpaceCameraPos.xyz);
 
              //calculatenormal
 
              float3 binormal = float3(0,0,0);
 
              float3 tangent = float3(0,0,0);
 
              CalculateWavesBinormalTangent(i.worldPos,binormal, tangent);
 
              float3 worldNormal = normalize(cross(tangent, binormal));
 
              float3x3 M = {binormal, worldNormal, tangent};//from world coord to tangent coord
 
              M=transpose(M);
 
              float3 bumpNormal = PerPixelNormal(_BumpTex, i.bumpCoords, _BumpStrength);
 
              //worldNormal= normalize( mul(M, normalize( bumpNormal)));
 
                                    
 
              //reflect
 
              float3 reflUV = reflect( viewVector, worldNormal);
 
              float2 offsets = worldNormal.xz*viewVector.y;
 
              float4 reflectionColor = tex2D(_ReflTexture,i.screenPos.xy/i.screenPos.z+offsets*_ReflOffset);
 
                                    
 
              float3 skyColor = texCUBE(_Skybox,reflUV);
 
              reflectionColor.xyz= lerp(skyColor, reflectionColor.xyz,reflectionColor.a);//==reflectionColor.xyz+(1-reflectionColor.a)*skyColor;
 
                                    
 
              return reflectionColor;
 
            }
 
          ENDCG 
        }
    }
}