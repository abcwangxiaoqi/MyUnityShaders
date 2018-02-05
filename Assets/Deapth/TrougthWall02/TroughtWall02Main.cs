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

        playerRT = RenderTexture.GetTemporary (Screen.width,Screen.height,0);

        Mat.SetTexture("_PlayerTex",playerRT);
        
        playerCam.enabled=true;
		playerCam.targetTexture=playerRT;
		playerCam.SetReplacementShader(Shader.Find("Custom/ReplacementShader"),null);
	}
	
    void OnRenderImage(RenderTexture src, RenderTexture des)
    {
        Graphics.Blit(src, des, Mat);
    }
}
