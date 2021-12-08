using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System;
using TrojanMouse.StressSystem;
using CassyScripts.Level_System;

//15/10/21 initially by Cassy -- Edited By Josh with approval :P 
// -- Note by Josh: Cassy did a great job though, helped me get an understanding on what to do!


namespace CassyScripts.GameController{
    [RequireComponent(typeof(Litter_System))]
    public class GameController : MonoBehaviour{
        [Serializable] public class Settings{
            public Litter_System litterSystem;
        }
        [SerializeField] Settings settings;
        

        [SerializeField] LevelSystem[] cycles;
        public LevelSystem[] GetSettings() => cycles;
        bool hasCompletedIntro; // INTRO WILL BE THE TUTORIAL
        

        Litter_System.Region[] regions { get { return settings.litterSystem.LitterRegions; } }

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

                int litterPerRegion = Mathf.FloorToInt((float)currentStage.litterOnStart / (float)regions.Length);
                foreach (Litter_System.Region region in regions){ // SPAWNS A DISTRIBUTED AMOUNT OF LITTER PER REGION                    
                    region.SpawnLitter(litterPerRegion, false);
                    region.maxLitterInRegion = Mathf.FloorToInt(currentStage.litterOnStart / regions.Length);
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
            

            if(litterRemaining > 0 && spawnDelay <=0){
                spawnDelay = spawnDelayHolder;
                Litter_System.Region region = regions[UnityEngine.Random.Range(0, regions.Length)];               
                
                litterRemaining -= (region.SpawnLitter(1) == 0)? 1 : 0;                
            }

            int remainingLitter = 0;
            foreach (Litter_System.Region region in regions){ remainingLitter += region.litterObjects.Count; }

            if(litterRemaining <=0 && remainingLitter <= 0){ loadNextStage = true; }

            spawnDelay -= (spawnDelay > 0) ? Time.deltaTime : 0;
        }
        #endregion



        //INCOMPLETE
        /*
        public void PreparationLoopStage()
        {
            CurrentGameStage = GameStages[1];
            CurrentLoopStage = LoopStages[0];
            //distribute nana betsys to gruttels
            _prepText = $"You have {NumNB} Nana Betsys to feed to your Gruttels, {NumStrengthNB} are strength " +
                $"meals and {NumRadationNB} are radiation proof meals. Who would you like to give them to?";
            //need names and number of gruttels available.
            //NEED HELP CREATING BUTTONS WITH SCRIPTABLE OBJECTS OF GRUTTELS ON
            // gruttels have name, gender, current power up
            // drag gruttels into place
            UIUpdater();
            //button calls MainRoundLoopStage
        }
        //INCOMPLETE
        public void MainRoundLoopStage()
        {
            CurrentLoopStage = LoopStages[1];
            //changing number of piles to be picked up based on loop
            switch (CurrentLoopNum)
            {
                case 0:
                    NumPiles = 5;
                    break;
                case 1:
                    NumPiles = 7;
                    break;
                case 2:
                    NumPiles = 10;
                    break;
                case 3:
                    NumPiles = 14;
                    break;
                case 4:
                    NumPiles = 18;
                    break;
            }

            //number of rubbish piles to be picked up
            _mainRoundText = $"Pick up as much of the litter as you can! There are currently " +
                $"{NumPiles} pieces of litter near the village.";
            // Stress & freakout needed
            UIUpdater();
        }
        public void LitterPickup()
        {
            //runs on interaction when litter is picked up
            //reduces num of litter piles in play
            if (NumPiles >= 1)
            {
                NumPiles--;
                _mainRoundText = $"Pick up as much of the litter as you can! There are currently " +
                $"{NumPiles} pieces of litter near the village.";
                UIUpdater();
            }
            else if (NumPiles == 0)
            {
                _mainRoundText = $"You've picked up all the litter!";
                UIUpdater();
                AftermathLoopStage();
            }
        }

        //INCOMPLETE
        void AftermathLoopStage()
        {
            CurrentLoopStage = LoopStages[2];
            if (CurrentLoopNum < 4)
            {
                CurrentLoopNum++;
                //won the round
                _aftermathText = "You won this wave! Now send a lucky gruttel to space and prepare for the next one";
                //choose what to spend litter on for upgrades
                //send gruttel to space to get nana betsys
                UIUpdater();
                //button calls PreparationLoopStage();
            }
            else if (CurrentLoopNum == 4)
            {
                CurrentLoopNum++;
                CurrentGameStage = GameStages[2];
                _victoryText = "Congratulations you've cleaned the litter and saved the Gruttels!";
                UIUpdater();
            }
        }

        void UIUpdater()
        {
            //updating text when called
            GameStageText.text = CurrentGameStage.ToString();
            LoopStageText.text = CurrentLoopStage.ToString();
            LoopNumText.text = CurrentLoopNum.ToString();
            //making sure only appropriate game stage UI is active
            //intro game stage
            if (CurrentGameStage == GameStages[0])
            {
                IntroGamePanel.SetActive(true);
                LoopGamePanel.SetActive(false);
                VictoryGamePanel.SetActive(false);

                IntroText.text = _introText;
            }
            //main game loop stage
            else if (CurrentGameStage == GameStages[1])
            {
                IntroGamePanel.SetActive(false);
                LoopGamePanel.SetActive(true);
                VictoryGamePanel.SetActive(false);
                //making sure only appropriate loop stage UI is active
                //preparation loop stage
                if (CurrentLoopStage == LoopStages[0])
                {
                    PreparationLoopPanel.SetActive(true);
                    MainRoundLoopPanel.SetActive(false);
                    AftermathLoopPanel.SetActive(false);

                    PreparationText.text = _prepText;
                }
                //main round loop stage
                else if (CurrentLoopStage == LoopStages[1])
                {
                    PreparationLoopPanel.SetActive(false);
                    MainRoundLoopPanel.SetActive(true);
                    AftermathLoopPanel.SetActive(false);

                    MainRoundText.text = _mainRoundText;
                }
                //aftermath round loop stage
                else if (CurrentLoopStage == LoopStages[2])
                {
                    PreparationLoopPanel.SetActive(false);
                    MainRoundLoopPanel.SetActive(false);
                    AftermathLoopPanel.SetActive(true);

                    AftermathText.text = _aftermathText;
                }
            }
            else if (CurrentGameStage == GameStages[2])
            {
                IntroGamePanel.SetActive(false);
                LoopGamePanel.SetActive(false);
                VictoryGamePanel.SetActive(true);

                VictoryText.text = _victoryText;
            }
        }*/
    }
}
