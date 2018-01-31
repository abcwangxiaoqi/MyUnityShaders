// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Test/Outline" {
Properties {
    _MainTex ("Base (RGB)", 2D) = "white" {}
    _MainColor ("Color", Color) = (1, 1, 1, 1)
    _OutlineWidth ("OutlineWidth", Range(0,1)) = 0.05
    _OutlineColor ("OutlineColor", Color) = (1, 1, 1, 1)
}
 
SubShader {
    //Queue需要设置为Transparent透明队列，因为一般场景里面建筑物等物件的Queue都是Geometry不透明队列，这里需要保证
    //这个shader渲染的角色需要比场景不透明物件渲染得晚，这样才能知道深度有没被场景物件刷新过，当前shader渲染
    //的角色有没有被场景物件“遮住”
    Tags { "Queue"="Transparent" "RenderType"="Opaque" }
 
    CGINCLUDE
    #include "UnityCG.cginc"
    struct appdata_t {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
        float2 texcoord : TEXCOORD0;
    };
 
    struct v2f {
        float4 pos : SV_POSITION;
        half2 texcoord : TEXCOORD0;
    };
 
    sampler2D _MainTex;
    float4 _MainTex_ST;
    float4 _MainColor;
    float _OutlineWidth;
    float4 _OutlineColor;
 
    //没被遮住部分的顶点着色器
    v2f vert (appdata_t v)
    {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
        return o;
    }
 
    //被遮住部分的顶点着色器
    v2f vert_outline (appdata_t v)
    {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal); //将法线从模型坐标空间转换到摄像机坐标空间
        float2 offset = TransformViewToProjection(normal.xy); //将法线xy从摄像机坐标空间转换到投影坐标空间，把3D坐标转换成2D屏幕坐标
        //2D屏幕坐标加上对应的法线乘以倍率，模型越边缘的地方越和屏幕表面平行（和人眼观察方向垂直），
        //模型越边缘的地方2D屏幕坐标xy越横竖向扩大
        o.pos.xy += offset * _OutlineWidth;
        o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
        return o;
    }
 
    //没被遮住部分的片段着色器
    fixed4 frag (v2f i) : SV_Target
    {
        fixed4 col = tex2D(_MainTex, i.texcoord);
        col *= _MainColor;
        UNITY_OPAQUE_ALPHA(col.a);
        return col;
    }
 
    //被遮住部分的片段着色器
    fixed4 frag_outline (v2f i) : SV_Target
    {
        return _OutlineColor;
    }
    ENDCG
 
    //没被遮住部分的Pass
    Pass {
        ZTest LEqual
 
        Stencil
        {
            Ref 1
            Comp Always
            Pass Replace //没被遮住部分会把遮罩缓冲区中的值刷新为1
            ZFail Replace //被遮住部分也会把遮罩缓冲区中的值刷新为1
        }
 
        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
        ENDCG
    }
 
    //被遮住部分的Pass
    Pass {
        ZTest Greater
 
        Stencil
        {
            Ref 1
            //让它不等于1，即被遮住部分不渲染，那为什么被遮住部分的描边会被渲染出来呢？因为描边部分是扩大过的，
            //而上面第一个pass使用的vert着色器是没有扩大过的，也就是说第一个pass刷的Stencil遮罩范围只是正常渲染时
            //的范围，不包括第二个pass扩大部分的（即描边部分）
            Comp NotEqual
        }
 
        CGPROGRAM
        #pragma vertex vert_outline
        #pragma fragment frag_outline
        ENDCG
    }
}
 
}