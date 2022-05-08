using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FPSCalc : MonoBehaviour
{
    float avg = 0F;

    // Update is called once per frame
    void Update()
    {
        avg += ((Time.deltaTime / Time.timeScale) - avg) * 0.03f; //run this every frame
        float displayValue = (1F / avg); //display this value
        Debug.Log(displayValue);
    }
}
