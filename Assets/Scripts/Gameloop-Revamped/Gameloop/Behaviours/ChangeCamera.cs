using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.GameplayLoop{ 
    public class ChangeCamera : GLNode{
        GameObject selectedCamera;
        GameObject[] cameras;
        public ChangeCamera(GameObject selectedCamera, GameObject[] cameras){
            this.selectedCamera = selectedCamera;
            this.cameras = cameras;
        }
        public override NodeState Evaluate(){
            foreach(GameObject cam in cameras){
                if(!cam){
                    continue;
                }
                cam.SetActive(false);
            }
            selectedCamera.SetActive(true);
            return NodeState.SUCCESS;
        }
    }
}