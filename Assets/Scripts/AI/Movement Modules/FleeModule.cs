using UnityEngine;

namespace TrojanMouse.AI.Movement
{
    public class FleeModule : MonoBehaviour
    {
        private void Start() {
            
        }

        // TODO:- Make the transition back out of this state using a check to see if the AI has gotten far enough away from the target.
        // STRETCH:- Convert to use NavMeshHit to create a more dynamic, realistic looking flee. Maybe it will only try this more dynamic style once it's a set distance away.
        /// <summary>
        /// This function handles the fleeing of the AI. Forcing the AI to run away from its target/agressor. Reuses some variables.
        /// <para>Ignores the check for litter, as it doesn't make sense for them to care about litter when fleeing.</para>
        /// </summary>
        public void Flee(AIData data, GameObject currentTarget)
        {
            //CheckForLitter(); 

            // Probably a better way to do this, but this is relatively simple.
            float distance = Vector3.Distance(gameObject.transform.position, currentTarget.transform.position);
            // Get the direction, then invert it
            Vector3 dir = -(currentTarget.transform.position - transform.position);

            if (distance <= data.WanderRadius)
            {
                // Increase speed
                data.Agent.speed *= 1.5f;
                // Run away from target
                data.Agent.SetDestination(transform.position + dir.normalized);
            }
            else
                data.Agent.speed = 3.5f;
        }
    }
}
