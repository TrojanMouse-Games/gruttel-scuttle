using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI; 

namespace TrojanMouse.GameplayLoop{ 
    public class EnableAI : GLNode{
        GameLoopBT gameloop;
        AIState aiState;
        bool hasApplied = false;

        public EnableAI(GameLoopBT gameloop, AIState aiState){ // CONSTRUCTOR TO PREDEFINE THIS CLASS VARIABLES
            this.gameloop = gameloop;
            this.aiState = aiState;
        }
        public override NodeState Evaluate(){
            if(hasApplied){ // MAKES SURE THIS IS ONLY RAN ONCE BY CREATING THIS SAFETY BLANKET
                return NodeState.SUCCESS;
            }   
            gameloop.ChangeAIState(aiState); // INVOKES AN EVENT
            if(aiState == AIState.Enabled){
                Camera.main.GetComponent<TrojanMouse.AI.Movement.MoveWithMouseGrab>().ToggleAIComponents(true, "putDown");
            }
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