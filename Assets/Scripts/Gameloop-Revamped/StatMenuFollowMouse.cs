using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.GameplayLoop{
    public class StatMenuFollowMouse : MonoBehaviour{
        [SerializeField] Vector3 menuOffset;
        void Update(){
            transform.position = Input.mousePosition + menuOffset;
        }
    }
}