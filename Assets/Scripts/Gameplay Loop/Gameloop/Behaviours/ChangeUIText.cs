using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace TrojanMouse.GameplayLoop
{
    public class ChangeUIText : GLNode
    {
        Text textUI;
        string text;
        public ChangeUIText(Text textUI, string text)
        { // CONSTRUCTOR TO PREDEFINE THIS CLASS VARIABLES
            this.textUI = textUI;
            this.text = text;
        }
        public override NodeState Evaluate()
        {
            textUI.text = text; // SETS THE TEXT
            return NodeState.SUCCESS;
        }
    }
}