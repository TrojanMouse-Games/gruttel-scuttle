using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;
using UnityEngine.SceneManagement;

public class CinemachineControl : MonoBehaviour
{
    //by Cassy 

    [SerializeField]
    private float camHoriMoveSpeed = 1;
    [SerializeField]
    private float camVertMoveSpeed = 1;
    [SerializeField]
    private float camZoomSpeed = 1;
    float hMove; float minHPos; float maxHPos; float startHPos;
    float vMove; float minVPos; float maxVPos; float startVPos;
    float startZoom = 50; float scrollMove; float maxZoom = 30; float minZoom = 70;
    //drag the scene's main v cam here
    public GameObject virtualCam;
    public GameObject targetVirtualCam;
    CinemachineVirtualCamera vcamComponent; CinemachineTrackedDolly dolly;
    CinemachineVirtualCamera targetVcamComponent; CinemachineTrackedDolly targetDolly;
    private bool rotatingTarget = false;
    string sceneName;

    public bool canDrag = true;
    Vector2 dragOrigin;
    int dragSpeed = 50;


    // Start is called before the first frame update
    void Start()
    {
        //gets the scene name
        sceneName = SceneManager.GetActiveScene().name;
        //gets appropriate min and max positions on dolly track for the scene
        switch (sceneName)
        {
            case "Area1_Rectangle":
                minHPos = 0; maxHPos = 1; startHPos = 0.8f;
                break;
            case "Area2_Circle":
                minHPos = -1000000; maxHPos = 1000000; startHPos = 0;
                break;
            case "Area3_SemiCircle":
                minHPos = 0; maxHPos = 4; startHPos = 2;
                minVPos = -5; maxVPos = 5; startVPos = 0;
                maxZoom = 30; minZoom = 70;
                break;
            case "Area3_SemiCircleWITHNEWLOOP":
                minHPos = 0; maxHPos = 4; startHPos = 2;
                break;
            case "Village":
                minHPos = 0; maxHPos = 4; startHPos = 2;
                minVPos = -2; maxVPos = 2; startVPos = -2;
                //fetches the target virtual camera component
                targetVcamComponent = targetVirtualCam.GetComponent<CinemachineVirtualCamera>();
                //gets the target dolly cam component
                targetDolly = targetVcamComponent.GetCinemachineComponent<CinemachineTrackedDolly>();
                //sets to target start position
                targetDolly.m_PathPosition = startHPos; targetDolly.m_PathOffset.y = startVPos;
                //sets for the rest of the script that we are using a second dolly to follow
                rotatingTarget = true;
                startZoom = 60;
                break;
        }
        //fetches the virtual camera component
        vcamComponent = virtualCam.GetComponent<CinemachineVirtualCamera>();
        //gets the dolly cam component
        dolly = vcamComponent.GetCinemachineComponent<CinemachineTrackedDolly>();
        //sets to start position to 0
        dolly.m_PathPosition = startHPos; dolly.m_PathOffset.y = startVPos;
        //sets the fov to the starting preset
        vcamComponent.m_Lens.FieldOfView = startZoom;
    }

    // Update is called once per frame
    void Update()
    {
        //gets horizontal input
        hMove = Input.GetAxis("Horizontal") + CamHoriMovementDrag();
        //gets horizontal input
        vMove = Input.GetAxis("Vertical") + CamVertMovementDrag();
        //gets scroll input
        scrollMove = Input.GetAxis("Mouse ScrollWheel");

        if (scrollMove != 0f)
        {
            CamZoom();
        }
        //if movement input received
        if (hMove != 0)
        {
            //function to move camera horizontally
            CamHoriMovement();
        }
        if (vMove != 0)
        {
            //function to move camera vertically
            CamVertMovement();
        }
    }

    float CamHoriMovementDrag()
    {
        if (!canDrag) return 0;
        if (Input.touchCount < 1) return 0;

        Touch touch = Input.GetTouch(0);
        switch (touch.phase)
        {
            case TouchPhase.Began:
                dragOrigin = touch.position;
                break;
            case TouchPhase.Moved:
                Vector3 pos = GetComponent<Camera>().ScreenToViewportPoint(dragOrigin - touch.position) * dragSpeed;
                dragOrigin = touch.position;
                return pos.x;
        }

        return 0;
    }
    float CamVertMovementDrag()
    {
        if (!canDrag) return 0;
        if (Input.touchCount < 1) return 0;

        Touch touch = Input.GetTouch(0);
        switch (touch.phase)
        {
            case TouchPhase.Began:
                dragOrigin = touch.position;
                break;
            case TouchPhase.Moved:
                Vector3 pos = GetComponent<Camera>().ScreenToViewportPoint(dragOrigin - touch.position) * dragSpeed;
                dragOrigin = touch.position;
                return pos.y;
        }

        return 0;
    }
    void CamHoriMovement()
    {
        //as long as if within range, moves camera along dolly
        if (minHPos <= dolly.m_PathPosition && dolly.m_PathPosition <= maxHPos)
        {
            dolly.m_PathPosition += (hMove * camHoriMoveSpeed * Time.deltaTime);
            //moves the target dolly too.
            if (targetDolly)
            {
                targetDolly.m_PathPosition += (hMove * camHoriMoveSpeed * Time.deltaTime);
            }
        }
        //sets position to min/max if it goes out of bounds
        if (minHPos > dolly.m_PathPosition)
        {
            dolly.m_PathPosition = minHPos;
            if (targetDolly)
            { 
                targetDolly.m_PathPosition = minHPos;
            }
        }
        if (dolly.m_PathPosition > maxHPos)
        {
            dolly.m_PathPosition = maxHPos;
            if (targetDolly)
            {
                targetDolly.m_PathPosition = maxHPos;
            }
        }
    }
    void CamVertMovement()
    {
        //as long as if within range, pans camera vertically
        if (minVPos <= dolly.m_PathOffset.y && dolly.m_PathOffset.y <= maxVPos)
        {
            dolly.m_PathOffset.y += (vMove * camVertMoveSpeed * Time.deltaTime);
            //moves target cam on dolly appropriately
            if (targetDolly)
            {
                targetDolly.m_PathOffset.y += (vMove * camVertMoveSpeed * Time.deltaTime);
            }
        }
        //sets position to min/max if it goes out of bounds
        if (minVPos > dolly.m_PathOffset.y)
        {
            if (targetDolly)
            {
                targetDolly.m_PathOffset.y = minVPos;
            }
            dolly.m_PathOffset.y = minVPos;
        }
        if (dolly.m_PathOffset.y > maxVPos)
        {
            if (targetDolly)
            {
                targetDolly.m_PathOffset.y = maxVPos;
            }
            dolly.m_PathOffset.y = maxVPos;
        }
    }
    void CamZoom()
    {
        //as long as if within range, zooms camera
        if (maxZoom <= vcamComponent.m_Lens.FieldOfView && vcamComponent.m_Lens.FieldOfView <= minZoom)
        {
            vcamComponent.m_Lens.FieldOfView -= (scrollMove * (camZoomSpeed * 1000) * Time.deltaTime);
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
