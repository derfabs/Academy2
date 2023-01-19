using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.ARSubsystems;
using UnityEngine.XR.ARFoundation;


public class TSObjectTracker : MonoBehaviour
{
    public XRReferenceObject trackableObject;
    public Vector3 physicalSize = new Vector3(1.0f, 1.0f);
    public float editScaler = 1.0f;
    float _playScaler = 1.0f;

    public bool hideTrackerWhenPlay = true;

    public Transform referenceGrouper;

    Vector3 _originPos;
    Quaternion _originRot;
    Vector3 _originScale;

    Vector3 _grouperPosLocal;
    Quaternion _grouperRotDiff;
    Vector3 _grouperOriginScale;

    //for Editor
    [HideInInspector] public Texture2D _lastTexture;
    [HideInInspector] public Vector2 _lastTrackerSize = new Vector2(1.0f, 1.0f);
    [HideInInspector] public float _sizeRatio = 1.0f;
    [HideInInspector] public int inspectorCounter = -1; // check if it first time selected
    [HideInInspector] public float _lastEditScaler = 1.0f;

    // Start is called before the first frame update
    void Start()
    {
        Debug.Log("TS Object Tracker found and started");
        if(hideTrackerWhenPlay)
        {
            gameObject.GetComponent<MeshRenderer>().enabled = false;
        }

        // grab reference data before scale
        _originPos = transform.position;
        _originRot = transform.rotation;
        _originScale = transform.localScale;

        if (referenceGrouper != null)
        {
            _grouperPosLocal = transform.InverseTransformPoint(referenceGrouper.position);
            _grouperRotDiff = referenceGrouper.rotation * Quaternion.Inverse(transform.rotation);
            _grouperOriginScale = referenceGrouper.localScale;
        }

        //scale after
        _playScaler = 1.0f / editScaler;

        if (_playScaler != 1.0f)
        {
            transform.localScale = Vector3.one * _playScaler;
        }
      }
public void UpdateTransform(Vector3 newPosition, Quaternion newRotation)
{
    transform.position = newPosition;
    transform.rotation = newRotation;

    if (referenceGrouper != null)
    {
        Vector3 posDiff = transform.position - _originPos;
        Quaternion rotDiff = transform.rotation * Quaternion.Inverse(_originRot);

        referenceGrouper.position = transform.TransformPoint(_grouperPosLocal);
        referenceGrouper.rotation = transform.rotation * _grouperRotDiff;
        referenceGrouper.localScale = _grouperOriginScale * _playScaler;
    }
}
   public void OnTrackingFound(int phyObjIndex)
    {
        Debug.Log("origin size: " + _originScale + "  obj: " + transform.localScale);

        if (gameObject.GetComponent<TSPhyObjTrackerEventHandler>())
        {
            Debug.Log("gameObject has a TSImagetrackerWventhandler");
            gameObject.GetComponent<TSPhyObjTrackerEventHandler>().OnTrackingFound(phyObjIndex);
        }
    }

    public void OnTrackingLost()
    {
        if (gameObject.GetComponent<TSPhyObjTrackerEventHandler>())
        {
            gameObject.GetComponent<TSPhyObjTrackerEventHandler>().OnTrackingLost();
        }

    }
}


