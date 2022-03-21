using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// MADE BY JOSHUA THOMPSON
namespace TrojanMouse.Inventory
{
    public class LitterObjectHolder : MonoBehaviour
    {
        public LitterObject litterObject;
        public Transform parent;
        public bool isPickedUp;

        private void OnDrawGizmos()
        {
            if (!parent) { return; }

            Gizmos.color = Color.red;
            Gizmos.DrawWireSphere(parent.position + parent.forward + litterObject.heldOffset, .25f);
        }
    }
}
