using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

namespace TrojanMouse.GameplayLoop{ 
    public class WinState : GLNode{
        bool hasApplied = false;
        GameObject village;
        public WinState(GameObject village){ // CONSTRUCTOR TO PREDEFINE THIS CLASS VARIABLES
            this.village = village;
        }
        public override NodeState Evaluate(){
            if(hasApplied){ // MAKES SURE THIS IS ONLY RAN ONCE BY CREATING THIS SAFETY BLANKET
                return NodeState.SUCCESS;
            }
            //calls the star rating calculation on victory
            village.GetComponent<CurrenciesAndValues>().StarRating();
            SceneManager.LoadScene("WinScreen");
            hasApplied = true;
            return NodeState.SUCCESS;
        }        
    }
}