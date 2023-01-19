using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ObjectController : MonoBehaviour
{
    [SerializeField]
    private string _name;

    [SerializeField]
    public string m_ImagePaired = "";

    [SerializeField]
    public string m_MQTT_In = "";

    //INPUT-ACTION:  RAYCAST
    public bool m_OnRayCastHide = false;

    public bool m_OnRayCastSendMQTT = false;

    public bool m_OnRayCastPlay = false;

    public bool m_OnRayCastMove = false;

    public bool m_OnRayCastMaterial = false;

    //INPUT-ACTION:  TRACKING
    public bool m_OnTrackedImageShow = false;

    public bool m_OnTrackedImageHide = false;

    public bool m_OnTrackedImageSendMQTT = false;

    public bool m_OnTrackedImagePlay = false;

    public bool m_OnTrackedImageMove = false;

    public bool m_OnTrackedImageMaterial = false;

    //INTPUT-ACTION: MQTT SIGNAL
    public bool m_OnMQTTHide = false;

    public bool m_OnMQTTSendMQTT = false;

    public bool m_OnMQTTPlay = false;

    public bool m_OnMQTTMove = false;

    public bool m_OnMQTTMaterial = false;

    //******
    // OUTPUT-ACTION
    // 1. HIDE/SHOW
    public StateManager stateManager;

    [SerializeField]
    public string[] m_DeactivateObjects;

    // 2. SEND SIGNAL
    public MQTT_Sender MQTT_Sender;

    // 3. PLAY
    public AudioSource AudioSource;

    // 4. MOVE
    public GameObject m_Target;

    private bool isMoving = false;

    public Rigidbody m_Rigidbody;

    public float m_Speed = 5f;

    public float m_Threshold = 0.5f;

    //5. MATERIAL DISSAPEAR
    public DissolveHelper m_DissolveHelper;

    public Material m_NewMaterial;

    //6. Send MQTT
    public MQTT_Receiver m_MQTT_Receiver;

    public string m_MQTT_Out = "";

    //******
    void Start()
    {
        m_DissolveHelper = GetComponent<DissolveHelper>();
        m_Rigidbody = GetComponent<Rigidbody>();
    }

    void FixedUpdate()
    {
        if (m_Target == null) return;
        if (!isMoving) return;

        Vector3 m_dir = m_Target.transform.position - transform.position;
        bool positionReached = m_dir.sqrMagnitude < m_Threshold;
        isMoving = !positionReached;

        m_dir.Normalize();
        m_Rigidbody
            .MovePosition(transform.position +
            m_dir * Time.deltaTime * m_Speed);
    }

    public string getName()
    {
        return _name;
    }

    public void Move()
    {
        if (m_Target == null)
        {
            return;
        }

        // m_Rigidbody.useGravity = true;
        isMoving = true;
    }

    public void OnRaycastHit()
    {
        Debug.Log("Calling OnRaycastHit: " + _name);

        if (m_OnRayCastMove)
        {
            Move();
        }

        if (m_OnRayCastHide)
        {
            stateManager.updateObjectState(_name, State.INVISIBLE);
            foreach (string name in m_DeactivateObjects)
            {
                stateManager.updateObjectState(name, State.INVISIBLE);
            }
        }

        if (m_OnRayCastPlay && AudioSource.clip != null)
        {
            AudioSource.Play();
        }

        if (m_OnRayCastSendMQTT)
        {
            MQTT_Sender.SendMessage();
        }

        if (m_OnRayCastMaterial)
        {
            Renderer renderer = this.gameObject.GetComponent<Renderer>();
            renderer.material = m_NewMaterial;
            m_DissolveHelper.onAction();
        }

        if (m_OnRayCastSendMQTT)
        {
            m_MQTT_Receiver.topicPublish = "topic";
            m_MQTT_Receiver.messagePublish = m_MQTT_Out;
            m_MQTT_Receiver.Publish();
        }
    }

    public void onImageTracked()
    {
        Debug.Log("Calling on ImageTracked: " + _name);
        if (m_OnTrackedImageMove)
        {
            Debug.Log("Moving");
            Move();
        }

        if (m_OnTrackedImageShow)
        {
            stateManager.updateObjectState(_name, State.VISIBLE);
        }

        if (m_OnTrackedImageHide)
        {
            foreach (string name in m_DeactivateObjects)
            {
                stateManager.updateObjectState(name, State.INVISIBLE);
            }
        }

        if (m_OnTrackedImagePlay && AudioSource.clip != null)
        {
            AudioSource.Play();
        }

        if (m_OnTrackedImageSendMQTT)
        {
            MQTT_Sender.SendMessage();
        }

        if (m_OnTrackedImageMaterial)
        {
            Renderer renderer = this.gameObject.GetComponent<Renderer>();
            renderer.material = m_NewMaterial;
            m_DissolveHelper.onAction();
        }
        if (m_OnTrackedImageSendMQTT)
        {
            m_MQTT_Receiver.topicPublish = "topic";
            m_MQTT_Receiver.messagePublish = m_MQTT_Out;
            m_MQTT_Receiver.Publish();
        }
    }

    public void OnMQTTReceived()
    {
        Debug.Log("Calling on OnMQTTReceived: " + _name);
        if (m_OnMQTTMove)
        {
            Move();
        }

        if (m_OnMQTTHide)
        {
            stateManager.updateObjectState(_name, State.INVISIBLE);
            foreach (string name in m_DeactivateObjects)
            {
                stateManager.updateObjectState(name, State.INVISIBLE);
            }
        }

        if (m_OnMQTTPlay && AudioSource.clip != null)
        {
            AudioSource.Play();
        }

        if (m_OnMQTTSendMQTT)
        {
            MQTT_Sender.SendMessage();
        }

        if (m_OnMQTTMaterial)
        {
            Renderer renderer = this.gameObject.GetComponent<Renderer>();
            renderer.material = m_NewMaterial;
            m_DissolveHelper.onAction();
        }
        if (m_OnMQTTSendMQTT)
        {
            m_MQTT_Receiver.topicPublish = "topic";
            m_MQTT_Receiver.messagePublish = m_MQTT_Out;
            m_MQTT_Receiver.Publish();
        }
    }
}

/*GameObject parentGameObject = this.gameObject;  
       
        materials = GetComponent<Renderer>().materials;
        var index = 0;

        Material[] newmaterials = new Material[materials.Length + 1];
        foreach (var item in materials)
        {
            newmaterials[index] = item;
            index++;
        }
        newmaterials[index] =
            (new Material(Shader.Find("AxisDissolveMetallic")));
        materials = newmaterials;

        foreach (var item in materials)
        {
            Debug.Log("Current materials: " + item.name);
        }

        m_DissolveHelper = parentGameObject.AddComponent<DissolveHelper>();
        */

/* 
            Material[] materials = renderer.materials;
            Material newMaterial = materials[materials.Length - 1];

            foreach (var item in materials)
            {
                Debug.Log("Current materials: " + item.name);
            }
        */
