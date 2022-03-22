using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FMODUnity;
using TrojanMouse.Gruttel;

namespace TrojanMouse.GameplayLoop
{
    public class GruttelsSelected2 : GLNode{
        HashSet<Transform> gruttelsSelected = new HashSet<Transform>();

        int gruttelsToSelect;
        Camera cam;
        float maxDistance;
        LayerMask whatIsGruttel;
        ShowGruttelStats statScript;

        Transform powerupStorage;
        Transform villageFolder;
        Transform playFolder;
        EventReference selectSound;
        public GruttelsSelected2(int gruttelsToSelect, Camera cam, float maxRayDistance, LayerMask whatIsGruttel, ShowGruttelStats statScript,Transform powerupStorage, Transform villageFolder, Transform playFolder, EventReference selectSound){ // CONSTRUCTOR TO PREDEFINE THIS CLASS VARIABLES
            this.gruttelsToSelect = gruttelsToSelect;
            this.cam = cam;
            this.maxDistance = maxRayDistance;
            this.whatIsGruttel = whatIsGruttel;
            this.statScript = statScript;
            this.powerupStorage = powerupStorage;
            this.villageFolder = villageFolder;
            this.playFolder = playFolder;
            this.selectSound = selectSound;
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
                gruttelSelectedIndex = villageFolder.childCount-1;
            }
            else if(gruttelSelectedIndex > villageFolder.childCount-1){
                gruttelSelectedIndex = 0;
            }

            GruttelReference gruttel = villageFolder.GetChild(gruttelSelectedIndex).GetComponent<GruttelReference>();
            // MOVE CAMERA
            #endregion

            #region GRUTTEL SELECTION
            if (Input.GetMouseButtonDown(0)){
                // CHECK IF GRUTTEL IS CLICKED ON
                RaycastHit hit;
                if (Physics.Raycast(GameLoopBT.instance.GetMouse(cam), out hit, maxDistance, whatIsGruttel)){ // FIRES A RAYCAST FROM WHEN THE USER CLICKS                    
                    if(hit.transform.GetInstanceID() != gruttel.transform.GetInstanceID() || gruttel.data.type != GruttelType.Normal){ // CHECK IF POWERUP IS ALREADY APPLIED AKA GRUTTEL IS LOCKED IN
                        return NodeState.FAILURE;
                    }

                    if (!gruttelsSelected.Contains(hit.collider.transform) && gruttelsSelected.Count < gruttelsToSelect){
                        gruttelsSelected.Add(hit.collider.transform);
                        hit.collider.transform.localScale = Vector3.one * 1.15f;
                        RuntimeManager.PlayOneShot(selectSound);
                    }
                    else if(gruttelsSelected.Contains(hit.collider.transform)){
                        gruttelsSelected.Remove(hit.collider.transform);
                        hit.collider.transform.localScale = Vector3.one;
                    }                    
                }
            }
            #endregion
            
            if (powerupStorage.parent.GetComponentsInChildren<Powerup>().Length <= 0 && gruttelsSelected.Count >= gruttelsToSelect){ // THIS COULD BE SET TO || IF THE USER SHOULDNT BE FORCED TO USE ALL POWERUPS
                return NodeState.SUCCESS;
            }


            statScript.UpdateStats(gruttel);
            statScript.EnableUI(true);
            return NodeState.FAILURE;
        }
    }
}