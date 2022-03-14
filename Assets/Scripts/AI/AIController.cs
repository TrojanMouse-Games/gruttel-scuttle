#region USING CALLS
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using TrojanMouse.Inventory;
using TrojanMouse.Litter.Region;
using TrojanMouse.Gruttel;
using TrojanMouse.AI.Behaviours;
using TrojanMouse.GameplayLoop;
#endregion

namespace TrojanMouse.AI
{
    public class AIController : MonoBehaviour
    {
        #region VARIABLES
        [Header("AI State & Type")]
        public AIType aiType; // The type of AI. Friendly, Nuetral or Hostile.
        public AIState currentState; // The current state of the AI. Wandering, Fleeing etc.
        public int avoidancePriority = 15; // The level of avoidance priority for the agent. lower = more important. Might be worth setting this based on the type of gruttel
        private AIState previousState; // The state that was last set, used for returning when litter is found.

        [Header("Public Variables")]
        public AIData data;
        public Transform currentTarget; // The current AI target.
        public Collider[] globalLitterArray;
        public Color baseColor;
        //bools for distraction
        public bool beingDirected;
        public LayerMask litterLayerMask;
        public float timer = 0f; // Internal timer used for state changes and tracking.
        public Animator animator;
        public float currSpeed;

        // Internal Variables
        private NavMeshHit hit; // Used for determining where the AI moves to.
        private bool blocked = false; // Internal true/false for checking whether the current AI path is blocked.
        private bool ignoreFSMTarget = false; // Ignores the currentTarget value for when the AI moves.
        private bool currentlyProcessing = true; // Check to see whether the AI is currently processing anything or not.

        private LitterRegion closestHomeRegion;
        Vector3 lastPosition;

        [Header("Scripts")] // All internal & private for the most part.
        // Module manager ref
        public ModuleManager moduleManager; // The script that manages all the modules on the AI.
        // Behaviour Modules
        private Friendly friendly; // Refernce to the friendly behaviour.
        private Neutral neutral; // Refernce to the neutral behaviour.
        private Hostile hostile; // Refernce to the hostile behaviour.
        // Other scripts
        private Equipper equipper; // reference to the equipper script
        private GruttelReference gruttelReference;

        private Inventory.Inventory inventory; // reference to the inventory script
        #endregion

        private void Start()
        {
            // Run the controller initialization process
            Initialization();
        }

        private void LateUpdate()
        {
            lastPosition = transform.position;
        }

        private void Update()
        {
            // update anim float
            animator.SetBool("isMoving", ((transform.position - lastPosition).magnitude > 0) ? true : false);
            //print((transform.position - lastPosition).magnitude);
            // Start the Timer function
            CheckDistraction();
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
            else if (!data.distracted)
            {
                switch (currentState)
                {
                    case AIState.Nothing:
                        if (timer > 10)
                        {
                            //currentState = (AIState)UnityEngine.Random.Range(0, 8);
                            // Default to the wandering state.
                            currentState = AIState.Wandering;
                        }
                        data.inventory = inventory;
                        currentState = moduleManager.litterModule.GetLitter(data);
                        inventory = data.inventory;
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
                        //Debug.Log($"Currently processing litter on {data.Agent.name}");
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
                    case AIState.MovingToLitter:
                        AttemptLitterPickup();
                        break;
                    case AIState.MovingToMachine:
                        AttemptLitterDrop();
                        break;
                    default:
                        // Fall back state
                        currentState = AIState.Wandering;
                        break;
                }
            }
            else
            {
                GetComponentInChildren<SkinnedMeshRenderer>().materials[0].SetColor("_Color", Color.red);
            }
        }

        void AttemptLitterPickup()
        {
            LitterObjectHolder target = moduleManager.litterModule.target;
            LitterObjectHolder holdingLitter = moduleManager.litterModule.target;
            bool litterInRange = Vector3.Distance(target.transform.position, transform.position) < data.pickupRadius;

            if (litterInRange)
            {
                target.isPickedUp = true;
                GetComponent<Equipper>().PickUp(target);
                holdingLitter = target;
                currentState = AIState.MovingToMachine;

                closestHomeRegion = RegionHandler.current.GetClosestRegion(RegionType.HOME, transform.position);

                if (closestHomeRegion == null)
                {
                    currentState = AIState.Nothing;
                }

                data.agent.SetDestination(closestHomeRegion.transform.position);
            }
        }

        void AttemptLitterDrop()
        {
            data.agent.SetDestination(closestHomeRegion.transform.position);

            bool machineInRange = Vector3.Distance(closestHomeRegion.transform.position, transform.position) < data.pickupRadius;

            if (machineInRange)
            {
                equipper.Drop(RegionType.HOME);
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
                data.agent.SetDestination(position);
            else
                // Move to the current target.
                data.agent.SetDestination(currentTarget.transform.position);
        }
        #endregion

        #region OTHER FUNCTIONS 
        private void Initialization()
        {
            data = new AIData(
                gameObject.GetComponent<NavMeshAgent>(),
                litterLayerMask,
                0,
                GetComponent<GruttelReference>()
            );

            moduleManager = gameObject.GetComponent<ModuleManager>();
            moduleManager.CheckScripts();

            data.agent = gameObject.GetComponent<NavMeshAgent>();
            data.agent.enabled = true;
            data.agent.avoidancePriority = avoidancePriority;
            timer = data.wanderCooldown;
            baseColor = GetComponentInChildren<SkinnedMeshRenderer>().materials[0].GetColor("_BaseColor");
            equipper = GetComponent<Equipper>();
            inventory = GetComponent<Inventory.Inventory>();
            gruttelReference = GetComponent<GruttelReference>();
            // Thing for setting up char stats, powerups etc

            // Simple check to make sure the agent is on a navmesh, if not destroy it
            if (data.agent.isOnNavMesh == false)
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

            //StartCoroutine(moduleManager.GetComponent<DistractionModule>().GenerateDistractionChance());
        }

        private void CheckDistraction()
        {
            data.distracted = moduleManager.distractionModule.distracted;
        }

        public void Timer()
        {
            // Start the timer
            timer += Time.deltaTime;
        }

        private void OnDrawGizmosSelected()
        {
            // JOSHS STUFF
            Gizmos.color = Color.red;
            Gizmos.DrawWireSphere(transform.position, data.pickupRadius);
            // --
            if (data == null)
            {
                return;
            }
            Gizmos.color = Color.magenta;
            Gizmos.DrawWireSphere(transform.position, data.detectionRadius);
        }

        void DisplayLineRenderer()
        {
            LineRenderer lr = GetComponent<LineRenderer>();

            float distance = Vector3.Distance(transform.position, data.agent.destination);

            if (distance == 0)
            {
                beingDirected = false;
                lr.enabled = false;
            }
            else
            {
                lr.enabled = true;
                Vector3[] path = data.agent.path.corners;
                lr.positionCount = path.Length;
                for (int i = 0; i < path.Length; i++)
                {
                    lr.SetPosition(i, path[i] + new Vector3(0, .5f, 0));
                }
            }
        }

        public void UpdateColor()
        {
            baseColor = GetComponentInChildren<SkinnedMeshRenderer>().materials[0].GetColor("_BaseColor");
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
                    if (data.agent != null)
                    {
                        Destroy(data.agent);
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
