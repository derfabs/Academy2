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

    //INPUT-ACTION:  RAYCAST
    public bool m_OnRayCastHide = false;

    public bool m_OnRayCastSendMQTT = false;

    public bool m_OnRayCastPlay = false;

    public bool m_OnRayCastMove = false;

    //INPUT-ACTION:  TRACKING
    public bool m_OnTrackedImageShow = false;

    public bool m_OnTrackedImageHide = false;

    public bool m_OnTrackedImageSendMQTT = false;

    public bool m_OnTrackedImagePlay = false;

    public bool m_OnTrackedImageMove = false;

    //INTPUT-ACTION: MQTT SIGNAL
    public bool m_OnMQTTHide = false;

    public bool m_OnMQTTSendMQTT = false;

    public bool m_OnMQTTPlay = false;

    public bool m_OnMQTTMove = false;

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
    //******
    void Start()
    {
        m_Rigidbody = this.GetComponent<Rigidbody>();
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
    }
}
