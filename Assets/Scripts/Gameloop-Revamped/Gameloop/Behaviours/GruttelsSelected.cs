using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.GameplayLoop{   
    public class GruttelsSelected : GLNode{
        public override NodeState Evaluate(){
            // IF NOT X AMT OF GRUTTELS ARE NOT SELECTED RETURN FAILURE OTHERWISE RETURN SUCCESS!

            return NodeState.FAILURE;
        }
    }
}