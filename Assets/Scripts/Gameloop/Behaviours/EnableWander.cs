using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace TrojanMouse.GameplayLoop{ 
    public class EnableWander : GLNode{
         
        bool isEnabled;
        bool hasApplied = false;
        public EnableWander(bool isEnabled){
            this.isEnabled = isEnabled;
        }
        public override NodeState Evaluate(){
            if(hasApplied){
                return NodeState.SUCCESS;
            }            
            GameLoopBT.instance.ChangeWanderState(isEnabled);
            hasApplied = true;
            return NodeState.SUCCESS;
        }        
    }
}