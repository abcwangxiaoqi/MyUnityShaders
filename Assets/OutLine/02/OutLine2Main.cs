using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OutLine2Main : MonoBehaviour {

	public Material mat;
	public Camera selectCam;
	public Color outlineCol;
	RenderTexture selectRT;
	// Use this for initialization
	void Start () {
		selectRT=RenderTexture.GetTemporary (Screen.width,Screen.height,0);
		selectCam.enabled=true;
		selectCam.targetTexture=selectRT;
		selectCam.SetReplacementShader(Shader.Find("Unlit/MyOutLine02"),null);

		mat.SetTexture("_OutLine",selectRT);
	}	

    void OnRenderImage(RenderTexture src, RenderTexture des)
    {
		 Graphics.Blit(src, des, mat);
    }
}
