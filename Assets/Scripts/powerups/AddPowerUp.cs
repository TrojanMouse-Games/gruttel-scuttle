using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using System;

namespace TrojanMouse.PowerUps{
    [Serializable] public class CompletedSpawning : UnityEvent { }

    public class AddPowerUp : MonoBehaviour{
        [SerializeField] CompletedSpawning onComplete;

        

        [SerializeField] GameObject powerupVisuals;
        [SerializeField] Vector3 powerUpSpawnOffset;
        [SerializeField] LayerMask whatIsGruttel;
        Camera cam;
        PowerupType selectedType = PowerupType.NORMAL;


        private void Awake(){
            cam = Camera.main;
            powerupsToDispence = 3;
        }
        private void Update(){
            if(powerupsToDispence > 0 && Input.GetMouseButtonDown(0)){ // THIS WILL NEED TO BE REVISED FOR MOBILE SUPPORT!
                Ray ray = cam.ScreenPointToRay(Input.mousePosition, Camera.MonoOrStereoscopicEye.Mono);
                RaycastHit hit;
                if (Physics.Raycast(ray , out hit, 100, whatIsGruttel)){
                    Dispence(selectedType, hit.transform.GetComponent<Powerup>());
                }
                powerupsToDispence--;
            }
            else if(waitingForInput && powerupsToDispence <=0){
                onComplete?.Invoke(); // CALLBACK 
                waitingForInput = false;
            }
        }



        float powerupsToDispence;
        bool waitingForInput;
        /// <summary>
        /// The amount of powerups to give to the Gruttels
        /// </summary>
        /// <param name="_amt"></param>
        public void AmountToDispence(float _amt){
            if (_amt < 0){
                return;
            }
            powerupsToDispence += _amt;
            waitingForInput = true;
        }
        /// <summary>
        /// Changes a variable in the functions script which will affect the type of powerup a Gruttel recieves
        /// </summary>
        /// <param name="_type">The powerup to be given to the Gruttel</param>
        public void SelectedPowerup(PowerupType _type){
            selectedType = _type;
        }
        void Dispence(PowerupType type, Powerup character){
            GameObject clonedObj = Instantiate(powerupVisuals, character.transform.position + powerUpSpawnOffset, Quaternion.identity, null);
            
            character.Type = type; // DO THIS IN X SECONDS
        }
    }
}
