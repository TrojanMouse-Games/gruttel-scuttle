using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.GameplayLoop{   
    public class SpawnGruttels : GLNode{
        GameObject gruttelObj;
        Transform[] spawnPoints;
        Transform lookAtObject;
        Transform villageFolder;

        bool hasSpawned;
        public SpawnGruttels(GameObject gruttelObj, Transform[] spawnPoints, Transform lookAtObject, Transform villageFolder){ // CONSTRUCTOR TO PREDEFINE THIS CLASS VARIABLES
            this.gruttelObj = gruttelObj;
            this.spawnPoints = spawnPoints;
            this.lookAtObject = lookAtObject;
            this.villageFolder = villageFolder;
        }
        public override NodeState Evaluate(){         
            // IF PASSED ALREADY THEN NO NEED TO RUN AGAIN
            if(hasSpawned){
                return NodeState.SUCCESS;
            }
            
            // SPAWN GRUTTELS AT SPAWN POINTS    
            foreach(Transform spawn in spawnPoints){
               // Vector3 dir = (lookAtObject.position - spawn.position);                
                GameObject newGruttel = GameLoopBT.instance.SpawnObj(gruttelObj, spawn.position, spawn.rotation, villageFolder);
                newGruttel.transform.eulerAngles = new Vector3(0, newGruttel.transform.eulerAngles.y, 0);
            }     
            hasSpawned = true;
            return NodeState.SUCCESS;
        }
    }
}