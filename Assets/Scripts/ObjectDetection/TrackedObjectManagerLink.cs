using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.ARSubsystems;
using UnityEngine.XR.ARFoundation;
using TMPro;

public class TrackedObjectManagerLink : MonoBehaviour
{
    public ARTrackedObjectManager manager;
    public TMP_Text Debug;
    public GameObject[] activatableGameObjects;
    public Dictionary<XRReferenceObject, int> ReferenceDictionary;
    int counter;


    private void Start()
    {
        counter = 0;
        Debug.text = "Started";
        ReferenceDictionary = new Dictionary<XRReferenceObject, int>();
        foreach (GameObject GO in activatableGameObjects)
        {
            GO.SetActive(false);
        }
        foreach (XRReferenceObject XRO in manager.referenceLibrary)
        {
            ReferenceDictionary.Add(XRO, counter);
            counter++;
        }
        Debug.text = "Dictionary finished with " + counter + " entries";
    }
    private void OnEnable()
    {
        manager.trackedObjectsChanged += OnChange;
    }

    private void OnDisable()
    {
        manager.trackedObjectsChanged -= OnChange;
    }

    private void OnChange(ARTrackedObjectsChangedEventArgs args)
    {
        foreach (ARTrackedObject obj in args.added)
        {  // Do stuff with the object
            XRReferenceObject XRO = obj.referenceObject;
            if (ReferenceDictionary.ContainsKey(obj.referenceObject))
            {
                Debug.text = "Reference found" + obj.referenceObject.name;
                activatableGameObjects[ReferenceDictionary[XRO]].SetActive(true);
            }
            else Debug.text = "No reference found";

        }
    }
}
