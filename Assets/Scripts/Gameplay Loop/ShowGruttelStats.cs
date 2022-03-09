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

                for(int i = 0; i < statsUI.GetChild(0).childCount; i++){ // ITERATES THROUGH EACH LABEL OBJECT
                    TextMeshProUGUI label = statsUI.GetChild(0).GetChild(i).GetComponent<TextMeshProUGUI>();                    
                    switch(i){ // SWITCH/CASE TO SET CORROSPONDING LABEL TO THE TEXT
                        case 0:
                            label.text = $"{gruttel.data.nickname}";
                            break;
                        case 1:
                            label.text = $"{gruttel.data.bios[0]}";
                            break;
                        default:
                            int curTraitVal = (gruttel.data.traits.Length - statsUI.GetChild(0).childCount) + i; // POSSIBLY VERY TEMPERMENTAL -- I WAS TRYING TO FIGURE OUT THE MATHS FOR THIS IN MY HEAD. WHAT ITS SUPPOSE TO DO AND KINDA DOES, IS RESET 'i's ANCHOR POINT AND MAP IT TO THE LENGTH OF TRAITS                            
                            if(curTraitVal < 0){ // SOMETIMES THE ABOVE VALUE RETURNS A VALUE <0 WHICH WOULD OBVIOUSLY CAUSE AN ERROR, SO WE SANITISE CHECK THAT VALUE
                                continue;
                            }
                            
                            label.text = gruttel.data.traits[curTraitVal];
                            break;
                    }
                }
                EnableUI(true); // ENABLE THE STATS UI
            }   
            else{
                EnableUI(false); // DISABLE THE STATS UI
            } 
        }
        public void EnableUI(bool isActive){
            statsUI.gameObject.SetActive(isActive);
        }
    }
}