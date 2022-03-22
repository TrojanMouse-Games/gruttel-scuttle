using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.AI
{
    /// <summary>
    /// The current state of the AI. This is used in the switch case.
    /// More can be added, so it is very expandable
    /// </summary>
    public enum AIState
    {
        Nothing,
        Moving,
        Processing,
        MovingToLitter,
        MovingToMachine
    }
}
