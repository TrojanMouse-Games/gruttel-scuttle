using UnityEngine;
using UnityEngine.SceneManagement;

/// <summary>
/// Simple script for controlling the pause menu within the game. Uses multiple functions and employs some fancy turnery operator doo dah.
/// </summary>
public class PauseMenu : MonoBehaviour
{
    [SerializeField]
    private GameObject pauseMenu;
    [SerializeField]
    private GameObject[] subMenus;
    public bool paused;
    [SerializeField] CursorLockMode cursor;

    // Start is called before the first frame update
    void Start()
    {
        pauseMenu.SetActive(false);
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            // Make sure that the options menu isn't being shown
            foreach (GameObject go in subMenus)
            {
                go.SetActive(false);
            }
            Pause();
        }
    }

    /// <summary>
    /// Pauses the game by setting the timecale. Also controls the the cursor lockstate.
    /// </summary>
    public void Pause()
    {
        paused = !paused;
        //cursor = Cursor.lockState = (paused == true) ? CursorLockMode.Confined : CursorLockMode.Locked;
        pauseMenu.SetActive(paused);

        Time.timeScale = (paused == true) ? 0 : 1;
    }

    string GetActiveSceneName()
    {
        Scene scene = SceneManager.GetActiveScene();
        return scene.name;
    }
}