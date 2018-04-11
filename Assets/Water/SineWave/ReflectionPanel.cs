using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ReflectionPanel : MonoBehaviour {

	Camera refCam;
	Material material;

	Transform panel;
	// Use this for initialization
	void Start () {

		panel=transform;


		GameObject refCamObj=new GameObject("refCam");
		refCam=refCamObj.AddComponent<Camera>();
		refCam.CopyFrom(Camera.main);
		refCam.enabled = false;
		refCam.cullingMask =  ~(1 << LayerMask.NameToLayer("Water"));
		refCam.clearFlags=CameraClearFlags.SolidColor;
		refCam.backgroundColor=Color.black;

		material=transform.GetComponent<Renderer>().sharedMaterial;

		RenderTexture renderTexture=new RenderTexture(Screen.width,Screen.height,24);
		refCam.targetTexture=renderTexture;		
	}

	Matrix4x4 refMatrix;
	public void OnWillRenderObject()
	{
		refMatrix=reflectionMatrix(panel);
		refCam.worldToCameraMatrix = Camera.main.worldToCameraMatrix * refMatrix;
		refCam.transform.position = refMatrix.MultiplyPoint(Camera.main.transform.position);

		Vector3 forward = Camera.main.transform.forward;
		Vector3 up = Camera.main.transform.up;
		forward = refMatrix.MultiplyPoint (forward);
		refCam.transform.forward = forward;
		
		GL.invertCulling = true;
		refCam.Render();
		GL.invertCulling = false;
		
		refCam.targetTexture.wrapMode = TextureWrapMode.Repeat;
		material.SetTexture("_RefTexture", refCam.targetTexture);
	}

	/*
	镜像矩阵
	 */
	Matrix4x4 reflectionMatrix(Transform panel)
	{
		Vector3 normal=panel.up;
		float d= -Vector3.Dot (normal, panel.position);

		Matrix4x4 matrix=new Matrix4x4();

		matrix.m00 = 1-2*normal.x*normal.x;
		matrix.m01 = -2*normal.x*normal.y;
		matrix.m02 = -2*normal.x*normal.z;
		matrix.m03 = -2*d*normal.x;

		matrix.m10 = -2*normal.x*normal.y;
		matrix.m11 = 1-2*normal.y*normal.y;
		matrix.m12 = -2*normal.y*normal.z;
		matrix.m13 = -2*d*normal.y;

		matrix.m20 = -2*normal.x*normal.z;
		matrix.m21 = -2*normal.y*normal.z;
		matrix.m22 = 1-2*normal.z*normal.z;
		matrix.m23 = -2*d*normal.z;

		matrix.m30 = 0;
		matrix.m31 = 0;
		matrix.m32 = 0;
		matrix.m33 = 1;

		return matrix;
	}

	// Update is called once per frame
	void Update () {
		
	}
}
