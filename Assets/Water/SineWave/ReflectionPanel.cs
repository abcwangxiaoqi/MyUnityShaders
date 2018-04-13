using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ReflectionPanel : MonoBehaviour {

	Camera reflectionCam;
	Camera refrationCam;
	Renderer renderer;
	Transform panel;
	MaterialPropertyBlock materialPropertyBlock;
	// Use this for initialization
	void Start () {

		materialPropertyBlock=new MaterialPropertyBlock();
		renderer=transform.GetComponent<Renderer>();
		renderer.GetPropertyBlock(materialPropertyBlock);

		panel=transform;

		#region 反射相机
		GameObject refCamObj=new GameObject("reflectionCam");
		reflectionCam=refCamObj.AddComponent<Camera>();
		reflectionCam.CopyFrom(Camera.main);
		reflectionCam.enabled = false;
		reflectionCam.cullingMask =  ~(1 << LayerMask.NameToLayer("Water"));
		reflectionCam.clearFlags=CameraClearFlags.SolidColor;
		reflectionCam.backgroundColor=new Color(0,0,0,0);
		RenderTexture reflectionRT=new RenderTexture(Screen.width,Screen.height,24);
		reflectionCam.targetTexture=reflectionRT;
		#endregion

		
		#region 折射相机
		GameObject refraCamObj=new GameObject("refractionCam");
		refrationCam=refraCamObj.AddComponent<Camera>();
		refrationCam.CopyFrom(Camera.main);
		refrationCam.fieldOfView*=1.1f;
		refrationCam.enabled = false;
		refrationCam.cullingMask =  ~(1 << LayerMask.NameToLayer("Water"));
		refrationCam.clearFlags=CameraClearFlags.SolidColor;
		refrationCam.backgroundColor=new Color(0,0,0,0);
		RenderTexture refractionRT=new RenderTexture(Screen.width,Screen.height,24);
		refrationCam.targetTexture=refractionRT;	
		#endregion	
	}

	Matrix4x4 refMatrix;
	public void OnWillRenderObject()
	{
		#region 反射
		refMatrix=reflectionMatrix(panel);
		reflectionCam.worldToCameraMatrix = Camera.main.worldToCameraMatrix * refMatrix;
		reflectionCam.transform.position = refMatrix.MultiplyPoint(Camera.main.transform.position);

		Vector3 forward = Camera.main.transform.forward;
		Vector3 up = Camera.main.transform.up;
		forward = refMatrix.MultiplyPoint (forward);
		reflectionCam.transform.forward = forward;	
		
		Vector4 panelVec=CameraSpacePlane(reflectionCam, panel.position, panel.up, 1.0f, 0);
		reflectionCam.projectionMatrix=reflectionCam.CalculateObliqueMatrix(panelVec);

		reflectionCam.targetTexture.wrapMode = TextureWrapMode.Repeat;	
		materialPropertyBlock.SetTexture("_RefTexture", reflectionCam.targetTexture);
		#endregion

		#region 折射
		refrationCam.transform.position=Camera.main.transform.position;
		refrationCam.transform.rotation=Camera.main.transform.rotation;

		Matrix4x4 P =GL.GetGPUProjectionMatrix(refrationCam.projectionMatrix, true);
		Matrix4x4 V=refrationCam.worldToCameraMatrix;
		Matrix4x4 VP=P*V;

		Vector4 panelVec2=CameraSpacePlane(refrationCam, panel.position, -panel.up, 1.0f, 0);

		refrationCam.projectionMatrix=refrationCam.CalculateObliqueMatrix(panelVec2);

		refrationCam.targetTexture.wrapMode = TextureWrapMode.Repeat;	
		materialPropertyBlock.SetTexture("_RefrTexture", refrationCam.targetTexture);

		
		materialPropertyBlock.SetMatrix("_RefractCameraVP",VP);
		#endregion

		renderer.SetPropertyBlock(materialPropertyBlock);

		GL.invertCulling = true;
		reflectionCam.Render();
		refrationCam.Render();
		GL.invertCulling = false;
	    
	}

	public Vector4 CameraSpacePlane(Camera cam, Vector3 pos, Vector3 normal, float sideSign,float clipPlaneOffset)
    {        
        Vector3 offsetPos = pos + normal * clipPlaneOffset;
        Matrix4x4 m = cam.worldToCameraMatrix;
        Vector3 cpos = m.MultiplyPoint(offsetPos);
        Vector3 cnormal = m.MultiplyVector(normal).normalized * sideSign;
        return new Vector4(cnormal.x, cnormal.y, cnormal.z, -Vector3.Dot(cpos, cnormal));
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
