using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrojanMouse.RegionManagement;

namespace TrojanMouse.GameplayLoop{   
    public class IsLitterCleared : GLNode{

        // DISCLAIMER: THIS NEEDS TO BE UPDATED TO INSTEAD CHECK TO SEE IF LITTER HAS BEEN RECYCLED
        public override NodeState Evaluate(){
            Region[] regions = Region_Handler.current.GetRegions(Region.RegionType.LITTER_REGION);
            int childCount = 0;
            foreach(Region region in regions){
                childCount += region.transform.childCount;
            }
            
            if(childCount <=0/*INSTEAD JUST CHECK TO SEE IF IT ALL HAS BEEN RECYCLED!!!*/){                
                return NodeState.SUCCESS;
            }
            return NodeState.FAILURE;
        }
    }
}