using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace TrojanMouse.GameplayLoop {
    [CreateAssetMenu(fileName = "CycleInfo", menuName = "ScriptableObjects/GameplayLoop/CycleController", order = 1)]
    public class CycleController : ScriptableObject {
        public UnityEvent cycleController;
        public void AddNanaBetsys(int quantityToAdd) {
            CycleManager.nanaBetsyCount += quantityToAdd;
        }
    }
}