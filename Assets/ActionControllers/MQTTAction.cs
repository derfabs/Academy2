using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MQTTAction : ActionController
{
    public string m_MessageIdentifier;

    public void OnReceived()
    {
        Debug.Log("Receiving MQTT message for: " + getName());
        OnCallback();
    }
}
