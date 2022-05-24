using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace TrojanMouse.GameplayLoop
{
    public class ChangeUIText : GLNode
    {
        string text;
        float? duration;
        UIText uitextscript;

        bool hasCalled;
        public ChangeUIText(UIText uitextscript, string text, float? duration = null)
        { // CONSTRUCTOR TO PREDEFINE THIS CLASS VARIABLES            
            this.text = text;
            this.duration = duration;
            this.uitextscript = uitextscript;
        }
        public override NodeState Evaluate()
        {
            if (hasCalled)
            {
                return NodeState.SUCCESS;
            }
            hasCalled = true;
            uitextscript.textQueue.Enqueue(new UIText.tooltips(text, duration));
            return NodeState.SUCCESS;
        }
    }
}