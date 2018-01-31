Shader "Esfog/OutLine/Mix" 
{
    Properties 
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
    }
    SubShader 
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            uniform sampler2D _MainTex;
            uniform sampler2D _OcclusionTex;
            uniform sampler2D _StretchTex;
            
            float4 frag(v2f_img i):COLOR
            {
                float4 srcCol = tex2D(_MainTex,i.uv);
                float4 occlusionCol = tex2D(_OcclusionTex,i.uv);
                float4 stretchCol = tex2D(_StretchTex,i.uv);
                float occlusionTotal = occlusionCol.r + occlusionCol.g + occlusionCol.b;
                float stretchTotal = stretchCol.r + stretchCol.g + stretchCol.b;
                
                if(occlusionTotal <0.01f&&stretchTotal>0.01f)
                {
                    return float4(stretchCol.rgb,srcCol.a);
                }
                else
                {
                    return srcCol;
                }
            }
            
            ENDCG
        }
    } 
    FallBack "Diffuse"
}