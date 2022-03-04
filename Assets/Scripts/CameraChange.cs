using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraChange : MonoBehaviour
{
    // Start is called before the first frame update
    public GameObject playgroundCam; public GameObject shopfrontCam;
    private bool isPlayground;

    //check if object with tag gruttel that you have directed is in the shopfront zone, if so, 
    //check if click is in trigger zone, if yes, change cam to shopfront.

    void Start()
    {
        isPlayground = true;
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void SwitchCams()
    {
        if (isPlayground)
        {
            Debug.Log("switching to shopfront");
            shopfrontCam.SetActive(true);
            playgroundCam.SetActive(false);
            isPlayground = false;
        }
        else if (!isPlayground)
        {
            Debug.Log("switching to playground");
            playgroundCam.SetActive(true);
            shopfrontCam.SetActive(false);
            isPlayground = true;
        }
    }
}
