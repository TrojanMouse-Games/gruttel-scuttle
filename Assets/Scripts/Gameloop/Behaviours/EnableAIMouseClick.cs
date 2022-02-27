using UnityEngine;
using TrojanMouse.AI.Movement; 

namespace TrojanMouse.GameplayLoop{ 
    public class EnableAIMouseClick : GLNode{
         
        bool isEnabled;
        bool hasApplied = false;
        public EnableAIMouseClick(bool isEnabled){
            this.isEnabled = isEnabled;
        }
        public override NodeState Evaluate(){
            if(hasApplied){
                return NodeState.SUCCESS;
            }            
            Camera.main.GetComponent<MoveWithMouseClick>().enabled = isEnabled;
            hasApplied = true;
            return NodeState.SUCCESS;
        }        
    }
}