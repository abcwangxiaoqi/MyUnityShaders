Shader "Esfog/OutLine/Stretch" 
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
            uniform float4 _OutLineColor;
            uniform float4 _ScreenSize;
            
            float4 frag(v2f_img i):COLOR
            {
                float4 c = tex2D(_MainTex,i.uv);
                float4 c1 = tex2D(_MainTex,float2(i.uv.x-_ScreenSize.x,i.uv.y)); //左边一个像素
                float4 c2 = tex2D(_MainTex,float2(i.uv.x+_ScreenSize.x,i.uv.y)); //右边一个像素
                float3 totalCol = c.rgb + c1.rgb + c2.rgb;
                float avg = totalCol.r + totalCol.g + totalCol.b;
 
                if(avg > 0.01)
                {
                    return _OutLineColor;
                }
                else
                {
                    return float4(0,0,0,0);
                }
            }
            
            ENDCG
        }
        
        Pass
        {
            Blend One One
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            #include "UnityCG.cginc"
            uniform sampler2D _MainTex;
            uniform float4 _OutLineColor;
            uniform float4 _ScreenSize;
            
            float4 frag(v2f_img i):COLOR
            {
                float4 c = tex2D(_MainTex,i.uv);
                float4 c1 = tex2D(_MainTex,float2(i.uv.x,i.uv.y-_ScreenSize.y)); //下边一个像素
                float4 c2 = tex2D(_MainTex,float2(i.uv.x,i.uv.y+_ScreenSize.y)); //上边一个像素
                float3 totalCol = c.rgb + c1.rgb + c2.rgb;
                float avg = totalCol.r + totalCol.g + totalCol.b;
                if(avg > 0.01)
                {
                    return _OutLineColor;
                }
                else
                {
                    return float4(0,0,0,0);
                }
            }
            
            ENDCG
        }
    } 
    FallBack "Diffuse"
}