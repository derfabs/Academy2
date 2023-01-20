using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ImageTrackedAction : ActionController
{
    public string m_ImagePaired = "";

    public float m_scale;

    public void OnImageTracked()
    {
        Debug.Log("Calling OnTrackedImage: " + getName());
        OnCallback();
    }
}
