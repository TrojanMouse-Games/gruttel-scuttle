using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;


// MADE BY JOSHUA THOMPSON
namespace TrojanMouse.Inventory {
    public class Inventory : MonoBehaviour{
        [SerializeField] int maxSlots = 1;
        public int MaxSlots{ get{ return maxSlots;} }


        Dictionary<LitterObject, int> inventory = new Dictionary<LitterObject, int>();
        public bool HasSlotsLeft(){
            return (inventory.Count < maxSlots) ? true: false;
        }

        public bool AddToInventory(LitterObject obj, int amount = 1){
                if(inventory.ContainsKey(obj) && inventory[obj] < obj.maxOfItem){ 
                    inventory[obj] += amount;
                    return true;
                }
                else if(inventory.Count >= maxSlots){ // NO MORE AVAILABLE SLOTS
                    return false;
                } 
                else{
                    inventory.Add(obj, amount);
                    return true;
                }
        }
        public void RemoveFromInventory(LitterObject obj, int amount = -1){
            if(!inventory.ContainsKey(obj)){ // NO NEED TO FOLLOW CODE IF IT DOESNT EXIST...
                return; 
            }
            
            if(amount < 0){
                inventory.Remove(obj);
                return;
            }

            inventory[obj] -= amount;
        }



    // VISUALISERS
        public GameObject Equip(Transform parent, int index, int previousIndex = -1){            
            if(inventory.Count-1 > index || (previousIndex >-1 && inventory.Count-1 > previousIndex)){ 
                return null; 
            }
            if(previousIndex >=0){ // DEQUIP CURRENTLY HELD OBJECT
                Dequip(parent, inventory.Keys.ToArray()[previousIndex].spawnableObject);
            }

            LitterObject item = inventory.Keys.ToArray()[index];
            return Instantiate(item.spawnableObject, (parent.position + parent.forward + item.heldOffset), Quaternion.FromToRotation(item.spawnableObject.transform.forward, parent.forward), parent); 
        }

        public void Dequip(Transform parent, GameObject obj){
            foreach(Transform child in parent){
                if(child.name == obj.name){
                    Destroy(child.gameObject);
                    return;
                }
            }
        }

        public void Dequip(GameObject obj){
            Destroy(obj);
        }
    }
}
