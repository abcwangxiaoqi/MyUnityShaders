﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetReplacementShader : MonoBehaviour {

	// Use this for initialization
	void Start () {

		Camera.main.SetReplacementShader(Shader.Find("Custom/ReplacementShader"),"rendertype");
		
	}
	
	void OnRenderImage(RenderTexture source,RenderTexture destination)
	{

	}
	// Update is called once per frame
	void Update () {
		
	}
}
