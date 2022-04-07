#region USING CALLS
using UnityEngine;
using UnityEngine.AI;
using TrojanMouse.Inventory;
using TrojanMouse.Litter.Region;
using TrojanMouse.Gruttel;
#endregion

namespace TrojanMouse.AI
{
    public class AIController : MonoBehaviour
    {
        #region VARIABLES
        [Header("AI State & Type")]
        public AIState currentState; // The current state of the AI. Wandering, Fleeing etc.
        public int avoidancePriority = 15; // The level of avoidance priority for the agent. lower = more important. Might be worth setting this based on the type of gruttel
        private AIState previousState; // The state that was last set, used for returning when litter is found.

        [Space]
        [Header("Public Variables")]
        public AIData data;
        public Transform currentTarget; // The current AI target.
        public Collider[] globalLitterArray;
        public Color? baseColor;
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

        [Space]
        [Header("Scripts")] // All internal & private for the most part.
        // Module manager ref
        public ModuleManager moduleManager; // The script that manages all the modules on the AI.
        // Other scripts
        [HideInInspector]public Equipper equipper; // reference to the equipper script
        private GruttelReference gruttelReference;
        private Inventory.Inventory inventory; // reference to the inventory script
        #endregion

        #region BUILT-IN
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
            // update anim float, might wanna move this to an AnimationUpdate func.
            animator.SetBool("isMoving", ((transform.position - lastPosition).magnitude > 0) ? true : false);
            // Start the Timer function
            CheckDistraction();
            Timer();
            HFSM();
        }
        #endregion

        #region STATE FUNCTIONS
        private void HFSM()
        {
            // Main AI logic. Incorporates AI FSM(Finite State Machine) flow.
            /* State Explanations:
                    - Nothing: AI does nothing, will be static and not process anything. Currently will switch out of this state
                                after 10 seconds.
                    - Moving: Doesn't do anything inherently.
                    - AttemptLitterPickup: Will get the AI to attempt to pick up a piece of litter
                    - MovingToMachine: Will attempt to move to a recylcer and then drop any held litter.
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
                            // Stop the AI
                            data.agent.SetDestination(gameObject.transform.position);
                        }
                        data.inventory = inventory;
                        currentState = moduleManager.litterModule.GetLitter(data);
                        inventory = data.inventory;
                        break;
                    case AIState.Moving:
                        if (ignoreFSMTarget)
                            Debug.LogWarning("Moving state was called whilst ignore bool was true, assuming it was called externally...");
                        else
                            if (currentTarget != null)
                            GotoPoint(currentTarget.transform.position, ignoreFSMTarget);
                        else                            
                            currentState = AIState.Nothing;
                            AttemptLitterDrop();
                        break;
                    case AIState.Processing:
                        break;
                    case AIState.MovingToLitter:
                        AttemptLitterPickup();
                        break;
                    case AIState.MovingToMachine:
                        AttemptLitterDrop();
                        break;
                    default:
                        // Fall back state
                        currentState = AIState.Nothing;
                        break;
                }
            }
            else
            {

                GetComponentInChildren<SkinnedMeshRenderer>()?.materials[0].SetColor("_Color", Color.red);
                GetComponentInChildren<MeshRenderer>()?.materials[0].SetColor("_Color", Color.red);
            }
        }

        void AttemptLitterPickup()
        {
            LitterObjectHolder target = moduleManager.litterModule.target;
            LitterObjectHolder holdingLitter = moduleManager.litterModule.target;
            bool litterInRange = Vector3.Distance(target.transform.position, transform.position) < data.detectionRadius;

            if (litterInRange){
                target.isPickedUp = true;
                GetComponent<Equipper>().PickUp(target);
                holdingLitter = target;
                currentState = AIState.MovingToMachine;                
            }
        }

        void AttemptLitterDrop()
        {            
            closestHomeRegion = RegionHandler.current.GetClosestRegion(RegionType.HOME, transform.position, data.detectionRadius);    
            if (!closestHomeRegion) {                 
                return; 
            }
            data.agent.SetDestination(closestHomeRegion.transform.position);
            currentState = AIState.MovingToMachine;
            bool machineInRange = Vector3.Distance(closestHomeRegion.transform.position, transform.position) < data.pickupRadius;

            if (machineInRange)
            {
                equipper.Drop(RegionType.HOME);
                //add to that region's litter meter
                closestHomeRegion.GetComponentInParent<MachineFill>().IncreaseFill();
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
            baseColor = GetComponentInChildren<SkinnedMeshRenderer>()?.materials[0].GetColor("_BaseColor");
            if(baseColor == null)
            {
                baseColor = GetComponentInChildren<MeshRenderer>()?.materials[0].GetColor("_BaseColor");
            }
            equipper = GetComponent<Equipper>();
            inventory = GetComponent<Inventory.Inventory>();
            gruttelReference = GetComponent<GruttelReference>();
            // Thing for setting up char stats, powerups etc

            // Simple check to make sure the agent is on a navmesh, if not destroy it
            if (data.agent.isOnNavMesh == false)
            {
                Destroy(this.gameObject);
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
            baseColor = GetComponentInChildren<SkinnedMeshRenderer>()?.materials[0].GetColor("_BaseColor");
            if (baseColor == null)
            {
                baseColor = GetComponentInChildren<MeshRenderer>()?.materials[0].GetColor("_BaseColor");
            }
        }

        /// <summary>
        /// Small function to clean up the script and associated components to avoid errors.
        /// </summary>
        /// <param name="thingsToClean">This number specifies what needs to be cleaned. 
        /// 1) Components (e.g navmesh agent) 2) Any other modules 3) This script itself</param>
        public void Cleanup(int thingsToClean)
        {
            switch (thingsToClean)
            {

                // Cleanup the Components
                case 1:
                    if (data.agent != null)
                    {
                        Destroy(data.agent);
                    }
                    break;

                // Clean up other modules
                case 2:
                    // Movement module check
                    moduleManager.ChangeAllModuleStates(1, false);
                    moduleManager.ChangeAllModuleStates(2, false);
                    break;

                // Clean up self script
                case 3:
                    Destroy(this);
                    break;
            }
            #endregion
        }
    }
}
