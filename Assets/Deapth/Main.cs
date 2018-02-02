using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//[ExecuteInEditMode]
public class Main : MonoBehaviour {
    
     RenderTexture playerRT;
     RenderTexture wallRT;

    public Camera playerCam;
    public Camera wallCam;

	public Material depthMat;

	void Start () {

        playerRT = RenderTexture.GetTemporary (Screen.width,Screen.height,0);
        wallRT = RenderTexture.GetTemporary (Screen.width,Screen.height,0);
        
        playerCam.enabled=true;
		playerCam.targetTexture=playerRT;
		playerCam.SetReplacementShader(Shader.Find("Custom/ReplacementShader"),null);

        wallCam.enabled=true;
		wallCam.targetTexture=wallRT;
		wallCam.SetReplacementShader(Shader.Find("Custom/ReplacementShader"),null);
	}
	
    void OnRenderImage(RenderTexture src, RenderTexture des)
    {
        depthMat.SetTexture("_PlayerTex",playerRT);
        depthMat.SetTexture("_WallTex",wallRT);
        Graphics.Blit(src, des, depthMat);
    }
}
