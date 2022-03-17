using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FMODUnity;

namespace TrojanMouse.GameplayLoop
{
    public class GruttelsSelected2 : GLNode{
        HashSet<Transform> gruttelsSelected = new HashSet<Transform>();

        Transform[] gruttels;
        Camera cam;
        float maxDistance;
        public GruttelsSelected2(Transform[] gruttels, Camera cam, float maxRayDistance){ // CONSTRUCTOR TO PREDEFINE THIS CLASS VARIABLES
            this.gruttels = gruttels;
            this.cam = cam;
            this.maxDistance = maxRayDistance
        }

        int gruttelSelectedIndex = 0;
        public override NodeState Evaluate(){
            #region GRUTTEL CYCLING
            gruttelSelectedIndex += (
                (Input.GetKeyDown(KeyCode.A))? -1: // IF 'A' KEY IS PRESSED (-1 off index)
                (Input.GetKeyDown(KeyCode.D))? 1: // IF 'D' KEY IS PRESSED (+1 onto index)
                0 // ELSE DONT ADD ANYTHING
            );

            if(gruttelSelectedIndex < 0){
                gruttelSelectedIndex = gruttels.Length;
            }
            else if(gruttelSelectedIndex > gruttels.Length){
                gruttelSelectedIndex = 0;
            }
            #endregion

            #region GRUTTEL SELECTION
            if (Input.GetMouseButtonDown(0)){
                // CHECK IF GRUTTEL IS CLICKED ON
                RaycastHit hit;
                if (Physics.Raycast(GameLoopBT.instance.GetMouse(cam), out hit, maxDistance, whatIsGruttel)){ // FIRES A RAYCAST FROM WHEN THE USER CLICKS
                  // CHECK IF POWERUP IS APPLIED
                }
            }



            return NodeState.FAILURE;
        }
    }
}