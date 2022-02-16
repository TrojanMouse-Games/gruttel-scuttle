using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrojanMouse.PowerUps;

namespace TrojanMouse.GameplayLoop{   
    public class PowerupsUsed : GLNode{
        Transform storage;

        public PowerupsUsed(Transform storage){
            this.storage = storage.parent;
        }
        public override NodeState Evaluate(){            
            if(storage.GetComponentsInChildren<Powerup>().Length >0){
                return NodeState.FAILURE;
            }
            return NodeState.SUCCESS;
        }
    }
}