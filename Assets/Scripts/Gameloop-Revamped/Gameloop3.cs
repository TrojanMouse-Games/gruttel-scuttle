using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEngine.Events;

namespace TrojanMouse.GameplayLoop{   

    public class Gameloop3 : MonoBehaviour{
        #region VARIABLES
        public static Gameloop3 instance;
        
        #region STAGE VARS
        public Stages curStage = Stages.Preperation;
        int numOfStages { get { return Enum.GetNames(typeof(Stages)).Length; } }
        #endregion
        [SerializeField] Level[] levels;
        int curLevel;
        #endregion


        private void Awake(){
            if (instance){ // IF INSTANCE IS ALREADY SET, THIS MEANS THERE IS ALREADY A GAMEPLAY LOOP SCRIPT IN SCENE
                Destroy(this);
            }
            instance = this;
        }

        private void Update(){
            bool enterNextStage = false,
                 enterNextLevel = false;

            switch (curStage){
                case Stages.Preperation:
                    // SELECT AND POWERUP GRUTTELS
                    enterNextStage = PrepStage();
                    break;
                case Stages.Ready:
                    // MANUALLY DRAG GRUTTELS
                    break;
                case Stages.Main:
                    // SPAWN LITTER
                    break;
                case Stages.Aftermath:
                    // AFTER COMPLETION, PROGRESS LEVEL
                    //enterNextLevel = true;
                    break;
                default:
                    break;
            }

            if (enterNextStage){ // PROGRESSES STAGE TO ALLOW FOR NEW BEHAVIOUR
                enterNextStage = false;
                curStage = ProgressStage();
            }
            curLevel = (enterNextLevel) ? (curLevel + 1) % levels.Length : curLevel; // PROGRESSES ONTO THE NEXT LEVEL IF ENTER NEXT LEVEL IS TRUE (MODULUS BASED)
        }

        /// <summary>
        /// This function will progress the stage onto the next stage, and will return that value
        /// </summary>        
        Stages ProgressStage(){
            int nextStageValue = ((int)curStage + 1) % (numOfStages); // Modulus value between 0 and the theoretical length of an enum
            return (Stages)nextStageValue; // This converts the int value back to the index of an enum 
        }











        #region STAGE HANDLERS
        /// <summary>
        /// This function will handle the Gruttel selection and the powerup dispencing
        /// </summary>
        /// <returns>If it returns true, that means that the next stage can be triggered</returns>
        PrepStageStates curPrepState = PrepStageStates.SpawnGruttels;
        bool PrepStage(){
            bool progressState = false;
            switch (curPrepState){
                case PrepStageStates.SpawnGruttels:
                    // CHECK VILLAGE, IF THERE ARE ALREADY GRUTTELS PRESENT THEN PROGRESS STATE OTHERWISE, SPAWN THEM AT POINTS
                    break;
                case PrepStageStates.SelectGruttels:
                    // PLAYERS SHOULD SELECT X AMT OF GRUTTELS BEFORE PROGRESSING STATE
                    // AFTER SELECTION, GRUTTELS WILL BE MOVED TO ANOTHER PARENTAL OBJECT, ONCE THAT PARENTAL OBJECT REACHES X AMOUNT OF GRUTTELS -- PROGRESS STATE
                    break;
                case PrepStageStates.DispencePowerups:
                    // SPAWN POWERUPS ONTO PLAYER
                    progressState = true; // HARD CODE PROGRESSION - DOESNT NEED TO WAIT ON ANYTHING
                    break;
                case PrepStageStates.WaitForPowerups:
                    // WAIT UNTIL NO POWERUPS ARE REMAINING
                    // RETURN TRUE IF THIS IS TRUE                    
                    break;
                default:
                    break;
            }

            if (progressState){
                int nextStageValue = ((int)curPrepState + 1) % (Enum.GetNames(typeof(PrepStageStates)).Length); // Modulus value between 0 and the theoretical length of an enum
                curPrepState = (PrepStageStates)nextStageValue; // This converts the int value back to the index of an enum 
            }
            return false; // SAFETY MASK, SHOULD ALWAYS RETURN FALSE HERE! -- RETURNS TRUE IN SWITCH CASE
        }        
        #endregion



        [Serializable] public enum Stages{
            Preperation,
            Ready,
            Main,
            Aftermath
        }
        [Serializable] public enum PrepStageStates{
            SpawnGruttels,
            SelectGruttels,
            DispencePowerups,
            WaitForPowerups
        }
    }
}