using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class PositionTest : MonoBehaviour
{
    public TMP_Text Debug3;
    // Start is called before the first frame update
    void Start()
    {
        Debug3 = GameObject.FindGameObjectWithTag("Debug3").GetComponent<TMP_Text>();
    }

    // Update is called once per frame
    void Update()
    {
        Debug3.text = "Position x" + this.gameObject.transform.position.x + " y" + this.gameObject.transform.position.y + " z" + this.gameObject.transform.position.z;
         
    }
}
