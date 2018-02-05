using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//[ExecuteInEditMode]
public class TroughtWall01Main : MonoBehaviour {
    
     RenderTexture playerRT;
     RenderTexture wallRT;

    public Camera playerCam;
    public Camera wallCam;

	public Material Mat;

	void Start () {

        playerRT = RenderTexture.GetTemporary (Screen.width,Screen.height,0);
        wallRT = RenderTexture.GetTemporary (Screen.width,Screen.height,0);

        Mat.SetTexture("_PlayerTex",playerRT);
        Mat.SetTexture("_WallTex",wallRT);
        
        playerCam.enabled=true;
		playerCam.targetTexture=playerRT;
		playerCam.SetReplacementShader(Shader.Find("Custom/ReplacementShader"),null);

        wallCam.enabled=true;
		wallCam.targetTexture=wallRT;
		wallCam.SetReplacementShader(Shader.Find("Custom/ReplacementShader"),null);
	}
	
    void OnRenderImage(RenderTexture src, RenderTexture des)
    {
        Graphics.Blit(src, des, Mat);
    }
}
