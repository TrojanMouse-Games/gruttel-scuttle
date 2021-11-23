using System.Collections;
using UnityEngine;
using UnityEngine.AI;

namespace TrojanMouse.AI.Movement
{
    /// <summary>
    /// This is the wander class, it holds all the functions neccesary to get the wander working with the AI. 
    /// With it's main class being Wander()
    /// </summary>
    [RequireComponent(typeof(AIController))]
    public class WanderModule : MonoBehaviour
    {
        float wanderCooldown;
        bool cleanup = false;
        float timer;
        public float maxWanderDuration = 30f;
        [SerializeField]
        private float timeLeftTillScriptCleanup;
        AIController aiController;

        private Coroutine disableScript;

        // Variable used for the RandomNav Function
        Vector3 newPos;

        private void OnEnable()
        {
            timeLeftTillScriptCleanup = maxWanderDuration;
            aiController = gameObject.GetComponent<AIController>();
            aiController.currentState = AIState.Wandering;
            disableScript = StartCoroutine(WaitForDelete(maxWanderDuration));
        }

        /// <summary>
        /// Supposed to reset variables on disable, but just gave me more headaches as it seems to keep resetting things regardless
        /// of whether the script is enabled or not.
        /// </summary>
        private void OnDisable()
        {
            StopCoroutine(disableScript);
            StopCoroutine(Cooldown(.1f));
            timer = 0f;
            timeLeftTillScriptCleanup = maxWanderDuration;
            cleanup = false;
            Debug.Log("timer=0");
            aiController.timer = 0f;
            aiController.currentState = AIState.Wandering;
        }

        private void Update()
        {
            // Might be a good idea to just access the AIControllers timer to avoid sync issues.
            // Start the timer
            timer += Time.deltaTime;

            timeLeftTillScriptCleanup -= (timeLeftTillScriptCleanup > 0) ? Time.deltaTime : 0;
        }

        /// <summary>
        /// This function handles the wandering for the AI.
        /// Uses the Navmesh and picks a point on it to move to. If the point is blocked by something, go to a new point.
        /// This will eventually extend the vision function(or class) to move move out of the wandering state.
        /// </summary>
        /// <param name="timer">Timer, passed in from the controller.</param>
        /// <param name="wanderTimer">How long to wait before moving to a new point, passed in from controller.</param>
        /// <param name="wanderRadius">How far to wander, passed in from controller.</param>
        /// <param name="blocked">Checks to see if the current picked point is blocked, Passed in from controller.</param>
        /// <param name="hit">Used for storing the navmesh location variable, passed in from controller.</param>
        /// <param name="agent">The navmesh agent, passed in from controller.</param>
        public void Wander(AIData data, bool blocked, NavMeshHit hit)
        {
            data.WanderCooldown = wanderCooldown;
            if (timer >= wanderCooldown)
            {
                newPos = RandomWanderPoint(transform.position, data.WanderRadius, -1);
                blocked = UnityEngine.AI.NavMesh.Raycast(transform.position, newPos, out hit, UnityEngine.AI.NavMesh.AllAreas);
                Debug.DrawLine(transform.position, newPos, blocked ? Color.red : Color.green);
                if (!blocked)
                {
                    data.Agent.SetDestination(newPos);
                    StartCoroutine(Cooldown(1));
                    timer = 0;
                }
                else
                {
                    newPos = RandomWanderPoint(transform.position, data.WanderRadius, -1);
                    timer = 0;
                }
            }
        }

        /// <summary>
        /// This void is what allows the AI to wander about the world, it's a little bit rudimentary
        /// but it is for sure good enough for what I need right now. For reference, some of this is
        /// identical to what I used in a previous project *Gimme Gimme*, it worked well enough then, and it
        /// should do the same for now
        ///
        /// <para>The only new parts are the blocked path detection which will make sure the AI doesn't run to a
        /// point it can't get to, causing it to do some unwanted behaviour</para>
        /// </summary>
        /// <param name="origin">Where the point is chosen from(around)</param>
        /// <param name="dist">How far it should pick from around the origin</param>
        /// <param name="layermask">The layermask of things to hit</param>
        /// <returns>nav hit point, which is a point on the navmesh</returns>
        private static Vector3 RandomWanderPoint(Vector3 origin, float dist, int layermask)
        {
            Vector3 randDirection = UnityEngine.Random.insideUnitSphere * dist;
            randDirection += origin;
            NavMeshHit navHit;
            NavMesh.SamplePosition(randDirection, out navHit, dist, layermask);
            return navHit.position;
        }

        IEnumerator Cooldown(float coolDown)
        {
            yield return new WaitForSeconds(coolDown);
            wanderCooldown = UnityEngine.Random.Range(1f, 10f);
        }

        /// <summary>
        /// This coroutine manages the delay that the script will wait before cleaning itself up.
        /// </summary>
        /// <param name="time">How long before the script gets cleaned up</param>
        /// <returns>waits for the alloted time before continuing</returns>
        IEnumerator WaitForDelete(float time)
        {
            yield return new WaitForSeconds(time);
            DisableScript();
        }

        /// <summary>
        /// Disables script, is public so it can be called elsewhere if needed.
        /// </summary>
        public void DisableScript()
        {
            this.enabled = false;
        }
    }
}