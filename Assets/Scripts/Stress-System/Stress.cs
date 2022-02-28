using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrojanMouse.RegionManagement;
using System.Linq;

// MADE BY JOSHUA THOMPSON
namespace TrojanMouse.StressSystem
{
    using GameplayLoop;
    public class Stress : MonoBehaviour
    {
        public static Stress current;
        Region[] litterRegions = new Region[] { };

        [HideInInspector] public float amountOfLitter;

        [Header("Settings")]
        [Tooltip("Time until this script will calculate stress again")] [SerializeField] float calculationCooldown; // TIME BETWEEN EACH CALCULATION FOR STRESS

        public float maxLitter;
        [SerializeField] float stress;
        [HideInInspector] public float Cooldown{
            get{
                return calculationCooldown;
            }
        }


        private void Awake(){
            current = this; // SINGLETON            
            InvokeRepeating("UpdateStress", calculationCooldown, calculationCooldown);
        }

        /*
        void UpdateStress()
        {
            if (gruttels.Count > 0 && GameLoop.current.curStage == 1) // UN-COMMENT THIS! JUST TO SUPPRESS THE ERROR!
            {
                timer += calculationCooldown;
                if (timer > peacefulPeriod) {
                    float stress = 0;
                    foreach (StressLocal gruttel in gruttels)
                    {
                        stress += gruttel.GruttelStress;
                    }

                    average = stress / gruttels.Count;
                    if (average >= 100)
                    {
                        SceneManager.LoadScene("LoseScreen");
                    }
                }
            }
        }
        */

        private void Update(){
            if (litterRegions.Length > 0 || Region_Handler.current.GetRegions(Region.RegionType.LITTER_REGION) == null){
                return;
            }
            litterRegions = Region_Handler.current.GetRegions(Region.RegionType.LITTER_REGION);
        }

        void UpdateStress(){
            if (litterRegions.Length > 0){
                stress = 0;
                foreach (Region region in litterRegions){
                    stress += region.transform.childCount;
                }
                //stress /= litterRegions.Length;
                amountOfLitter = stress;
            }
        }

    }
}