using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FMODUnity;
using TrojanMouse.Gruttel;
using TrojanMouse.AI;

namespace TrojanMouse.GameplayLoop
{
    public class GruttelsSelected : GLNode{
        public static GruttelsSelected instance;
        public HashSet<Transform> gruttelsSelected = new HashSet<Transform>();        
        
        int gruttelsToSelect;
        Camera cam;
        float maxDistance;
        LayerMask whatIsGruttel;
        ShowGruttelStats statScript;

        Transform powerupStorage;
        public Transform villageFolder;
        Transform playFolder;
        public Transform lineupCam;
        EventReference selectSound;
        public GruttelsSelected(int gruttelsToSelect, Camera cam, Transform lineupCam, float maxRayDistance, LayerMask whatIsGruttel, ShowGruttelStats statScript,Transform powerupStorage, Transform villageFolder, Transform playFolder, EventReference selectSound){ // CONSTRUCTOR TO PREDEFINE THIS CLASS VARIABLES
            instance = this;

            this.gruttelsToSelect = gruttelsToSelect;
            this.cam = cam;
            this.maxDistance = maxRayDistance;
            this.whatIsGruttel = whatIsGruttel;
            this.statScript = statScript;
            this.powerupStorage = powerupStorage;
            this.villageFolder = villageFolder;
            this.playFolder = playFolder;
            this.lineupCam = lineupCam;
            this.selectSound = selectSound;                
        }

        public int gruttelSelectedIndex = 0;
        Vector3 smoothVel;
        bool hasInitiated;
        Vector3 targetPos;
        public override NodeState Evaluate(){                        

            #region GRUTTEL CYCLING
            int newIndex = gruttelSelectedIndex + (
                (Input.GetKeyDown(KeyCode.A))? -1: // IF 'A' KEY IS PRESSED (-1 off index)
                (Input.GetKeyDown(KeyCode.D))? 1: // IF 'D' KEY IS PRESSED (+1 onto index)
                0 // ELSE DONT ADD ANYTHING
            );
            
            if(newIndex < 0){
                newIndex = villageFolder.childCount-1;
            }
            else if(newIndex > villageFolder.childCount-1){
                newIndex = 0;
            }


            if(newIndex != gruttelSelectedIndex || !hasInitiated){ // IF CHANGED VALUE
                hasInitiated = true;
                gruttelSelectedIndex = newIndex;
                // FIND NEW POSITION
                targetPos = new Vector3(villageFolder.GetChild(gruttelSelectedIndex).position.x, lineupCam.position.y, lineupCam.position.z);
            }
            lineupCam.position = Vector3.SmoothDamp(lineupCam.position, targetPos, ref smoothVel, .1f);

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
                foreach(Transform g in gruttelsSelected){
                    g.parent = playFolder;
                }
                foreach (Transform g in villageFolder){
                    g.gameObject.SetActive(false);
                }
                statScript.EnableUI(false);
                return NodeState.SUCCESS;
            }


            statScript.UpdateStats(gruttel);
            statScript.EnableUI(true);
            return NodeState.FAILURE;
        }
    }
}