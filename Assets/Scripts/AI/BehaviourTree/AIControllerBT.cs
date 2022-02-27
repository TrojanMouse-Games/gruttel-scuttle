using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrojanMouse.GameplayLoop;
using UnityEngine.AI;

namespace TrojanMouse.AI{
    public class AIControllerBT : MonoBehaviour{
        public AIData data;
        public LayerMask litterLayerMask;

        GLNode topNode;
        GLNode CreateBehaviourTree(){
            #region NODES            
            Wander wandering = new Wander(data, true, transform.position);
            #endregion
            return new GLSelector(new List<GLNode>{wandering});
        } 








        



        private void Awake() {
            data = new AIData(
                agent: gameObject.GetComponent<NavMeshAgent>(),
                litterLayer: litterLayerMask,
                wanderCooldown: 5
            );

            if(topNode == null){
                topNode = CreateBehaviourTree();
            }
        }
        
        private void Update() {
            switch(topNode.Evaluate()){
                case NodeState.SUCCESS:                                     
                    topNode = CreateBehaviourTree(); // CREATE BT FOR NEXT LEVEL
                    break;
                case NodeState.FAILURE:
                    break;
                case NodeState.RUNNING:
                    break;
            }
        }
    }
}