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
    public GameObject highScoreObj;
    public List<GameObject> stars = new List<GameObject>();
    public bool newHighScore = false;
    void Start()
    {
        FindStars();
    }

    [ContextMenu("Find Stars")]
    public void FindStars()
    {
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
        for (int i = 0; i < starRating; i++)
        {
            yield return new WaitForSeconds(1);
            stars[i].SetActive(true);
            //any sound for each star in here Otis
        }

        if (PlayerPrefs.GetInt("SEMICIRCLEBLOCKOUTHighScore", 0) > 0 &&
        PlayerPrefs.GetInt("Area3_SemiCircleHighScore", 0) > 0)
        {
            ShowComicEnd();
        }
    }

    void SaveData()
    {
        string lastScene = PlayerPrefs.GetString("LastScene", SceneManager.GetActiveScene().name);

        starRating = PlayerPrefs.GetInt($"{lastScene}starRating");
        if (PlayerPrefs.HasKey($"{lastScene}HighScore"))
        {
            highScore = PlayerPrefs.GetInt($"{lastScene}HighScore");
            if (starRating > highScore)
            {
                PlayerPrefs.SetInt($"{lastScene}HighScore", starRating);
                highScoreObj.SetActive(true);
            }
        }
        else
        {
            PlayerPrefs.SetInt($"{lastScene}HighScore", starRating);
            highScore = PlayerPrefs.GetInt($"{lastScene}HighScore");
            highScoreObj.SetActive(true);
        }
    }

    void ShowComicEnd()
    {
        SceneManager.LoadScene("ComicEnd");
    }
}
