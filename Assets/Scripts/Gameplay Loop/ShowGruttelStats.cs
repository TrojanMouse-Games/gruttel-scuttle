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
            /*
            Ray ray = cam.ScreenPointToRay(Input.mousePosition); // SHOOT RAY FROM CAMERA (MOUSE POSITION) TO WORLD POINT 
            RaycastHit hit;
            if(Physics.Raycast(ray, out hit, maxDetectionDistance, whatIsGruttel)){ // CHECK TO SEE IF RAY HITS GRUTTEL
                
                EnableUI(true); // ENABLE THE STATS UI
            }   
            else{
                EnableUI(false); // DISABLE THE STATS UI
            } 
            */            
        }
        public void EnableUI(bool isActive){
            statsUI.gameObject.SetActive(isActive);
        }

        public void UpdateStats(GruttelReference gruttel){
            bool updateTraits = false;
            for (int i = 0; i < statsUI.GetChild(0).GetChild(1).childCount; i++){ // ITERATES THROUGH EACH LABEL OBJECT
                TextMeshProUGUI label = statsUI.GetChild(0).GetChild(1).GetChild(i).GetComponent<TextMeshProUGUI>();
                
                switch (i){ // SWITCH/CASE TO SET CORROSPONDING LABEL TO THE TEXT
                    case 0:
                        label.text = $"{gruttel.data.nickname}";
                        break;
                    case 1:
                        if(gruttel.data.bios.Length <= 0) { return; }
                        label.text = $"{gruttel.data.bios[0]}";
                        break;
                    default:                        
                        updateTraits = true;                        
                        break;
                }
            }
            // ITERATE THROUGH ALL TRAITS
            if (!updateTraits){
                return;
            }

            for (int x = 0; x < 3; x++){
                TextMeshProUGUI label = statsUI.GetChild(0).GetChild(1).GetChild(2 + x).GetComponent<TextMeshProUGUI>();
                label.text = (x < gruttel.data.traits.Length)? gruttel.data.traits[x] : "";
            }
        }
    }
}