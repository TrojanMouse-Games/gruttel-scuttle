using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ApplyRating : MonoBehaviour
{
    //By Cassy
    //For use in victory screen (and loss screen?)
    //Retrieves star rating from main level and displays it
    // Start is called before the first frame update
    public int starRating;
    public GameObject star1, star2, star3;
    //public static List<GameObject> stars;
    //public GameObject[] stars;
    List<GameObject> stars = new List<GameObject>();

    void Start()
    {
        stars.Add(star1); stars.Add(star2); stars.Add(star3);

        //retrieve saved star rating from last scene
        foreach (GameObject star in stars)
        {
            star.SetActive(false);
        }
        RevealStar();        
    }

    void RevealStar()
    { 
        for (int i = 0; i < starRating ; i++)
        { 
            StartCoroutine(starCoroutine());
            IEnumerator starCoroutine()
            {
                Debug.Log("Star rating is " + starRating + " and current star to display is " + i);
                yield return new WaitForSeconds(1);
                stars[i].SetActive(true);
            }
        }
    }
}
