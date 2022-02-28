using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawBridge : MonoBehaviour
{
    public bool isRaised = false;

    // Ray & hit to be used to for raycast
    public Ray ray;
    public RaycastHit hit;

    // Update is called once per frame
    void Update()
    {
        if (CheckForClick())
        {
            // Having the ray pos set in here avoids it being called each frame.
            ray = Camera.main.ScreenPointToRay(Input.mousePosition);

            // Fire the ray and check to see if the bridge has been clicked
            if (Physics.Raycast(ray, out hit, Mathf.Infinity) && hit.transform == this.transform)
            {
                isRaised = !isRaised;
                Debug.Log($"Hit the drawbridge! {isRaised}");

                MoveBridge();
            }
        }
    }

    /// <summary>
    /// Checks for a click from the mouse.
    /// </summary>
    /// <returns>True if clicked, else false</returns>
    bool CheckForClick()
    {
        if (Input.GetMouseButtonDown(0))
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    /// <summary>
    /// Moves the drawbridge upwards.
    /// </summary>
    void MoveBridge()
    {
        if (isRaised)
        {
            // Store original pos
            Vector3 originalPosition = transform.rotation.eulerAngles;
            //Quaternion testPOs = Quaternion.Euler(originalPosition);

            // Calculate new pos

            // Move to upwards pos
            
        }
        else
        {
            // Return to original pos
        }
    }
}
