using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.AI
{
    /// <summary>
    /// The three behaviour extensions of the AI. Not yet implemented really.
    /// Will eventually change certain features like flee chance and speed etc.
    /// <para>Basically, these will later determine what chance the AI has to do something.</para>
    /// </summary>
    public enum AIType
    {
        Friendly,
        Hostile,
        Neutral
    }

    /// <summary>
    /// The current state of the AI. This is used in the switch case.
    /// More can be added, so it is very expandable
    /// </summary>
    public enum AIState
    {
        Nothing,
        Wandering,
        Moving,
        Processing,
        Patrolling,
        Fleeing,
        Dead,
        MovingToLitter,
        MovingToMachine
    }
}
