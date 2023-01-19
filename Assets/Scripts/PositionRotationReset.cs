using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.ARFoundation;

public class PositionReset1 : MonoBehaviour
{

    public GameObject arCam;
    // Start is called before the first frame update
    void Start()
    {
        arCam = FindObjectOfType<ARCameraManager>().gameObject;

        //setting Up the position of everyting
        Vector3 cameraPos = arCam.transform.position;
        Vector3 cameraDirection = arCam.transform.forward;
        Quaternion cameraRotation = arCam.transform.rotation;

        Vector3 spawnPos = cameraPos + cameraDirection;
        Quaternion spawnRotation = new Quaternion(0f, cameraRotation.y, 0f, cameraRotation.w);

        transform.position = new Vector3(spawnPos.x, cameraPos.y, spawnPos.z);
        transform.rotation = spawnRotation;
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
