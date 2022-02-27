using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace TrojanMouse.GameplayLoop{ 
    public class ChangeUIText : GLNode{
        Text textUI;
        string text;
        public ChangeUIText(Text textUI, string text){
            this.textUI = textUI;
            this.text = text;
        }
        public override NodeState Evaluate(){
            textUI.text = text;
            return NodeState.SUCCESS;
        }
    }
}