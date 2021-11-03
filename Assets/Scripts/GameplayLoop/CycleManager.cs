using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.GameplayLoop {
    public class CycleManager : MonoBehaviour {
        public List<CycleController> cycles;

        public int currentCycle = 0;

        public static int nanaBetsyCount = 0;

        // Start is called before the first frame update
        void Start() { }

        // Update is called once per frame
        void Update() { }

        public void StartNewCycle() {
            cycles[currentCycle].cycleController.Invoke();
            currentCycle++;
            if (currentCycle >= cycles.Count) {
                currentCycle = 0;
            }
        }

        /// <summary>
        /// GET THE NEXT LEVEL AND START THE PLAYFIELD WITH IT
        /// </summary>
        public void StartLevel() {
            
        }
    }
}