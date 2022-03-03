using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace TrojanMouse.StressSystem
{
    public class StressUI : MonoBehaviour
    {
        [SerializeField] Image fillbar;
        [SerializeField] float smoothingSpeed;
        [SerializeField] Animator animator;
        float velocity;

        private void Awake()
        {
            fillbar = (!fillbar) ? GetComponent<Image>() : fillbar;
        }

        void Update(){
            fillbar.fillAmount = Mathf.SmoothDamp(fillbar.fillAmount, (float)Stress.current.amountOfLitter / (float)Stress.current.maxLitter, ref velocity, smoothingSpeed);  
            animator.SetBool("Wobble", (Stress.current.isCountingDown)? true: false);         
            Debug.Log(Stress.current.isCountingDown);   
        }
    }
}