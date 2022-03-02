using UnityEngine;
using TrojanMouse.PowerUps;
using System;

namespace TrojanMouse.GameplayLoop{
    [CreateAssetMenu(fileName = "New Level", menuName = "ScriptableObjects/GameLoop/Create New Level")]
    public class Level : ScriptableObject{
        [Header("Prep-Stage Settings")]
        [Tooltip("Players will have to select x amount of Gruttels to then proceed onto next stage")] public int numOfGruttelsToSelect;
        
        public PowerupsToBeDispenced[] powerups;
        [Tooltip("Time (seconds) until the main round starts")] public float readyStageIntermission;

        [Header("Main-Stage Settings")]
        public Waves[] wavesInLevel;
        [Tooltip("Max litter until stress reaches 100% stress")] public int maxLitter;
        [Serializable] public class PowerupsToBeDispenced{
            public string name;
            [Tooltip("Powerups to be dispenced to player")] public PowerupType powerup;
            public Sprite image;
        }
    }
}