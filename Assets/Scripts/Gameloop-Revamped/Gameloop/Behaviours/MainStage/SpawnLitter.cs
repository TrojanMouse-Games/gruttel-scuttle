using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrojanMouse.RegionManagement;
using TrojanMouse.BallisticTrajectory;

namespace TrojanMouse.GameplayLoop{   
    public class SpawnLitter : GLNode{
        Ballistics[] shooterObjs;
        Region[] regionObjs;
        int litterToSpawn;        
        float spawnDelayHolder, spawnDelay;

        public SpawnLitter(Ballistics[] shooterObjs, Region[] regionObjs, int litterToSpawn, float waveDuration){            
            this.shooterObjs = shooterObjs;
            this.regionObjs = regionObjs;
            this.litterToSpawn = litterToSpawn;
            this.spawnDelayHolder = waveDuration / litterToSpawn;
        }
        
        bool CanSpawn(){
            spawnDelay -= (spawnDelay >0)? Time.deltaTime : 0;
            if(spawnDelay <=0){
                spawnDelay = spawnDelayHolder;
                return true;
            }
            return false;
        } 
        
        
        public override NodeState Evaluate(){
            if(litterToSpawn <= 0){
                return NodeState.SUCCESS;    
            }

            
            if(CanSpawn()){
                Region region = regionObjs[Random.Range(0, regionObjs.Length)];
                Ballistics shooter = shooterObjs[Random.Range(0, shooterObjs.Length)];                
                litterToSpawn -= (region.litterManager.SpawnLitter(region.GetComponent<Collider>(), shooter, 1) < 0) ? 1 : 0;
            }
            return NodeState.FAILURE; 
        }
    }
}