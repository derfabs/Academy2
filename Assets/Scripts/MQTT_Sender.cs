using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class MQTT_Sender : MonoBehaviour
{
    public string topic;
    public string message;
    public string tagOfTheMQTTReceiver = "MQTTReceiver";
    public MQTT_Receiver MQTT_Receiver;
    public TMP_Text Debug;


    // Start is called before the first frame update
    void Start()
    {
        Debug = GameObject.FindGameObjectWithTag("Debug4").GetComponent<TMP_Text>();
        MQTT_Receiver = GameObject.FindGameObjectWithTag(tagOfTheMQTTReceiver).gameObject.GetComponent<MQTT_Receiver>();
        SendMessage();
    }

    public void SendMessage()
    {
        MQTT_Receiver.topicPublish = topic;
        MQTT_Receiver.messagePublish = message;
        Debug.text = "Sent Message" + topic + message;
        MQTT_Receiver.Publish();
        
    }
    
   
}
