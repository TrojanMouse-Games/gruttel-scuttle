using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MachineFill : MonoBehaviour
{
    //maximum amount of litter in the machine before dispensing reward
    public float maxFillLevel = 50;
    //current amount of litter in machine
    public float currentFillLevel;
    //current fill level of recycling machine dome
    private float domeFillLevel;
    //scriptable object of reward attached to this machine
    public RewardManager reward;
    //material for the filling dome
    private MeshRenderer domeRenderer;
    //village and currency UI objects (for accessing components and vars)
    private CurrenciesAndValues currencies;
    private GameObject currencyUI;

    // Start is called before the first frame update
    void Start()
    {
        //current fill level of this machine
        currentFillLevel = 0;
        //fill level of machine
        domeFillLevel = 0;
        //getting the currencies script and object holding pop up UI
        currencies = GameObject.Find("VILLAGE").GetComponent<CurrenciesAndValues>();
        currencyUI = currencies.currencyUI;
        //getting the dome renderer
        domeRenderer = transform.GetChild(0).GetComponent<MeshRenderer>();  
    }
    //handles filling the machine, and any side effects like animation or sound changes
    public void IncreaseFill()
    {
        //increases fill level by 1
        currentFillLevel++;
        //OTIS - filling a little sound
        domeFillLevel += (1 / maxFillLevel);
        //Dome material
        Material[] domeMat = domeRenderer.materials;
        //Setting fill amount on dome material
        domeMat[0].SetFloat("FillAmount", domeFillLevel);
        //called if the machine fills
        if (currentFillLevel == maxFillLevel)
        {
            //OTIS - Any sounds for a full machine
            //Make machine full, pop out right reward
            reward.RewardFunction(currencies, currencyUI);
        }
    }
    //Empties the machine and handles animations and sounds
    public void EmptyFill()
    {
        //OTIS - Emptying sounds
        currentFillLevel = 0;
        //cooldown period
        //set time for cooldown e.g. 10s publicly
        //gradually empty
        //make sure can't dispense rubbish there? disable home region component?
        //need josh to add a accessible "variable" and matt to sort
    }
}
