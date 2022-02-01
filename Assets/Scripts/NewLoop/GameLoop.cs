using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEngine.Events;
using TrojanMouse.PowerUps;
using TrojanMouse.RegionManagement;
using UnityEngine.UI;

// MADE BY JOSHUA THOMPSON
namespace TrojanMouse.GameplayLoop
{
    using AI.Movement;

    [Serializable] public class CameraControl : UnityEvent<bool> { }
    [Serializable] public class RecycleObject : UnityEvent { }
    [Serializable]
    public class VillageSettings
    {
        [Tooltip("Place all the nodes for this level in here, all nodes will spawn a Gruttel on them")] public Transform[] gruttelSpawnPoints;
        [Tooltip("Gruttel Prefab here...")] public GameObject gruttelPrefab;
        [Tooltip("To keep hierarchy clean, choose a folder the Gruttels will spawn within")] public Transform gruttelFolder;

        [Tooltip("When on the introduction phase, this is the position the camera will interpolate to")] public Transform cameraTarget;
        public PowerupSettings powerupSettings;
    }
    [Serializable] public class PowerupSettings
    {
        [Tooltip("This is where the powerups will be deposited")] public Transform powerupStorage;
        [Tooltip("Powerup Prefab here...")] public GameObject powerupPrefab;
        public Sprite buffPower, radioPower;
    }

    public class GameLoop : MonoBehaviour
    {
        #region VARIABLES

        [SerializeField] VillageSettings villageSettings;
        [SerializeField] Cycle[] cycles;

        [Tooltip("The camera should interpolate to a given point after this being invoked")] [SerializeField] CameraControl cameraToVillage;
        [Tooltip("Can be used to play animation on recycler")] [SerializeField] RecycleObject recycleObject;

        public GameObject prepCam;
        public Text cycleText;
        public Text stageText;

        int timer;


        #region LEVEL DICTATORS
        bool isRunning; // THIS IS USED FOR ITERATING THROUGH STAGES
        public int curLevel, curStage; // These are the level controllers
        int numOfGruttelsToPick;
        int remainingLitterToSpawn;
        int litterToBeRecycled;
        float spawnDelayHolder, spawnDelay;
        public static GameLoop current;
        #endregion
        #endregion
        [SerializeField] float postPrepStageIntermission;
        [HideInInspector] public float stageIntermission;
        private void Start(){
            current = this;
            foreach (Transform node in villageSettings.gruttelSpawnPoints){
                // SPAWN GRUTTELS IN VILLAGE
                GameObject newGruttel = Instantiate(villageSettings.gruttelPrefab, node.position, node.rotation, villageSettings.gruttelFolder);
                // FACE THE CAMERA TARGET POS
                newGruttel.transform.LookAt(villageSettings.cameraTarget);
                newGruttel.transform.rotation = Quaternion.Euler(0, newGruttel.transform.rotation.eulerAngles.y, 0);
            }
            Camera.main.GetComponent<MoveWithMouseClick>().enabled = false;
            prepCam.SetActive(false);
            StartCoroutine(CountDownStage());
        }

        private void Update(){
            if (cycles[0].stages[curStage].levelComplete) {
                UnityEngine.SceneManagement.SceneManager.LoadScene("WinScreen");
            }
            #region DEPENDENCY MANAGEMENT
            if (curStage == 0 && !isRunning){ // PREP STAGE --
                isRunning = true;
                stageIntermission = postPrepStageIntermission;
                // ZOOM IN ON VILLAGE
                prepCam.SetActive(true);
                cameraToVillage?.Invoke(true); // CAMERA SHOULD RECIEVE THIS AND THEN INTERPOLATE TO THIS POSITION
                // SELECT GRUTTELS

                // DISPENCE POWERUPS TO PUT ON GRUTTELS   
                foreach (PowerupType powerUp in cycles[curLevel].stages[curStage].powerupsToDispence){
                    GameObject clonedPowerup = Instantiate(villageSettings.powerupSettings.powerupPrefab, Vector3.zero, Quaternion.identity, villageSettings.powerupSettings.powerupStorage);
                    Powerup pu = clonedPowerup.GetComponent<Powerup>();
                    pu.Type = powerUp;
                    clonedPowerup.name = powerUp.ToString();
                    // CHANGE IMAGE OF POWERUP CORROSPONDING TO TYPE
                    clonedPowerup.GetComponent<Image>().sprite = (powerUp == PowerupType.BUFF) ? villageSettings.powerupSettings.buffPower : villageSettings.powerupSettings.radioPower;
                }
            }
            else if (!isRunning)
            {
                isRunning = true;
                // RETURN CAMERA TO GAME MODE
                prepCam.SetActive(false);
                Camera.main.GetComponent<MoveWithMouseClick>().enabled = true;
                cameraToVillage?.Invoke(false); // CAMERA SHOULD RECIEVE THIS AND THEN INTERPOLATE TO THIS POSITION
                remainingLitterToSpawn = cycles[curLevel].stages[curStage].litterSettings.numOfLitterToSpawn;
                litterToBeRecycled = remainingLitterToSpawn;

                spawnDelayHolder = cycles[curLevel].stages[curStage].litterSettings.durationOfPhase / remainingLitterToSpawn;
            }
            #endregion           

            #region LEVEL MANAGEMENT
            if (cycles[curLevel].stages[curStage].IsComplete(numOfGruttelsToPick, villageSettings.powerupSettings.powerupStorage.parent.GetComponentsInChildren<Powerup>().Length, litterToBeRecycled))
            {
                isRunning = false;
                if (curStage + 1 > cycles[curLevel].stages.Length)
                {
                    curLevel = (curLevel + 1) % cycles.Length; // LEVEL INCREMENTOR
                    curStage = 0;
                }
                else
                {
                    curStage = (curStage + 1) % cycles[curLevel].stages.Length; // STAGE INCREMENTOR
                }
            }
            #endregion    

            #region LITTER SPAWNER
            if (remainingLitterToSpawn > 0 && spawnDelay <= 0 && stageIntermission <=0)
            {
                spawnDelay = spawnDelayHolder;
                Region[] regions = Region_Handler.current.GetRegions(Region.RegionType.LITTER_REGION);
                Region region = regions[UnityEngine.Random.Range(0, regions.Length)];
                remainingLitterToSpawn -= (region.litterManager.SpawnLitter(region.GetComponent<Collider>(), 1) < 0) ? 1 : 0;
            }
            spawnDelay -= (spawnDelay > 0) ? Time.deltaTime : 0;
            #endregion

            stageIntermission -= (stageIntermission >0)? Time.deltaTime : 0;
        }

        IEnumerator CountDownStage() {
            cycleText.text = cycles[0].stages[curStage].name;
            yield return new WaitForSeconds(1);
            float durationOfPhase = cycles[curLevel].stages[curStage].litterSettings.durationOfPhase;
            if (durationOfPhase != 0) {
                timer++;
                if (timer >= durationOfPhase) {
                    timer = 0;
                    curStage++;
                }
            }
            StartCoroutine(CountDownStage());
        }


        public void RecycleObj()
        {
            litterToBeRecycled--;
            recycleObject?.Invoke();
        }
    }
}