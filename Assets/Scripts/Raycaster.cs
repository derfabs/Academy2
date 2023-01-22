using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class Raycaster : MonoBehaviour
{
    public Camera playerCamera;

    public GameObject hitGameObject;

    public GameObject previousHitGameObject;

    private string text = "";

    public bool STATE = false;

    public void Toggle()
    {
        STATE = !STATE;
    }

    void Update()
    {
        if (!STATE) return;
        if (Input.touchCount > 0)
        {
            MakeRaycast();
        }
        if (Input.GetMouseButtonUp(0))
        {
            MakeRaycastMouse();
        }
    }

    void MakeRaycast()
    {
        text = "Raycast from TOUCH event. \n";
        Vector3 ray =
            playerCamera.ScreenToWorldPoint(Input.GetTouch(0).position);
        Ray myRay = playerCamera.ScreenPointToRay(Input.GetTouch(0).position);
        RaycastHit hit;

        if (Physics.Raycast(myRay.origin, myRay.direction, out hit, 25))
        {
            hitGameObject = hit.collider.gameObject;
            text += "Object hit:" + hit.collider.gameObject.name + ".\n";
        }
        if (
            (
            hitGameObject &&
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
            text += "Raycast Action called.\n";
            previousHitGameObject = hitGameObject;
            Debug.Log (text);
        }
        else
        {
            text += "Object hit before.";
            Debug.Log (text);
        }
    }

    void MakeRaycastMouse()
    {
        text = "Raycast from MOUSE event. \n";
        Vector3 ray = playerCamera.ScreenToWorldPoint(Input.mousePosition);
        Ray myRay = playerCamera.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;

        if (Physics.Raycast(myRay.origin, myRay.direction, out hit, 25))
        {
            Debug.Log("lookat me" + hit.collider.gameObject.ToString());
            hitGameObject = hit.collider.gameObject;
            text += "Object hit:" + hit.collider.gameObject.name + ".\n";
        }
        if (
            (
            hitGameObject != null &&
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

            text += "Raycast Action called. \n";
            previousHitGameObject = hitGameObject;
            Debug.Log (text);
        }
        else
        {
            text += "Object hit before. ";
            Debug.Log (text);
        }
    }
}
