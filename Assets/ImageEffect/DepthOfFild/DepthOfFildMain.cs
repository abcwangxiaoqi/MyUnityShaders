using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DepthOfFildMain : MonoBehaviour {

    public Shader CurShader;
    private Material material;
	
	[Range(0.1f,1)]
	public float distance=0.5f;

    //降采样次数
    [Range(0, 6), Tooltip("[降采样次数]向下采样的次数。此值越大,则采样间隔越大,需要处理的像素点越少,运行速度越快。")]
    public int DownSampleNum = 2;
    //模糊扩散度
    [Range(0.0f, 20.0f), Tooltip("[模糊扩散度]进行高斯模糊时，相邻像素点的间隔。此值越大相邻像素间隔越远，图像越模糊。但过大的值会导致失真。")]
    public float BlurSpreadSize = 3.0f;
    //迭代次数
    [Range(0, 8), Tooltip("[迭代次数]此值越大,则模糊操作的迭代次数越多，模糊效果越好，但消耗越大。")]
    public int BlurIterations = 3;

    void Start()
    {
        material=new Material(CurShader);
		Camera.main.depthTextureMode |= DepthTextureMode.Depth; 
    }

    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        //通过右移，准备长、宽参数值
        int renderWidth = sourceTexture.width >> DownSampleNum;
        int renderHeight = sourceTexture.height >> DownSampleNum;

        // 【1】处理Shader的通道0，用于降采样 ||Pass 0,for down sample
        //准备一个缓存renderBuffer，用于准备存放最终数据
        RenderTexture renderBuffer = RenderTexture.GetTemporary(renderWidth, renderHeight);
        RenderTexture tempBuffer = RenderTexture.GetTemporary(renderWidth, renderHeight);
        //拷贝sourceTexture中的渲染数据到renderBuffer,并仅绘制指定的pass0的纹理数据
        Graphics.Blit(sourceTexture, renderBuffer);

        //【2】根据BlurIterations（迭代次数），来进行指定次数的迭代操作
        for (int i = 0; i < BlurIterations; i++)
        {
            //Shader的降采样参数赋值
            material.SetFloat("_DownSampleValue", BlurSpreadSize + i);

            //垂直方向模糊处理
            Graphics.Blit(renderBuffer, tempBuffer, material, 0);

            // 水平方向模糊处理
            Graphics.Blit(tempBuffer, renderBuffer, material, 1);
        }

		material.SetTexture("_BlurTex",renderBuffer);
		material.SetFloat("_FieldDepth",distance);

		Graphics.Blit(sourceTexture, destTexture, material, 2);

        RenderTexture.ReleaseTemporary(tempBuffer);
        RenderTexture.ReleaseTemporary(renderBuffer);
    }
}
