using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

namespace TrojanMouse.AI
{
    using Gruttel;

    [Serializable]
    public class AIData
    {
        public Inventory.Inventory inventory;
        public NavMeshAgent agent;
        public LayerMask litterLayer;
        public float wanderRadius { get; } = 10;
        public float detectionRadius { get; } = 10;
        public float pickupRadius { get; } = 2;
        public float wanderCooldown;
        public Vector2 wanderCooldownRange { get; } = new Vector2(2, 10);

        public bool distracted = false;

        public GruttelData gruttel;

        public AIData(NavMeshAgent _agent,
            LayerMask _litterLayer,
            float _wanderCooldown,
            GruttelData gruttelData)
        {
            agent = _agent;
            litterLayer = _litterLayer;
            wanderCooldown = _wanderCooldown;
            gruttel = gruttelData;
        }
    }
}

