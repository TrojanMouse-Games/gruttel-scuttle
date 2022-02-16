using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrojanMouse.RegionManagement;

namespace TrojanMouse.GameplayLoop{   
    public class SpawnLitter : GLNode{
        int remainingLitterToSpawn;
        public SpawnLitter(int remainingLitterToSpawn){
            this.remainingLitterToSpawn = remainingLitterToSpawn;
        }
        public override NodeState Evaluate(){
            if(remainingLitterToSpawn <= 0){
                return NodeState.SUCCESS;    
            }


            if(GameLoopBT.instance.CanSpawn()){
                Region[] regions = Region_Handler.current.GetRegions(Region.RegionType.LITTER_REGION);
                Region region = regions[UnityEngine.Random.Range(0, regions.Length)];
                remainingLitterToSpawn -= (region.litterManager.SpawnLitter(region.GetComponent<Collider>(), 1) < 0) ? 1 : 0;
            }
            return NodeState.FAILURE; 
        }
    }
}