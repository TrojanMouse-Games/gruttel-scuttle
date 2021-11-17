using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// MADE BY JOSHUA THOMPSON
namespace TrojanMouse.Inventory {
    public class Equipper : MonoBehaviour{
        int slots, currentIndex;
        GameObject selectedObject; // OBJECT TO FIND
        Transform itemParent;
        [SerializeField] float dropOffset;

        [SerializeField] Inventory inventoryHandler;

        private void Awake(){ 
            inventoryHandler = (!inventoryHandler)? transform.GetComponent<Inventory>() : inventoryHandler; // ASSIGNS THE INVENTORY HANDLER ONTO THIS SCRIPT
            slots = inventoryHandler.MaxSlots;
        }


        public void PickUp(Transform obj, int previousIndex = -1){
            LitterObject litter = obj.GetComponent<LitterObject>();            
            if(!litter){ 
                return; 
            }
            
            inventoryHandler.AddToInventory(litter);
            inventoryHandler.Equip(itemParent, currentIndex);
        }

        public void Drop(){            
            Instantiate(selectedObject, itemParent.position + (itemParent.forward * dropOffset), Quaternion.FromToRotation(selectedObject.transform.forward, itemParent.forward)/*,USE FUNCTION TO FIND CLOSEST REGION TO GRUTTEL AND SPAWN LITTER IN THAT REGION*/); // SPAWN LITTER
            inventoryHandler.Dequip(selectedObject);
        }
    }
}