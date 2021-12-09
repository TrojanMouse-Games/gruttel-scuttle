using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CamController : MonoBehaviour
{
    [SerializeField]
        private float speed = 2;
    [SerializeField]
    private float xMinClamp = 14;
    [SerializeField]
    private float zoomSpeed = 2;
    [SerializeField]
    private float xMaxClamp = 111;
    private Vector3 cameraPos;


    // Start is called before the first frame update
    void Start()
    {
        cameraPos = new Vector3(xMaxClamp, transform.position.y, transform.position.z);
        transform.position = cameraPos;
    }

    // Update is called once per frame
    void Update()
    {
        CamScroll();
    }
    private void FixedUpdate()
    {
        CamMovement();
    }
    public void CamScroll()
    {
        if (Input.GetAxis("Mouse ScrollWheel") > 0)
        {
            if (transform.position.y > 13.5f)
            {
                transform.position += transform.forward * zoomSpeed;
            }
            else
            {
                Vector3 tempPos = transform.position;
                tempPos.y = 13.5f;
                tempPos.z = 24.7f;
                transform.position = tempPos;
            }

        }

        if (Input.GetAxis("Mouse ScrollWheel") < 0)
        {
            transform.position -= transform.forward * zoomSpeed;
            //Camera.main.fieldOfView += 2;
            if (transform.position.y < 17.8f)
            {
                transform.position -= transform.forward * zoomSpeed;
            }
            else
            {
                Vector3 tempPos = transform.position;
                tempPos.y = 17.8f;
                tempPos.z = 28.9f;
                transform.position = tempPos;
            }
        }
    }
    public void CamMovement()
    {
        float hMove = Input.GetAxis("Horizontal");

        Vector3 tempPos = transform.position;
        tempPos.x -= hMove*speed;
        tempPos.x = Mathf.Clamp(tempPos.x, xMinClamp, xMaxClamp);
        transform.position = tempPos;
    }
}
