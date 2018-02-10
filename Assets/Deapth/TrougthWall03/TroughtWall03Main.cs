using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//[ExecuteInEditMode]
public class TroughtWall03Main : MonoBehaviour {
    
    RenderTexture playerRT;
    RenderTexture wallRT;
    public Camera playerCam;
    public Camera wallCam;
	public Material Mat;

    public Color outline;

    [Range(0.1f,1)]
    public float Intensity=0.5f;

	void Start () {

        playerRT = RenderTexture.GetTemporary (Screen.width,Screen.height,0);
        wallRT = RenderTexture.GetTemporary (Screen.width,Screen.height,0);

        Mat.SetTexture("_PlayerTex",playerRT);
        Mat.SetTexture("_WallTex",wallRT);
        
        playerCam.enabled=true;
		playerCam.targetTexture=playerRT;
		playerCam.SetReplacementShader(Shader.Find("Unlit/TWReplaceShader"),null);

        wallCam.enabled=true;
		wallCam.targetTexture=wallRT;
		wallCam.SetReplacementShader(Shader.Find("Custom/ReplacementShader"),null);
	}
	
    void OnRenderImage(RenderTexture src, RenderTexture des)
    {
        Mat.SetFloat("_Intensity",Intensity);
        Mat.SetColor("_OutLineColor",outline);
        Graphics.Blit(src, des, Mat);
    }
}
