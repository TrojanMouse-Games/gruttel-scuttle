using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEngine.Events;
using TrojanMouse.PowerUps;

// MADE BY JOSHUA THOMPSON
namespace TrojanMouse.GameplayLoop{

    [Serializable] public class CameraControl : UnityEvent<Transform>{}

    [Serializable] public class VillageSettings{
        [Tooltip("Place all the nodes for this level in here, all nodes will spawn a Gruttel on them")] public Transform[] gruttelSpawnPoints;
        [Tooltip("Gruttel Prefab here...")] public GameObject gruttelPrefab;
        [Tooltip("To keep hierarchy clean, choose a folder the Gruttels will spawn within")] public Transform gruttelFolder;

        [Tooltip("When on the introduction phase, this is the position the camera will interpolate to")] public Transform cameraTarget;
    }


    public class GameLoop : MonoBehaviour{
        #region VARIABLES

        [SerializeField] VillageSettings villageSettings;
        [SerializeField] Cycle[] cycles;

        [Tooltip("The camera should interpolate to a given point after this being invoked")][SerializeField] CameraControl cameraToVillage;

        #region LEVEL DICTATORS
        int curLevel, curStage; // These are the level controllers
        int numOfGruttelsToPick;
        int numOfPowerupsToSet;
        int remainingLitterToSpawn;
        int litterToFilter; //E.G. LITTER ON THE FIELD
        #endregion
        #endregion

        private void Start() {   
            foreach(Transform node in villageSettings.gruttelSpawnPoints){
                // SPAWN GRUTTELS IN VILLAGE
                GameObject newGruttel = Instantiate(villageSettings.gruttelPrefab, node.position, node.rotation, villageSettings.gruttelFolder);
                // FACE THE CAMERA TARGET POS
                newGruttel.transform.LookAt(villageSettings.cameraTarget);
                newGruttel.transform.rotation = Quaternion.Euler(0, newGruttel.transform.rotation.eulerAngles.y, 0);
            }            
        }

        private void Update() {
            // INTRODUCTION HANDLING
            if(curStage == 0){
                // PREP STAGE --
                    // ZOOM IN ON VILLAGE
                cameraToVillage?.Invoke(villageSettings.cameraTarget); // CAMERA SHOULD RECIEVE THIS AND THEN INTERPOLATE TO THIS POSITION
                    // SELECT GRUTTELS
                    // DISPENCE POWERUPS TO PUT ON GRUTTELS                
            }
            else{
                // SPAWN LITTER
            }


            

            // LEVEL MANAGEMENT
            if(cycles[curLevel].stages[curStage].IsComplete(numOfGruttelsToPick, numOfPowerupsToSet, remainingLitterToSpawn, litterToFilter)){ 
                if(curStage + 1 > cycles[curLevel].stages.Length){ 
                    curLevel = (curLevel + 1) % cycles.Length; // LEVEL INCREMENTOR
                    curStage = 0;
                }                
                else{
                    curStage = (curStage + 1) % cycles[curLevel].stages.Length; // STAGE INCREMENTOR
                }                
            }
        }









        
    }
}