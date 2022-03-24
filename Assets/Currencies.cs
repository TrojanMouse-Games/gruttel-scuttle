using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public class Currencies : MonoBehaviour
{

    //NPC items - Can be used to unlock special NPCs - gets added to when reward gained.
    public List<string> NPCObjects;
    //Clothing currency - Can be used to buy skins
    public float clothingCoinAmount;
    //Nana Betsy Vouchers  - Josh help - can be redeemed at Nana Betseries
    public float numOfVouchers;
    //the UI object holding the currency update pop up
    public GameObject currencyUI;

    // Start is called before the first frame update
    void Start()
    {
        currencyUI.SetActive(false);
        currencyUI.GetComponentInChildren<UnityEngine.UI.Text>().text = "";
    }
    public IEnumerator UIFlash()
    {
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
        currencyUI.GetComponentInChildren<UnityEngine.UI.Text>().text = "";
    }

}
