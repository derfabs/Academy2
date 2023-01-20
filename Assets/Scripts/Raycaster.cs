using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class Raycaster : MonoBehaviour
{
    public Camera playerCamera;

    public TMP_Text textDebug;

    public TMP_Text hitObjects;

    public GameObject hitGameObject;

    public GameObject previousHitGameObject;

    void Awake()
    {
    }

    // Update is called once per frame
    void Update()
    {
        string text =
            "hitGameObject" +
            hitGameObject.name +
            "//previous:" +
            previousHitGameObject;

        if (Input.touchCount > 0)
        {
            text = "TOUCHED";
            MakeRaycast();
        }
        if (Input.GetMouseButtonUp(0))
        {
            text = "Mouse";
            MakeRaycastMouse();
        }
    }

    void MakeRaycast()
    {
        // textDebug.text = "raycast";
        Vector3 ray =
            playerCamera.ScreenToWorldPoint(Input.GetTouch(0).position);
        Ray myRay = playerCamera.ScreenPointToRay(Input.GetTouch(0).position);
        RaycastHit hit;

        if (Physics.Raycast(myRay.origin, myRay.direction, out hit, 25))
        {
            hitGameObject = hit.collider.gameObject;
            //textDebug.text = "object hit:" + hit.collider.gameObject.name;
        }
        if (
            (
            hitGameObject != previousHitGameObject &&
            hitGameObject.GetComponent<RaycastAction>() != null
            ) ||
            (
            previousHitGameObject == null &&
            hitGameObject.GetComponent<RaycastAction>() != null
            )
        )
        {
            hitGameObject.GetComponent<RaycastAction>().OnRaycastHit();

            //    Debug
            //        .Log("Raycast Action called, Object hit: " +
            //       hit.collider.gameObject.name);
            previousHitGameObject = hitGameObject;
        }
        else
        {
            textDebug.text = "Object hit before";
        }
    }

    void MakeRaycastMouse()
    {
        // textDebug.text = "raycast";
        Vector3 ray = playerCamera.ScreenToWorldPoint(Input.mousePosition);
        Ray myRay = playerCamera.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;

        if (Physics.Raycast(myRay.origin, myRay.direction, out hit, 25))
        {
            hitGameObject = hit.collider.gameObject;
            //  Debug
            //      .Log("Raycast Action called, Object hit: " +
            //      hit.collider.gameObject.name);
        }
        if (
            (
            hitGameObject != previousHitGameObject &&
            hitGameObject.GetComponent<RaycastAction>() != null
            ) ||
            (
            previousHitGameObject == null &&
            hitGameObject.GetComponent<RaycastAction>() != null
            )
        )
        {
            hitGameObject.GetComponent<RaycastAction>().OnRaycastHit();

            // textDebug.text =
            //     "Raycast Action called, Object hit: " +
            //     hit.collider.gameObject.name;
            previousHitGameObject = hitGameObject;
        }
        else
        {
            //  textDebug.text = "Object hit before";
        }
    }
}
