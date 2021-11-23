using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace TrojanMouse.Generic {
    public class ScenePreloading : MonoBehaviour {
        // the overall async operation for loading the scene
        public static AsyncOperation asyncLoad;

        /// <summary>
        /// Preloads the selected scene.
        /// </summary>
        /// <param name="scene">The scene to preload.</param>
        public static IEnumerator PreloadScene(Scene scene) {
            asyncLoad = SceneManager.LoadSceneAsync(scene.buildIndex);

            asyncLoad.allowSceneActivation = false;

            while (!asyncLoad.isDone) {
                yield return null;
            }
        }
        /// <summary>
        /// Switch to the scene that has been preloaded.
        /// </summary>
        public static void ActivateScene() {
            asyncLoad.allowSceneActivation = true;
        }
    }
}