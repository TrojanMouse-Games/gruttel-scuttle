using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace TrojanMouse.GameplayLoop {
    using Generic;
    public class CycleManager : MonoBehaviour {
        public enum InputTypes {
            DragAndDrop,
            PointAndClick
        }
        public List<CycleController> cycles;

        public int currentCycle = 0;

        public static int readyMealCount = 0;

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
        public void StartLevel(LevelSettings level) {
            ScenePreloading.PreloadScene(level.levelScene);
        }
    }
}