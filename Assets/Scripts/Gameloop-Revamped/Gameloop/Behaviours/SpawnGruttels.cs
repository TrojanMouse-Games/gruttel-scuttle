using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.GameplayLoop{   
    public class SpawnGruttels : GLNode{
        public SpawnGruttels(){
            // PASS CAMERA IN     
        }
        public override NodeState Evaluate(){            
            // CHECK TO SEE IF GRUTTELS ALREADY HAVE SPAWNED... IF NOT...        
            // SPAWN GRUTTELS AT SPAWN POINTS    
            // TELL CAMERA TO GO TO X LOCATION

            return NodeState.SUCCESS;
        }
    }
}