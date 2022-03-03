using UnityEngine;
using TrojanMouse.RegionManagement;

// MADE BY JOSHUA THOMPSON
namespace TrojanMouse.StressSystem
{
    using GameplayLoop;
    public class Stress : MonoBehaviour{
        public static Stress current;
        Region[] litterRegions = new Region[] { };

        [HideInInspector] public float amountOfLitter;

        [Header("Settings")]
        [Tooltip("Time until this script will calculate stress again")] [SerializeField] float calculationCooldown; // TIME BETWEEN EACH CALCULATION FOR STRESS

        public float maxLitter;        
        [HideInInspector] public float Cooldown{
            get{
                return calculationCooldown;
            }
        }


        private void Awake(){
            if (current){ // THIS ENSURES THAT ONLY ONE INSTANCE OF THIS SCRIPT EXISTS IN THE SCENE
                Destroy(this);
                return;
            }

            current = this; // SINGLETON            
            InvokeRepeating("UpdateStress", calculationCooldown, calculationCooldown); // THIS WILL AUTOMATICALLY CALL THE 'UpdateStress' FUNCTION EVERY X SECONDS BASED ON THE 'calculationCooldown' VARIABLE
        }        

        private void Update(){
            if (litterRegions.Length > 0 || Region_Handler.current.GetRegions(Region.RegionType.LITTER_REGION) == null){ // SAFETY MEASURE TO ENSURE THAT THERE ARE REGIONS TO ACCESS AND THAT IT ONLY IS CALLED ONCE
                return;
            }
            litterRegions = Region_Handler.current.GetRegions(Region.RegionType.LITTER_REGION); // POPULATES THE 'litterRegions' ARRAY WITH ALL REGIONS
        }

        void UpdateStress(){
            if (litterRegions.Length > 0){ // SAFETY MEASURE TO MAKE SURE THIS IS POPULATED
                float stress = 0; // CREATE NEW VALUE TO CALCULATE WITH
                foreach (Region region in litterRegions){ // ITERATE THROUGH ALL LITTERREGIONS
                    stress += region.transform.childCount; // APPEND THE AMOUNT OF CHILDREN INSIDE A REGION TO THIS VALUE
                }                
                amountOfLitter = stress; // SET THE PUBLIC READABLE VALUE TO THE AMOUNT OF STRESS
            }
        }

    }
}