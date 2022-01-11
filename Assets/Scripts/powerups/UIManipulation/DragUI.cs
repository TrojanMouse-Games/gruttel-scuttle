using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

namespace TrojanMouse.PowerUps{
    [RequireComponent(typeof(Powerup))]
    public class DragUI : MonoBehaviour{
        public Canvas canvas;
        [SerializeField] LayerMask whatIsGruttel;
        [SerializeField] bool lockGruttelToOneType;
        Vector2 startingPos; // POSITION THIS ITEM WAS SPAWNED AT
        Transform parent; // USE THIS TO TELEPORT THE ELEMENT BACK INTO THE ORDER GROUP
        PowerupType type;

        Camera camera;
        private void Start() {
            parent = transform.parent;
            canvas = parent.parent.GetComponent<Canvas>();
            camera = Camera.main;
            type = transform.GetComponent<Powerup>().Type;
        } 
        
        ///<summary>Drags the UI element to the position of the mouse when clicked on</summary>
        public void Drag(BaseEventData _data){        
            PointerEventData pointData = (PointerEventData)_data;
            transform.SetParent(parent.parent);

            Vector2 pos;
            RectTransformUtility.ScreenPointToLocalPointInRectangle( // GETS THE LOCAL POSITION OF THE UI ELEMENT ON THE SCREEN SINCE IT USES A DIFFERENT COORDINATE SYSTEM TO NORMAL 2D/3D SPACE
                (RectTransform)canvas.transform,
                pointData.position,
                canvas.worldCamera,
                out pos
            );

            transform.position = canvas.transform.TransformPoint(pos); // MOVES THE POSITION OF THE ELEMENT BASED ON THE POSITION OF ITS PARENT (CANVAS)
        }    

        ///<summary>Checks to see if what this element is on is a Gruttel or not, if it is then it'll delete the object and powerup the Gruttel otherwise teleport the element back into place</summary>
        public void Drop(BaseEventData _data){                       
            if(!IsGruttel(type)){
                transform.SetParent(parent); 
                return;
            }
            Destroy(gameObject);
        }


        ///<summary>Checks if the mouse position is on a Gruttel using raycasts. It'll return true if it hits a Gruttel</summary>
        bool IsGruttel(PowerupType selectedType){
            Ray ray = camera.ScreenPointToRay(Input.mousePosition, Camera.MonoOrStereoscopicEye.Mono);
            RaycastHit hit;
             
            if (Physics.Raycast(ray , out hit, 100, whatIsGruttel)){                
                Powerup gruttel = hit.transform.GetComponent<Powerup>();
                
                if(gruttel.Type != PowerupType.NORMAL && lockGruttelToOneType){ 
                    return false;
                }
                gruttel.Type = selectedType;
            }
            return (hit.transform)? true : false;
        }
    }
}