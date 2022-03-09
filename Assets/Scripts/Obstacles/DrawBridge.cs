using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class DrawBridge : MonoBehaviour
{
    // This is used to show the bridges state
    public bool isRaised = false;

    // Ray & hit to be used to for raycast
    public Ray ray;
    public RaycastHit hit;

    // Navmesh References
    NavMeshObstacle navMeshObstacle;
    
    // Other stuff
    public Vector3 positionToMoveTo, positionToRotateTo;
    Vector3 originalRotation, originalPosition;

    /// <summary>
    /// Start is called on the frame when a script is enabled just before
    /// any of the Update methods is called the first time.
    /// </summary>
    void Start()
    {
        navMeshObstacle = gameObject.AddComponent<NavMeshObstacle>();
    }

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
                Debug.Log($"Hit the drawbridge, its name is {hit.transform.name}! {isRaised}");

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
            // Save original postion
            originalPosition = transform.position;
            originalRotation = transform.rotation.eulerAngles;

            // Move to upwards pos
            hit.transform.rotation = Quaternion.Euler(positionToRotateTo);
            hit.transform.position = positionToMoveTo;
            
            //Rebake the mesh
            // Currently DONT do this, freezes the editor, crashes builds and ends the universe
            ChangeNavMesh();
        }
        else
        {
            // Move to original pos
            hit.transform.rotation = Quaternion.Euler(originalRotation);
            hit.transform.position = originalPosition;

            //Rebake the mesh
            // Currently DONT do this, freezes the editor, crashes builds and ends the universe
            ChangeNavMesh();
        }
    }

    /// <summary>
    /// Changes the navmesh
    /// </summary>
    void ChangeNavMesh()
    {
        navMeshObstacle.carving = !navMeshObstacle.carving;
    }
}
