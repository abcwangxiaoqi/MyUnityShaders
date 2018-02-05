using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyDepthMain : MonoBehaviour {

	public Material Mat;

	void Start () {
		Camera.main.depthTextureMode = DepthTextureMode.Depth;
	}
	
    void OnRenderImage(RenderTexture src, RenderTexture des)
    {
        Graphics.Blit(src, des, Mat);
    }
}
