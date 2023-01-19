using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class moveto : MonoBehaviour
{
    public Vector3 Position1;
    public Vector3 Position2;
    public float speed;


    // Start is called before the first frame update
    void Start()
    {
        
        
    }

    // Update is called once per frame
    void Update()
    {
        this.gameObject.transform.position = Vector3.MoveTowards(transform.position, Position1, speed * Time.deltaTime);

    }

  
    void MoveToPosition2()
    {

        transform.position = Vector3.MoveTowards(transform.position, Position2, speed * Time.deltaTime);
    }


}
