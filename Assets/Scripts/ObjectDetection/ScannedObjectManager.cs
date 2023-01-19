using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.ARSubsystems;
using UnityEngine.XR.ARFoundation;


public class ScannedObjectManager : MonoBehaviour
{

    // In this code, the tracked Object in the physical World is called PhyObjs,
    // digital objects are objs
    public XRReferenceObjectLibrary targetLib; // Die XR Reference Library
    public Transform[] trackerObjs; // Ein array der Transforms der TrackerObjs
    // Hier wird ein Array der Transforms der getrackten Objekte angelegt
    TrackingState[] trackerStates_phyObjs;// Array der Trackerzustände


    //Hier wird der Status der getrackten Objekte überprüft

    ARTrackedObjectManager _foundationTrackerManager; //AR Foundation Tracking Manager  
    Dictionary<string, int> trackerPhyObjNameDict; //Dictionary der Namen und Nummern der Objekte

    public UnityEngine.UI.Text debugText;
    public TagManager TagManager;
    

    int _phyObjIndex = 0;

    //setting tracked Object Limit
    Dictionary<int, TSObjectTracker> trackedPhyObjs = new Dictionary<int, TSObjectTracker>(); //Dictionary der Nummer und des TS Object Scripts der zugehörigen Objekte
    //int maxTrackPhyObjCount = 0;


    // Start is called before the first frame update
    void Start()
    {
        //setting up reference
        trackerStates_phyObjs = new TrackingState[targetLib.count]; //Die Referenzobjekte werden durchgezählt
        Debug.Log("Tracking states established");
        trackerPhyObjNameDict = new Dictionary<string, int>(); // Ein neues Dictionary wird angelegt 
        for (int i = 0; i < trackerObjs.Length; i++) 
        {
            Debug.Log("Went inside for loop");
            trackerPhyObjNameDict.Add(trackerObjs[i].name, i); // Hier wird den Namens-Nummern-Dictionary ein Eintrag hinzugefügt
            trackerStates_phyObjs[i] = TrackingState.None;// Und der Tracking state des Objekts auf None gesetzt
            Debug.Log("For loop over, trying to find manager");

        }
        //Init foundation ar object manager
        _foundationTrackerManager = GameObject.FindObjectOfType<ARTrackedObjectManager>(); //Der AR Tracked Object Manager wird gesucht

        Debug.Log("Get Manager" + _foundationTrackerManager.gameObject.name); // Debug Log mit dem GO des Tracker Managers
        debugText.text = "Get Manager" + _foundationTrackerManager.gameObject.name; 
        _foundationTrackerManager.enabled = false;
        _foundationTrackerManager.referenceLibrary = targetLib; //Die ReferenceLibrary wird geladen
        _foundationTrackerManager.enabled = true;

        Debug.Log("Start AR Manager");
        debugText.text = "Start AR Manager";
        


    }


    // Update is called once per frame
    void Update()
    {
        UpdateTrackerStatus();

        if (debugText != null)
        {
            LogTrackerStatus();
        }
    }

    void UpdateTrackerStatus()
    {
        
        foreach (ARTrackedObject _phyObj in _foundationTrackerManager.trackables) //für jedes trackable Item in Trackables
        {
            _phyObjIndex = trackerPhyObjNameDict[_phyObj.referenceObject.name]; // phyObjIndex bekommt die Nummer des Referenzobjekts

            Debug.Log(_phyObj.referenceObject.name + " wurde getrackt");
            TagManager.Tag = _phyObj.referenceObject.name;
            // state has change!
            if (_phyObj.trackingState != trackerStates_phyObjs[_phyObjIndex]) //Der Trackingstate des Objekts ändert sich
            {
                Debug.Log("state has changed");
                trackerStates_phyObjs[_phyObjIndex] = _phyObj.trackingState; // Der Trackerstate des Objekts mit der Nummer soundso wird dem gerade im Loop angesprochenen Objekt zugewiesen

                if (_phyObj.trackingState == TrackingState.Tracking) //wenn das phyObj gerade getrackt wird, dann...
                {
                     trackedPhyObjs.Add(_phyObjIndex, trackerObjs[_phyObjIndex].GetComponent<TSObjectTracker>()); //Hol dir den Object Tracker von dem Objekt 
                     trackerObjs[_phyObjIndex].GetComponent<TSObjectTracker>().OnTrackingFound(_phyObjIndex);
                     Debug.Log("Es wird getrackt" + trackedPhyObjs);

                 }
                    else
                    {
                        trackerObjs[_phyObjIndex].GetComponent<TSObjectTracker>().OnTrackingFound(_phyObjIndex);
                    }
                }
                else if (_phyObj.trackingState == TrackingState.Limited)
                {
                  
                        trackedPhyObjs.Remove(_phyObjIndex);
                        trackerObjs[_phyObjIndex].GetComponent<TSObjectTracker>().OnTrackingLost();
                }
                else if (_phyObj.trackingState == TrackingState.None)
                {
                    // error?
                    Debug.Log("Object [" + _phyObj.referenceObject.name + "] become NONE");
                }


            // update data if tracked
            if (_phyObj.trackingState == TrackingState.Tracking)
            {

                if (trackedPhyObjs.ContainsKey(_phyObjIndex))
                UpdateTargetObjStatus(_phyObj, _phyObjIndex);
            
            else
            {
                UpdateTargetObjStatus(_phyObj, _phyObjIndex);

            }

            }
        }
    }


    void UpdateTargetObjStatus(ARTrackedObject targetPhyObj, int targetIndex)
    {
        Transform targetObj = trackerObjs[targetIndex];

        //targetObj.position = targetImg.transform.position;
        //targetObj.rotation = targetImg.transform.rotation;
        //targetObj.transform.localScale = new Vector3(targetImg.extents.x, 1.0f, targetImg.extents.y);

        targetObj.GetComponent<TSObjectTracker>().UpdateTransform(targetPhyObj.transform.position, targetPhyObj.transform.rotation);
    }

    void LogTrackerStatus()
    {
        string debugMessage = "";
        //debugMessage += "trackers: " + _foundationTrackerManager.trackables.count + "\n";

        foreach (ARTrackedObject _phyObj in _foundationTrackerManager.trackables)
        {
            debugMessage += _phyObj.name + "\n";
            debugMessage += "[" + _phyObj.referenceObject.name + "]: " + _phyObj.trackingState.ToString() + "\n";
            debugMessage += "extends: " + _phyObj.transform.position.x + "  " + _phyObj.transform.position.y + "\n";
        }

        debugText.text = debugMessage;
    }

   
  
}
