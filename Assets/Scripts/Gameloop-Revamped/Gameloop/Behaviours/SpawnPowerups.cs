using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.GameplayLoop{   
    public class SpawnPowerups : GLNode{
        public override NodeState Evaluate(){
            return NodeState.RUNNING;
        }
    }
}