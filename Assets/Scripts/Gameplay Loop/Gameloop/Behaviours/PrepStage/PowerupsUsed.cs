using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrojanMouse.Gruttel;

namespace TrojanMouse.GameplayLoop
{
    public class PowerupsUsed : GLNode
    {
        Transform storage;

        public PowerupsUsed(Transform storage)
        { // CONSTRUCTOR TO PREDEFINE THIS CLASS VARIABLES
            this.storage = storage.parent;
        }
        public override NodeState Evaluate()
        {
            if (storage.GetComponentsInChildren<Powerup>().Length > 0)
            { // CHECKS TO SEE IF THERE ARE STILL POWERUPS IN THE FOLDER
                return NodeState.FAILURE;
            }
            return NodeState.SUCCESS;
        }
    }
}