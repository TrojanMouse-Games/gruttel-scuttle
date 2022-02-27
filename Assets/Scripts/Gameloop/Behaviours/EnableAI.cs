using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace TrojanMouse.GameplayLoop{ 
    public class EnableAI : GLNode{
         
        AIState aiState;
        bool hasApplied = false;
        public EnableAI(AIState aiState){
            this.aiState = aiState;
        }
        public override NodeState Evaluate(){
            if(hasApplied){
                return NodeState.SUCCESS;
            }            
            GameLoopBT.instance.ChangeAIState(aiState);
            hasApplied = true;
            return NodeState.SUCCESS;
        }

        public enum AIState{
            Disabled,
            Enabled,
            Dragable
        }
    }
}