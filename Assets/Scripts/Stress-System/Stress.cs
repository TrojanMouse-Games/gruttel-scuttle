using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

// MADE BY JOSHUA THOMPSON
namespace TrojanMouse.StressSystem
{
    using GameplayLoop;
    public class Stress : MonoBehaviour
    {
        public static Stress current;
        List<StressLocal> gruttels = new List<StressLocal>();

        [HideInInspector] public float average;
        float timer;
        public float peacefulPeriod = 20f;

        [Header("Settings")]
        [Tooltip("Time until this script will calculate stress again")] [SerializeField] float calculationCooldown; // TIME BETWEEN EACH CALCULATION FOR STRESS
        [HideInInspector]
        public float Cooldown
        {
            get
            {
                return calculationCooldown;
            }
        }


        private void Awake()
        {
            current = this; // SINGLETON
            InvokeRepeating("UpdateStress", calculationCooldown, calculationCooldown);
        }


        public void AddGruttel(StressLocal gruttel)
        {
            gruttels.Add(gruttel);
        }


        void UpdateStress()
        {
            if (gruttels.Count > 0 && GameLoop.current.curStage == 1)
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


    }
}