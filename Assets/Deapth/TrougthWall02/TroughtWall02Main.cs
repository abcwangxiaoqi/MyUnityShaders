using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//[ExecuteInEditMode]
public class TroughtWall02Main : MonoBehaviour {
    
     RenderTexture playerRT;

    public Camera playerCam;

	public Material Mat;

	void Start () {

        Camera.main.depthTextureMode = DepthTextureMode.Depth;  
        playerCam.SetReplacementShader(Shader.Find("Custom/ReplacementShader"),null);
	}
	
    private void OnPreRender()
	{
        playerRT = RenderTexture.GetTemporary (Screen.width,Screen.height,0);
        Mat.SetTexture("_PlayerTex",playerRT);
		playerCam.targetTexture=playerRT;	
		playerCam.Render();
	}

	private void OnPostRender()
	{
		RenderTexture.ReleaseTemporary(playerRT);
	}

    void OnRenderImage(RenderTexture src, RenderTexture des)
    {
        Graphics.Blit(src, des, Mat);
    }
}
