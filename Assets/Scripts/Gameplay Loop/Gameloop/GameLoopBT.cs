using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEngine.UI;
using TMPro;
using TrojanMouse.StressSystem;
using FMODUnity;

namespace TrojanMouse.GameplayLoop{   
    public class GameLoopBT : MonoBehaviour{        
        public static GameLoopBT instance;
        #region VARIABLES
        [SerializeField] Prerequisites prerequisiteSettings;
        
        [SerializeField] Level[] levels;
        [SerializeField] int curLevel; // THIS IS THE LEVEL THAT'LL BE ACCESSED FROM THE BEGINNING
        GLNode topNode;
        Camera cam;
        public static event Action<EnableAI.AIState> SetAIState;  // CHANGES THE BEHAVIOUR OF ALL AI
        float spawnDelay;
        #endregion
        
        GLNode CreateBehaviourTree(Level level){            
            GameObject[] cameras = new GameObject[]{ prerequisiteSettings.prepCamera, prerequisiteSettings.readyStageCamera, prerequisiteSettings.mainCamera}; // STORES ALL THE CAMERAS INTO AN ARRAY

            #region NODES
            #region PREP NODES
            SpawnGruttels spawnGruttels = new SpawnGruttels(prerequisiteSettings.gruttelObj, prerequisiteSettings.gruttelVillageSpawnPoints, prerequisiteSettings.objectForGruttelsToLookAtWhenSpawned, prerequisiteSettings.gruttelVillageFolder); // PASS IN BOTH FOLDERS, IF BOTH EMPTY, THEN SPAWN GRUTTELS
            //GruttelsSelected areGruttelsSelected = new GruttelsSelected(level.numOfGruttelsToSelect, 100, prerequisiteSettings.whatIsGruttel, cam, prerequisiteSettings.gruttelVillageFolder, prerequisiteSettings.gruttelPlayFolder, prerequisiteSettings.selectSound);
            SpawnPowerups spawnPowerups = new SpawnPowerups(prerequisiteSettings.powerupPrefab, level.powerups, prerequisiteSettings.powerupSpawnFolder);
            GruttelsSelected areGruttelsSelected = new GruttelsSelected(level.numOfGruttelsToSelect, cam, prerequisiteSettings.prepCamera.transform, 100, prerequisiteSettings.whatIsGruttel, prerequisiteSettings.statScript, prerequisiteSettings.powerupSpawnFolder, prerequisiteSettings.gruttelVillageFolder, prerequisiteSettings.gruttelPlayFolder, prerequisiteSettings.selectSound);
            ChangeUIText selectGruttelsText = new ChangeUIText(prerequisiteSettings.tipText, $"Click on {level.numOfGruttelsToSelect} Gruttels to proceed");
            EnableAI disableAI = new EnableAI(EnableAI.AIState.Disabled);
            ChangeCamera prepCam = new ChangeCamera(prerequisiteSettings.prepCamera, cameras);            
            #endregion
            #region READY NODES
            ChangeUIText dragGruttelsText = new ChangeUIText(prerequisiteSettings.tipText, $"Drag and drop Gruttels into position before the game starts!");
            ChangeCamera readyCam = new ChangeCamera(prerequisiteSettings.readyStageCamera, cameras);
            Intermission timeToDragGruttels = new Intermission(level.readyStageIntermission, prerequisiteSettings.intermissionTimer, prerequisiteSettings.timerLabel);
            EnableAI dragAI = new EnableAI(EnableAI.AIState.Dragable);            
            #endregion
            #region MAIN NODES
            ChangeUIText mainRoundText = new ChangeUIText(prerequisiteSettings.tipText, $"Round started, Click on the Gruttels and guide them to litter!");
            ChangeCamera mainCam = new ChangeCamera(prerequisiteSettings.readyStageCamera, cameras, false);
            EnableStress enableStress = new EnableStress(true);
            LitterHandler litterHandler = new LitterHandler(level, prerequisiteSettings.cycleText);
            IsLitterCleared isLitterCleared = new IsLitterCleared();
            EnableStress disableStress = new EnableStress(false);

            EnableAI enableAI = new EnableAI(EnableAI.AIState.Enabled);
            #endregion
            #region AFTERMATH NODES
            WinState win = new WinState();
            #endregion
            
            #endregion

            // EACH ACTION LABELLED IN THESE SEQUENCES ARE ACTED OUT AS A CHECKLIST SYSTEM, ONCE ONE IS COMPLETED, IT WILL ENTER THE NEXT PHASE.
            #region PREPSTAGE
            GLSequence prepStage = new GLSequence(new List<GLNode>{
                spawnGruttels, 
                prepCam, 
                selectGruttelsText, 
                disableAI,                 
                spawnPowerups,                 
                areGruttelsSelected
            });
            #endregion
            #region READYSTAGE
            GLSequence readyStage = new GLSequence(new List<GLNode>{
                dragGruttelsText, 
                readyCam, 
                dragAI, 
                timeToDragGruttels
            });
            #endregion
            #region MAINSTAGE
            GLSequence mainStage = new GLSequence(new List<GLNode>{
                mainRoundText, 
                enableAI,
                mainCam,
                enableStress,
                litterHandler, 
                //isLitterCleared,
                disableStress
                });
            #endregion
            #region AFTERMATHSTAGE
            GLSequence afterMainStage = new GLSequence(new List<GLNode>{
                win,
            });
            #endregion
            return new GLSequence(new List<GLNode>{prepStage, readyStage, mainStage, afterMainStage});
        }

