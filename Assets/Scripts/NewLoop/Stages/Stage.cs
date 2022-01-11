using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using TrojanMouse.PowerUps;

// MADE BY JOSHUA THOMPSON
namespace TrojanMouse.GameplayLoop{
    [Serializable] public class LitterSettings{
        public int numOfLitterToSpawn; 
        public float durationOfPhase;
    }



    [Serializable] public class Stage{
        // LOOP WILL WAIT ON THESE BEFORE INCREMENTING
        [Header("STAGE DEPENDENCIES")]
        public int numOfGruttelsToPick;        
        public LitterSettings litterSettings;
        public PowerupType[] powerupsToDispence;


        public bool IsComplete(int numOfGruttelsToPick, int numOfPowerupsToSet, int litterToBeRecycled){
            if(numOfGruttelsToPick <= 0 && numOfPowerupsToSet <= 0 && litterToBeRecycled <= 0){ // IF STAGE HAS COMPLETED...
                return true;
            }
            return false;
        }
    }
}