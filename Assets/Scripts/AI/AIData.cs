using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

namespace TrojanMouse.AI
{
    public class AIData
    {
        public NavMeshAgent Agent;
        public LayerMask LitterLayer;
        public float WanderRadius { get; } = 15;
        public float DetectionRadius { get; } = 5;
        public float WanderCooldown;
        public Vector2 WanderCooldownRange { get; } = new Vector2(2, 10);

        public AIData(NavMeshAgent agent,
            LayerMask litterLayer,
            float wanderCooldown
            )
        {
            Agent = agent;
            LitterLayer = litterLayer;
            WanderCooldown = wanderCooldown;
        }
    }
}

