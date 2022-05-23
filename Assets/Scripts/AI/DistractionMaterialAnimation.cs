using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DistractionMaterialAnimation : MonoBehaviour
{
    /// SCRIPT NO LONGER IN USE FUNCTIONALLY HOWEVER
    /// IT IS USED TO GET A REFERENCE TO THE OBJECT THIS IS ATTACHED TO

    private void Start()
    {
        gameObject.SetActive(false);
    }

    // [SerializeField] MeshRenderer distractionMat;
    // [SerializeField] Color32 targetColor;
    // Color32 defaultColor, moveToColor;


    // [SerializeField] float transitionDuration;
    // float curDuration;
    // bool moveToTarget;

    // private void Start(){
    //     defaultColor = distractionMat.material.color;
    // }

    // private void Update(){
    //     ColourAnimation();
    // }

    // void ColourAnimation(){
    //     moveToColor = (moveToTarget) ? targetColor : defaultColor;


    //     Color32 curCol = distractionMat.material.color;
    //     if (Mathf.Abs(moveToColor.r - curCol.r) <= 1 && Mathf.Abs(moveToColor.r - curCol.r) <= 1 && Mathf.Abs(moveToColor.r - curCol.r) <= 1)
    //     {
    //         moveToTarget = !moveToTarget;
    //     }
    //     distractionMat.material.color = Color.Lerp(distractionMat.material.color, moveToColor, Time.deltaTime * transitionDuration);
    // }
}
