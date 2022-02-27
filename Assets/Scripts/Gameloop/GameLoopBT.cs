using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEngine.UI;

namespace TrojanMouse.GameplayLoop{   
    public class GameLoopBT : MonoBehaviour{        
        public static GameLoopBT instance;

        #region VARIABLES
        [SerializeField] Prerequisites prerequisiteSettings;
        
        [SerializeField] Level[] levels;
        [SerializeField] int curLevel, curWave; // THIS IS THE LEVEL THAT'LL BE ACCESSED FROM THE BEGINNING
        GLNode topNode;
        Camera cam;
        public static event Action<bool> SetWanderState;  // CHANGES THE BEHAVIOUR OF Wander AI        
        float spawnDelay;
        #endregion
        
        GLNode CreateBehaviourTree(Level level){            
            GameObject[] cameras = new GameObject[]{ prerequisiteSettings.prepCamera, prerequisiteSettings.readyStageCamera, prerequisiteSettings.mainCamera};

            #region NODES
            #region PREP NODES
            SpawnGruttels spawnGruttels = new SpawnGruttels(prerequisiteSettings.gruttelObj, prerequisiteSettings.gruttelVillageSpawnPoints, prerequisiteSettings.objectForGruttelsToLookAtWhenSpawned, prerequisiteSettings.gruttelVillageFolder); // PASS IN BOTH FOLDERS, IF BOTH EMPTY, THEN SPAWN GRUTTELS
            GruttelsSelected areGruttelsSelected = new GruttelsSelected(level.numOfGruttelsToSelect, 100, prerequisiteSettings.whatIsGruttel, cam, prerequisiteSettings.gruttelVillageFolder, prerequisiteSettings.gruttelPlayFolder);
            SpawnPowerups spawnPowerups = new SpawnPowerups(prerequisiteSettings.powerupPrefab, level.powerups, prerequisiteSettings.powerupSpawnFolder);
            PowerupsUsed arePowerupsUsed = new PowerupsUsed(prerequisiteSettings.powerupSpawnFolder);
            ChangeUIText selectGruttelsText = new ChangeUIText(prerequisiteSettings.tipText, $"Click on {level.numOfGruttelsToSelect} Gruttels to proceed");
            ChangeUIText addPowerupsText = new ChangeUIText(prerequisiteSettings.tipText, $"Drag and drop Nana Betsy's onto your Gruttels");
            ChangeCamera prepCam = new ChangeCamera(prerequisiteSettings.prepCamera, cameras);

            EnableWander disableWander = new EnableWander(false);
            EnableAIDrag disableDragAIPrep = new EnableAIDrag(false);  
            EnableAIMouseClick disableMouseClickAIPrep = new EnableAIMouseClick(false);  
            GLSequence disableAI = new GLSequence(new List<GLNode>{disableWander, disableDragAIPrep, disableMouseClickAIPrep});            
            #endregion
            #region READY NODES
            ChangeUIText dragGruttelsText = new ChangeUIText(prerequisiteSettings.tipText, $"Drag and drop Gruttels into position before the game starts!");
            ChangeCamera readyCam = new ChangeCamera(prerequisiteSettings.readyStageCamera, cameras);
            Intermission timeToDragGruttels = new Intermission(level.readyStageIntermission, prerequisiteSettings.intermissionTimer);
            
            EnableAIDrag enableDragAI = new EnableAIDrag(true);             
            #endregion
            #region MAIN NODES
            ChangeUIText mainRoundText = new ChangeUIText(prerequisiteSettings.tipText, $"Round started, Click on the Gruttels and guide them to litter!");
            ChangeCamera mainCam = new ChangeCamera(prerequisiteSettings.readyStageCamera, cameras, false);
            LitterHandler litterHandler = new LitterHandler(level);
            IsLitterCleared isLitterCleared = new IsLitterCleared();

            EnableWander enableWander = new EnableWander(true);
            EnableAIDrag disableDragAIMain = new EnableAIDrag(false);  
            EnableAIMouseClick enableMouseClickAIPrep = new EnableAIMouseClick(true);  
            GLSequence enableAI = new GLSequence(new List<GLNode>{enableWander, disableDragAIMain, enableMouseClickAIPrep}); 
            #endregion
            #region AFTERMATH NODES
            #endregion
            #endregion

            GLSequence prepStage = new GLSequence(new List<GLNode>{spawnGruttels, prepCam, selectGruttelsText, disableAI, areGruttelsSelected, spawnPowerups, addPowerupsText, arePowerupsUsed});
            GLSequence readyStage = new GLSequence(new List<GLNode>{dragGruttelsText, readyCam, enableDragAI, timeToDragGruttels});
            GLSequence mainStage = new GLSequence(new List<GLNode>{mainRoundText, enableAI, mainCam, litterHandler, isLitterCleared});

            
            return new GLSequence(new List<GLNode>{prepStage, readyStage, mainStage});
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

            if(topNode == null){
                topNode = CreateBehaviourTree(levels[curLevel]);
            }
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
        
        public void ChangeWanderState(bool state){
            SetWanderState?.Invoke(state);
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

            [Header("Camera Settings")]
            public GameObject prepCamera;
            public GameObject readyStageCamera;
            public GameObject mainCamera;

            [Header("UI Settings")]
            public Text cycleText;
            public Text stageText;
            public Text tipText;
            public Image intermissionTimer;
        }
    }
}