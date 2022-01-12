using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

namespace TrojanMouse.Menu
{
    public class Buttons : MonoBehaviour
    {
        AsyncOperation async;

        public string playScene = "Area1_Rectangle";
        public GameObject playButton;
        public GameObject levelPanel;

        public void LoadLevel(string level)
        {
            playScene = level;
            LoadScene(0);
        }
        public void LevelSelectOne()
        {
            playScene = "Area1_Rectangle";
            LevelSelected();
        }
        public void LevelSelectTwo()
        {
            playScene = "Area2_Circle";
            LevelSelected();
        }
        public void LevelSelectThree()
        {
            playScene = "Area3_SemiCircle";
            LevelSelected();
        }

        public void LevelSelected()
        {
            levelPanel.SetActive(false);
            playButton.SetActive(true);
        }

        public void LoadScene(float wait)
        {
            StartCoroutine(DelayLoad(wait));
        }

        public void CloseGame()
        {
            Application.Quit();
        }

        public void OpenLink(string url)
        {
            Application.OpenURL(url);
        }

        IEnumerator LoadSceneAsyncProcess(string sceneName)
        {
            async = SceneManager.LoadSceneAsync(sceneName);
            async.allowSceneActivation = false;

            while (!async.isDone)
            {
                Debug.Log($"[scene]:{sceneName} [load progress]: {async.progress}");

                yield return null;
            }
        }

        void Update()
        {
            if (async == null)
            {
                StartCoroutine(LoadSceneAsyncProcess(playScene));
            }
        }

        IEnumerator DelayLoad(float wait)
        {
            yield return new WaitForSeconds(wait);
            async.allowSceneActivation = true;
        }
    }
}