using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ImageTrackedAction : ActionController
{
    public string m_ImagePaired = "";

    public void OnImageTracked()
    {
        Debug.Log("Calling OnTrackedImage: " + getName());
        OnCallback();
    }
}
