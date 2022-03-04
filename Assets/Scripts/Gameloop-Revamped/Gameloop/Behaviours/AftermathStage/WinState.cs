using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

namespace TrojanMouse.GameplayLoop{ 
    public class WinState : GLNode{
        bool hasApplied = false;
        public WinState(){ // CONSTRUCTOR TO PREDEFINE THIS CLASS VARIABLES
            
        }
        public override NodeState Evaluate(){
            if(hasApplied){ // MAKES SURE THIS IS ONLY RAN ONCE BY CREATING THIS SAFETY BLANKET
                return NodeState.SUCCESS;
            }   
            SceneManager.LoadScene("WinScreen");
            hasApplied = true;
            return NodeState.SUCCESS;
        }        
    }
}