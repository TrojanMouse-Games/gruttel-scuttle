using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// MADE BY JOSHUA THOMPSON
namespace TrojanMouse.GameplayLoop{
[CreateAssetMenu(fileName = "Cycle", menuName = "ScriptableObjects/GameLoop/Create Cycle")]
    public class Cycle : ScriptableObject{
        public Stage[] stages;                 
    }
}