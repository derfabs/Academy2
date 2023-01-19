using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

public class SpawnSceneFromImage : MonoBehaviour
{
    /*
        Pre-condition: 
            - Have a tracking image names "Start";
            - Have initialized a StateManager.

        After detecting the starting image send its position to StateManager to translates objects of scene.
    
    */
    private ARTrackedImageManager m_TrackedImageManager;

    public StateManager m_StateManager;

    private ARTrackedImage m_LastImageSeelected;

    private bool ready = false;

    void OnEnable() => m_TrackedImageManager.trackedImagesChanged += OnChanged;

    void OnDisable() => m_TrackedImageManager.trackedImagesChanged -= OnChanged;

    void OnChanged(ARTrackedImagesChangedEventArgs eventArgs)
    {
        foreach (var newImage in eventArgs.updated)
        {
            if (newImage.referenceImage.name == "Start")
            {
                TrackingState state = newImage.trackingState;
                onStartCallback (newImage);
            }
            else
            {
                onUpdateState (newImage);
            }
        }
    }

    void Awake()
    {
        m_TrackedImageManager = GetComponent<ARTrackedImageManager>();
        m_StateManager = GetComponent<StateManager>();

        Debug
            .Log("State Manager successfully loaded: " +
            m_StateManager.ToString());
    }

    private void onStartCallback(ARTrackedImage m_SelectedImage)
    {
        if (ready) return;

        TrackingState state = m_SelectedImage.trackingState;
        Debug
            .Log($"Image Update: {m_SelectedImage.transform.position}" +
            $"{m_SelectedImage.transform.eulerAngles}");

        if (state == TrackingState.Tracking)
        {
            m_StateManager.updateWorldPosition(m_SelectedImage.transform);

            ready = true;
        }
    }

    private void onUpdateState(ARTrackedImage m_SelectedImage)
    {
        if (m_SelectedImage == m_LastImageSeelected) return;

        TrackingState state = m_SelectedImage.trackingState;
        if (state == TrackingState.Tracking)
        {
            m_LastImageSeelected = m_SelectedImage;
            m_StateManager.onImageTracked (m_SelectedImage);
        }
    }
}
