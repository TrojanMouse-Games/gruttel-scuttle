using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// MADE BY JOSHUA THOMPSON
namespace TrojanMouse.StressSystem{
    public class Stress : MonoBehaviour{
        public static Stress current;
        List<StressLocal> gruttels = new List<StressLocal>();

        [HideInInspector] public float average;

        [Header("Settings")]
        [Tooltip("Time until this script will calculate stress again")][SerializeField] float calculationCooldown; // TIME BETWEEN EACH CALCULATION FOR STRESS
        [HideInInspector] public float Cooldown{
            get{
                return calculationCooldown;
            }
        }


        private void Awake() {
            current = this; // SINGLETON
            InvokeRepeating("UpdateStress", calculationCooldown, calculationCooldown);
        }


        public void AddGruttel(StressLocal gruttel) {
            gruttels.Add(gruttel);
        } 


        void UpdateStress(){            
            if(gruttels.Count >0){
                float stress = 0;
                foreach(StressLocal gruttel in gruttels){
                    stress += gruttel.GruttelStress;                    
                }
                stress /= gruttels.Count;
                average = stress;        
                Debug.Log(average);        
            }                        
        }
    }
}