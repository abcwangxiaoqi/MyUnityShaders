// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Esfog/OutLine/Depth" 
{
    SubShader 
    {
        Tags { "RenderType"="Opaque" }
        Pass 
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f 
            {
                float4 pos : SV_POSITION;
                float2 depth : TEXCOORD0;
            };

            v2f vert (appdata_base v) 
            {
                v2f o;
                o.pos = UnityObjectToClipPos (v.vertex);
                o.depth = o.pos.zw;
                return o;
            }

            half4 frag(v2f i) : COLOR 
            {
                half x= Linear01Depth(i.depth.x/i.depth.y);
                return half4(x, x, x, x);
            }
            ENDCG
        }
    }
}