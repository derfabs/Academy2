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

            initState.name = item.name;
            initState.reference = item;
            initState.state = getCurrentState(item);

            m_SceneState.Add (initState);
        }
    }

    private void loadImagesPaired()
    {
        foreach (GameObject item in sceneObjects)
        {
            ImageTrackedAction _controller =
                item.transform.GetComponent<ImageTrackedAction>();
            if (_controller == null) return;
            string imageName = _controller.m_ImagePaired;

            if (imageName.Length > 0)
            {
                if (m_ImagesPairesDic.ContainsKey(imageName))
                {
                    Debug.Log($"${imageName} already paired");
                }
                else
                {
                    Debug.Log("Image Paired:" + imageName);
                    m_ImagesPairesDic.Add (imageName, item);
                }
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
            Debug
                .Log("Item name: " +
                (item.name == item.reference.name).ToString());

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
        Debug.Log("Restart callback... ");
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
        Debug.Log("Image position: " + imagePosition.ToString());
        GameObject selected = m_ImagesPairesDic[imageName];
        Debug.Log("Old position: " + selected.transform.position.ToString());

        // 1. Update position according trackedIamge (should check orientation)
        selected.transform.position = imagePosition;
        Debug.Log("New position: " + selected.transform.position.ToString());
        ImageTrackedAction _selected =
            selected.GetComponent<ImageTrackedAction>();
        string gameName = _selected.getName();
        Debug.Log($"IMAGE TRACKED:${imageName} with prefab ${gameName}");

        // 2. OnImageTracked
        _selected.OnImageTracked();
    }

    public void OnMQTTReceived(string msg)
    {
        Debug.Log("Receiving msg..");

        foreach (RecordObject item in m_SceneState)
        {
            MQTTAction _action = item.reference.GetComponent<MQTTAction>();
            string _identifier = _action.m_MessageIdentifier;
            bool _contains = msg.Contains(_action.m_MessageIdentifier);

            Debug.Log($"{msg} contains {_identifier}: {_contains}");

            if (_contains)
            {
                _action.OnReceived();
            }
        }
    }

    // *************************************
}
