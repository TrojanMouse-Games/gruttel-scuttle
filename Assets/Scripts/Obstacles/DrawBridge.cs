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
        public float timeUntilFirstBridgeRaise, timeUntillBridgeRaise;
        Vector3 originalRotation, originalPosition;

        /// <summary>
        /// Start is called on the frame when a script is enabled just before
        /// any of the Update methods is called the first time.
        /// </summary>
        void Start()
        {
            RaiseBridge(timeUntilFirstBridgeRaise);
            // Save original postion
            originalPosition = pivot.transform.localPosition;
            originalRotation = pivot.transform.localRotation.eulerAngles;
        }

        /// <summary>
        /// Update is called every frame, if the MonoBehaviour is enabled.
        /// </summary>
        void Update()
        {
            if (!isRaised)
            {
                RaiseBridge(timeUntillBridgeRaise);
            }
        }

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
            //StopCoroutine(RaiseBridgeAfterTime(0f));
            if (isRaised)
            {
                // Move to upwards pos
                pivot.transform.localRotation = Quaternion.Euler(positionToRotateTo);
                pivot.transform.localPosition = positionToMoveTo;
            }
            else if (!isRaised)
            {
                // Move to original pos
                pivot.transform.localRotation = Quaternion.Euler(originalRotation);
                pivot.transform.localPosition = originalPosition;

            }
        }

        /// <summary>
        /// Raises the bridge, starts a coroutine to pick when based on the passed in float
        /// </summary>
        /// <param name="timeUntilRaise">How long to wait before raising the bridge</param>
        void RaiseBridge(float timeUntilRaise)
        {
            isRaised = true;
            StartCoroutine(RaiseBridgeAfterTime(timeUntilRaise));
        }

        /// <summary>
        /// This will raise the bridge after the passed in about of time
        /// </summary>
        /// <param name="time">the amount of time that needs to be passed before it raises</param>
        /// <returns></returns>
        IEnumerator RaiseBridgeAfterTime(float time)
        {
            float randomTime = Random.Range(0, time);
            yield return new WaitForSeconds(randomTime);
            MoveBridge();
        }
    }
}

