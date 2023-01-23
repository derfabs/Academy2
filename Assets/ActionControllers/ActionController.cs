using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

[System.Serializable]
public struct Move
{
    public Rigidbody m_Rigidbody;

    public bool m_MoveTowards;

    public GameObject m_Target;

    public float m_Speed;

    public float m_Threshold;

    public bool m_UseGravity;

    public float timeOffset;
}

[System.Serializable]
public struct Display
{
    public bool m_Show;

    public bool m_Hide;

    [SerializeField]
    public string[] m_DeactivateObjects;

    public float timeOffset;
}

[System.Serializable]
public struct AudioPlay
{
    public bool m_Play;

    public AudioSource m_AudioSource;

    public float timeOffset;
}

[System.Serializable]
public struct SendMQTT
{
    public MQTT_Receiver m_Manager;

    public bool m_SendMQTT;

    public string m_Topic;

    public string m_Message;

    public float timeOffset;
}

[System.Serializable]
public struct MaterialDisappear
{
    public bool m_Disappear;

    public DissolveHelper m_DissolveHelper;

    public Material m_NewMaterial;

    public float timeOffset;
}

public class ActionController : MonoBehaviour
{
    private StateManager m_StateManager;

    [SerializeField]
    public Move m_ActionMove;

    private bool isMoving = false;

    [SerializeField]
    public Display m_ActionDisplay;

    [SerializeField]
    public AudioPlay m_ActionAudioPlay;

    [SerializeField]
    public SendMQTT m_ActionSendMQTT;

    [SerializeField]
    public MaterialDisappear m_ActionMaterialDisappear;

    public bool MOVE_START = false;

    private bool MOVE_READY = false;

    private bool DISPLAY_START = false;

    private bool DISPLAY_READY = false;

    private bool AUDIO_START = false;

    private bool AUDIO_READY = false;

    private bool MQTT_START = false;

    private bool MQTT_READY = false;

    private bool MATERIAL_START = false;

    private bool MATERIAL_READY = false;

    void Start()
    {
        m_ActionMaterialDisappear.m_DissolveHelper =
            GetComponent<DissolveHelper>();

        m_ActionMove.m_Rigidbody = GetComponent<Rigidbody>();

        m_StateManager = FindObjectOfType<StateManager>();
    }

    public string getName()
    {
        return this.gameObject.name;
    }

    void FixedUpdate()
    {
        if (m_ActionMove.m_Target == null) return;
        if (!isMoving) return;

        Vector3 m_dir =
            m_ActionMove.m_Target.transform.position - transform.position;
        bool positionReached = m_dir.sqrMagnitude < m_ActionMove.m_Threshold;
        isMoving = !positionReached;

        m_dir.Normalize();
        m_ActionMove
            .m_Rigidbody
            .MovePosition(transform.position +
            m_dir * Time.deltaTime * m_ActionMove.m_Speed);
    }

    void startMove()
    {
        if (m_ActionMove.m_MoveTowards)
        {
            if (m_ActionMove.m_Target == null) return;
            m_ActionMove.m_Rigidbody.useGravity = m_ActionMove.m_UseGravity;
            isMoving = true;
        }
        MOVE_START = true;
    }

    void startDisplay()
    {
        string _currentName = getName();
        if (m_ActionDisplay.m_Show)
        {
            m_StateManager.updateObjectState(_currentName, State.VISIBLE);
        }

        if (m_ActionDisplay.m_Hide)
        {
            m_StateManager.updateObjectState(_currentName, State.INVISIBLE);
        }

        foreach (string name in m_ActionDisplay.m_DeactivateObjects)
        {
            m_StateManager.updateObjectState(name, State.INVISIBLE);
        }
        DISPLAY_START = true;
    }

    void startAudio()
    {
        if (m_ActionAudioPlay.m_Play)
        {
            m_ActionAudioPlay.m_AudioSource.Play();
        }
        AUDIO_START = true;
    }

