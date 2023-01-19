using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OSC_Receiver : MonoBehaviour
{
public OSC osc;
// Start is called before the first frame update
void Start()
    {
osc.SetAddressHandler("/CubeXYZ", OnReceiveXYZ);
osc.SetAddressHandler("/CubeX", OnReceiveX);
osc.SetAddressHandler("/CubeY", OnReceiveY);
osc.SetAddressHandler("/CubeZ", OnReceiveZ);
  }

void OnReceiveXYZ(OscMessage message)
    {
        float x = message.GetFloat(0);
        float y = message.GetFloat(1);
        float z = message.GetFloat(2);

        transform.position = new Vector3(x, y, z);
    }

    void OnReceiveX(OscMessage message)
    {
        float x = message.GetFloat(0);

        Vector3 position = transform.position;

        position.x = x;

        transform.position = position;
    }

    void OnReceiveY(OscMessage message)
    {
        float y = message.GetFloat(0);

        Vector3 position = transform.position;

        position.y = y;

        transform.position = position;
    }

    void OnReceiveZ(OscMessage message)
    {
        float z = message.GetFloat(0);

        Vector3 position = transform.position;

        position.z = z;

        transform.position = position;
    }

}
