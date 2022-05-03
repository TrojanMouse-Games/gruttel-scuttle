using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using TrojanMouse.AI;
using TrojanMouse.GameplayLoop;
namespace TrojanMouse.Gruttel
{
    public class DragUI : MonoBehaviour
    {
        public Canvas canvas;
        [SerializeField] LayerMask whatIsGruttel;
        [SerializeField] bool lockGruttelToOneType;

        Vector2 startingPos; // POSITION THIS ITEM WAS SPAWNED AT
        Transform parent; // USE THIS TO TELEPORT THE ELEMENT BACK INTO THE ORDER GROUP
        public GruttelType powerupType;


        [System.Serializable]
        public class gruttelSettings{
            public Mesh type;
            public Material texture;
        }
        [SerializeField] gruttelSettings[] gruttelTypes;

        Camera camera;
        CinemachineControl cam;
        private void Start()
        {
            parent = transform.parent;
            canvas = parent.parent.GetComponent<Canvas>();
            camera = Camera.main;
            cam = camera.GetComponent<CinemachineControl>();
        }

        ///<summary>Drags the UI element to the position of the mouse when clicked on</summary>
        public void Drag(BaseEventData _data)
        {
            if (cam){
                cam.canDrag = false;
            }
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
        public void Drop(BaseEventData _data)
        {
            if (cam){
                cam.canDrag = true;
            }
            
            if (!IsGruttel(powerupType))
            {
                transform.SetParent(parent);
                return;
            }
            Destroy(gameObject);
        }


        ///<summary>Checks if the mouse position is on a Gruttel using raycasts. It'll return true if it hits a Gruttel</summary>
        bool IsGruttel(GruttelType powerupType){            
            Ray ray = camera.ScreenPointToRay(Input.mousePosition, Camera.MonoOrStereoscopicEye.Mono);
            RaycastHit hit;

            if (Physics.Raycast(ray, out hit, 100, whatIsGruttel))
            {
                GruttelData gruttelData = hit.transform.GetComponent<GruttelReference>().data;

                if (gruttelData.type != GruttelType.Normal && lockGruttelToOneType){
                    return false;
                }

                if(hit.collider.transform.GetInstanceID() != GruttelsSelected.instance.villageFolder.GetChild(GruttelsSelected.instance.gruttelSelectedIndex).transform.GetInstanceID()){ // MAKES SURE POWERUP IS APPLIED TO SELECTED 
                    return false;
                }

                Mesh curMesh = null;
                Material curMaterial = null;
                switch (powerupType){
                    case GruttelType.Buff:
                        curMesh = gruttelTypes[0].type;
                        curMaterial = gruttelTypes[0].texture;
                        break;
                    case GruttelType.Radioactive:
                        curMesh = gruttelTypes[1].type;
                        curMaterial = gruttelTypes[1].texture;
                        break;
                }
                if(GruttelsSelected.instance.gruttelsSelected.Count >= GruttelsSelected.instance.gruttelsToSelect && !GruttelsSelected.instance.gruttelsSelected.Contains(hit.collider.transform)){
                    return false;
                }

                gruttelData.UpdateGruttelType(powerupType);
                if (!GruttelsSelected.instance.gruttelsSelected.Contains(hit.collider.transform)){
                    GruttelsSelected.instance.gruttelsSelected.Add(hit.collider.transform);
                }
                
                hit.transform.gameObject.GetComponentInParent<AIController>().UpdateColor();
            }
            return (hit.transform) ? true : false;
        }
    }
}