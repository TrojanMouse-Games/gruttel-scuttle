#region USING CALLS
using System;
using System.Collections;
using JoshsScripts.CharacterStats;
using JoshsScripts.PowerUp;
using TrojanMouse.AI.Movement;
using TrojanMouse.AI.Behaviours;
using UnityEngine;
using UnityEngine.AI;
#endregion

namespace TrojanMouse.AI
{
    #region CONTROLLER CLASS
    public class AIController : MonoBehaviour
    {
        #region VARIABLES
        [Header("AI State & Type")]
        public AIState.AIType aiType; // The type of AI. Friendly, Nuetral or Hostile.
        public AIState.currState currentState; // The current state of the AI. Wandering, Fleeing etc.
        private AIState.currState previousState; // The state that was last set, used for returning when litter is found.

        [Header("Public Vars")]
        public GameObject followPoint = null; // Gameobject that the AI can follow. Usually the transform of the target that needs to be followed.
        public float wanderRadius = 15f; // How far the AI should wander.
        public float litterDetectionRadius = 50f; // Range in which AI will find litter.
        public float wanderTimer; // The time between wander movements.
        public NavMeshAgent agent; // NavMeshAgent reference.
        public LayerMask whatIsLitter; // What the AI will go and process as litter.

        // Internal Variables
        [SerializeField]
        private Transform currentTarget; // The current AI target.
        private NavMeshHit hit; // Used for determining where the AI moves to.
        private float timer = 0f; // Internal timer used for state changes and tracking.
        private bool blocked = false; // Internal true/false for checking whether the current AI path is blocked.
        private bool moduleSpawnCheck = false; // Check to see whether a module has been spawned or not, to avoid duplicate spawning. Might not be needed.
        private bool ignoreFSMTarget = false; // Ignores the currentTarget value for when the AI moves.
        private bool currentlyProcessing = true; // Check to see whether the AI is currently processing anything or not.

        [Header("Scripts")] // All internal & private for the most part.
        [SerializeField]
        private CharacterStats characterStats; // Reference to the Character stats script.
        // Movement Modules, in order of most used.
        private WanderModule wanderScript; // Reference to the Wander Module.
        private Patrol patrolScript; // Reference to the Patrol module.
        private MoveWithMouseGrab moveToMouse; // Reference to the Move to Mouse Point module.
        // Behaviour Modules
        private Friendly friendly; // Refernce to the friendly behaviour.
        private Neutral neutral; // Refernce to the neutral behaviour.
        private Hostile hostile; // Refernce to the hostile behaviour.
        #endregion

        #region BASE FUNCTIONS
        /// <summary>
        /// Start is called before the first frame update
        /// </summary>
        void Start()
        {
            // Run the initialization function, hover over the name for more information.
            Initialization();
        }

