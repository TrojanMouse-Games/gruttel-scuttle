using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace TrojanMouse.GameplayLoop{ 
    public class EnableAI : GLNode{
         
        AIState aiState;
        bool hasApplied = false;
        public EnableAI(AIState aiState){ // CONSTRUCTOR TO PREDEFINE THIS CLASS VARIABLES
            this.aiState = aiState;
        }
        public override NodeState Evaluate(){
            if(hasApplied){ // MAKES SURE THIS IS ONLY RAN ONCE BY CREATING THIS SAFETY BLANKET
                return NodeState.SUCCESS;
            }   
            GameLoopBT.instance.ChangeAIState(aiState); // INVOKES AN EVENT
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