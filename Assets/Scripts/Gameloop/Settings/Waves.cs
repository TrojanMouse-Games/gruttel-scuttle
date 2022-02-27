using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrojanMouse.RegionManagement;
using TrojanMouse.BallisticTrajectory;

namespace TrojanMouse.GameplayLoop{
    [CreateAssetMenu(fileName = "New Wave", menuName = "ScriptableObjects/GameLoop/Create New Wave")]
    public class Waves : ScriptableObject{        
        [Header("Wave Settings")]
        [Tooltip("Total amount of litter to start spawning over a duration of time")] public int litterToSpawnForWave;
        [Tooltip("Time it takes for 'LitterToSpawnForWave' amount of litter to finish spawning (Seconds)")] public float timeToSpawnAllLitter;
        [Tooltip("Time until next wave starts")] public float intermissionBeforeNextWave;

        [Header("Shooter Settings -- PUT NAMES OF PLACES IN HERE")]
        public string[] shootersInThisWave;
        public string[] regionsToLandAtInThisWave;        
    }
}