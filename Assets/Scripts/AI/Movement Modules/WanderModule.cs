using System.Collections;
using UnityEngine;
using UnityEngine.AI;

namespace TrojanMouse.AI.Movement {
    /// <summary>
    /// This is the wander class, it holds all the functions neccesary to get the wander working with the AI. 
    /// With it's main class being Wander()
    /// </summary>
    [RequireComponent(typeof(AIController))]
    public class WanderModule : MonoBehaviour {
        float m_wanderTimer;
        bool cleanup = false;
        float timer;
        public float maxWanderDuration;
        [SerializeField]
        private float timeLeftTillScriptCleanup;
        AIController aIController;

        private void Update() {
            // Might be a good idea to just access the AIControllers timer to avoid sync issues.
            // Start the timer
            timer += Time.deltaTime;

            timeLeftTillScriptCleanup = maxWanderDuration - Time.time;

            if (!cleanup)
                StartCoroutine(WaitForDelete(maxWanderDuration));
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
        public void Wander(float wanderTimer, float wanderRadius, bool blocked, NavMeshHit hit, NavMeshAgent agent) {
            wanderTimer = m_wanderTimer;
            if (timer >= wanderTimer) {
                if (!blocked) {
                    RaycastHit vision;

                    Vector3 newPos = RandomWanderPoint(transform.position, wanderRadius, -1);
                    blocked = UnityEngine.AI.NavMesh.Raycast(transform.position, newPos, out hit, UnityEngine.AI.NavMesh.AllAreas);
                    Physics.Raycast(gameObject.transform.position, gameObject.transform.forward, out vision, 5f);
                    Debug.DrawLine(transform.position, newPos, blocked ? Color.red : Color.green);
                    agent.SetDestination(newPos);
                    StartCoroutine(Cooldown(1));

                    timer = 0;

                    if (Physics.Raycast(transform.position, transform.forward, out vision, 50f)) {
                        if (vision.transform.gameObject.tag == "NPC") {
                            newPos = gameObject.transform.position;
                            //Debug.Log("Moving to an NPC" + "(" + vision.transform.name + ")");
                            agent.SetDestination(newPos);
                        }
                    }
                } else {
                    Vector3 newPos = RandomWanderPoint(transform.position, wanderRadius, -1);
                    timer = 0;
                    blocked = false;
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
        private static Vector3 RandomWanderPoint(Vector3 origin, float dist, int layermask) {
            Vector3 randDirection = UnityEngine.Random.insideUnitSphere * dist;
            randDirection += origin;
            NavMeshHit navHit;
            NavMesh.SamplePosition(randDirection, out navHit, dist, layermask);
            return navHit.position;
        }

        IEnumerator Cooldown(float coolDown) {
            yield return new WaitForSeconds(coolDown);
            m_wanderTimer = UnityEngine.Random.Range(2, 10);
        }

        /// <summary>
        /// This coroutine manages the delay that the script will wait before cleaning itself up.
        /// </summary>
        /// <param name="time">How long before the script gets cleaned up</param>
        /// <returns>waits for the alloted time before continuing</returns>
        IEnumerator WaitForDelete(float time) {
            yield return new WaitForSeconds(time);
            cleanup = true;
            DestroyScript();
        }

        /// <summary>
        /// Destroys script, is public so it can be called elsewhere if needed.
        /// </summary>
        public void DestroyScript() {
            Destroy(this);
        }

    }
}