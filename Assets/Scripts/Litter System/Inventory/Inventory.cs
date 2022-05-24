using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;

// MADE BY JOSHUA THOMPSON
namespace TrojanMouse.Inventory
{
    using Litter.Region;
    public class Inventory : MonoBehaviour
    {
        [SerializeField] int maxSlots = 1;
        public int MaxSlots { get { return maxSlots; } }

        public Animator animator;
        public Transform holdPosition;

        Dictionary<LitterObject, int> inventory = new Dictionary<LitterObject, int>();

        public bool HasSlotsLeft()
        {
            return (inventory.Count < maxSlots) ? true : false;
        }

        public bool AddToInventory(LitterObject obj, int amount = 1)
        {
            if (inventory.ContainsKey(obj) && inventory[obj] < obj.maxOfItem)
            {
                inventory[obj] += amount;
                return true;
            }
            else if (inventory.Count >= maxSlots)
            { // NO MORE AVAILABLE SLOTS
                return false;
            }
            else
            {
                inventory.Add(obj, amount);
                return true;
            }
        }
        public void RemoveFromInventory(LitterObject obj, int amount = -1)
        {
            if (!inventory.ContainsKey(obj))
            { // NO NEED TO FOLLOW CODE IF IT DOESNT EXIST...
                return;
            }

            if (amount < 0)
            {
                inventory.Remove(obj);
                return;
            }

            inventory[obj] -= amount;
        }



        // VISUALISERS
        public GameObject Equip(LitterObjectHolder litter, int index, int previousIndex = -1)
        {
            if (animator != null)
            {
                animator.SetBool("hasTrash", true);
                animator.SetInteger("trashType", (int)litter.litterObject.typeOfLitter);
            }

            if (inventory.Count - 1 > index || (previousIndex > -1 && inventory.Count - 1 > previousIndex))
            {
                return null;
            }
            if (previousIndex >= 0)
            { // DEQUIP CURRENTLY HELD OBJECT
                Dequip(litter.transform, inventory.Keys.ToArray()[previousIndex].spawnableObject);
            }

            LitterObject item = inventory.Keys.ToArray()[index];
            litter.transform.parent = holdPosition;
            litter.transform.localPosition = Vector3.zero;
            litter.transform.localRotation = Quaternion.Euler(Vector3.zero);
            return litter.gameObject;
        }

        public void Dequip(Transform parent, GameObject obj)
        {
            if (animator != null)
            {
                animator.SetBool("hasTrash", false);
            }
            foreach (Transform child in parent)
            {
                if (child.name == obj.name)
                {
                    Destroy(child.gameObject);
                    return;
                }
            }
        }

        public void Dequip(GameObject obj, RegionType regionType)
        {
            if (animator != null)
            {
                animator.SetBool("hasTrash", false);
            }
            if (regionType == RegionType.HOME)
            {
                Destroy(obj);
            }
            else
            {
                obj.transform.parent = null;
            }
        }
    }
}
