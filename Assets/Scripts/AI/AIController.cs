#region USING CALLS
using System;
using System.Collections;
using System.Collections.Generic;
using TrojanMouse.Inventory;
using TrojanMouse.RegionManagement;
using TrojanMouse.PowerUps;
using TrojanMouse.AI.Behaviours;
using TrojanMouse.AI.Movement;
using UnityEngine;
using UnityEngine.AI;
#endregion

namespace TrojanMouse.AI
{
    public class AIController : MonoBehaviour
    {
        #region VARIABLES
        [Header("AI State & Type")]
        public AIType aiType; // The type of AI. Friendly, Nuetral or Hostile.
        public AIState currentState; // The current state of the AI. Wandering, Fleeing etc.
        private AIState previousState; // The state that was last set, used for returning when litter is found.

        [Header("Public Variables")]
        public AIData data;
        public Transform currentTarget; // The current AI target.
        public Collider[] globalLitterArray;
        public Color baseColor;
        //bools for distraction
        public bool beingDirected;
        public bool distracted;
        public LayerMask litterLayerMask;
        public float timer = 0f; // Internal timer used for state changes and tracking.

        // Internal Variables
        private NavMeshHit hit; // Used for determining where the AI moves to.
        private bool blocked = false; // Internal true/false for checking whether the current AI path is blocked.
        private bool ignoreFSMTarget = false; // Ignores the currentTarget value for when the AI moves.
        private bool currentlyProcessing = true; // Check to see whether the AI is currently processing anything or not.

        [Header("Scripts")] // All internal & private for the most part.
        // Movement Modules, in order of most used.
        private ModuleManager moduleManager; // The script that manages all the modules on the AI.
        // private WanderModule wanderScript; // Reference to the Wander Module.
        // private Patrol patrolScript; // Reference to the Patrol module.
        private MoveWithMouseGrab moveToMouse; // Reference to the Move to Mouse Point module.
        // Behaviour Modules
        private Friendly friendly; // Refernce to the friendly behaviour.
        private Neutral neutral; // Refernce to the neutral behaviour.
        private Hostile hostile; // Refernce to the hostile behaviour.
        private Equipper equipper; // reference to the equipper script
        private Powerup powerUp; // reference to the equipper script
        private Inventory.Inventory inventory; // reference to the equipper script
        #endregion

        private void Start()
        {
            // Run the controller initialization process
            Initialization();
        }

        private void Update()
        {
            // Start the Timer function
            Timer();
            HFSM();
        }

        #region STATE FUNCTIONS
        /// <summary>
        /// 
        /// </summary>
        private void HFSM()
        {
            // Main AI logic. Incorporates AI FSM(Finite State Machine) flow.
            /* State Explanations:
                    - Nothing: AI does nothing, will be static and not process anything. Currently will switch out of this state
                                after 10 seconds.
                    - Wandering: AI will wander around the navmesh.
                    - Moving: AI will move to set point on the navmesh. Can also be called externally.
                    - Processing: AI is processing a task, like collecting litter for example.
                    - Patrolling: AI will drop gameobject patrol points and move between them. Self cleaning script.
                    - (UNUSED)Following: AI will follow a point, object and stop within a distance of it.
                    - (UNUSED)Attacking: AI Will attack its target, if it can.
                    - (UNUSED)Defending: AI will attempt to stop enemy from causing damage to structures
                    - (UNUSED)Healing: AI will heal, either in place or on the move.
                    - Fleeing: AI will flee from all targets and enemies. Basically it moves away.
                    - Dead: AI has been killed, or destroyed. This triggers script cleanup.
            */
            // If we're telling the AI to move, update the line renderer
            if (beingDirected)
            {
                DisplayLineRenderer();
            }
            else if (!distracted)
            {
                // Detect and process the litter
                GetLitter();

                switch (currentState)
                {
                    case AIState.Nothing:
                        if (timer > 10)
                        {
                            //currentState = (AIState)UnityEngine.Random.Range(0, 8);
                            // Default to the wandering state.
                            currentState = AIState.Wandering;
                        }
                        // Make sure this is false so more modules can be spawned.
                        break;
                    case AIState.Wandering:
                        // Enable the wandering module.
                        if (moduleManager.wander != null)
                        {
                            moduleManager.wander.enabled = true;
                            moduleManager.wander.Wander(data, blocked, hit);
                            //Debug.Log($"Enabled wandering on {this.gameObject.name}");
                        }

                        //I also need to add some logic for detecting enemies or other AI.
                        break;
                    case AIState.Moving:
                        if (ignoreFSMTarget)
                            Debug.LogWarning("Moving state was called whilst ignore bool was true, assuming it was called externally...");
                        else
                            if (currentTarget != null)
                                GotoPoint(currentTarget.transform.position, ignoreFSMTarget);
                            else
                                currentState = AIState.Nothing;
                        break;
                    case AIState.Processing:
                        //Debug.Log($"Currently processing litter on {agent.name}");
                        //GetLitter();
                        break;
                    case AIState.Patrolling:
                        if (moduleManager.patrol != null)
                        {
                            moduleManager.patrol.enabled = true;
                            Debug.Log($"Enabled patrolling on {this.gameObject.name}");
                        }

                        if (moduleManager.patrol.enabled == false)
                        {
                            //First we reset the timer, and then set the state back to nothing.
                            timer = 0;
                            currentState = AIState.Nothing;
                        }
                        break;
                    case AIState.Fleeing:
                        if (moduleManager.fleeModule != null)
                        {
                            moduleManager.fleeModule.enabled = true;
                            moduleManager.fleeModule.Flee(data, currentTarget.gameObject);
                        }
                        break;
                    case AIState.Dead:
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
                        currentState = AIState.Wandering;
                        break;
                }
            }
            else
            {
                GetComponent<MeshRenderer>().materials[0].SetColor("_Color", Color.red);
            }
        }

