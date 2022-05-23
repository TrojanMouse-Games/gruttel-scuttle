using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using Fungus;

public class VillageCurrency : MonoBehaviour
{
    //access the currency holding script
    public CurrenciesAndValues currencies;
    //access the inventory for ui
    public GameObject inventoryNPC;
    public GameObject inventoryCoins;
    public GameObject coinText;
    public GameObject inventoryVouchers;
    public GameObject voucherText;
    //inventory possible items
    public int numOfClothingCoins;
    public int numOfVouchers;
    public List<RewardManager> NPCObjects;

    public GameObject[] level1Duckies;
    public GameObject[] level2Duckies;

    public int level1StarRating;
    public int level2StarRating;

    public Flowchart wrenchFlowchart;

    // Start is called before the first frame update
    void Start()
    {
        inventoryCoins.SetActive(false);
        inventoryVouchers.SetActive(false);
        inventoryNPC.SetActive(false);

        numOfClothingCoins = currencies.clothingCoinAmount;
        numOfVouchers = currencies.numOfVouchers;
        NPCObjects = currencies.NPCObjects;

        DisplayInventory();
        EnableStarsLevelSelect();
    }
    void DisplayInventory()
    {
        if (numOfClothingCoins != 0)
        {
            coinText.GetComponent<TextMeshPro>().text = numOfClothingCoins.ToString();
            inventoryCoins.SetActive(true);
        }
        if (numOfVouchers != 0)
        {
            voucherText.GetComponent<TextMeshPro>().text = numOfVouchers.ToString();
            inventoryVouchers.SetActive(true);
        }
        if (NPCObjects.Count != 0)
        {
            inventoryNPC.SetActive(true);
            wrenchFlowchart.SetBooleanVariable("Spanner", true);
        }
    }
    void EnableStarsLevelSelect()
    {
        //level 1
        if (PlayerPrefs.HasKey("Area3_SemiCirclestarRating"))
        {
            level1StarRating = PlayerPrefs.GetInt("Area3_SemiCircleHighScore");
            Debug.Log(level1StarRating);
        }
        for (int i = 0; i < level1StarRating; i++)
        {
            level1Duckies[i].SetActive(true);
        }

        //level 2
        if (PlayerPrefs.HasKey("SEMICIRCLEBLOCKOUTstarRating"))
        {
            level2StarRating = PlayerPrefs.GetInt("SEMICIRCLEBLOCKOUTHighScore");
            Debug.Log(level2StarRating);
        }
        for (int i = 0; i < level2StarRating; i++)
        {
            level2Duckies[i].SetActive(true);
        }
    }

}
