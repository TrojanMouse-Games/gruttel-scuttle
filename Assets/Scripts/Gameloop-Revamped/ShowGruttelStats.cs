using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrojanMouse.Gruttel;
using TMPro;

namespace TrojanMouse.GameplayLoop{
    public class ShowGruttelStats : MonoBehaviour{
        [SerializeField] LayerMask whatIsGruttel;
        [SerializeField] float maxDetectionDistance;
        [SerializeField] Transform statsUI;
        Camera cam;

        void Start(){
            cam = Camera.main; // ASSIGNS A VARIABLE
        }
        void Update(){
            if(!statsUI){ // SAFETY MEASURE TO ENSURE STATS UI VARIABLE IS ASSIGNED
                Debug.LogError($"ERROR: PLEASE ASSIGN THE STATS UI TO '{transform.name}'");
                return;
            }

            Ray ray = cam.ScreenPointToRay(Input.mousePosition); // SHOOT RAY FROM CAMERA (MOUSE POSITION) TO WORLD POINT 
            RaycastHit hit;
            if(Physics.Raycast(ray, out hit, maxDetectionDistance, whatIsGruttel)){ // CHECK TO SEE IF RAY HITS GRUTTEL
                GruttelReference gruttel = hit.transform.GetComponent<GruttelReference>(); // GETS THE DATA FROM THE GRUTTEL
                statsUI.GetChild(0).GetComponent<TextMeshProUGUI>().text = $"Name: {gruttel.data.nickname}"; // GETS THE T
                string traits = "";
                foreach(string trait in gruttel.data.traits){
                    traits += $"* {trait}\n\n";
                }
                statsUI.GetChild(1).GetComponent<TextMeshProUGUI>().text = $"{traits}";
                // set gruttel stats to ui
                // enable ui
                EnableUI(true);
            }   
            else{
                // disable ui
                EnableUI(false);
            } 
        }
        public void EnableUI(bool isActive){
            statsUI.gameObject.SetActive(isActive);
        }
    }
}