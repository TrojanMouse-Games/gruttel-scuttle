using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.GameplayLoop{
    [CreateAssetMenu(fileName = "New Level", menuName = "ScriptableObjects/GameLoop/Create New Level")]
    public class Level : ScriptableObject{
        [Header("Prep-Stage Settings")]
        [Tooltip("Players will have to select x amount of Gruttels to then proceed onto next stage")] public int numOfGruttelsToSelect;
        [Tooltip("Number of powerups to dispence to the player to be used on the Gruttels!")] public int numOfPowerupsToDispence;
        [Tooltip("Time (seconds) until the main round starts")] public float readyStageIntermission;

        [Header("Main-Stage Settings")]
        [Tooltip("Total amount of litter to start spawning over a duration of time")] public int litterToSpawnForWave;
        [Tooltip("Time it takes for 'LitterToSpawnForWave' amount of litter to finish spawning (Seconds)")] public float timeToSpawnAllLitter;
    }
}