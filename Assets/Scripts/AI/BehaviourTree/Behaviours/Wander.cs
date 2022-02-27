using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrojanMouse.GameplayLoop;
using UnityEngine.AI;

namespace TrojanMouse.AI{
    public class Wander : GLNode{
        #region INITIALISATION VARIABLES
        AIData data;
        bool isWandering;
        Vector3 position;        
        #endregion

        public Wander(AIData data, bool isWandering, Vector3 position){
            this.data = data;
            this.isWandering = isWandering;
            this.position = position;     

            GameLoopBT.SetWanderState += SetWandering;       
        }


        public override NodeState Evaluate(){
            if(isWandering){
                Move(data);
            }
            return NodeState.RUNNING; // ALWAYS RETURN RUNNING, SO THAT THE TREE IS NEVER COMPLETE - WANDERING SHOULD BE LAST RESORT
        }

        

        #region HELPER FUNCTIONS
        Vector3 newPos;
        float timer;
        NavMeshHit hit;

        /// <summary>
        /// This function handles the wandering for the AI.
        /// Uses the Navmesh and picks a point on it to move to. If the point is blocked by something, go to a new point.
        /// This will eventually extend the vision function(or class) to move move out of the wandering state.
        /// </summary>
        /// <param name="data">data, profile made from the AIController.</param>        
        private void Move(AIData data){
            timer += Time.deltaTime;
            if(timer < data.WanderCooldown){
                return;
            }

            newPos = RandomWanderPoint(position, data.WanderRadius, -1);
            bool blocked = NavMesh.Raycast(position, newPos, out hit, NavMesh.AllAreas);
            Debug.DrawLine(position, newPos, blocked ? Color.red : Color.green);

            if(blocked){
                return;
            }
            data.Agent.SetDestination(newPos);
            timer = 0;
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
        private Vector3 RandomWanderPoint(Vector3 origin, float dist, int layermask){
            Vector3 randDirection = UnityEngine.Random.insideUnitSphere * dist;
            randDirection += origin;
            NavMeshHit navHit;
            NavMesh.SamplePosition(randDirection, out navHit, dist, layermask);
            return navHit.position;
        }
        
        
        void SetWandering(bool isWandering){            
            this.isWandering = isWandering; 
        }
        #endregion
    }
}