        /// <summary>
        /// Simple function for moving to a point in the world. Can be called externally.
        /// <para>Will also set the state of the FSM if not already set. See param descriptions for more info.</para>
        /// </summary>
        /// <param name="position">The postion that the AI will move to</param>
        /// <param name="ignoreFSMTarget">This determines whether the AI will goto the "currentTarget" or an externally passed in one.
        /// true = ignore, false = go to already set target</param>
        public void GotoPoint(Vector3 position, bool ignoreFSMTarget)
        {
            Debug.LogWarning("Forcing AI to move to requested point!");

            // Function is accessed by other classes, so first we make sure to set the state to
            // "Moving" as not to confuse the script.
            currentState = AIState.Moving;

            if (ignoreFSMTarget)
                // Move to the position passed in
                data.Agent.SetDestination(position);
            else
                // Move to the current target.
                data.Agent.SetDestination(currentTarget.transform.position);
        }

        //  TODO: PASS IN PREV STATE
        /// <summary>
        /// This function checks for litter and then starts processing it if any is found.
        /// </summary>
        /// <returns>If litter is found, it will call the process function, if not it will just return</returns>
        public Region GetLitter()
        {
            Region closestRegion = Region_Handler.current.GetClosestRegion(Region.RegionType.LITTER_REGION, transform);
            if (closestRegion.transform.childCount <= 0)
            {
                return closestRegion;
            }

            moduleManager.DisableAllModules();

            if (!inventory.HasSlotsLeft())
            {
                Region closesHomeRegion = Region_Handler.current.GetClosestRegion(Region.RegionType.HOME, transform);
                if (data.Agent.remainingDistance <= data.Agent.stoppingDistance)
                {
                    equipper.Drop(Region.RegionType.HOME);
                    currentTarget = gameObject.transform;
                    data.Agent.SetDestination(closesHomeRegion.transform.position);
                }
            }
            else
            {
                LitterObject litterType = null;
                foreach (Transform obj in closestRegion.transform)
                {
                    Debug.Log(closestRegion.transform);
                    LitterObject type = closestRegion.transform.GetChild(0).GetComponent<LitterObjectHolder>().type;
                    bool cantPickup = powerUp.Type != type.type && type.type != PowerupType.NORMAL;
                    if (!cantPickup)
                    {
                        litterType = type;
                        break;
                    }
                }

                if (litterType)
                { // BREAKS OUT THE CODE IF THE TYPE IS NOT NORMAL AND IS NOT OF X TYPE
                    equipper.PickUp(closestRegion.transform.GetChild(0), powerUp.Type, litterType);
                    data.Agent.SetDestination(closestRegion.transform.GetChild(0).position);
                }
            }

            return closestRegion;
        }

