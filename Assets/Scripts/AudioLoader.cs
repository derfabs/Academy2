using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioLoader : MonoBehaviour
{
    public AudioClip AudioToPlay;
    public AudioSource AudioSource;
    // Start is called before the first frame update
    void Start()
    {
        AudioSource = GameObject.FindGameObjectWithTag("AudioPlayer").GetComponent<AudioSource>(); ;
          if (AudioSource.isPlaying != true)
        { AudioSource.PlayOneShot(AudioToPlay); }
      
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
