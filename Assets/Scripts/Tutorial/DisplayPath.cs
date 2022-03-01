using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

namespace TrojanMouse.Utils
{
    /// <summary>
    /// Directly ported from AIController.cs
    /// Originally written by Matt, updated by Hayley then Josh.
    /// </summary>
    public class DisplayPath : MonoBehaviour
    {
        public void DisplayLineRenderer(NavMeshAgent agent, Vector3 destination)
        {
            LineRenderer lr = GetComponent<LineRenderer>();

            float distance = Vector3.Distance(transform.position, destination);

            if (distance == 0)
            {
                lr.enabled = false;
            }
            else
            {
                lr.enabled = true;
                Vector3[] path = agent.path.corners;
                lr.positionCount = path.Length;
                for (int i = 0; i < path.Length; i++)
                {
                    lr.SetPosition(i, path[i] + new Vector3(0, .5f, 0));
                }
            }
        }
    }

}
