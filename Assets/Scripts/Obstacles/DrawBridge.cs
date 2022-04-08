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

        // Other stuff
        public Vector3 positionToMoveTo, positionToRotateTo;
        public GameObject pivot;
        Vector3 originalRotation, originalPosition;

        /// <summary>
        /// Checks to see if you've clicked on the bridge collider.
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
            }
            else
            {
                // Move to original pos
                pivot.transform.localRotation = Quaternion.Euler(originalRotation);
                pivot.transform.localPosition = originalPosition;
            }
        }
    }
}

