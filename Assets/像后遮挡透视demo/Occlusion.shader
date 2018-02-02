Shader "Esfog/OutLine/Occlusion" 
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
            sampler2D _CameraDepthTexture;
            uniform float4 _OutLineColor;
            
            float4 frag(v2f_img i):COLOR
            {
                float playerDepth = Linear01Depth(tex2D(_MainTex,i.uv));

                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
				float bufferDepth = Linear01Depth(depth);

                //float bufferDepth =Linear01Depth(tex2D(_CameraDepthTexture,i.uv));
                
                float4 resColor = float4(0,0,0,0);
                if((playerDepth < 1.0) && (playerDepth- bufferDepth)>0.0002)
                {
                    //resColor = float4(_OutLineColor.rgb,1);
                    resColor = float4(1,0,0,1);
                }
                //return float4(playerDepth,0,0,1);
                //return float4(0,1,0,1);
                return resColor;
            }
            ENDCG
        }
    } 
    FallBack "Diffuse"
}