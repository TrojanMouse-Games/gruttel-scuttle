using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace TrojanMouse.StressSystem{
    public class StressUI : MonoBehaviour{
        [SerializeField] Image fillbar;    
        [SerializeField] float smoothingSpeed;
        float velocity;

        private void Awake() {            
            fillbar = (!fillbar)? GetComponent<Image>(): fillbar;
        }
        
        void Update(){
            fillbar.fillAmount = Mathf.SmoothDamp(fillbar.fillAmount, Stress.current.average/100, ref velocity, smoothingSpeed);
        }
    }
}