    void startSendMQTT()
    {
        if (m_ActionSendMQTT.m_SendMQTT)
        {
            MQTT_Receiver _manager = m_ActionSendMQTT.m_Manager;

            if (_manager == null) return;
            _manager.topicPublish = m_ActionSendMQTT.m_Topic;
            _manager.messagePublish = m_ActionSendMQTT.m_Message;
            _manager.Publish();
        }
        MQTT_START = true;
    }

    void startMaterial()
    {
        if (m_ActionMaterialDisappear.m_Disappear)
        {
            Material _newMaterial = m_ActionMaterialDisappear.m_NewMaterial;
            if (_newMaterial == null) return;
            Renderer renderer = this.gameObject.GetComponent<Renderer>();
            renderer.material = _newMaterial;

            m_ActionMaterialDisappear.m_DissolveHelper.onAction();
        }
        MATERIAL_START = true;
    }

    IEnumerator MoveCoRoutine()
    {
        while (!MOVE_START)
        {
            if (MOVE_READY)
            {
                startMove();
            }
            else
            {
                MOVE_READY = true;
                if (m_ActionMove.timeOffset > 0)
                {
                    yield return new WaitForSeconds(m_ActionMove.timeOffset);
                    Debug
                        .Log($"Trigger MOVE in " +
                        m_ActionMove.timeOffset +
                        " seconds.");
                }
            }
        }
    }

    IEnumerator DisplayCoRoutine()
    {
        while (!DISPLAY_START)
        {
            if (DISPLAY_READY)
            {
                startDisplay();
            }
            else
            {
                DISPLAY_READY = true;
                if (m_ActionDisplay.timeOffset > 0)
                {
                    yield return new WaitForSeconds(m_ActionDisplay.timeOffset);
                    Debug
                        .Log($"Trigger DISPLAY in " +
                        m_ActionDisplay.timeOffset +
                        " seconds.");
                }
            }
        }
    }

    IEnumerator PlayAudioCoRoutine()
    {
        while (!AUDIO_START)
        {
            if (AUDIO_READY)
            {
                startAudio();
            }
            else
            {
                AUDIO_READY = true;
                if (m_ActionAudioPlay.timeOffset > 0)
                {
                    yield return new WaitForSeconds(m_ActionAudioPlay
                                .timeOffset);
                    Debug
                        .Log($"Trigger AUDIO in " +
                        m_ActionAudioPlay.timeOffset +
                        " seconds.");
                }
            }
        }
    }

    IEnumerator SendMQTTCoRoutine()
    {
        while (!MQTT_START)
        {
            if (MQTT_READY)
            {
                startSendMQTT();
            }
            else
            {
                MQTT_READY = true;
                if (m_ActionSendMQTT.timeOffset > 0)
                {
                    yield return new WaitForSeconds(m_ActionSendMQTT
                                .timeOffset);
                    Debug
                        .Log($"Trigger SEND MQTT in " +
                        m_ActionSendMQTT.timeOffset +
                        " seconds.");
                }
            }
        }
    }

    IEnumerator MaterialCoRoutine()
    {
        while (!MATERIAL_START)
        {
            if (MATERIAL_READY)
            {
                startMaterial();
            }
            else
            {
                MATERIAL_READY = true;
                if (m_ActionMaterialDisappear.timeOffset > 0)
                {
                    yield return new WaitForSeconds(m_ActionMaterialDisappear
                                .timeOffset);
                    Debug
                        .Log($"Trigger MATERIAL DISAPPEAR in " +
                        m_ActionMaterialDisappear.timeOffset +
                        " seconds.");
                }
            }
        }
    }

    public void OnCallback()
    {
        //------------------------------------------------------
        //1. ACTION MOVE
        StartCoroutine("MoveCoRoutine");

        //------------------------------------------------------
        //2. ACTION DISPLAY
        StartCoroutine("DisplayCoRoutine");

        //------------------------------------------------------
        //3. ACTION AUDIO PLAY
        StartCoroutine("PlayAudioCoRoutine");

        //------------------------------------------------------
        //4. ACTION SEND MQTT
        StartCoroutine("SendMQTTCoRoutine");

        //------------------------------------------------------
        //5. ACTION MATERIAL UPDATE
        StartCoroutine("MaterialCoRoutine");
    }
}
