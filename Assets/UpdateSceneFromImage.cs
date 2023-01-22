using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

public class UpdateSceneFromImage : MonoBehaviour
{
    /*
        Listen to events of AR TrackedImageManager, and sends detected images to StateManager.
    
    */
    private ARTrackedImageManager m_TrackedImageManager;

    private StateManager m_StateManager;

    private ARTrackedImage m_LastImageSeelected;

    void OnEnable() => m_TrackedImageManager.trackedImagesChanged += OnChanged;

    void OnDisable() => m_TrackedImageManager.trackedImagesChanged -= OnChanged;

    void OnChanged(ARTrackedImagesChangedEventArgs eventArgs)
    {
        foreach (var newImage in eventArgs.updated)
        {
            onUpdateState (newImage);
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
