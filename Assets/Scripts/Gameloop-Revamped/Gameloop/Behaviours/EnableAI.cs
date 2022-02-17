using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace TrojanMouse.GameplayLoop{ 
    public class EnableAI : GLNode{
        bool isEnabled;
        public EnableAI(bool isEnabled){
            this.isEnabled = isEnabled;
        }
        public override NodeState Evaluate(){
            
            return NodeState.SUCCESS;
        }
    }
}