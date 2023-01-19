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
    public string[] m_DeactivateObjects;

    private bool isMoving = false;

    public Rigidbody m_Rigidbody;

    public float m_Speed = 5f;

    public float m_Threshold = 0.5f;

    public GameObject m_Target;

    // public MQTT_Sender MQTT_Sender;
    public AudioSource AudioSource;

    public StateManager stateManager;

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
        m_Rigidbody.useGravity = true;
        isMoving = true;
    }

    public void OnRaycastHit()
    {
        Debug.Log("touch me: " + _name);

        if (m_Target != null)
        {
            Move();
        }

        if (stateManager != null)
        {
            stateManager.updateObjectState(_name, State.INVISIBLE);
            foreach (string name in m_DeactivateObjects)
            {
                stateManager.updateObjectState(name, State.INVISIBLE);
            }
        }

        if (AudioSource.clip != null)
        {
            AudioSource.Play();
        }

        // MQTT_Sender.SendMessage();
    }
}
