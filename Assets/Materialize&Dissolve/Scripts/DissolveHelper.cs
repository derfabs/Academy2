using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class DissolveHelper : MonoBehaviour
{
    private Dissolver dissolver;
    private bool wait = true;

    public bool cycle;
    public bool dissolve;
    public bool materialize;


    void Start()
    {
        dissolver = GetComponent<Dissolver>();
    }

    void Update()
    {
       

        if (dissolver && wait)
        {
            if (cycle) {
                if (dissolver.MaterializeDissolve())
                {
                    //wait = false;
                    StartCoroutine(Coroutine());
                }
            }
            else if (dissolve)
            { dissolver.Dissolve(); }
            else if (materialize)
            { dissolver.Materialize(); }

        }
    }

    IEnumerator Coroutine()
    {
        yield return new WaitForSeconds(1.6f);
        dissolver.ReplaceMaterials();
        //wait = true;
    }
}
