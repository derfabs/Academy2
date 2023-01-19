using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.ARSubsystems;
using UnityEngine.XR.ARFoundation;

public class TagManager : MonoBehaviour
{
    public string Tag;
    string PreviousTag;
    GameObject[] ToSetActive;


    void Awake()
    {
        Tag = "empty";
        PreviousTag = "empty";
    }
    // Update is called once per frame  
    void Update()
    {
     
        if (Tag != PreviousTag)
        {
            Debug.Log("Tracked Objects changed");
            TagsChanged();
        }

        PreviousTag = Tag;

    }

    private void TagsChanged ()
    {
        ToSetActive = GameObject.FindGameObjectsWithTag(Tag);
        if (GameObject.FindGameObjectsWithTag(Tag) != null)
            {
                Debug.Log("Found" + ToSetActive.Length + "Objects with tag" + Tag);
                foreach (GameObject obj in ToSetActive)
                {
                obj.transform.GetChild(0).gameObject.SetActive(true); }
            }
         else Debug.Log("Found No Objects with Tag");
                
       }
    }
