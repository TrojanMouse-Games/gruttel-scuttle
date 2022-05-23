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

    // Start is called before the first frame update
    void Start()
    {
        if (vcaName == "Master")
        {
            vcaName = "";
        }

        slider = GetComponent<Slider>();

        slider.value = PlayerPrefs.GetFloat($"VOLUME: {vcaName}", 1f);

        busController = RuntimeManager.GetBus("bus:/" + vcaName);

        SetVolume(slider.value);
    }

    public void SetVolume(float volume)
    {
        busController.setVolume(volume);

        if (emitter != null)
        {
            emitter.EventInstance.setVolume(volume);
        }

        PlayerPrefs.SetFloat($"VOLUME: {vcaName}", volume);
    }
}
