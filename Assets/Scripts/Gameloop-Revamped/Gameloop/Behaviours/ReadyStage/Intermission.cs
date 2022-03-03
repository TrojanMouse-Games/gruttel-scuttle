using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using FMODUnity;

namespace TrojanMouse.GameplayLoop{ 
    public class Intermission : GLNode{
        public float maxDuration, remainingDuration;
        public Image imageUI;
        public StudioGlobalParameterTrigger
        public Intermission(float duration, Image imageUI = null){
            this.maxDuration = duration;
            this.remainingDuration = duration;
            
            this.imageUI = imageUI;

           
        }

        public override NodeState Evaluate(){
            if(imageUI){
                imageUI.fillAmount = (remainingDuration / maxDuration);
            }
            if(remainingDuration <= 0){
                return NodeState.SUCCESS;
            }
            remainingDuration -= Time.deltaTime;
            return NodeState.FAILURE;
        }
    }
}