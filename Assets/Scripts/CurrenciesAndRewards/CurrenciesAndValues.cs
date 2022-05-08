using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TrojanMouse.StressSystem;
using TrojanMouse.GameplayLoop;
using System.Linq;
using UnityEngine.SceneManagement;
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
    //the gameloop component of the region handler
    private GameLoopBT gameLoop;
    public float averageStressAmount;

    private float maxStress;
    private float stressPercent;

    List<float> stressThresholds = new List<float>();
    private int starRating = 0;

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

        //gameLoop = regionHandler.GetComponent<GameLoopBT>();
    }
    //called on victory but before victory screen
    public void StarRating()
    {
        gameLoop = regionHandler.GetComponent<GameLoopBT>();
        //Gets the list of stress values each second from the stress system
        List<float> levelStressValues = Stress.current.levelStressValues;
        Debug.Log("levelStressValues list ");
        foreach (float i in levelStressValues)
        {
            Debug.Log(i.ToString());
        }
        //Calculate average stress value of the list, accumulated across the level
        averageStressAmount = levelStressValues.Average();
        Debug.Log("average stress amount" + averageStressAmount);
        //Retrieve the current level object and the stress thresholds % attaches to it
        int curLevel = gameLoop.curLevel;
        Debug.Log("current level object name " + gameLoop.levels[(int)curLevel].name);
        //adds level's stress thresholds to list
        stressThresholds.AddRange(gameLoop.levels[(int)curLevel].stressThresholds);
        stressThresholds.Add(0f);
        //Defines max stress at the max amount of litter
        maxStress = Stress.current.maxLitter;
        Debug.Log("max stress" + maxStress);
        //Uses the max stress to calculate the average stress as a %
        stressPercent = (averageStressAmount / maxStress)*100;
        Debug.Log("stress percent " + stressPercent);

        bool valueFound = false;

        //if the player stress percent average is between 0 and the first threshold
        for (int i = 0; i < stressThresholds.Count; i++)
        {
            if (stressPercent >= stressThresholds[i])
            { 
                starRating = i + 1;
                Debug.Log($"You get {starRating} stars!");
                valueFound = true;
                SaveData();
                break;
            }
        }
        if (!valueFound)
        {
            Debug.LogError("Cassy fucked up with the star rating system, please let her (or someone competent) know");
        }
        //- HAYLEY - SAVE STAR RATING ASSIGNED TO THE LEVEL
    }
    void SaveData()
    {
        //saves current star rating for victory scene
        PlayerPrefs.SetInt($"{SceneManager.GetActiveScene().name}starRating", starRating);
    }
}
