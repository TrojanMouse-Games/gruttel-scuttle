using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.GameplayLoop{ 
    public class ChangeCamera : GLNode{
        GameObject selectedCamera;
        GameObject[] cameras;
        bool isEnabled;
        public ChangeCamera(GameObject selectedCamera, GameObject[] cameras, bool isEnabled = true){ // CONSTRUCTOR TO PREDEFINE THIS CLASS VARIABLES
            this.selectedCamera = selectedCamera;
            this.cameras = cameras;
            this.isEnabled = isEnabled;
        }
        public override NodeState Evaluate(){
            foreach(GameObject cam in cameras){ // ITERATES THROUGH ALL CAMERAS AND DEACTIVES THEM UNLESS THEY ARE THE SELECTED CAMERA
                if(!cam){
                    continue;
                }
                cam.SetActive(false);
            }
            selectedCamera.SetActive(isEnabled); // ENABLES/DISABLES THE SELECTED CAMERA
            return NodeState.SUCCESS;
        }
    }
}