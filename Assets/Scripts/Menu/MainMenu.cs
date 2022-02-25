using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;

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

        // to be used later.
        AsyncOperation async;

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
                SceneManager.LoadScene(sceneToPlay);
            }
            else
            {
                SceneManager.LoadScene(alternateLevel);
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
        #endregion
    }

}