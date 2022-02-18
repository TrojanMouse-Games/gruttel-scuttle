using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace TrojanMouse.GameplayLoop{ 
    public class EnableAI : GLNode{
        AIState aiState;
        public EnableAI(AIState state){
            this.aiState = state;
        }
        public override NodeState Evaluate(){
            
            return NodeState.SUCCESS;
        }

        public enum AIState{
            Disabled,
            Enabled,
            Dragable
        }
    }
}