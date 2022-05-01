using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrojanMouse.Litter.Region;
using TrojanMouse.BallisticTrajectory;

namespace TrojanMouse.GameplayLoop
{
    public class SpawnLitter : GLNode
    {
        Ballistics[] shooterObjs;
        LitterRegion[] regionObjs;
        int litterToSpawn;
        float spawnDelayHolder, spawnDelay;
        int currentWave, totalNumWaves;

        public SpawnLitter(Ballistics[] shooterObjs, LitterRegion[] regionObjs, int litterToSpawn, float waveDuration, int currentWave, int totalNumWaves)
        { // CONSTRUCTOR TO PREDEFINE THIS CLASS VARIABLES           
            this.shooterObjs = shooterObjs;
            this.regionObjs = regionObjs;
            this.litterToSpawn = litterToSpawn;
            this.spawnDelayHolder = waveDuration / litterToSpawn;
            this.currentWave = currentWave;
            this.totalNumWaves = totalNumWaves;
        }


        /// <returns>RETURNS IF IT IS POSSIBLE TO SPAWN LITTER</returns>
        bool CanSpawn()
        {
            spawnDelay -= (spawnDelay > 0) ? Time.deltaTime : 0;
            if (spawnDelay <= 0)
            {
                spawnDelay = spawnDelayHolder;
                return true;
            }
            return false;
        }


        public override NodeState Evaluate()
        {
            if (litterToSpawn <= 0)
            {
                return NodeState.SUCCESS;
            }
            if (CanSpawn())
            {
                Debug.Log($"Wave {currentWave} of {totalNumWaves}");
                LitterRegion region = regionObjs[Random.Range(0, regionObjs.Length)]; // SELECTS A RANDOM REGION TO SPAWN THE LITTER WITHIN
                Ballistics shooter = shooterObjs[Random.Range(0, shooterObjs.Length)]; // SELECTS A RANDOM SHOOTER TO SPAWN THE LITTER AT
                litterToSpawn -= (region.litterManager.SpawnLitter(region.GetComponent<Collider>(), shooter, 1) < 0) ? 1 : 0; // DEDUCTS LITTER TO SPAWN IF THE FUNCTION IN LITTER MANAGER RETURNS A VALUE LESS THAN 0
            }
            return NodeState.FAILURE;
        }
    }
}