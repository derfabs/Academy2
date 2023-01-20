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

    public bool m_SetPosition;

    public Vector3 m_NewPosition;
}

[System.Serializable]
public struct Display
{
    public bool m_Show;

    public bool m_Hide;

    [SerializeField]
    public string[] m_DeactivateObjects;
}

[System.Serializable]
public struct AudioPlay
{
    public bool m_Play;

    public AudioSource m_AudioSource;
}

[System.Serializable]
public struct SendMQTT
{
    public MQTT_Receiver m_Manager;

    public bool m_SendMQTT;

    public string m_Topic;

    public string m_Message;
}

[System.Serializable]
public struct MaterialDisappear
{
    public bool m_Disappear;

    public DissolveHelper m_DissolveHelper;

    public Material m_NewMaterial;
}

public class ActionController : MonoBehaviour
{
    public StateManager m_StateManager;

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

    void Start()
    {
        m_ActionMaterialDisappear.m_DissolveHelper =
            GetComponent<DissolveHelper>();

        m_ActionMove.m_Rigidbody = GetComponent<Rigidbody>();
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

    public void OnCallback()
    {
        //------------------------------------------------------
        //1. ACTION MOVE
        if (m_ActionMove.m_MoveTowards)
        {
            if (m_ActionMove.m_Target == null) return;
            m_ActionMove.m_Rigidbody.useGravity = m_ActionMove.m_UseGravity;
            isMoving = true;
        }
        if (m_ActionMove.m_SetPosition)
        {
            if (m_ActionMove.m_NewPosition == null) return;
            m_ActionMove.m_Rigidbody.MovePosition(m_ActionMove.m_NewPosition);
        }

        //------------------------------------------------------
        //2. ACTION DISPLAY
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

        //------------------------------------------------------
        //3. ACTION AUDIO PLAY
        if (m_ActionAudioPlay.m_Play)
        {
            m_ActionAudioPlay.m_AudioSource.Play();
        }

        //------------------------------------------------------
        //4. ACTION SEND MQTT
        if (m_ActionSendMQTT.m_SendMQTT)
        {
            MQTT_Receiver _manager = m_ActionSendMQTT.m_Manager;

            if (_manager == null) return;
            _manager.topicPublish = m_ActionSendMQTT.m_Topic;
            _manager.messagePublish = m_ActionSendMQTT.m_Message;
            _manager.Publish();
        }

        //------------------------------------------------------
        //5. ACTION MATERIAL UPDATE
        if (m_ActionMaterialDisappear.m_Disappear)
        {
            Material _newMaterial = m_ActionMaterialDisappear.m_NewMaterial;
            if (_newMaterial == null) return;
            Renderer renderer = this.gameObject.GetComponent<Renderer>();
            renderer.material = _newMaterial;

            m_ActionMaterialDisappear.m_DissolveHelper.onAction();
        }
    }
}
