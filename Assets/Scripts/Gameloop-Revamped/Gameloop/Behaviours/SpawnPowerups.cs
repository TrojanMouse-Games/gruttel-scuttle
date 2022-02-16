using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.GameplayLoop{   
    public class SpawnPowerups : GLNode{
        GameObject powerupObj;
        int quantity;
        Transform storage;

        bool hasSpawned;
        public SpawnPowerups(GameObject powerupObj, int quantity, Transform powerupStorage){
            this.powerupObj = powerupObj;
            this.quantity = quantity;
            this.storage = powerupStorage;
        }

        public override NodeState Evaluate(){
            if(hasSpawned){
                return NodeState.SUCCESS;
            }

            for(int i = 0; i < quantity; i++){
                GameObject powerup = GameLoopBT.SpawnObj(powerupObj, Vector3.zero, Quaternion.identity, storage);
            }
            hasSpawned = true;
            return NodeState.SUCCESS;
        }
    }
}