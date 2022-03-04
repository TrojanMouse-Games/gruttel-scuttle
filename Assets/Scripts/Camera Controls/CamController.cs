using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class CamController : MonoBehaviour
{
    ///Script for controlling the basic camera in the rectangular level. 
    ///Covers panning left and right and zooming in and out in limits
    ///By Cassy and Hayley <3

    [SerializeField]
    private float speed = 2;
    private float dragSpeed = 0.5f;
    [SerializeField]
    private float xMinClamp = 14;
    [SerializeField]
    private float zoomSpeed = 2;
    [SerializeField]
    private float xMaxClamp = 111;
    [SerializeField]
    private float yMinClamp = 9.35f;
    [SerializeField]
    private float yMaxClamp = 11.6f;

    private Vector3 cameraPos;
    private Vector3 dragOrigin;

    public UnityEvent CameraMovement;
    public bool canDrag = true;
    //for ref default cam position should be 111, 10.48, 25.6

    // Start is called before the first frame update
    void Start()
    {
        //Start camera position
        cameraPos = new Vector3(xMaxClamp, transform.position.y, transform.position.z);
        transform.position = cameraPos;
        CameraMovement = new UnityEvent();

        CameraMovement.AddListener(KeyboardCamMovement);
        CameraMovement.AddListener(MouseCamMovement);
#if UNITY_ANDROID
#endif
    }

    // Update is called once per frame
    void Update()
    {
        //The scroll is jaggy in FixedUpdate
        CamScroll();
        CameraMovement.Invoke();
    }
    private void FixedUpdate()
    {
    }
    //Scrolls camera in and out to zoom
    public void CamScroll()
    {
        //temporary position 
        Vector3 tempPos = transform.position;
        //if scroll up (zoom in)
        if (Input.GetAxis("Mouse ScrollWheel") > 0)
        {
            //as long as its no more than max zoom
            if (transform.position.y > yMinClamp)
            {
                //zoom in at zoom speed
                tempPos += transform.forward * zoomSpeed;
                //make sure new zoom level is within range
                tempPos.y = Mathf.Clamp(tempPos.y, yMinClamp, yMaxClamp);
                //change position
                transform.position = tempPos;
            }
            else
            {
                //set manually to max zoom
                tempPos.y = yMinClamp;
                tempPos.z = 22.28f;
                transform.position = tempPos;
            }
        }
        //if scroll down (zoom out)
        if (Input.GetAxis("Mouse ScrollWheel") < 0)
        {
            //as long as its no more than min zoom
            if (transform.position.y < yMaxClamp)
            {
                //zoom out at zoom speed
                tempPos -= transform.forward * zoomSpeed;
                //make sure new zoom level is within range
                tempPos.y = Mathf.Clamp(tempPos.y, yMinClamp, yMaxClamp);
                //change position
                transform.position = tempPos;
            }
            else
            {
                //set manually to min zoom
                tempPos.y = yMaxClamp;
                tempPos.z = 27.3f;
                transform.position = tempPos;
            }
        }
    }
    //pans camera left andf right
    public void KeyboardCamMovement()
    {
        //horizontal input
        float hMove = Input.GetAxis("Horizontal");

        Vector3 tempPos = transform.position;
        //move at speed
        tempPos.x -= hMove * speed;
        //make sure new position is within range
        tempPos.x = Mathf.Clamp(tempPos.x, xMinClamp, xMaxClamp);
        //change position
        transform.position = tempPos;
    }

    public void MouseCamMovement()
    {
        if (!canDrag) return;

        if (Input.GetMouseButtonDown(0))
        {
            dragOrigin = Input.mousePosition;
            return;
        }

        if (Input.GetMouseButton(0))
        {
            Vector3 pos = Camera.main.ScreenToViewportPoint(Input.mousePosition - dragOrigin) * dragSpeed;
            Vector3 move = new Vector3(pos.x, 0, 0);

            transform.Translate(move, Space.World);
        }
    }
}
