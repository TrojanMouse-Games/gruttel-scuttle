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
    }
}