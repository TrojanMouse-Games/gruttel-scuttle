using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using FMODUnity;
using FMOD.Studio;

public class VolumeSlider : MonoBehaviour
{
    private FMOD.Studio.Bus busController;
    public string vcaName;
    private Slider slider;
    public StudioEventEmitter emitter;

    public List<string> vcaNameList;

    // Start is called before the first frame update
    void Start()
    {
        if (vcaName == "Master")
        {
            vcaName = "";
        }
        busController = RuntimeManager.GetBus("bus:/" + vcaName);

        slider = GetComponent<Slider>();
    }

    public void SetVolume(float volume)
    {
        busController.setVolume(volume);

        if (emitter != null)
        {
            emitter.EventInstance.setVolume(volume);
        }
    }
}
