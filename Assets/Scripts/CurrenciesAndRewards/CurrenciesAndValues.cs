using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
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
}
