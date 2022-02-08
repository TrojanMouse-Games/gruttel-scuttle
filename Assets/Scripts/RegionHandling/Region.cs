using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;



/* 
--// HOW TO USE \\--
Listening to feedback from my previous system, i was asked to try make it more minimal and ease of access for designers
and therefore i am trying to use built-in unity feature such as colliders to measure boundaries such as litter spawning regions and more

- Move this script onto a region object and it should generate a collider for you? Preferably a box collider - You should be able to change it to another type if you wish!
- Re-scale the collider to the region size
- Move the object to the desired position on the map
- In inspector where this script is located, assign the correct variables to match the purpose of this region 

- MAKE SURE THIS OBJECT COLLIDER IS SET TO TRIGGER!
- WHEN RESIZING THE COLLIDERS MAKE SURE TO SET THE 'CENTER' VALUE TO 0!

- You do not need to place a litter scriptable object inside the variable slot if this is not a litter region
*/



// DEVELOPED BY JOSH THOMPSON
namespace TrojanMouse.RegionManagement{
    [RequireComponent(typeof(Collider))] public class Region : MonoBehaviour{
        [Header("Please open this script to see how to use it!")]
        [SerializeField] RegionType type;
        public RegionType Type{ get{ return type; } } // PROGRAMMERS ACCESS THIS VARIABLE -- Read only, returns the type of region this is

        public LitterManager litterManager;

        public Collider regionCollider;

        [SerializeField] Color32 debugColour = Color.red;
        public Color32 DebugColour{ get{ return debugColour;} }

        private void Start() { 
            Region_Handler.current.PingRegions += PingRegion;
            regionCollider = transform.GetComponent<Collider>();
        }
        void PingRegion() => Region_Handler.current.AddRegion(this);

        [Serializable] public enum RegionType{
            NONE,
            LITTER_REGION,
            HOME
        }
    
    
        private void OnDrawGizmosSelected() {
            Gizmos.color = DebugColour;
            Gizmos.DrawWireSphere(transform.position, .1f);
       }
    }
}