        /// <summary>
        /// Runs every frame. FSM is ran in here.
        /// </summary>
        private void Update()
        {
            // Start the timer
            timer += Time.deltaTime;

            // Detect and process the litter
            CheckForLitter();

            #region FSM

            // Main AI logic. Incorporates AI FSM(Finite State Machine) flow.
            /* State Explanations:
                    - Nothing: AI does nothing, will be static and not process anything. Currently will switch out of this state
                                after 10 seconds.
                    - Wandering: AI will wander around the navmesh.
                    - Moving: AI will move to set point on the navmesh. Can also be called externally.
                    - Processing: AI is processing a task, like collecting litter for example.
                    - Patrolling: AI drop gameobject patrol points and move between them. Self cleaning script.
                    - Following: AI will follow a point, object and stop within a distance of it.
                    - Attacking: AI Will attack its target, if it can.
                    - Defending: AI will attempt to stop enemy from causing damage to structures
                    - Healing: AI will heal, either in place or on the move.
                    - Fleeing: AI will flee from all targets and enemies. Basically it moves away.
                    - Dead: AI has been killed, or destroyed. This triggers script cleanup.
            */
            switch (currentState)
            {
                case AIState.currState.Nothing:
                    if (timer > 10)
                    {
                        currentState = (AIState.currState)UnityEngine.Random.Range(0, 8);
                    }
                    // Make sure this is false so more modules can be spawned.
                    moduleSpawnCheck = false;
                    break;
                case AIState.currState.Wandering:
                    // Spawn the Wander module.
                    if (!moduleSpawnCheck && wanderScript == null)
                    {
                        moduleSpawnCheck = true;
                        wanderScript = gameObject.AddComponent<WanderModule>();
                        wanderScript.Wander(timer, wanderTimer, wanderRadius, blocked, hit, agent);
                        Debug.Log("Adding the wander movement module to " + this.name);
                    }

                    if (wanderScript == null)
                    {
                        //First we reset the timer, and then set the state back to nothing.
                        timer = 0;
                        currentState = AIState.currState.Nothing;
                    }

                    //I also need to add some logic for detecting enemies or other AI.
                    break;
                case AIState.currState.Moving:
                    if (ignoreFSMTarget)
                        Debug.LogWarning("Moving state was called whilst ignore bool was true, assuming it was called externally...");
                    else
                        GotoPoint(currentTarget, ignoreFSMTarget);
                    break;
                case AIState.currState.Processing:
                    Debug.Log($"Currently processing litter on {agent.name}");
                    CheckForLitter();
                    break;
                case AIState.currState.Patrolling:
                    if (!moduleSpawnCheck && patrolScript != null)
                    {
                        moduleSpawnCheck = true;
                        patrolScript = gameObject.AddComponent<Patrol>();
                        Debug.Log("Adding the patrol movement module to " + this.name);
                    }

                    if (patrolScript == null)
                    {
                        //First we reset the timer, and then set the state back to nothing.
                        timer = 0;
                        currentState = AIState.currState.Nothing;
                    }
                    break;
                case AIState.currState.Following:
                    agent.autoBraking = true;
                    if (followPoint != null)
                        agent.SetDestination(followPoint.transform.position);
                    else
                        currentState = AIState.currState.Wandering;
                    break;
                case AIState.currState.Attacking:
                    //Goto enemy
                    if (currentTarget != null)
                        agent.SetDestination(currentTarget.position);
                    //Deal damage

                    break;
                case AIState.currState.Defending:

                    break;
                case AIState.currState.Healing:

                    break;
                case AIState.currState.Fleeing:
                    Flee();
                    break;
                case AIState.currState.Dead:
                    Rigidbody rb = gameObject.AddComponent(typeof(Rigidbody)) as Rigidbody;

                    // Clean up the script sequentially, delete anything that could throw errors.
                    Cleanup(1);
                    // Add a force to make the NPC fall over

                    Cleanup(2);
                    Cleanup(3);
                    Cleanup(4);
                    break;

                default:
                    // Fall back state
                    currentState = AIState.currState.Wandering;
                    break;
            }
            #endregion
        }
        #endregion

        #region STATE FUNCTIONS

        /// <summary>
        /// This function handles the fleeing of the AI. Forcing the AI to run away from its target/agressor. Reuses some variables.
        /// <para>Ignores the check for litter, as it doesn't make sense for them to care about litter when fleeing.</para>
        /// </summary>
        private void Flee()
        {
            //CheckForLitter(); 

            // Probably a better way to do this, but this is relatively simple.
            float distance = Vector3.Distance(gameObject.transform.position, currentTarget.transform.position);
            // Get the direction, then invert it
            Vector3 dir = -(currentTarget.position - transform.position);

            if (distance <= wanderRadius)
            {
                // Increase speed
                agent.speed *= 1.5f;
                // Run away from target
                agent.SetDestination(transform.position + dir.normalized);
            }
            else
                agent.speed = 3.5f;
        }

        /// <summary>
        /// Simple function for moving to a point in the world. Can be called externally.
        /// <para>Will also set the state of the FSM if not already set. See param descriptions for more info.</para>
        /// </summary>
        /// <param name="position">The postion that the AI will move to</param>
        /// <param name="ignoreFSMTarget">This determines whether the AI will goto the "currentTarget" or an externally passed in one.
        /// true = ignore, false = go to already set target</param>
        public void GotoPoint(Transform position, bool ignoreFSMTarget)
        {

            CheckForLitter();

            // Function is accessed by other classes, so first we make sure to set the state to
            // "Moving" as not to confuse the script.
            currentState = AIState.currState.Moving;

            if (ignoreFSMTarget)
                // Move to the position passed in
                agent.SetDestination(position.transform.position);
            else
                // Move to the current target.
                agent.SetDestination(currentTarget.transform.position);
        }

        #endregion

        #region OTHER FUNCTIONS
        /// <summary>
        /// <para>This function sets up the variables and grabs all the correct reference to scripts.</para>
        /// It also adds the correct behaviour module to the controller.
        /// </summary>
        public void Initialization()
        {
            agent = gameObject.GetComponent<NavMeshAgent>();
            agent.enabled = true;
            timer = wanderTimer;

            try
            {
                characterStats = GetComponent<CharacterStats>();
            }
            catch (NullReferenceException e)
            {
                Debug.LogError($"Error: {e.Message}. Character stats not set.");
            }

            // This assigns the player follow point;
            //followPoint = GameObject.FindGameObjectWithTag("PlayerFollowPoint");

            // Simple check to make sure the agent is on a navmesh, if not destroy it
            if (agent.isOnNavMesh == false)
            {
                Destroy(this.gameObject);
            }

            // Add the correct type of AI to the script. Allows for added behaviour
            switch (aiType)
            {
                case AIState.AIType.Neutral:
                    neutral = gameObject.AddComponent<Neutral>();
                    break;
                case AIState.AIType.Friendly:
                    friendly = gameObject.AddComponent<Friendly>();
                    break;
                case AIState.AIType.Hostile:
                    hostile = gameObject.AddComponent<Hostile>();
                    break;
            }
        }

