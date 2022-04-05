using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using TrojanMouse.StressSystem;

[CreateAssetMenu(fileName = "", menuName = "ScriptableObjects/MachineRewards/Create Reward", order = 1)]
public class RewardManager : ScriptableObject
{
    //coroutine for flashing ui
    private IEnumerator coroutine;
    
    [Header("Reward and Type")]
    [Tooltip("Add the prefab that you want to be shown and obtained by the player.")]
    public Sprite rewardImage;
    public RewardType rewardType;
    //the multiple choice list for categories of machine rewards
    [System.Serializable]
    public enum RewardType
    {
        None = 0,
        ClothingCoins,
        NPCSpecial,
        NanaBetsyVoucher,
        StressLimitIncrease
    }
    [Header("Stress Limit Increase Amount")]
    [Tooltip("Only choose an option if the reward type is Stress Limit Increase. Small is 10%, Medium is 20%, and Large is 40%.")]
    public StressLimitIncrease stressLimitInc;
    //the multiple choice list for stress reduction quantities
    public enum StressLimitIncrease
    {
        None = 0,
        Small = 10,
        Medium = 20,
        Large = 40
    }
    [Header("NPC Object Type")]
    [Tooltip("Only choose an option if the reward type is NPC Special. Only use each type once in game.")]
    public NPCObject NPCObjectType;
    //the multiple choice list for NPC special objects
    public enum NPCObject
    { 
        None = 0,
        Paintbrush,
        RollingPin,
        Spanner,
        ParrotToy
    }
    //The function triggered by MachineFill.cs when a machine has filled up and needs to dispense a reward, taking in the village object
    //that the Currencies.cs script is attached to, and the currency UI object
    public void RewardFunction(CurrenciesAndValues currencies, GameObject currencyUI)
    {
        //Runs the corresponding function for the selected reward type
        switch (rewardType)
        {
            case RewardType.ClothingCoins:
                ClothingCoinFunction(currencies, currencyUI);
                break;
            case RewardType.NPCSpecial:
                NPCSpecialFunction(currencies, currencyUI);
                break;
            case RewardType.NanaBetsyVoucher:
                NanaBetsyFunction(currencies, currencyUI);
                break;
            case RewardType.StressLimitIncrease:
                StressLimitIncFunction(currencies, currencyUI);
                break;
        }
    }
    //Function to dispense a clothing coin reward
    void ClothingCoinFunction(CurrenciesAndValues currencies, GameObject currencyUI)
    {
        Debug.Log("Clothing coin function called");
        //Increase clothing coin number
        currencies.clothingCoinAmount++;
        //Set image and text to clothing coin icon and number
        currencies.currencySprite.sprite = rewardImage;
        currencies.currencyText.text = currencies.clothingCoinAmount.ToString();
        //Enable relevant UI
        currencies.currencySprite.gameObject.SetActive(true);
        currencies.currencyText.gameObject.SetActive(true);
        //Flash UI
        coroutine = currencies.UIFlash();
        currencies.StartCoroutine(coroutine);
    }
    //Function to dispense an NPC special object reward
    void NPCSpecialFunction(CurrenciesAndValues currencies, GameObject currencyUI)
    {
        Debug.Log("NPC object function called");
        //Add object to the currently owned NPC objects list
        currencies.NPCObjects.Add(NPCObjectType.ToString());
        //Set image to NPC object icon
        currencies.currencySprite.sprite = rewardImage;
        //Enable relevant UI
        currencies.currencySprite.gameObject.SetActive(true);
        //Flash UI
        coroutine = currencies.UIFlash();
        currencies.StartCoroutine(coroutine);
    }
    //Function to dispense a Nana Betsy reward object
    void NanaBetsyFunction(CurrenciesAndValues currencies, GameObject currencyUI)
    {
        Debug.Log("Nana Betsy voucher function called");
        currencies.numOfVouchers++;
        //Set image to Nana Betsy voucher icon
        currencies.currencySprite.sprite = rewardImage;
        //Enable relevant UI
        currencies.currencySprite.gameObject.SetActive(true);
        //Flash UI
        coroutine = currencies.UIFlash();
        currencies.StartCoroutine(coroutine);
    }
    //Function to dispense a stress reduction
    void StressLimitIncFunction(CurrenciesAndValues currencies, GameObject currencyUI)
    {
        Debug.Log("stress limit increase declared");
        //REDUCE STRESS BY AMOUNT IN STRESS REDUCTION, 
        Debug.Log("you have chosen " + stressLimitInc + "size stress limit increase, with a value of " + (int)stressLimitInc + "%.");
        Stress.current.maxLitter *= (((int)stressLimitInc)/100);
        //work out percentage, convert to int and add
        //Sounds of destress

        //Set image to stress icon
        currencies.currencySprite.sprite = rewardImage;
        //Set UI text to stress amount change
        currencies.currencyText.text = "+"+((int)stressLimitInc).ToString()+"%";
        //Enable relevant UI
        currencies.currencySprite.gameObject.SetActive(true);
        currencies.currencyText.gameObject.SetActive(true);
        //Flash UI
        coroutine = currencies.UIFlash();
        currencies.StartCoroutine(coroutine);
    }
}