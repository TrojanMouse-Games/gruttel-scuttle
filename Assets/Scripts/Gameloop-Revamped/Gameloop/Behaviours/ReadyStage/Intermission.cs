using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

namespace TrojanMouse.GameplayLoop{ 
    public class Intermission : GLNode{
        public float maxDuration, remainingDuration;
        public Image imageUI;
        TextMeshProUGUI label;
        public Intermission(float duration, Image imageUI = null, TextMeshProUGUI label = null){
            this.maxDuration = duration;
            this.remainingDuration = duration;
            
            this.imageUI = imageUI;
            this.label = label;
        }

        public override NodeState Evaluate(){
            if(imageUI){
                imageUI.fillAmount = (remainingDuration / maxDuration);
            }
            if(label){
                label.text = Mathf.Ceil(remainingDuration).ToString();
            }

            if(remainingDuration <= 0){
                imageUI?.transform.parent.gameObject.SetActive(false);
                return NodeState.SUCCESS;
            }

            imageUI?.transform.parent.gameObject.SetActive(true);
            remainingDuration -= Time.deltaTime;
            return NodeState.FAILURE;
        }
    }
}