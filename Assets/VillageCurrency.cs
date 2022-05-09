using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class VillageCurrency : MonoBehaviour
{
    //access the currency holding script
    public CurrenciesAndValues currencies;
    //access the inventory for ui
    public GameObject inventoryNPC;
    public GameObject inventoryCoins;
    public TextMeshPro coinText;
    public GameObject inventoryVouchers;
    public TextMeshPro voucherText;
    //inventory possible items
    public int numOfClothingCoins;
    public int numOfVouchers;
    public List<RewardManager> NPCObjects;

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
    }
    void DisplayInventory()
    {
        if (numOfClothingCoins != 0)
        {
            coinText.text = numOfClothingCoins.ToString();
            inventoryCoins.SetActive(true);
        }
        if (numOfVouchers != 0)
        {
            voucherText.text = numOfVouchers.ToString();
            inventoryVouchers.SetActive(true);
        }
        if (NPCObjects.Count != 0)
        {
            inventoryNPC.SetActive(true);
        }
    }

}
