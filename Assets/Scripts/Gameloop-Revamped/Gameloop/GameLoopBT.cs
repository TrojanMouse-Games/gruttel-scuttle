using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

namespace TrojanMouse.GameplayLoop{   
    public class GameLoopBT : MonoBehaviour{        
        public static GameLoopBT instance;

        #region VARIABLES
        [SerializeField] Prerequisites prerequisiteSettings;
        
        [SerializeField] Level[] levels;
        [SerializeField] int curLevel; // THIS IS THE LEVEL THAT'LL BE ACCESSED FROM THE BEGINNING
        GLNode topNode;
        Camera cam;

        float spawnDelayHolder, spawnDelay;
        #endregion
        
        GLNode CreateBehaviourTree(Level level){
            spawnDelayHolder = CalculateSpawnDelay(levels[curLevel]);

            #region NODES
            #region PREP NODES
            SpawnGruttels spawnGruttels = new SpawnGruttels(prerequisiteSettings.gruttelObj, prerequisiteSettings.gruttelVillageSpawnPoints, prerequisiteSettings.objectForGruttelsToLookAtWhenSpawned, prerequisiteSettings.gruttelVillageFolder); // PASS IN BOTH FOLDERS, IF BOTH EMPTY, THEN SPAWN GRUTTELS
            GruttelsSelected areGruttelsSelected = new GruttelsSelected(level.numOfGruttelsToSelect, 100, prerequisiteSettings.whatIsGruttel, cam, prerequisiteSettings.gruttelVillageFolder, prerequisiteSettings.gruttelPlayFolder);
            SpawnPowerups spawnPowerups = new SpawnPowerups(prerequisiteSettings.powerupPrefab, level.numOfPowerupsToDispence, prerequisiteSettings.powerupSpawnFolder);
            PowerupsUsed arePowerupsUsed = new PowerupsUsed(prerequisiteSettings.powerupSpawnFolder);
            #endregion
            
            #region MAIN NODES
            SpawnLitter spawnLitter = new SpawnLitter(level.litterToSpawnForWave);
            IsLitterCleared isLitterCleared = new IsLitterCleared();
            #endregion
            #endregion

            GLSequence prepStage = new GLSequence(new List<GLNode>{spawnGruttels, areGruttelsSelected, spawnPowerups, arePowerupsUsed});
            GLSequence mainStage = new GLSequence(new List<GLNode>{spawnLitter, isLitterCleared});

            
            return new GLSequence(new List<GLNode>{prepStage, mainStage});
        }







        private void Awake() {    
            #region SINGLETON CREATION
            if(!instance){
                instance = this;
            }   
            else{
                Destroy(this);
            }
            #endregion
            
            cam = Camera.main;
            topNode = CreateBehaviourTree(levels[curLevel]);
        }

        void Update(){
            switch(topNode.Evaluate()){
                case NodeState.SUCCESS:
                    curLevel = (curLevel + 1) % levels.Length; // ITERATES TO THE NEXT LEVEL OR 0                    
                    topNode = CreateBehaviourTree(levels[curLevel]); // CREATE BT FOR NEXT LEVEL
                    break;
                case NodeState.FAILURE:
                    break;
                case NodeState.RUNNING:
                    break;
            }
        }

        ///<summary>THIS FUNCTION WILL ALLOW BT BEHAVIOURS TO CALL THIS FUNCTION, BECAUSE THEY DO NOT DERIVE FROM MONOBEHAVIOUR SO THIS WILL NOT WORK OTHERWISE... SIMPLY SPAWNS OBJECTS</summary>
        public GameObject SpawnObj(GameObject obj, Vector3 spawnPoint, Quaternion rotation, Transform parent){
            return Instantiate(obj, spawnPoint, rotation, parent);
        }
        
        ///<summary>THIS FUNCTION WILL RETURN A MOUSE RAY, 'INPUT.MOUSEPOSITION' ONLY DERIVES FROM MONOBEHAVIOUR WHICH THE BT BEHAVIOURS DO NOT, SO THIS NEEDS TO BE HERE TO WORK</summary>
        public Ray GetMouse(Camera cam){            
            if(Input.GetMouseButtonDown(0)){
                return cam.ScreenPointToRay(Input.mousePosition);
            }
            return new Ray();
        }

        public bool CanSpawn(){
            spawnDelay -= (spawnDelay >0) ? Time.deltaTime : 0;
            if(spawnDelay <=0){
                spawnDelay = spawnDelayHolder;
                return true;
            }
            return false;
        }

        float CalculateSpawnDelay(Level level){
            return level.timeToSpawnAllLitter / level.litterToSpawnForWave;
        }
        
        [Serializable] public class Prerequisites{
            [Header("Gruttel Settings")]
            [Tooltip("This is the Gruttel prefab. 1 will for spawn every spawnpoint...")] public GameObject gruttelObj;
            [Tooltip("These are the positions the Gruttels will spawn at")] public Transform[] gruttelVillageSpawnPoints;
            [Tooltip("This is folder where the Gruttels will initially spawn within")] public Transform gruttelVillageFolder;
            [Tooltip("After selected, Gruttels will move into this folder, where they will be activated and used to play the level")] public Transform gruttelPlayFolder;
            [Tooltip("This is needed for Gruttel selection, please choose the layermask the gameobject uses!")] public LayerMask whatIsGruttel;
            public Transform objectForGruttelsToLookAtWhenSpawned;

            [Header("Powerup Settings")]
            [Tooltip("Powerup Prefab here...")] public GameObject powerupPrefab;
            [Tooltip("This is where the powerups will be deposited (SHOULD BE INSIDE A CANVAS OBJECT)")] public Transform powerupSpawnFolder;
        }
    }
}