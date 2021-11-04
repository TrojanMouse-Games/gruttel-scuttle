using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace TrojanMouse.GameplayLoop {
    [CreateAssetMenu(fileName = "CycleInfo", menuName = "ScriptableObjects/GameplayLoop/CycleController", order = 1)]
    public class CycleController : ScriptableObject {

        // the event that takes place when this cycle starts
        public UnityEvent cycleController;

        /// <summary>
        /// Add Nana Betsy's to the player's inventory
        /// </summary>
        /// <param name="quantityToAdd">the number of Nana Betsy's to add</param>
        public void AddReadyMeal(int quantityToAdd) {
            CycleManager.readyMealCount += quantityToAdd;
        }

        /// <summary>
        /// Switch the type of input the player is using
        /// </summary>
        /// <param name="inputType">the type of input to enable</param>
        public void SwitchInput(CycleManager.InputTypes inputType) {

        }
    }
}