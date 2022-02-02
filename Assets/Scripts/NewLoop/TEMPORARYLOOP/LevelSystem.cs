using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

namespace CassyScripts.Level_System{
    [CreateAssetMenu(fileName = "New Level",menuName = "ScriptableObjects/Level/Create Level")]
    public class LevelSystem : ScriptableObject{
        [Serializable] public class Stage{
            public string stageName = "StageNameHere";
            public float timeBetweenStages = 10f;

            [Header("PowerUp Settings")]            
            [Tooltip("These MUST be picked up in order for next stage to complete")] public GameObject[] powerUpsToPickUp;


            [Header("Litter Settings")]
            [Tooltip("This is the amount of litter spawning as soon as this stage starts")] public int litterOnStart = 60;
            [Tooltip("This is the litter that must be picked up to complete the wave")] public int litterForWave = 60;
            [Tooltip("Time it'll take to spawn all the litter (Lower this if you would like it to be more stressful for the player :) )")] public float durationOfWave = 120f;
            
        }
        public Stage[] stages;
    }
}
