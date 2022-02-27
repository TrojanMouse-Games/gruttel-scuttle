using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.GameplayLoop{ 
    public class ChangeCamera : GLNode{
        GameObject selectedCamera;
        GameObject[] cameras;
        bool isEnabled;
        public ChangeCamera(GameObject selectedCamera, GameObject[] cameras, bool isEnabled = true){
            this.selectedCamera = selectedCamera;
            this.cameras = cameras;
            this.isEnabled = isEnabled;
        }
        public override NodeState Evaluate(){
            foreach(GameObject cam in cameras){
                if(!cam){
                    continue;
                }
                cam.SetActive(false);
            }
            selectedCamera.SetActive(isEnabled);
            return NodeState.SUCCESS;
        }
    }
}