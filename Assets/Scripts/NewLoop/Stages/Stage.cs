using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

// MADE BY JOSHUA THOMPSON
namespace TrojanMouse.GameplayLoop{
    [Serializable] public class Stage{
        // LOOP WILL WAIT ON THESE BEFORE INCREMENTING
        public int numOfGruttelsToPick, numOfPowerupsToDispence;
        public int numOfLitterToSpawn; 
        public float durationOfPhase;


        public bool IsComplete(int numOfGruttelsToPick, int numOfPowerupsToSet, int remainingLitterToSpawn, int litterToFilter){
            if(numOfGruttelsToPick <= 0 && numOfPowerupsToSet <= 0 && remainingLitterToSpawn <= 0 && litterToFilter <= 0){ // IF STAGE HAS COMPLETED...
                return true;
            }
            return false;
        }
    }
}