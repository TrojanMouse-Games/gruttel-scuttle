using System;
using System.Collections;
using System.Collections.Generic;
//using FMODUnity;
using UnityEngine;

namespace TrojanMouse.AI.Movement {
    public class MoveWithMouseClick : MonoBehaviour {
        #region VARIABLES
        [Tooltip("Most of these will self assign")]
        [Header("Public Variables")]
        public Camera mainCam; // Reference to the main camera.
        public LayerMask whatToSelect, whatToIgnore, objectMask; // The two layermasks which dictate what can be clicked on.
        public float rayDistance; // How far to fire the ray.

        public bool directing; // this will be the check to tell the script whether the player has already clicked on an AI.

        // Internal variables
        RaycastHit hit; // Internal hit var.
        Transform selected; // The currently selected obj.
        Ray worldPoint; // Internal global script wide variable used for the raycast.

        private bool awaitingLocationClick; // This is to tell the code that the script that we're waiting for the second user input, I.e telling the AI where to go.

        //Audio
        //[SerializeField] private EventReference firstClick;
        //[SerializeField] private EventReference secondClick;
        #endregion

        #region UNITY FUNCTIONS
        // Start is called before the first frame update
        void Start() {
            //Get the cam ref
            mainCam = Camera.main;
        }

        // Update is called once per frame
        void Update() {
            // The current position of the mouse
            Vector2 mousePos = Input.mousePosition;
            // The current place of the mouse in the world
            worldPoint = mainCam.ScreenPointToRay(mousePos);

            #region MAIN LOGIC
            // Check to see if the mouse has been pressed, if yes, do logic
            if (Input.GetButtonDown("Fire1") && !directing && FireRay(whatToSelect, rayDistance)) {
                //RuntimeManager.PlayOneShot(firstClick);
                // Check to see if the hit obj is an AI
                if (CheckAI()) {
                    // if yes, save it to a local transform
                    selected = hit.transform;
                    //Debug.Log(hit.transform.name);
                    // Set the state to directing, this will make sure the user doesn't click on another AI.
                    directing = true;

                    StartCoroutine(ChangeColorSelect(hit.transform));
                }
                // Toggle anything that needs to be turned off
            } else if (directing) {
                // Now that we've selected an AI to move, we watch for a second click
                if (Input.GetButtonDown("Fire1") && FireRay(objectMask, rayDistance)) {

                    // Move AI to location
                    // Access the targets AI controller
                    AIController aiController = selected.GetComponent<AIController>();

                    // OTIS ADD AUDIO CODE HERE FOR SENDING THE GRUTTLES TO A NEW LOCATION.
                    //RuntimeManager.PlayOneShot(secondClick);

                    // Call the movement function
                    aiController.GotoPoint(hit.point, true);
                    //aiController.CheckForLitter();
                    directing = false;

                    aiController.beingDirected = true;
                    Debug.Log($"{aiController.gameObject.name} is being directed: {aiController.beingDirected}");
                    selected.GetComponent<MeshRenderer>().materials[0].SetColor("_BaseColor", aiController.baseColor);
                }
            }
            #endregion
        }

        IEnumerator ChangeColorSelect(Transform transform) {
            yield return new WaitForSeconds(0.25f);
            transform.GetComponent<MeshRenderer>().materials[0].SetColor("_BaseColor", Color.gray);
        }
        #endregion

        #region OTHER FUNCTIONS
        /// <summary>
        /// Mad wizard formatting with a turnery operator.
        /// checks for whether the hit obj has an AIController.
        /// </summary>
        /// <typeparam name="AIController">The AIController</typeparam>
        /// <returns>if yes returns true, no false</returns>
        private bool CheckAI() {
            if (hit.transform.GetComponent<AIController>() == null) {
                return false;
            }

            Debug.Log($"{hit.transform.name} is distracted: {hit.transform.GetComponent<AIController>().distracted}");
            return !hit.transform.GetComponent<AIController>().distracted;
        }

        /// <summary>
        /// Fires out the ray from the worldpoint.
        /// </summary>
        /// <param name="lMask">The layermask to be used.</param>
        /// <param name="rDistance">How far to fire the ray.</param>
        /// <returns></returns>
        bool FireRay(LayerMask lMask, float rDistance) {
            return (Physics.Raycast(worldPoint.origin, worldPoint.direction, out hit, rDistance, lMask, QueryTriggerInteraction.Collide)) ? true : false;
        }
        #endregion
    }
}