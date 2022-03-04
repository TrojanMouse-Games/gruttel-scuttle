using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using FMODUnity;

public class VolumeSlider : MonoBehaviour
{
    private FMOD.Studio.VCA vcaController;
    public string vcaName;

    private Slider slider;


    // Start is called before the first frame update
    void Start()
    {
        vcaController = RuntimeManager.GetVCA("vca:/" + vcaName);
        slider = GetComponent<Slider>();
    }

    public void SetVolume(float volume)
    {
        vcaController.setVolume(volume);
    }



 
}
