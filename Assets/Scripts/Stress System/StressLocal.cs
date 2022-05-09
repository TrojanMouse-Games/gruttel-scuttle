using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// MADE BY JOSHUA THOMPSON
namespace TrojanMouse.StressSystem
{
    public class StressLocal : MonoBehaviour
    {
        [Header("Local Stress - For Gruttel")] [Range(0, 100)] [SerializeField] float stress; // THIS WILL EVENTUALLY USE HAYLEYS SCRIPT
        [Header("Settings")]
        [SerializeField] int litterToFullyStressGruttel = 10;
        [SerializeField] LayerMask whatIsLitter;
        [SerializeField] float FOV;

        public float GruttelStress
        { // THIS ALLOWS ANY SCRIPT TO ACCESS THE STRESS OF THIS CURRENT GRUTTEL
            get
            {
                return stress;
            }
        }


        void Start()
        {
            //Stress.current.AddGruttel(this); // ADDS THIS SCRIPT TO A LIST THAT THE PARENT SCRIPT WILL READ FROM
            if (Stress.current != null)
            {
                InvokeRepeating("CalculateStress", Stress.current.Cooldown, Stress.current.Cooldown);
            }
        }

        void CalculateStress()
        {
            Collider[] litter = Physics.OverlapSphere(transform.position, FOV, whatIsLitter);

            if (litter.Length <= 0)
            {
                return;
            }

            stress = (litter.Length / (float)litterToFullyStressGruttel) * 100;
        }

        private void OnDrawGizmosSelected()
        {
            Gizmos.DrawWireSphere(transform.position, FOV);
        }
    }
}