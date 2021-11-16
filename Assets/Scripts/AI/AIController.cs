#region USING CALLS
using System;
using System.Collections;
using System.Collections.Generic;
//using JoshsScripts.CharacterStats;
//using JoshsScripts.PowerUp;
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
        public AIState.AIType aiType; // The type of AI. Friendly, Nuetral or Hostile.
        public AIState.currState currentState; // The current state of the AI. Wandering, Fleeing etc.
        private AIState.currState previousState; // The state that was last set, used for returning when litter is found.

        [Header("Public Variables")]
        public float wanderRadius = 15f; // How far the AI should wander.
        public float litterDetectionRadius = 50f; // Range in which AI will find litter.
        public float wanderTimer; // The time between wander movements.
        public NavMeshAgent agent; // NavMeshAgent reference.
        public LayerMask whatIsLitter; // What the AI will go and process as litter.
        public Collider[] globalLitterArray;
        public Color baseColor;
        //bools for distraction

        // Internal Variables
        [SerializeField]
        private Transform currentTarget; // The current AI target.
        private NavMeshHit hit; // Used for determining where the AI moves to.
        private float timer = 0f; // Internal timer used for state changes and tracking.
        private bool blocked = false; // Internal true/false for checking whether the current AI path is blocked.
        private bool moduleSpawnCheck = false; // Check to see whether a module has been spawned or not, to avoid duplicate spawning. Might not be needed.
        private bool ignoreFSMTarget = false; // Ignores the currentTarget value for when the AI moves.
        private bool currentlyProcessing = true; // Check to see whether the AI is currently processing anything or not.
        private bool doWander;

        [Header("Scripts")] // All internal & private for the most part.
        // Movement Modules, in order of most used.
        private WanderModule wanderScript; // Reference to the Wander Module.
        private Patrol patrolScript; // Reference to the Patrol module.
        private MoveWithMouseGrab moveToMouse; // Reference to the Move to Mouse Point module.
        // Behaviour Modules
        private Friendly friendly; // Refernce to the friendly behaviour.
        private Neutral neutral; // Refernce to the neutral behaviour.
        private Hostile hostile; // Refernce to the hostile behaviour.
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
                    - Patrolling: AI drop gameobject patrol points and move between them. Self cleaning script.
                    - (UNUSED)Following: AI will follow a point, object and stop within a distance of it.
                    - (UNUSED)Attacking: AI Will attack its target, if it can.
                    - (UNUSED)Defending: AI will attempt to stop enemy from causing damage to structures
                    - (UNUSED)Healing: AI will heal, either in place or on the move.
                    - Fleeing: AI will flee from all targets and enemies. Basically it moves away.
                    - Dead: AI has been killed, or destroyed. This triggers script cleanup.
            */
        }
        #endregion

        #region OTHER FUNCTIONS 
        private void Initialization()
        {
            agent = gameObject.GetComponent<NavMeshAgent>();
            agent.enabled = true;
            timer = wanderTimer;
            baseColor = GetComponent<MeshRenderer>().materials[0].GetColor("_BaseColor");

            // Thing for setting up char stats, powerups etc

            // UNUSED AS OF NOW.
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

        public void Timer()
        {
            // Start the timer
            timer += Time.deltaTime;
        }
        #endregion
    }

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