        private void Awake() {
            #region SINGLETON CREATION
            if (instance){
                Destroy(this);
                return;
            }
            instance = this;
            #endregion            
            cam = Camera.main; // ASSIGN THE CAMERA VARIABLE

            if(topNode == null){                
                topNode = CreateBehaviourTree(levels[curLevel]); // THIS INITIATES THE TREE FROM WHEN THE GAME STARTS. IT WILL START THE TREE AT LEVEL 1
            }
        }

        void Update(){            
            switch(topNode.Evaluate()){ // THIS LINE CALLS THE EVALUATE FUNCTION WHICH ULTIMATELY TRIGGERS THE TREE TO BE SEARCHED FOR ACTIONS
                case NodeState.SUCCESS:
                    curLevel = (curLevel + 1) % levels.Length; // ITERATES TO THE NEXT LEVEL OR 0                  
                    topNode = CreateBehaviourTree(levels[curLevel]); // CREATE BT FOR NEXT LEVEL
                    break;
                case NodeState.FAILURE:
                    break;
                case NodeState.RUNNING:
                    break;
            }
            Stress.current.maxLitter = prerequisiteSettings.gruttelPlayFolder.childCount * prerequisiteSettings.maxLitterStressPerGruttel; // THIS IS MULTIPLIED PER GRUTTEL
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
        
        /// <summary>THIS FUNCTION WILL CHANGE THE AI STATE TO THE PASSED STATE</summary>
        /// <param name="state">THE STATE YOU WISH TO FORCE CHANGE ALL AI TO</param>
        public void ChangeAIState(EnableAI.AIState state){
            SetAIState?.Invoke(state);
        }

        // SETTINGS FOR THE INSPECTOR
        [Serializable] public class Prerequisites{
            [Header("Gruttel Settings")]
            [Tooltip("This is the Gruttel prefab. 1 will for spawn every spawnpoint...")] public GameObject gruttelObj;
            [Tooltip("These are the positions the Gruttels will spawn at")] public Transform[] gruttelVillageSpawnPoints;
            [Tooltip("This is folder where the Gruttels will initially spawn within")] public Transform gruttelVillageFolder;
            [Tooltip("After selected, Gruttels will move into this folder, where they will be activated and used to play the level")] public Transform gruttelPlayFolder;
            [Tooltip("This is needed for Gruttel selection, please choose the layermask the gameobject uses!")] public LayerMask whatIsGruttel;
            [Tooltip("For every Gruttel, this will be the stress the game will be able to handle")] public float maxLitterStressPerGruttel;
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
            public TextMeshProUGUI timerLabel;
            public ShowGruttelStats statScript;

            [Header("Audio Settings")]
            public EventReference selectSound;
        }
    }
}
