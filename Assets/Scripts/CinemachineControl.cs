using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;
using UnityEngine.SceneManagement;

public class CinemachineControl : MonoBehaviour
{
    //by Cassy 

    [SerializeField]
    private float speed;
    float hMove;
    public GameObject virtualCam;
    CinemachineTrackedDolly dolly;
    float minPos;
    float maxPos;
    float startPos;
    string sceneName;

    // Start is called before the first frame update
    void Start()
    {
        //gets the scene name
        sceneName = SceneManager.GetActiveScene().name;
        //gets appropriate min and max positions on dolly track for the scene
        switch (sceneName)
        {
            case "Area1_Rectangle":
                minPos = 0; maxPos = 1; startPos = 0;
                break;
            case "Area2_Circle":
                minPos = -1000000; maxPos = 1000000; startPos = 0;
                break;
            case "Area3_SemiCircle":
                minPos = 0; maxPos = 4; startPos = 2;
                break;
        }
        //gets the dolly cam component
        dolly = virtualCam.GetComponent<CinemachineVirtualCamera>().GetCinemachineComponent<CinemachineTrackedDolly>();
        //sets to start position to 0
        dolly.m_PathPosition = startPos;
    }

    // Update is called once per frame
    void Update()
    {
        //gets horizontal input
        hMove = Input.GetAxis("Horizontal");
        //sets position to min/max if it goes out of bounds
        if (minPos > dolly.m_PathPosition)
        {
            dolly.m_PathPosition = minPos;
        }
        if (dolly.m_PathPosition > maxPos)
        {
            dolly.m_PathPosition = maxPos;
        }
        //movement input received
        if (hMove != 0)
        {
            //as long as if within range, moves camera along dolly
            if (minPos <= dolly.m_PathPosition && dolly.m_PathPosition <= maxPos)
            {
                dolly.m_PathPosition += (hMove * speed * Time.deltaTime );
            }
        }
    }
}
