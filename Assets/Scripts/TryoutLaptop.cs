using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TryoutLaptop : MonoBehaviour
{
//    public MQTT_Sender MQTT_Sender;
    public OSC_Sender osc_Sender;
    // Start is called before the first frame update
    void Start()
    {
 //       MQTT_Sender.SendMessage();
        osc_Sender.Cat();
    }

    // Update is called once per frame
    void Update()
    {
       
    }
}
