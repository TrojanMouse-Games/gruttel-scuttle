using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlipObstacles : MonoBehaviour
{
    //determines if raised
    private bool isFlipped;
    public float speed = 1, minY = 0, maxY = 5;
    public GameObject gateLeft, gateRight;
    private RaycastHit hit;
    private Ray ray;

    // Start is called before the first frame update
    void Start()
    {
        if (gateLeft.transform.position.y == minY)
        {
            isFlipped = false;
        }
        else if (gateLeft.transform.position.y == maxY)
        {
            isFlipped = true;
        }
    }
    private void Update()
    {
        ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        if (Physics.Raycast(ray,out hit, Mathf.Infinity) && Input.GetMouseButtonDown(0))
        {
            if (hit.transform == gateLeft.transform || hit.transform == gateRight.transform)
            {
                Debug.Log("clicked obstacle");
                //if the left gate is raised, lower left and raise right
                if (isFlipped)
                {
                    while (gateLeft.transform.localPosition.y >= minY)
                    {
                        gateLeft.transform.Translate(0, -speed * Time.deltaTime, 0);
                        gateRight.transform.Translate(0, speed * Time.deltaTime, 0);
                    }
                    isFlipped = false;
                }
                //if left gate is lowered, raise left and lower right
                else if (!isFlipped)
                {
                    while (gateLeft.transform.localPosition.y <= maxY)
                    {
                        gateLeft.transform.Translate(0, speed * Time.deltaTime, 0);
                        gateRight.transform.Translate(0, -speed * Time.deltaTime, 0);
                    }
                    isFlipped = true;
                }
            }

        }
    }
}
