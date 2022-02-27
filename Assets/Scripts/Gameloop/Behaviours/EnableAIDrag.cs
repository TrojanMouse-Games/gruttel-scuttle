using UnityEngine;
using TrojanMouse.AI.Movement; 

namespace TrojanMouse.GameplayLoop{ 
    public class EnableAIDrag : GLNode{
         
        bool isEnabled;
        bool hasApplied = false;
        public EnableAIDrag(bool isEnabled){
            this.isEnabled = isEnabled;
        }
        public override NodeState Evaluate(){
            if(hasApplied){
                return NodeState.SUCCESS;
            }            
            Camera.main.GetComponent<MoveWithMouseGrab>().enabled = isEnabled;
            hasApplied = true;
            return NodeState.SUCCESS;
        }        
    }
}