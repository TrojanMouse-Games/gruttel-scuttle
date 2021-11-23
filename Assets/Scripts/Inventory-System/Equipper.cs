using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrojanMouse.RegionManagement;
using TrojanMouse.PowerUps;
// MADE BY JOSHUA THOMPSON
namespace TrojanMouse.Inventory {
    public class Equipper : MonoBehaviour{
        int slots, currentIndex;
        GameObject selectedObject; // OBJECT TO FIND
        [SerializeField] Transform itemParent;
        [SerializeField] float dropOffset;

        [SerializeField] Inventory inventoryHandler;

        private void Awake(){ 
            inventoryHandler = (!inventoryHandler)? transform.GetComponent<Inventory>() : inventoryHandler; // ASSIGNS THE INVENTORY HANDLER ONTO THIS SCRIPT
            slots = inventoryHandler.MaxSlots;
        }


        public void PickUp(Transform obj, PowerupType powerUp, LitterObject type, int previousIndex = -1){           
            if(powerUp != type.type && type.type != PowerupType.NORMAL) { // BREAKS OUT THE CODE IF THE TYPE IS NOT NORMAL AND IS NOT OF X TYPE
                return; 
            }
            Debug.Log($"{powerUp} | {type.type}");
            bool success = inventoryHandler.AddToInventory(type);                       
            if(success){
                Debug.Log(success); 
                selectedObject = inventoryHandler.Equip(itemParent, currentIndex);                
                if(selectedObject){                   
                    selectedObject.GetComponent<LitterObjectHolder>().parent = itemParent;
                    selectedObject.GetComponent<Rigidbody>().isKinematic = true;                    
                }
                Destroy(obj.gameObject);                
            }            
        }

        public void Drop(Region.RegionType _type){        
            GameObject droppedItem = Instantiate(selectedObject, itemParent.position + (itemParent.forward * dropOffset), Quaternion.FromToRotation(Vector3.forward, itemParent.forward), Region_Handler.current.GetClosestRegion(_type, transform).transform); // SPAWN LITTER
            
            inventoryHandler.Dequip(selectedObject);
            inventoryHandler.RemoveFromInventory(selectedObject.GetComponent<LitterObjectHolder>().type);
        }

        private void OnDrawGizmosSelected() {
            Gizmos.DrawWireSphere(itemParent.position + (itemParent.forward * dropOffset), .25f);
        }
    }
}