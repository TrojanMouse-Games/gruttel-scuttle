using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TrojanMouse.StressSystem;
using TrojanMouse.GameplayLoop;
using System.Linq;
public class CurrenciesAndValues : MonoBehaviour
{
    //NPC items - Can be used to unlock special NPCs - gets added to when reward gained.
    public List<string> NPCObjects;
    //Clothing currency - Can be used to buy skins
    public float clothingCoinAmount;
    //Nana Betsy Vouchers  - Josh help - can be redeemed at Nana Betseries
    public float numOfVouchers;
    //the UI object holding the currency update pop up
    public GameObject currencyUI;
    //UI sprite to change
    public Image currencySprite;
    //UI text to change
    public Text currencyText;
    //region handler object to access stress and levels
    public GameObject regionHandler;
    public float averageStressAmount;

    public float maxStress;
    public float stressPercent;
    public float firstStressThreshold;
    public float secondStressThreshold;


    // Start is called before the first frame update
    void Start()
    {
        //Ensure currency ui is inactive and blank at start
        currencyUI.SetActive(false);
        currencySprite.gameObject.SetActive(false);
        currencyText.gameObject.SetActive(false);
        currencySprite.sprite = null;
        currencyText.text = "";
    }
    //Flashes UI for reward icon (and text) in screen corner
    public IEnumerator UIFlash()
    {
        //OTIS - Sounds for the "You've just earned this! Type UI popping up and flashing"
        currencyUI.SetActive(true);
        yield return new WaitForSeconds(.25f);
        currencyUI.SetActive(false);
        yield return new WaitForSeconds(.25f);
        currencyUI.SetActive(true);
        yield return new WaitForSeconds(.25f);
        currencyUI.SetActive(false);
        yield return new WaitForSeconds(.25f);
        currencyUI.SetActive(true);
        yield return new WaitForSeconds(.25f);
        currencyUI.SetActive(false);
        //Disable all UI
        currencySprite.gameObject.SetActive(false);
        currencyText.gameObject.SetActive(false);
        currencyText.text = "";
    }
    //called on victory but before victory screen
    public void StarRating()
    {
        //Gets the list of stress values each second from the stress system
        List<float> levelStressValues = Stress.current.levelStressValues;
        Debug.Log("levelStressValues list ");
        foreach (float i in levelStressValues)
        {
            Debug.Log(i.ToString());
        }
        averageStressAmount = levelStressValues.Average();
        Debug.Log("average stress amount" + averageStressAmount);
        float curLevel = regionHandler.GetComponent<GameLoopBT>().curLevel;
        Debug.Log("current level object name " + regionHandler.GetComponent<GameLoopBT>().levels[(int)curLevel].name);
        Vector2 stressThresholds = regionHandler.GetComponent<GameLoopBT>().levels[(int)curLevel].stressThresholds;
        maxStress = Stress.current.maxLitter;
        Debug.Log("max stress" + maxStress);
        stressPercent = (averageStressAmount / maxStress)*100;
        Debug.Log("stress percent " + stressPercent);
        firstStressThreshold = stressThresholds.x;
        secondStressThreshold = stressThresholds.y;
        Debug.Log("stress thresholds are " + firstStressThreshold + " and " + secondStressThreshold);
        if (0 < stressPercent && stressPercent <= firstStressThreshold)
        {
            //3 stars
            Debug.Log("you get 3 stars!");
        }
        else if (firstStressThreshold < stressPercent && stressPercent <= secondStressThreshold)
        {
            //2 stars
            Debug.Log("you get 2 stars!");
        }
        else if (secondStressThreshold < stressPercent && stressPercent < maxStress)
        {
            //1 stars
            Debug.Log("you get 1 stars!");
        }
        else
        {
            Debug.LogError("Cassy has fucked up with the star rating.");
        }
    }
}
