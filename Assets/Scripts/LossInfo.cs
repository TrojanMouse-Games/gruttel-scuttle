using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.UI;

public class LossInfo : MonoBehaviour
{
    // Retrieve number of completed waves and display
    [SerializeField]
    private TextMeshProUGUI FailedWaveText;
    private string lossInfo;
    // Start is called before the first frame update
    void Start()
    {
        //should say x/x as in num of waves completed out of total
        lossInfo = PlayerPrefs.GetString("FailedWaveCount");
        FailedWaveText.text = $"You survived for {lossInfo} waves.";
        PlayerPrefs.DeleteKey("FailedWaveCount");
    }
}
