using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

// DEVELOPED BY JOSH THOMPSON
namespace TrojanMouse.RegionManagement{
    [CreateAssetMenu(fileName = "Litter Manager Settings", menuName = "ScriptableObjects/Region/Litter Manager Settings")]
    public class LitterManager : ScriptableObject{
        [Serializable] public class LitterTypes{
            [Header("% chance to spawn | lower the value, rarer it is")][Range(0,100)] public int chanceToSpawn;
            [Tooltip("This is the object that'll actually spawn")] public GameObject litterObject;            
        }
        public LitterTypes[] litter;


        [Header("This is the MAX amount of litter inside this region")] public int maxLitterInRegion = 25;        

        ///<summary>THIS FUNCTION SPAWNS LITTER INSIDE THE BOUNDARIES OF THIS REGION</summary>
        ///<param name="region">The region the litter will spawn within</param>
        ///<param name="litterToSpawn">The amount of litter that'll spawn after calling this function</param>
        ///<param name="maxLitter">If this value is smaller than the scriptable object maxLitterInRegion, this will take priority. If it is < 0 then it'll be ignored</param>
        ///<returns>The excess value. If it returns a negative value, then there is still room to spawn more litter otherwise it is full</returns>
        public int SpawnLitter(Collider region, int litterToSpawn, int maxLitter = -1){
            int numOfLitterInRegion = region.transform.childCount;
            maxLitter = (maxLitter < 0)? maxLitterInRegion : maxLitter;


            int iterationTo = Mathf.Clamp(numOfLitterInRegion + litterToSpawn, numOfLitterInRegion, Mathf.Min(maxLitter, maxLitterInRegion)); // THIS IS WHAT THE FOR LOOP WILL ITERATE UP TO. - IT ENSURES THE VALUE DOES NOT EXCEED THE MAX LITTER
            for(int i = numOfLitterInRegion; i < iterationTo; i++){
                #region SELECTING LITTER OBJECT
                float chance = (float) UnityEngine.Random.Range(0, 100);
                List<LitterTypes> possibleLitterToSpawn = new List<LitterTypes>();

                foreach(LitterTypes litterType in litter){ // THIS LOOP FIGURES OUT WHAT CAN SPAWN BASED ON THE RANDOM VALUE AND ADDS IT TO THE LIST
                    if(chance < litterType.chanceToSpawn) { possibleLitterToSpawn.Add(litterType);}
                }

                LitterTypes selectedLitter = possibleLitterToSpawn[UnityEngine.Random.Range(0,possibleLitterToSpawn.Count)];
                #endregion
                #region GET POSITION
                Vector3 minPos = region.transform.position - region.bounds.extents,
                        maxPos = region.transform.position + region.bounds.extents;

                Vector3 spawnPos = new Vector3(
                    UnityEngine.Random.Range(minPos.x, maxPos.x),
                    UnityEngine.Random.Range(minPos.y, maxPos.y),
                    UnityEngine.Random.Range(minPos.z, maxPos.z)
                );
                #endregion

                Instantiate(selectedLitter.litterObject, spawnPos, Quaternion.identity, region.transform);
            }            
            return region.transform.childCount - maxLitter; // RETURNS THE EXCESS (NEGATIVE VALUES MEANS THERE IS STILL ROOM TO SPAWN)
        }
    }
}