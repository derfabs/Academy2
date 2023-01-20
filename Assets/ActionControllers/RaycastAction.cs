using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RaycastAction : ActionController
{
    public void OnRaycastHit()
    {
        Debug.Log("Calling OnRaycastHit: " + getName());
        OnCallback();
    }
}