        /// <summary>
        /// Small function to clean up the script and associated components to avoid errors.
        /// </summary>
        /// <param name="thingsToClean">This number specifies what needs to be cleaned. 
        /// 1) AI type scripts 2) Components (e.g navmesh agent) 3) Any other modules 4) This script itself</param>
        public void Cleanup(int thingsToClean)
        {
            switch (thingsToClean)
            {
                // Clean up AI Type scripts
                case 1:
                    // Small function to cleanup the script upon a deletion call
                    if (friendly != null)
                    {
                        Destroy(friendly);
                    }
                    if (neutral != null)
                    {
                        Destroy(neutral);
                    }
                    if (hostile != null)
                    {
                        Destroy(hostile);
                    }
                    break;

                // Cleanup the Components
                case 2:
                    if (agent != null)
                    {
                        Destroy(agent);
                    }
                    break;

                // Clean up other modules
                case 3:
                    // Movement module check
                    if (patrolScript != null)
                    {
                        Destroy(patrolScript);
                    }
                    break;

                // Clean up self script
                case 4:
                    Destroy(this);
                    break;
            }
        }

        //  TODO: PASS IN PREV STATE
        /// <summary>
        /// This function checks for litter and then starts processing it if any is found.
        /// </summary>
        /// <returns>If litter is found, it will call the process function, if not it will just return</returns>
        public Collider[] CheckForLitter()
        {
#if UNITY_EDITOR
            Debug.Log($"{transform.name} is currently checking for litter. (1)");
#endif

            // Create a new litter array each time the function is called.
            Collider[] litterArray = Physics.OverlapSphere(transform.position, litterDetectionRadius, whatIsLitter);
            if (litterArray.Length > 0)
            {
                currentlyProcessing = true;
                return ProcessLitter(currentlyProcessing, litterArray);
            }
            else
            {
                currentlyProcessing = false;
                currentState = AIState.currState.Wandering;
            }
            return litterArray;
        }

        /// <summary>
        /// This is how the litter processing works. Works in tandem with Josh's Pickup/Powerup system.
        /// Uses a Overlap sphere to get colliders and adds them to an array.
        /// </summary>
        private Collider[] ProcessLitter(bool isProcessing, Collider[] litterArray)
        {
            if (currentlyProcessing)
            {
#if UNITY_EDITOR
                Debug.Log($"{transform.name} is currently processing litter. (2)");
#endif
                // Small error check to make sure the AI has things to process.
                if (litterArray.Length <= 0)
                {
                    // Tell the AI that it's done processing litter.
                    currentlyProcessing = false;
                    // Set the state back to wandering.
                    currentState = AIState.currState.Wandering;
                    // Exit the loop.
                    return litterArray;
                }
                else
                {
                    // Tell the AI that it still has litter to process
                    currentlyProcessing = true;
                }
                // Small error reporting
                PickUpHandler pickUpHandler = litterArray[0].GetComponent<PickUpHandler>();
                if (!pickUpHandler)
                {
                    Debug.LogError($"No Pickup Handler found on this {litterArray[0].transform.name}, please add one to avoid this error! Continuing..");
                    // if an error is found, return and continue.
                    return litterArray;
                }

                Debug.Log($"Transform = {transform}, stats = {characterStats.Specialties[0]}");
                // Call Joshs pickup function.
                pickUpHandler.PickUp(transform, characterStats.Specialties[0]);

                // If litter is found, set AI State
                currentState = AIState.currState.Processing;
                // Move to litter
                agent.SetDestination(litterArray[0].transform.position);
            }
            return litterArray;
        }

        private void OnDrawGizmosSelected()
        {
            Gizmos.color = Color.magenta;
            Gizmos.DrawWireSphere(transform.position, litterDetectionRadius);
        }
        #endregion

    }

    #endregion

    #region AI STATE CLASS
    public static class AIState
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
        public enum currState
        {
            Nothing,
            Wandering,
            Moving,
            Processing,
            Following,
            Patrolling,
            Attacking,
            Defending,
            Healing,
            Fleeing,
            Dead
        }
    }
    #endregion
}