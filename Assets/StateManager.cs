using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

public enum State
{
    VISIBLE,
    INVISIBLE
}

struct RecordObject
{
    public string name;

    public GameObject reference;

    public State state;
}

public class StateManager : MonoBehaviour
{
    /*
        Receives a list of all scene objects.
        Stores its name, reference and state for each.
        
    */
    [SerializeField]
    private GameObject[] sceneObjects;

    [SerializeField]
    private Button restartButton;

    public Dictionary<string, GameObject>
        m_ImagesPairesDic = new Dictionary<string, GameObject>();

    private List<RecordObject> m_SceneState = new List<RecordObject>();

    private ARSessionOrigin ar_SessionOrigin;

    void Start()
    {
        ar_SessionOrigin = GetComponent<ARSessionOrigin>();
        loadSceneState();
        loadImagesPaired();
        restartButton.onClick.AddListener (restartState);
    }

    // *************************************
    // On START UP helpers
    private State getCurrentState(GameObject item)
    {
        State currentState;

        if (item.activeSelf)
        {
            currentState = State.VISIBLE;
        }
        else
        {
            currentState = State.INVISIBLE;
        }
        return currentState;
    }

    private void loadSceneState()
    {
        foreach (GameObject item in sceneObjects)
        {
            RecordObject initState = new RecordObject();
            string name =
                item.transform.GetComponent<ObjectController>().getName();
            initState.name = name;
            initState.reference = item;
            initState.state = getCurrentState(item);
            m_SceneState.Add (initState);
        }
    }

    private void loadImagesPaired()
    {
        foreach (GameObject item in sceneObjects)
        {
            string imageName =
                item.transform.GetComponent<ObjectController>().m_ImagePaired;

            if (imageName.Length > 0)
            {
                Debug.Log("Imaged Paired:" + imageName);
                m_ImagesPairesDic.Add (imageName, item);
            }
        }
    }

    // *************************************
    // Actions of Manager
    public void updateWorldPosition(Transform transform)
    {
        Vector3 origin = transform.position;
        Quaternion orientation = transform.rotation;
        Vector3 eulerAngles = transform.eulerAngles;

        Debug.Log($"State Manager: {origin} - " + $"{transform.eulerAngles}");

        foreach (GameObject item in sceneObjects)
        {
            Vector3 currentPosition = item.transform.position;
            Quaternion currentOrientation = item.transform.rotation;

            Vector3 newPosition = currentPosition + origin;

            ar_SessionOrigin
                .MakeContentAppearAt(item.transform, newPosition, orientation);
        }
    }

    public void updateObjectState(string name, State newstate)
    {
        Debug.Log("Setting: " + name + " to " + newstate);
        RecordObject selectedObject;
        foreach (RecordObject item in m_SceneState)
        {
            if (item.name == name)
            {
                selectedObject = item;
                selectedObject.state = newstate;

                if (newstate == State.VISIBLE)
                {
                    selectedObject.reference.SetActive(true);
                }
                if (newstate == State.INVISIBLE)
                {
                    selectedObject.reference.SetActive(false);
                }
            }
        }
    }

    public void restartState()
    {
        Debug.Log("Calling restart");
        foreach (RecordObject item in m_SceneState)
        {
            RecordObject selected = item;
            selected.state = State.VISIBLE;
            selected.reference.SetActive(true);
        }
    }

    public void onImageTracked(ARTrackedImage trackedImage)
    {
        Debug.Log("Looking for element: onImageTracked");
        string imageName = trackedImage.referenceImage.name;

        Vector3 imagePosition = trackedImage.transform.position;
        Debug.Log("image position: " + imagePosition.ToString());
        GameObject selected = m_ImagesPairesDic[imageName];
        Debug.Log("old position: " + selected.transform.position.ToString());

        // 1. Update position according trackedIamge (should check orientation)
        selected.transform.position = imagePosition;
        Debug.Log("new position: " + selected.transform.position.ToString());
        ObjectController selectedOC = selected.GetComponent<ObjectController>();
        string gameName = selectedOC.getName();
        Debug.Log($"IMAGE TRACKED:${imageName} with prefab ${gameName}");

        // 2. OnImageTracked
        selectedOC.onImageTracked();
    }

    public void OnMQTTReceived(string msg)
    {
        Debug.Log("Receiving msg..");
        foreach (RecordObject item in m_SceneState)
        {
            if (
                item.name.Contains(msg) // TODO: Updtae to any message
            )
            {
                Debug.Log("About to do something...");
                item
                    .reference
                    .GetComponent<ObjectController>()
                    .OnMQTTReceived();
            }
        }
    }

    // *************************************
}
