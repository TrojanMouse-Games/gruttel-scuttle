using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace TrojanMouse.GameplayLoop{ 
    public class Intermission : GLNode{
        public float duration;
        public Intermission(float duration){
            this.duration = duration;
        }

        public override NodeState Evaluate(){
            if(duration <= 0){
                return NodeState.SUCCESS;
            }
            duration -= Time.deltaTime;
            return NodeState.FAILURE;
        }
    }
}