using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class SampleBlurMain : MonoBehaviour {

	[Range(1,10)]
	public float BlurRadius;

	public Shader shader;
	Material material;
	// Use this for initialization
	void Start () {

		material=new Material(shader);
		
	}

	void OnRenderImage(RenderTexture src, RenderTexture des)
	{
		material.SetFloat("_BlurRadius",BlurRadius);
		Graphics.Blit(src,des,material);
	}
}
