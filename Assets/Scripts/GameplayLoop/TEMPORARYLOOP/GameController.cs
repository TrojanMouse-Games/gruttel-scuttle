using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System;
using TrojanMouse.StressSystem;
using CassyScripts.Level_System;
using TrojanMouse.RegionManagement;

//15/10/21 initially by Cassy -- Edited By Josh with approval :P 
// -- Note by Josh: Cassy did a great job though, helped me get an understanding on what to do!


namespace CassyScripts.GameController{
    [RequireComponent(typeof(Region_Handler))]
    public class GameController : MonoBehaviour{
        [Serializable] public class Settings{
            public Region_Handler litterSystem;
        }
        [SerializeField] Settings settings;
        

        [SerializeField] LevelSystem[] cycles;
        public LevelSystem[] GetSettings() => cycles;
        bool hasCompletedIntro; // INTRO WILL BE THE TUTORIAL

        #region STAGE VARIABLES
        bool loadNextStage = true, loadNextCycle = false;

        public int cycleIndex, stageIndex; // Indexes used to find the stage to load for the player
        float durationRemaining, litterRemaining;
        float intermission = 0;
        public float Intermission { get { return intermission; } } // ACCESSOR -- USED FOR UI

        float spawnDelayHolder, spawnDelay;
        
        #endregion
        private void Start() => intermission = cycles[cycleIndex].stages[stageIndex].timeBetweenStages;
        private void Update(){                     
            if (!hasCompletedIntro){
                IntroGameStage();
                return; 
            }
            StageProcessor();
            StageSpawner();            
        }

        #region GAME FUNCTIONS
        /// <summary>THIS STAGE IS DESIGNED TO TEACH THE PLAYER HOW TO PLAY THE GAME</summary>
        public void IntroGameStage(){
            //PRE CONDITIONS NEED TO BE MET E.G. SHOWING PLAYER THE CONTROLS
            hasCompletedIntro = true;
        }

        /// <summary>THIS FUNCTION IS IN CONTROL OF INITIATING EACH STAGE</summary>
        void StageProcessor(){
            if (loadNextStage && intermission <= 0){
                if (loadNextCycle){ // LOADS NEXT LEVEL SET                    
                    loadNextCycle = false;
                    cycleIndex = (cycleIndex + 1) % cycles.Length;
                }
                loadNextStage = false;
                LevelSystem.Stage currentStage = cycles[cycleIndex].stages[stageIndex];
                Debug.Log($"Loading {cycles[cycleIndex].name} || {currentStage.stageName}");

                Region[] regions = Region_Handler.current.GetRegions(Region.RegionType.LITTER_REGION);
                int litterPerRegion = Mathf.FloorToInt((float)currentStage.litterOnStart / (float)regions.Length);
                foreach (Region region in regions){ // SPAWNS A DISTRIBUTED AMOUNT OF LITTER PER REGION                           
                    region.litterManager.maxLitterInRegion = Mathf.FloorToInt(currentStage.litterOnStart / regions.Length);
                    region.litterManager.SpawnLitter(region.GetComponent<Collider>(), litterPerRegion);
                }
                
                #region SETTINGS SETTER
                litterRemaining = currentStage.litterForWave;
                durationRemaining = currentStage.durationOfWave;

                spawnDelayHolder = durationRemaining / litterRemaining;
                #endregion
                Debug.Log($"Planning to spawn {litterRemaining} litter!");
                if (stageIndex == cycles[cycleIndex].stages.Length - 1) { loadNextCycle = true; }
                stageIndex = (stageIndex + 1) % cycles[cycleIndex].stages.Length; // SIMPLE WAY OF RESETTING THE STAGE INDEX AFTER IT REACHES THE MAX

                intermission = cycles[cycleIndex].stages[stageIndex].timeBetweenStages;
            }

            intermission -= (intermission > 0) ? Time.deltaTime : 0;
        }

        void StageSpawner(){
            if (loadNextStage) { return; }
            
            Region[] regions = Region_Handler.current.GetRegions(Region.RegionType.LITTER_REGION);
            if(litterRemaining > 0 && spawnDelay <=0){
                spawnDelay = spawnDelayHolder;                
                Region region = regions[UnityEngine.Random.Range(0, regions.Length)];               
                
                litterRemaining -= (region.litterManager.SpawnLitter(region.GetComponent<Collider>(), 1) == 0)? 1 : 0;                
            }

            int remainingLitter = 0;            
            foreach (Region region in regions){ remainingLitter += region.litterManager.litter.Length; }
            if(litterRemaining <=0 && remainingLitter <= 0){ loadNextStage = true; }

            spawnDelay -= (spawnDelay > 0) ? Time.deltaTime : 0;
        }
        #endregion
    }
}
