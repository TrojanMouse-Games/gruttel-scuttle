using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;
using UnityEngine.SceneManagement;

public class CinemachineControl : MonoBehaviour
{
    //by Cassy 

    [SerializeField]
    private float camMoveSpeed = 1; 
    [SerializeField]
    private float camZoomSpeed = 1;
    float hMove;float minPos;float maxPos;float startPos; float fov = 50; float scrollMove;float maxZoom = 30;float minZoom = 70;
    //drag the scene's main v cam here
    public GameObject virtualCam;
    CinemachineVirtualCamera vcamComponent; CinemachineTrackedDolly dolly;
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
        //fetches the virtual camera component
        vcamComponent = virtualCam.GetComponent<CinemachineVirtualCamera>();
        //gets the dolly cam component
        dolly = vcamComponent.GetCinemachineComponent<CinemachineTrackedDolly>();
        //sets to start position to 0
        dolly.m_PathPosition = startPos;
        //sets the fov to the starting preset
        vcamComponent.m_Lens.FieldOfView = fov;
    }

    // Update is called once per frame
    void Update()
    {
        //gets horizontal input
        hMove = Input.GetAxis("Horizontal");
        //gets scroll input
        scrollMove = Input.GetAxis("Mouse ScrollWheel");

        if (scrollMove != 0f)
        {
            CamZoom();
        }
        //if movement input received
        if (hMove != 0)
        {
            //function to move camera
            CamMovement();
        }
    }
    void CamMovement()
    { 
        //as long as if within range, moves camera along dolly
        if (minPos <= dolly.m_PathPosition && dolly.m_PathPosition <= maxPos)
        {
            dolly.m_PathPosition += (hMove * camMoveSpeed * Time.deltaTime );
        }
        //sets position to min/max if it goes out of bounds
        if (minPos > dolly.m_PathPosition)
        {
            dolly.m_PathPosition = minPos;
        }
        if (dolly.m_PathPosition > maxPos)
        {
            dolly.m_PathPosition = maxPos;
        }
    }
    void CamZoom()
    {
        //as long as if within range, zooms camera
        if (maxZoom <= vcamComponent.m_Lens.FieldOfView && vcamComponent.m_Lens.FieldOfView <= minZoom)
        {
            vcamComponent.m_Lens.FieldOfView -= (scrollMove * (camZoomSpeed*1000) * Time.deltaTime);
        }
        //sets zoom level to min/max if goes out of bounds
        if (maxZoom > vcamComponent.m_Lens.FieldOfView)
        {
            vcamComponent.m_Lens.FieldOfView = maxZoom;
        }
        if (vcamComponent.m_Lens.FieldOfView > minZoom)
        {
            vcamComponent.m_Lens.FieldOfView = minZoom;
        }
    }
}
