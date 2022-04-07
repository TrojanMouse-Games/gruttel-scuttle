using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrojanMouse.Litter.Region;
using TrojanMouse.Gruttel;

// MADE BY JOSHUA THOMPSON
namespace TrojanMouse.Inventory
{
    public class Equipper : MonoBehaviour
    {
        int slots, currentIndex;
        GameObject selectedObject; // OBJECT TO FIND
        public GameObject HeldObject { get { return selectedObject; } }
        [SerializeField] Transform itemParent;
        [SerializeField] float dropOffset;

        [SerializeField] Inventory inventoryHandler;

        private void Awake()
        {
            inventoryHandler = (!inventoryHandler) ? transform.GetComponent<Inventory>() : inventoryHandler; // ASSIGNS THE INVENTORY HANDLER ONTO THIS SCRIPT
            slots = inventoryHandler.MaxSlots;
        }


        public bool PickUp(LitterObjectHolder litter)
        {
            bool success = inventoryHandler.AddToInventory(litter.litterObject);
            if (success)
            {
                selectedObject = inventoryHandler.Equip(litter.transform, currentIndex);
                if (selectedObject)
                {
                    selectedObject.GetComponent<LitterObjectHolder>().parent = itemParent;
                    selectedObject.GetComponent<Rigidbody>().isKinematic = true;
                    selectedObject.GetComponent<Collider>().enabled = false;
                }
            }
            return success;
        }

        public void Drop(RegionType _type)
        {
            //GameObject droppedItem = Instantiate(selectedObject, itemParent.position + (itemParent.forward * dropOffset), Quaternion.FromToRotation(Vector3.forward, itemParent.forward), Region_Handler.current.GetClosestRegion(_type, transform.position).transform); // SPAWN LITTER
            //droppedItem.GetComponent<Rigidbody>().isKinematic = false;
            //droppedItem.GetComponent<Collider>().enabled = true;

            if (selectedObject)
            {
                LitterObjectHolder holder = selectedObject.GetComponent<LitterObjectHolder>();
                if (holder != null)
                {
                    inventoryHandler.RemoveFromInventory(holder.litterObject);
                }

                inventoryHandler.Dequip(selectedObject);
                selectedObject = null;
            }
        }

        private void OnDrawGizmosSelected()
        {
            Gizmos.DrawWireSphere(itemParent.position + (itemParent.forward * dropOffset), .25f);
        }
    }
}