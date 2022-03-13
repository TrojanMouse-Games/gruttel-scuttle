using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrojanMouse.Inventory;
using TrojanMouse.Gruttel;

namespace TrojanMouse.AI
{
    public class LitterModule : MonoBehaviour
    {
        public LitterObjectHolder target;
        public LitterObjectHolder holdingLitter;

        public AIState GetLitter(AIData data)
        {
            Inventory.Inventory inventory = data.inventory;
            if ((target == null || target.isPickedUp) && holdingLitter == null)
            {
                target = GetNewTarget(data, inventory);
            }

            if (target == null)
            {
                return AIState.Nothing;
            }

            if (holdingLitter != null)
            {
                return AIState.MovingToMachine;
            }

            return AIState.MovingToLitter;
        }

        public LitterObjectHolder GetNewTarget(AIData data, Inventory.Inventory inventory)
        {
            if (inventory.HasSlotsLeft())
            {
                Collider[] litterInRange = Physics.OverlapSphere(transform.position, data.detectionRadius, data.litterLayer);
                GruttelType gruttelType = data.gruttel.data.type;

                foreach (Collider c in litterInRange)
                {
                    LitterObjectHolder litter = c.GetComponent<LitterObjectHolder>();

                    bool canPickup = CanPickupLitter(litter.litterObject.typeOfLitter, gruttelType);
                    Debug.Log($"can pickup: {canPickup}");

                    if (canPickup)
                    {
                        data.agent.SetDestination(litter.transform.position);
                        return litter;
                    }
                }
            }

            return null;
        }

        bool CanPickupLitter(GruttelType litterType, GruttelType gruttelType)
        {
            if (litterType == gruttelType || litterType == GruttelType.Normal)
            {
                return true;
            }
            return false;
        }
    }
}