using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.GameplayLoop{   
    public class PowerupsUsed : GLNode{
        public override NodeState Evaluate(){
            return NodeState.RUNNING;
        }
    }
}