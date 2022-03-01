using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

namespace TrojanMouse.Menu
{
    /// <summary>
    /// Controls the main menu. Need to reincorporate async loading.
    /// </summary>
    public class MainMenu : MonoBehaviour
    {
        string sceneToPlay;

        [Header("UI Elements")]
        public GameObject playButton; // The play button itself
        public GameObject levelPanel; // The level selection panel
        public Slider loadingBar; // Used for displaying loading progress

        // to be used later.
        AsyncOperation asyncLoad;

        #region  LEVEL_LOADING
        public void SelectLevel(string levelToSelect)
        {
            sceneToPlay = levelToSelect;
            FixUI();
        }

        /// <summary>
        /// Loads a level, can either load an external passed in level OR whatevers selected in the Select level function.
        /// </summary>
        /// <param name="level">The level to load.</param>
        public void LoadLevel(string alternateLevel)
        {
            if (alternateLevel == "")
            {
                //SceneManager.LoadScene(sceneToPlay);
                StartCoroutine(LoadSceneAsync(sceneToPlay));
            }
            else
            {
                //SceneManager.LoadScene(alternateLevel);
                StartCoroutine(LoadSceneAsync(alternateLevel));
            }
        }

        /// <summary>
        ///The Application loads the Scene in the background as the current Scene runs.
        ///This is particularly good for creating loading screens. Which is the thing
        /// we're using it for.
        /// </summary>
        /// <returns></returns>
        IEnumerator LoadSceneAsync(string thingToLoad)
        {
            // Start loading the scene
            asyncLoad = SceneManager.LoadSceneAsync(thingToLoad);

            //asyncLoad.allowSceneActivation = false;

            // Wait until the asynchronus scene fully loads
            while (!asyncLoad.isDone)
            {
                // Don't allow the scene to change untill it's loaded
                // Show the loading progress
                DisplayLoadProgress();
                
                if (asyncLoad.isDone)
                {
                    // If loading is done, load the scene.
                    StartCoroutine(Loaded());
                }
                yield return null;
            }

        }
        #endregion

        #region OTHER_FUNCTIONS
        /// <summary>
        /// Fixes the UI to be correct, disables the level panel and enables the play button
        /// </summary>
        public void FixUI()
        {
            levelPanel.SetActive(false);
            playButton.SetActive(true);
        }

        /// <summary>
        /// Opens a URL in the default browser.
        /// </summary>
        /// <param name="url">The url to open</param>
        public void OpenLink(string url)
        {
            Application.OpenURL(url);
        }

        /// <summary>
        /// Quits the game.
        /// </summary>
        public void QuitGame()
        {
            Application.Quit();
        }

        /// <summary>
        /// Updates the loading bars value based on the percentage of the loaded scene
        /// </summary>
        public void DisplayLoadProgress()
        {
            // Update the slider value
            loadingBar.value = asyncLoad.progress;
        }

        IEnumerator Loaded()
        {
            yield return new WaitForSeconds(1);
            asyncLoad.allowSceneActivation = true;
        }
        #endregion
    }

}