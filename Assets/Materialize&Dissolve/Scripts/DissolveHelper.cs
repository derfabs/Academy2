using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class DissolveHelper : MonoBehaviour
{
    private Dissolver dissolver;

    public bool cycle = true;

    public bool dissolve = false;

    public bool materialize = false;

    void Start()
    {
        GameObject parentGameObject = this.gameObject;
        Debug.Log("GAME OBJECT NAME:" + parentGameObject.name);
        dissolver = parentGameObject.GetComponent<Dissolver>();
    }

    public void onAction()
    {
        if (dissolver)
        {
            if (cycle)
            {
                if (dissolver.MaterializeDissolve())
                {
                    StartCoroutine(Coroutine());
                }
            }
            else if (dissolve)
            {
                dissolver.Dissolve();
            }
            else if (materialize)
            {
                dissolver.Materialize();
            }
        }
    }

    IEnumerator Coroutine()
    {
        yield return new WaitForSeconds(1.6f);
        dissolver.ReplaceMaterials();
    }
}
