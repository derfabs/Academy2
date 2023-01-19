using UnityEngine;
using System.Collections;

public class OSC_Sender : MonoBehaviour
{

    public OSC osc;

    // Use this for initialization
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown("o"))
        { Test(); }
    }


    public void Test()
    {
       
        OscMessage message;

        message = new OscMessage();
        message.address = "/composition/layers/1/clips/1/connect";
        message.values.Add(1);
        //message.values.Add(2);
        //message.values.Add(3);
        osc.Send(message);
            Debug.Log("Osc message sent");
    }

    public void Cat()
    {
        OscMessage message;
        message = new OscMessage();
        message.address = "/composition/layers/1/clips/2/connect";
        message.values.Add(1);
        osc.Send(message);
        Debug.Log("Osc message cat sent");


    }
     
}