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
        //shaking animation and audio strength based on fill level, and fill of machine visual
    }
    public void IncreaseFill()
    {
        //MOSTLY WORKING
        currentFillLevel++;
        domeFillLevel += 1 / maxFillLevel;
        //NOT WORKING, object and material are the correct ones, no matching parameters show with debugs
        Debug.Log(domeMat.GetFloat("FillAmount"));
        domeMat.SetFloat("FillAmount", domeFillLevel);
        Debug.Log(domeMat.GetFloat("FillAmount"));
        if (currentFillLevel == maxFillLevel)
        {
            reward.RewardFunction();
        }
    }
}
