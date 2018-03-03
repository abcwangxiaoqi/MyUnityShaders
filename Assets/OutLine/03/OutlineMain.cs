using UnityEngine;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class OutlineMain : MonoBehaviour
{
	//模糊半径
	[Range(1,10)]
	public float BlurRadius;
    //降分辨率  
	[Range(0.8f,1)]
    public float Sample = 1;  

    //迭代次数  
	[Range(1,5)]
    public int iteration = 3;  
	public Shader blurShader;
	public Shader effectoutlineShader;
	public Color outlineColor = Color.white;

	public Camera outlineCamera;

	Material blurMaterial;
	Material outlineMaterial;
	// Use this for initialization
	void Start () {

		blurMaterial=new Material(blurShader);
		outlineMaterial=new Material(effectoutlineShader);
	}

	RenderTexture playerRT;
	private void OnPreRender()
	{
		playerRT = RenderTexture.GetTemporary(Screen.width, Screen.height, 0);
		outlineCamera.targetTexture = playerRT;
		outlineCamera.Render();
	}

	private void OnPostRender()
	{
		RenderTexture.ReleaseTemporary(playerRT);
	}

	RenderTexture blurRT;
	RenderTexture temp;

	void OnRenderImage(RenderTexture src, RenderTexture des)
	{		
		int width=(int)(Screen.width*Sample);
		int height=(int)(Screen.height*Sample);

		#region 进行模糊处理
		blurRT=RenderTexture.GetTemporary(width,height,0);	
		temp=RenderTexture.GetTemporary(width,height,0);
		Graphics.Blit(playerRT,blurRT);

		//进行多次迭代
		for (int i = 0; i < iteration; i++)
		{
			blurMaterial.SetFloat("_BlurRadius",BlurRadius);
			Graphics.Blit(blurRT,temp,blurMaterial);
			Graphics.Blit(temp,blurRT);
		}		
		RenderTexture.ReleaseTemporary(temp);
		#endregion		

		outlineMaterial.SetTexture("_PlayerMap", playerRT);
		outlineMaterial.SetTexture("_BlurMap", blurRT);
		outlineMaterial.SetColor("_OutlineColor", outlineColor);
		Graphics.Blit(src, des, outlineMaterial);		
		RenderTexture.ReleaseTemporary(blurRT);		
	}
}