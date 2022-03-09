using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrojanMouse.Gruttel;

// MADE BY JOSHUA THOMPSON
namespace TrojanMouse.Inventory
{
    [CreateAssetMenu(fileName = "Litter Object", menuName = "ScriptableObjects/Inventory/Litter Object")]
    public class LitterObject : ScriptableObject
    {
        public GameObject spawnableObject;
        public Vector3 heldOffset;
        public int maxOfItem = 1;
        public PowerupType type;
    }
}