        /// <summary>
        /// This is how the litter processing works. Works in tandem with Josh's Pickup/Powerup system.
        /// Uses a Overlap sphere to get colliders and adds them to an array.
        /// </summary>
        private Collider[] ProcessLitter(bool isProcessing, Collider[] litterArray)
        {
            throw new NotImplementedException();

            // if (currentlyProcessing)
            // {
            //     // Small error check to make sure the AI has things to process.
            //     if (litterArray.Length <= 0)
            //     {
            //         // Tell the AI that it's done processing litter.
            //         currentlyProcessing = false;
            //         // Set the state back to wandering.
            //         currentState = AIState.Wandering;
            //         // Exit the loop.
            //         return litterArray;
            //     }
            //     else
            //     {
            //         // Tell the AI that it still has litter to process
            //         currentlyProcessing = true;
            //     }

            //     // LITTER ITERATION
            //     Vector3 targetPos = transform.position;

            //     foreach (Collider litter in litterArray)
            //     { // ITERATES THROUGH ALL LITTER UNTIL IT CAN FIND LITTER WHICH CAN BE PICKED UP
            //         // Small error reporting
            //         PickUpHandler pickUpHandler = litter.GetComponent<PickUpHandler>();
            //         if (!pickUpHandler)
            //         {
            //             Debug.LogError($"No Pickup Handler found on this {litterArray[0].transform.name}, please add one to avoid this error! Continuing..");
            //             // if an error is found, return and continue.
            //             return litterArray;
            //         }
            //         if (pickUpHandler.PickUp(transform, characterStats.Specialties[0]) == PickUpHandler.ErrType.TooFar)
            //         { // Call Joshs pickup function. -- WE WANT THIS ERROR TO OCCUR SO THAT AI WILL MOVE
            //             targetPos = litter.transform.position;
            //             int distractionChance = UnityEngine.Random.Range(0, 2500);
            //             if (distractionChance == 0)
            //             {
            //                 distracted = true;
            //             }
            //             break;
            //         }
            //     }

            //     // If litter is found, set AI State
            //     currentState = AIState.Processing;
            //     // Validation to make sure AI is back on navmesh before setting destination, if it fails warn us.
            //     if (agent.isOnNavMesh)
            //     {
            //         // Move to litter
            //         agent.SetDestination(targetPos);
            //     }
            //     else
            //     {
            //         Debug.LogWarning($"{agent.transform.name}'s target isn't valid!!");
            //     }
            // }
            // return litterArray;
        }
        #endregion

        #region OTHER FUNCTIONS 
        private void Initialization()
        {
            data = new AIData(
                agent: gameObject.GetComponent<NavMeshAgent>(),
                litterLayer: litterLayerMask,
                wanderCooldown: 0
            );

            moduleManager = gameObject.GetComponent<ModuleManager>();
            moduleManager.CheckScripts();

            data.Agent = gameObject.GetComponent<NavMeshAgent>();
            data.Agent.enabled = true;
            timer = data.WanderCooldown;
            baseColor = GetComponent<MeshRenderer>().materials[0].GetColor("_Color");
            equipper = GetComponent<Equipper>();
            powerUp = GetComponent<Powerup>();
            inventory = GetComponent<Inventory.Inventory>();
            // Thing for setting up char stats, powerups etc

            // UNUSED AS OF NOW.
            // This assigns the player follow point;
            //followPoint = GameObject.FindGameObjectWithTag("PlayerFollowPoint");

            // Simple check to make sure the agent is on a navmesh, if not destroy it
            if (data.Agent.isOnNavMesh == false)
            {
                Destroy(this.gameObject);
            }

            // Add the correct type of AI to the script. Allows for added behaviour
            switch (aiType)
            {
                case AIType.Neutral:
                    neutral = gameObject.AddComponent<Neutral>();
                    break;
                case AIType.Friendly:
                    friendly = gameObject.AddComponent<Friendly>();
                    break;
                case AIType.Hostile:
                    hostile = gameObject.AddComponent<Hostile>();
                    break;
            }
        }

        public void Timer()
        {
            // Start the timer
            timer += Time.deltaTime;
        }

        private void OnDrawGizmosSelected()
        {
            if (data == null)
            {
                return;
            }
            Gizmos.color = Color.magenta;
            Gizmos.DrawWireSphere(transform.position, data.DetectionRadius);
        }

        void DisplayLineRenderer()
        {
            LineRenderer lr = GetComponent<LineRenderer>();

            float distance = Vector3.Distance(transform.position, data.Agent.destination);

            if (distance == 0)
            {
                beingDirected = false;
                lr.enabled = false;
            }
            else
            {
                lr.enabled = true;

                lr.SetPosition(0, transform.position);
                lr.SetPosition(1, data.Agent.destination);
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
                    if (data.Agent != null)
                    {
                        Destroy(data.Agent);
                    }
                    break;

                // Clean up other modules
                case 3:
                    // Movement module check
                    moduleManager.wander.enabled = false;
                    moduleManager.patrol.StopPatrol();
                    break;

                // Clean up self script
                case 4:
                    Destroy(this);
                    break;
            }
            #endregion
        }
    }
}
