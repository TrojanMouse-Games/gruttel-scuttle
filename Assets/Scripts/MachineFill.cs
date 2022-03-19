using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MachineFill : MonoBehaviour
{
    //maximum amount of litter in the machine before dispensing reward
    public int maxFillLevel = 50;
    //current amount of litter in machine
    public int currentFillLevel;
    private float domeFillLevel;
    //check which reward is equipped to this machine, which scriptable object
    public RewardManager reward;
    //on collection spawn item in certain po

    private Material domeMat;

    // Start is called before the first frame update
    void Start()
    {
        currentFillLevel = 0;
        domeMat = transform.GetChild(0).GetComponent<MeshRenderer>().material;
        domeFillLevel = 0;
    }
    // Update is called once per frame
    void Update()
    {
        if (currentFillLevel == maxFillLevel)
        {
            reward.RewardFunction();
        }

        //shaking animation and audio strength based on fill level, and fill of machine visual
    }
    public void IncreaseFill()
    {
        currentFillLevel++;
        domeFillLevel += 1 / maxFillLevel;
        //
        domeMat.SetFloat("FillAmount", domeFillLevel);
        //domeMat.FillAmount == currentFillLevel;
    }
}
