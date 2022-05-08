using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PropellorObstacle : MonoBehaviour
{
    [SerializeField] float rotateDuration;
    [SerializeField] int degreesToRotate;
    Quaternion targetRot;
    private void Awake()
    {
        targetRot = transform.rotation;
    }
    /// <summary>
    /// THIS ON RUNTIME WILL INTERPOLATE THE ROTATION OF THIS OBJECT TO A TARGET
    /// </summary>
    void Update()
    {
        transform.rotation = Quaternion.Slerp(transform.rotation, targetRot, Time.deltaTime / rotateDuration); // 
    }

    /// <summary>
    /// THIS WHEN THE OBJECT IS CLICKED ON WILL UPDATE THE TARGET ROTATION VARIABLE
    /// </summary>
    private void OnMouseDown()
    {
        Debug.Log("hit");
        Vector3 newRot = transform.rotation.eulerAngles + new Vector3(0, degreesToRotate, 0);
        targetRot = Quaternion.Euler(newRot);
    }
}