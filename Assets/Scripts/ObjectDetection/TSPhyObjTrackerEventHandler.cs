using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(TSObjectTracker))]
public class TSPhyObjTrackerEventHandler : MonoBehaviour
{
    public virtual void OnTrackingFound(int imgIndex)
    {
        Debug.Log("tracker [" + gameObject.name + "] Found!");
    }

    public virtual void OnTrackingLost()
    {
        Debug.Log("tracker [" + gameObject.name + "] Lost!");
    }
}
