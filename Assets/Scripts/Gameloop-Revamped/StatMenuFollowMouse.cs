using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.GameplayLoop{
    public class StatMenuFollowMouse : MonoBehaviour{
        [SerializeField] Vector3 menuOffset;
        void Update(){
            transform.position = Input.mousePosition + menuOffset; // SIMPLY MOVES THE OBJECT THIS IS ATTACHED TO, TO THE POSITION ON THE SCREEN WHERE THE MOUSE IS + AN OFFSET
        }
    }
}