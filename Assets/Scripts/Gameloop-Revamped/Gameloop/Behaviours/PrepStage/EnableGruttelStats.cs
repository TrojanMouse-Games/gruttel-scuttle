using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.GameplayLoop{   
    public class EnableGruttelStats : GLNode{
        
        ShowGruttelStats statScript;
        bool isEnabled;
        bool hasApplied;
        public EnableGruttelStats(ShowGruttelStats statScript, bool isEnabled) { // CONSTRUCTOR TO PREDEFINE THIS CLASS VARIABLES
            this.statScript = statScript;
            this.isEnabled = isEnabled;
        }
        public override NodeState Evaluate(){         
            // IF PASSED ALREADY THEN NO NEED TO RUN AGAIN
            if(hasApplied){
                return NodeState.SUCCESS;
            }
            
            
            if(!isEnabled){ // IF DISABLING THE STAT SCRIPT, THIS WILL MAKE SURE THE UI IS DISABLED PRIOR
                statScript.EnableUI(false);
            }
            statScript.enabled = isEnabled; // ENABLES/DISABLES THE SCRIPT
            hasApplied = true;
            return NodeState.SUCCESS;
        }
    }
}