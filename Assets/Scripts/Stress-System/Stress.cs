using UnityEngine;
using System.Collections;
using TrojanMouse.RegionManagement;
using UnityEngine.SceneManagement;
using TrojanMouse.GameplayLoop;
// MADE BY JOSHUA THOMPSON
namespace TrojanMouse.StressSystem
{
    using GameplayLoop;
    public class Stress : MonoBehaviour{
        public static Stress current;
        Region[] litterRegions = new Region[] { };
        [HideInInspector] public bool isCountingDown;

        [HideInInspector] public float amountOfLitter;

        [HideInInspector] public bool startStress;


        [Header("Settings")]
        [Tooltip("Time until this script will calculate stress again")] [SerializeField] float calculationCooldown; // TIME BETWEEN EACH CALCULATION FOR STRESS
        [SerializeField] float maxStressCountdown;
        float curCountdown;
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
            #region STRESS COUNTDOWN
            if(amountOfLitter >= maxLitter && !isCountingDown && startStress){
                isCountingDown = true;
                curCountdown = Time.time + maxStressCountdown;
            }
            if(Time.time >= curCountdown && isCountingDown){
                isCountingDown = false;
                if(amountOfLitter >= maxLitter){
                    // switch scene
                    SceneManager.LoadSceneAsync("LoseScreen");  
                }                
            }
            #endregion
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