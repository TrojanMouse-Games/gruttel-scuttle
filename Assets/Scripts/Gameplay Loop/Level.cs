using UnityEngine;
using TrojanMouse.Gruttel;
using System;

namespace TrojanMouse.GameplayLoop
{
    [CreateAssetMenu(fileName = "New Level", menuName = "ScriptableObjects/GameLoop/Create New Level")]
    public class Level : ScriptableObject
    {
        [Header("Prep-Stage Settings")]
        [Tooltip("Players will have to select x amount of Gruttels to then proceed onto next stage")] public int numOfGruttelsToSelect;

        public PowerupsToBeDispenced[] powerups;
        [Tooltip("Time (seconds) until the main round starts")] public float readyStageIntermission;

        [Header("Main-Stage Settings")]
        [Tooltip("The percentage thresholds of stress that lower the star rating.")] 
        public Vector2 stressThresholds;
        
        public Waves[] wavesInLevel;
        [Serializable]
        public class PowerupsToBeDispenced
        {
            public string name;
            [Tooltip("Powerups to be dispenced to player")] public GruttelType powerupType;
            public Sprite image;
        }
    }
}