using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class ApplyRating : MonoBehaviour
{
    //By Cassy
    //For use in victory screen (and loss screen?)
    //Retrieves star rating from main level and displays it
    // Start is called before the first frame update
    public int starRating, highScore;
    public GameObject star1, star2, star3, highScoreObj;
    List<GameObject> stars = new List<GameObject>();
    public bool newHighScore = false;

    void Start()
    {
        stars.Add(star1); stars.Add(star2); stars.Add(star3);
        //retrieve saved star rating from last scene - HAYLEY
        SaveData();
        foreach (GameObject star in stars)
        {
            star.SetActive(false);
        }
        StartCoroutine(RevealStar());
    }
   IEnumerator RevealStar()
   { 
        for (int i = 0; i < starRating ; i++)
        {
            yield return new WaitForSeconds(1);
            stars[i].SetActive(true);
            //any sound for each star in here Otis
        }
   }
    void SaveData()
    {
        starRating = PlayerPrefs.GetInt($"{SceneManager.GetActiveScene().name}starRating");
        if (PlayerPrefs.HasKey($"{SceneManager.GetActiveScene().name}HighScore"))
        {
            highScore = PlayerPrefs.GetInt($"{SceneManager.GetActiveScene().name}HighScore");
            if (starRating > highScore)
            {
                PlayerPrefs.SetInt($"{SceneManager.GetActiveScene().name}HighScore", starRating);
                highScoreObj.SetActive(true);
            }
        }
        else
        {
            PlayerPrefs.SetInt($"{SceneManager.GetActiveScene().name}HighScore", starRating);
            highScore = PlayerPrefs.GetInt($"{SceneManager.GetActiveScene().name}HighScore");
            highScoreObj.SetActive(true);
        }
    }
}
