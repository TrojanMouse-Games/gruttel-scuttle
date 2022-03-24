using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MachineFill : MonoBehaviour
{
    //maximum amount of litter in the machine before dispensing reward
    public int maxFillLevel = 50;
    //current amount of litter in machine
    public int currentFillLevel;
    //current fill level of recycling machine dome
    private float domeFillLevel;

    //scriptable object of reward attached to this machine
    public RewardManager reward;
    //material for the filling dome
    private Material domeMat;

    //village and currency UI objects (for accessing components and vars)
    private Currencies currencies;
    private GameObject currencyUI;

    // Start is called before the first frame update
    void Start()
    {
        //current fill level of this machine
        currentFillLevel = 0;
        //the material on the machine's clear dome and the fill level of it
        domeMat = transform.GetChild(0).GetComponent<MeshRenderer>().material;
        domeFillLevel = 0;
        //getting the currencies script and object holding pop up UI
        currencies = GameObject.Find("VILLAGE").GetComponent<Currencies>();
        currencyUI = currencies.currencyUI;
    }
    //handles filling the machine, and any side effects like animation or sound changes
    public void IncreaseFill()
    {
        //increases fill level by 1
        currentFillLevel++;
        //filling a little sound
        domeFillLevel += 1 / maxFillLevel;
        //NOT WORKING, object and material are the correct ones, no matching parameters show with debugs
        Debug.Log("current fill level of " + this.gameObject + " = " + currentFillLevel);
        domeMat.SetFloat("FillAmount", domeFillLevel);
        //called if the machine fills
        if (currentFillLevel == maxFillLevel)
        {
            //any sounds for a full machine
            //make machine full, pop out right reward
            reward.RewardFunction(currencies, currencyUI);
        }
    }
    //Empties the machine and handles animations and sounds
    public void EmptyFill()
    {
        //emptying sounds
        currentFillLevel = 0;
    }
}
