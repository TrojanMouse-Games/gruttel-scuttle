using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.GameplayLoop{   
    public class GameLoopBT : MonoBehaviour{
        GLNode topNode;

        GLNode CreateBehaviourTree(){
            #region NODES
            #region PREP NODES
            SpawnGruttels spawnGruttels = new SpawnGruttels();
            GruttelsSelected areGruttelsSelected = new GruttelsSelected();
            SpawnPowerups spawnPowerups = new SpawnPowerups();
            PowerupsUsed arePowerupsUsed = new PowerupsUsed();
            #endregion
            #endregion

            GLSequence prepStage = new GLSequence(new List<GLNode>{spawnGruttels, areGruttelsSelected, spawnPowerups, arePowerupsUsed});

            return new GLSequence(new List<GLNode>{prepStage});
        }







        private void Awake() {            
            topNode = CreateBehaviourTree();
        }

        void Update(){
            switch(topNode.Evaluate()){
                case NodeState.SUCCESS:
                    break;
                case NodeState.FAILURE:
                    break;
                case NodeState.RUNNING:
                    break;
            }
        }
    }
}