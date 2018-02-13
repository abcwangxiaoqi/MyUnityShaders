using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class SampleBlurProMain : MonoBehaviour {

	//模糊半径
	[Range(1,10)]
	public float BlurRadius;

	[Range(0,6), Tooltip("[降采样次数]向下采样的次数。此值越大,则采样间隔越大,需要处理的像素点越少,运行速度越快。")] 
	public int DownSampleNum = 2;  

    //迭代次数  
	[Range(1,5)]
    public int iteration = 3;  

	public Shader shader;
	Material material;
	// Use this for initialization
	void Start () {

		material=new Material(shader);
		
	}

	void OnRenderImage(RenderTexture src, RenderTexture des)
	{
		/*
		均值模糊 改进 迭代模糊
		也就是用上一次模糊的输出作为下一次模糊的输入，迭代之后的模糊效果更加明显
		 */
		
		int width=Screen.width>>DownSampleNum;
		int height=Screen.height>>DownSampleNum;
		RenderTexture RT1=RenderTexture.GetTemporary(width,height,0);	
		RenderTexture RT2=RenderTexture.GetTemporary(width,height,0);			

		Graphics.Blit(src,RT1);

		//进行多次迭代
		for (int i = 0; i < iteration; i++)
		{
			material.SetFloat("_BlurRadius",BlurRadius);
			Graphics.Blit(RT1,RT2,material);
			Graphics.Blit(RT2,RT1);
		}		
		Graphics.Blit(RT1,des);

		RenderTexture.ReleaseTemporary(RT1);
		RenderTexture.ReleaseTemporary(RT2);
	}
}
