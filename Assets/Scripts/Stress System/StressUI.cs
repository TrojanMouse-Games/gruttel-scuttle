using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
namespace TrojanMouse.StressSystem
{
    public class StressUI : MonoBehaviour
    {
        [SerializeField] Image fillbar;
        [SerializeField] float smoothingSpeed;
        [SerializeField] Animator animator;
        float velocity;
        [SerializeField] string sceneToIgnore;

        private void Awake()
        {
            fillbar = (!fillbar) ? GetComponent<Image>() : fillbar;
        }

        void Update()
        {
            if (SceneManager.GetActiveScene().name == sceneToIgnore)
            {
                return;
            }
            fillbar.fillAmount = Mathf.SmoothDamp(fillbar.fillAmount, (float)Stress.current.amountOfLitter / (float)Stress.current.maxLitter, ref velocity, smoothingSpeed);
            animator.SetBool("Wobble", (Stress.current.isCountingDown) ? true : false);
        }
    }
}