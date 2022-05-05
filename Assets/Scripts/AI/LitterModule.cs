using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrojanMouse.Inventory;
using TrojanMouse.Gruttel;
using Fungus;

namespace TrojanMouse.AI
{
    public class LitterModule : MonoBehaviour
    {
        public LitterObjectHolder target;
        public LitterObjectHolder holdingLitter;
        public string Message;
        public Flowchart flowchart;

        public Collider[] litterInRange;

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
            LitterObjectHolder potentialTarget = null;
            if (inventory.HasSlotsLeft())
            {
                litterInRange = Physics.OverlapSphere(transform.position, data.detectionRadius, data.litterLayer);
                GruttelType gruttelType = data.gruttel.data.type;

                foreach (Collider c in litterInRange)
                {
                    LitterObjectHolder litter = c.GetComponent<LitterObjectHolder>();
                    if (litter == null)
                    {
                        return null;
                    }
                    bool canPickup = CanPickupLitter(litter.litterObject.typeOfLitter, gruttelType);
                    Debug.Log($"can pickup: {canPickup}");

                    if (canPickup)
                    {
                        data.agent.SetDestination(litter.transform.position);
                        if (litter.litterObject.typeOfLitter == gruttelType)
                        { // SHOULD MEAN IF THE LITTER IS THE SAME TYPE OF THE BUFFED GRUTTEL THEN THE GRUTTEL WILL PRIORITISE THE SAME TYPE OF LITTER
                            Fungus.Flowchart.BroadcastFungusMessage(Message);
                            return litter;
                        }
                        potentialTarget = litter;
                    }
                }
                return potentialTarget;
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