using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// DEVELOPED BY JOSH THOMPSON
namespace TrojanMouse.RegionManagement{
    public class Region_TestSpawn : MonoBehaviour{
        [SerializeField] float spawnCooldown = .25f;
        [SerializeField] int spawnAmount = 1;
        float cooldown;

        Region[] litterRegions;


        bool hasBooted;
        private void Start(){
            StartCoroutine(SpawnLitter());          
        }

        void CheckBooted()
        {
            if (!hasBooted && Region_Handler.current.HasBooted)
            {
                hasBooted = true;
                litterRegions = Region_Handler.current.GetRegions(Region.RegionType.LITTER_REGION);
                return;
            }
            else if (!hasBooted) { return; }            
        }

        void Update(){
            if (!hasBooted){
                CheckBooted();
            }
            //cooldown -= (cooldown > 0) ? Time.deltaTime : 0;

            //if(cooldown <= 0){
            //    cooldown = spawnCooldown;
            //    Region selectedRegion = litterRegions[Random.Range(0, litterRegions.Length)];

            //    selectedRegion.litterManager.SpawnLitter(selectedRegion.regionCollider, spawnAmount);
            //}
        }

        IEnumerator SpawnLitter()
        {
            yield return new WaitForSeconds(spawnCooldown);
            Region selectedRegion = litterRegions[Random.Range(0, litterRegions.Length)];

            selectedRegion.litterManager.SpawnLitter(selectedRegion.regionCollider, spawnAmount);

            StartCoroutine(SpawnLitter());
        }
    }
}
