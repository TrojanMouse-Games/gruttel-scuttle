using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.GameplayLoop{
    [CreateAssetMenu(fileName = "New Level", menuName = "ScriptableObjects/GameLoop/Create New Level")]
    public class Level : ScriptableObject{
        public int numOfgruttelsToSelect;
        public int numOfpowerupsToDispence;
    }
}