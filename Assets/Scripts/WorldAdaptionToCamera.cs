using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WorldApadaptionToCamera : MonoBehaviour
{
    public GameObject arCam;
    void Start()
    {
        arCam = FindObjectOfType<Camera>().gameObject;

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
