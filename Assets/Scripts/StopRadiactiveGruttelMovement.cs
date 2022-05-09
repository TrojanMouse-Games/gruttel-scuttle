using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrojanMouse.AI;

public class StopRadiactiveGruttelMovement : MonoBehaviour
{
    public AIData aiData;
    public Vector3 destination;

    private void Awake()
    {
        aiData = transform.parent.parent.parent.parent.parent.parent.parent.parent.GetComponent<AIController>().data;
        aiData.agent.speed *= 1.24316312101f;
        aiData.agent.acceleration *= 1.24316312101f;
    }

    public void OnCollisionEnter(Collision other)
    {
        if (aiData.agent.isOnNavMesh)
        {
            aiData.agent.isStopped = true;
            aiData.agent.velocity = Vector3.zero;
        }
    }
    public void OnCollisionExit(Collision other)
    {
        if (aiData.agent.isOnNavMesh)
        {
            aiData.agent.isStopped = false;
        }
    }
}
