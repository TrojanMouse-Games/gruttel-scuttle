using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

namespace TrojanMouse.Game.Obstacles
{
    public class DrawBridge : MonoBehaviour
    {
        // This is used to show the bridges state
        public bool isRaised = false;

        // Navmesh References
        NavMeshObstacle navMeshObstacle;

        // Other stuff
        public Vector3 positionToMoveTo, positionToRotateTo;
        public GameObject pivot;
        Vector3 originalRotation, originalPosition;

        /// <summary>
        /// Start is called on the frame when a script is enabled just before
        /// any of the Update methods is called the first time.
        /// </summary>
        void Start()
        {
            navMeshObstacle = gameObject.AddComponent<NavMeshObstacle>();
        }

        /// <summary>
        /// 
        /// </summary>
        private void OnMouseDown()
        {
            isRaised = !isRaised;
            Debug.Log($"Hit the drawbridge, its name is {transform.name}! {isRaised}");

            MoveBridge();
        }

        /// <summary>
        /// Moves the drawbridge upwards.
        /// </summary>
        void MoveBridge()
        {
            if (isRaised)
            {
                // Save original postion
                originalPosition = pivot.transform.localPosition;
                originalRotation = pivot.transform.localRotation.eulerAngles;

                // Move to upwards pos
                pivot.transform.localRotation = Quaternion.Euler(positionToRotateTo);
                pivot.transform.localPosition = positionToMoveTo;

                // Change the mesh
                ChangeNavMesh();
            }
            else
            {
                // Move to original pos
                pivot.transform.localRotation = Quaternion.Euler(originalRotation);
                pivot.transform.localPosition = originalPosition;

                // Change the mesh
                ChangeNavMesh();
            }
        }

        /// <summary>
        /// Changes the navmesh
        /// </summary>
        void ChangeNavMesh()
        {
            navMeshObstacle.carving = !navMeshObstacle.carving;
        }
    }
}

