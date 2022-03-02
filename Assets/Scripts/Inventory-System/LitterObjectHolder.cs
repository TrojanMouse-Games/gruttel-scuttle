using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// MADE BY JOSHUA THOMPSON
namespace TrojanMouse.Inventory
{
    public class LitterObjectHolder : MonoBehaviour
    {
        public LitterObject type;
        public Transform parent;

        private void OnDrawGizmos()
        {
            if (!parent) { return; }

            Gizmos.color = Color.red;
            Gizmos.DrawWireSphere(parent.position + parent.forward + type.heldOffset, .25f);
        }

        private void OnCollisionEnter(Collision other)
        {
            if (other.transform.CompareTag("Ground"))
            {
                GetComponent<Rigidbody>().constraints = RigidbodyConstraints.FreezeAll;
            }
        }
    }
}
