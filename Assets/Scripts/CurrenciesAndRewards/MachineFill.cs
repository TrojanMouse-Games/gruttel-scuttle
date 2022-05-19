using System.Collections;
using System.Collections.Generic;
using UnityEngine.SceneManagement;
using UnityEngine;
using TrojanMouse.Litter.Region;

public class MachineFill : MonoBehaviour
{
    //maximum amount of litter in the machine before dispensing reward
    public float maxFillLevel = 50;
    //current amount of litter in machine
    public float currentFillLevel;
    //current fill level of recycling machine dome
    private float domeFillLevel;
    //temp holder of fill level before changing
    private float _domeFillLevel;
    //scriptable object of reward attached to this machine
    public RewardManager reward;
    //material for the filling dome
    private MeshRenderer domeRenderer;
    //village, machine fill and currency UI objects (for accessing components and vars)
    private CurrenciesAndValues currencies;
    private MachineFill machineFill;
    private GameObject currencyUI;
    //gets the home region child object
    public GameObject homeRegionObj;
    //gets home region component on the child object
    private LitterRegion homeRegion;
    //small stress limit inc reward to replace limited ones
    public RewardManager smallStress;
    private float timeElapsed;
    //time to fill a little rubbish
    [Tooltip("Seconds to fill once piece of litter")]
    private float fillLerpDuration = .5f;
    //cooldown time
    [Tooltip("Seconds for machine to be on cooldown")]
    private float emptyLerpDuration = 10f;


    // Start is called before the first frame update
    void Start()
    {
        //saves this component as variable to pass in
        machineFill = this;
        //current fill level of this machine
        currentFillLevel = 0;
        //fill level of machine
        domeFillLevel = 0;
        //getting the currencies script and object holding pop up UI
        currencies = GameObject.Find("VILLAGE").GetComponent<CurrenciesAndValues>();
        currencyUI = currencies.currencyUI;
        //getting the dome renderer
        domeRenderer = transform.GetChild(0).GetComponent<MeshRenderer>();
        //gets home region attached to this object
        homeRegion = homeRegionObj.GetComponent<LitterRegion>();
        if (PlayerPrefs.HasKey(SceneManager.GetActiveScene().name + this.gameObject.name))
        {
            reward = smallStress;
        }
    }
    //handles filling the machine, and any side effects like animation or sound changes
    public void IncreaseFill()
    {
        //increases fill level by 1
        currentFillLevel++;
        //OTIS - filling a little sound
        //temp value before fill level changes
        _domeFillLevel = domeFillLevel;
        //updated fill level
        domeFillLevel += (1 / maxFillLevel);
        //calling coroutine to gradually increase fill
        StartCoroutine(Lerp(_domeFillLevel, domeFillLevel, fillLerpDuration));
    }
    //called if the machine is full
    private void OnMouseDown()
    {
        if (currentFillLevel >= maxFillLevel)
        {
            //OTIS - Any sounds for a full machine
            //Make machine full, pop out right reward
            reward.RewardFunction(currencies, currencyUI, machineFill);
        }
    }
    //Lerp used to gradually fill and empty machine
    IEnumerator Lerp(float startValue, float endValue, float lerpDuration)
    {
        //Dome material
        Material[] domeMat = domeRenderer.materials;
        timeElapsed = 0;
        //runs until set time ends
        while (timeElapsed < lerpDuration)
        {
            //Setting fill amount on dome material to gradually change
            domeMat[0].SetFloat("FillAmount", Mathf.Lerp(startValue, endValue, timeElapsed / lerpDuration));
            timeElapsed += Time.deltaTime;
            yield return null;
        }
        //set the final level
        domeMat[0].SetFloat("FillAmount", domeFillLevel);
    }

    //Empties the machine and handles animations and sounds, called from reward function completing
    public void EmptyFill()
    {
        //disable machine from use
        homeRegion.enabled = false;
        //OTIS - Emptying sounds
        _domeFillLevel = domeFillLevel;
        domeFillLevel = 0;
        currentFillLevel = 0;
        StartCoroutine(Lerp(_domeFillLevel, domeFillLevel, emptyLerpDuration));
        if (reward.oneTimeUse)
        {
            reward = smallStress;
        }
        homeRegion.enabled = true;
        PlayerPrefs.SetString(SceneManager.GetActiveScene().name + this.gameObject.name, reward.name);
    }
}
