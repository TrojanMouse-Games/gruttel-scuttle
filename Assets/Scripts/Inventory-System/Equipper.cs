using System.Collections;
using System.Collections.Generic;
using UnityEngine;

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


        public void PickUp(Transform obj, LitterObject type, int previousIndex = -1){           
            
            bool success = inventoryHandler.AddToInventory(type);            
            if(success){
                selectedObject = inventoryHandler.Equip(itemParent, currentIndex);                
                if(selectedObject){                   
                    selectedObject.GetComponent<LitterObjectHolder>().parent = itemParent;
                }                
            }
            Destroy(obj.gameObject);
        }

        public void Drop(){        
            Instantiate(selectedObject, itemParent.position + (itemParent.forward * dropOffset), Quaternion.FromToRotation(Vector3.forward, itemParent.forward)/*,USE FUNCTION TO FIND CLOSEST REGION TO GRUTTEL AND SPAWN LITTER IN THAT REGION*/); // SPAWN LITTER
            inventoryHandler.Dequip(selectedObject);
            inventoryHandler.RemoveFromInventory(selectedObject.GetComponent<LitterObjectHolder>().type);
        }

        private void OnDrawGizmosSelected() {
            Gizmos.DrawWireSphere(itemParent.position + (itemParent.forward * dropOffset), .25f);
        }
    }
}