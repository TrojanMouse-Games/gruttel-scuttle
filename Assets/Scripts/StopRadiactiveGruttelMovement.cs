using System;
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
        try
        {
            aiData = transform.parent.parent.parent.parent.parent.parent.parent.parent.GetComponent<AIController>().data;
            aiData.agent.speed *= 1.6f;
            aiData.agent.acceleration *= 1.6f;
        }
        catch (NullReferenceException e)
        {
            Debug.LogWarning($"{e.Message} | AIController isn't on this gruttel's parent object. Ignore this message if this was an intentional action.");
            Destroy(this);
        }
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
