using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEngine.Events;
using TrojanMouse.PowerUps;
using TrojanMouse.RegionManagement;

// MADE BY JOSHUA THOMPSON
namespace TrojanMouse.GameplayLoop{

    [Serializable] public class CameraControl : UnityEvent<bool>{}

    [Serializable] public class VillageSettings{
        [Tooltip("Place all the nodes for this level in here, all nodes will spawn a Gruttel on them")] public Transform[] gruttelSpawnPoints;
        [Tooltip("Gruttel Prefab here...")] public GameObject gruttelPrefab;
        [Tooltip("To keep hierarchy clean, choose a folder the Gruttels will spawn within")] public Transform gruttelFolder;

        [Tooltip("When on the introduction phase, this is the position the camera will interpolate to")] public Transform cameraTarget;
        public PowerupSettings powerupSettings;
    }
    [Serializable] public class PowerupSettings{
        [Tooltip("This is where the powerups will be deposited")] public Transform powerupStorage;
        [Tooltip("Powerup Prefab here...")] public GameObject powerupPrefab;
    }

    public class GameLoop : MonoBehaviour{
        #region VARIABLES

        [SerializeField] VillageSettings villageSettings;
        [SerializeField] Cycle[] cycles;

        [Tooltip("The camera should interpolate to a given point after this being invoked")][SerializeField] CameraControl cameraToVillage;

        #region LEVEL DICTATORS
        bool isRunning; // THIS IS USED FOR ITERATING THROUGH STAGES
        int curLevel, curStage; // These are the level controllers
        int numOfGruttelsToPick;        
        int remainingLitterToSpawn;
        int litterRecycled;
        float spawnDelayHolder, spawnDelay;
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
            #region DEPENDENCY MANAGEMENT
            if(curStage == 0 && !isRunning){ // PREP STAGE --
                isRunning = true;               
                // ZOOM IN ON VILLAGE
                cameraToVillage?.Invoke(true); // CAMERA SHOULD RECIEVE THIS AND THEN INTERPOLATE TO THIS POSITION
                // SELECT GRUTTELS

                // DISPENCE POWERUPS TO PUT ON GRUTTELS   
                foreach(PowerupType powerUp in cycles[curLevel].stages[curStage].powerupsToDispence){
                    GameObject clonedPowerup = Instantiate(villageSettings.powerupSettings.powerupPrefab, Vector3.zero, Quaternion.identity, villageSettings.powerupSettings.powerupStorage);
                    Powerup pu = clonedPowerup.GetComponent<Powerup>(); 
                    pu.Type = powerUp;
                    clonedPowerup.name = powerUp.ToString();      
                    // CHANGE IMAGE OF POWERUP CORROSPONDING TO TYPE
                }                        
            }
            else if(!isRunning){
                isRunning = true;
                // RETURN CAMERA TO GAME MODE
                cameraToVillage?.Invoke(false); // CAMERA SHOULD RECIEVE THIS AND THEN INTERPOLATE TO THIS POSITION
                remainingLitterToSpawn = cycles[curLevel].stages[curStage].litterSettings.numOfLitterToSpawn;               

                spawnDelayHolder = cycles[curLevel].stages[curStage].litterSettings.durationOfPhase / remainingLitterToSpawn;
            }
            #endregion           

            #region LEVEL MANAGEMENT
            if(cycles[curLevel].stages[curStage].IsComplete(numOfGruttelsToPick, villageSettings.powerupSettings.powerupStorage.parent.GetComponentsInChildren<Powerup>().Length, remainingLitterToSpawn, litterToFilter)){ 
                isRunning = false;
                if(curStage + 1 > cycles[curLevel].stages.Length){ 
                    curLevel = (curLevel + 1) % cycles.Length; // LEVEL INCREMENTOR
                    curStage = 0;
                }                
                else{
                    curStage = (curStage + 1) % cycles[curLevel].stages.Length; // STAGE INCREMENTOR
                }                
            }
            #endregion    

            #region LITTER SPAWNER
            if(remainingLitterToSpawn >0 && spawnDelay <=0){
                spawnDelay = spawnDelayHolder;
                Region[] regions = Region_Handler.current.GetRegions(Region.RegionType.LITTER_REGION);
                Region region = regions[UnityEngine.Random.Range(0, regions.Length)]; 
                remainingLitterToSpawn -= (region.litterManager.SpawnLitter(region.GetComponent<Collider>(), 1) == 0)? 1 : 0;                
                //Debug.Log(region.litterManager.SpawnLitter(region.GetComponent<Collider>(), 1)); -- ISSUE WITH SPAWNING LITTER, NOT NEGATING PROPERALLY
                
            }
            spawnDelay -= (spawnDelay > 0) ? Time.deltaTime : 0;
            #endregion
            Debug.Log(curStage);     
        }
    }
}