using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrojanMouse.RegionManagement;
using TrojanMouse.BallisticTrajectory;

namespace TrojanMouse.GameplayLoop{   
    public class LitterHandler : GLNode{
        Level level;
        
        GLSequence spawnManager = new GLSequence(new List<GLNode>{}, true);
        public LitterHandler(Level level){         
            foreach(Waves wave in level.wavesInLevel){
                List<Ballistics> shootersInWave = new List<Ballistics>();
                List<Region> regionsInWave = new List<Region>();
                #region POPULATE LISTS
                foreach(string shooterObj in wave.shootersInThisWave){
                    GameObject shooterGObj = GameObject.Find(shooterObj);
                    if(shooterGObj){
                        shootersInWave.Add(shooterGObj.GetComponent<Ballistics>());
                    }
                }
                foreach(string regionObj in wave.regionsToLandAtInThisWave){
                    GameObject regionGObj = GameObject.Find(regionObj);
                    if(regionGObj){
                        regionsInWave.Add(regionGObj.GetComponent<Region>());
                    }
                }
                #endregion

                spawnManager.realTimeNodes.Add(
                    new SpawnLitter(shootersInWave.ToArray(), regionsInWave.ToArray(), wave.litterToSpawnForWave, wave.timeToSpawnAllLitter)
                );
                spawnManager.realTimeNodes.Add(new Intermission(wave.intermissionBeforeNextWave));
            }
        }
        public override NodeState Evaluate(){
            switch(spawnManager.Evaluate()){
                case NodeState.SUCCESS:
                    return NodeState.SUCCESS;
                case NodeState.FAILURE:
                    return NodeState.FAILURE;
                case NodeState.RUNNING:
                    return NodeState.RUNNING;
            }
            return NodeState.FAILURE; 
        }
    }
}