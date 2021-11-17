using UnityEngine;
//using FMODUnity;

namespace TrojanMouse.AI.Movement
{
    /// <summary>
    /// Simple class to handle the movement of AI using the mouse. Uses smoothdamp.
    /// Extracted from AIController.cs for performance reason concerning the ray.
    /// </summary>
    public class MoveWithMouseGrab : MonoBehaviour
    {
        #region VARIABLES
        public LayerMask whatToSelect, whatToIgnore; // The two layermasks used for NPC hits.
        public float rayDistance; // How far to fire the ray.

        private Camera mainCam; // The camera to be used for firing the ray.
        private bool grabbing; // Dictates whether the AI has been grabbed.

        // Damping vars
        [SerializeField] private float amountOfSmoothing; // How much the position is smoothed when moving
        private Vector3 posVelocity; // Internal, used for the smooth damp

        RaycastHit hit; // Internal hit variable.
        Transform target; // The currently hit obj.
        Ray worldPoint; // Internal global script wide variable used for the raycast.

        //Audio
        //[SerializeField] private EventReference pickup;
        //[SerializeField] private EventReference drop;


        #endregion

        #region UNITY FUNCTIONS
        private void Start()
        {
            // Get the cam ref
            mainCam = Camera.main;
        }

        public void Update()
        {
            // The current mouse position
            Vector2 mousePos = Input.mousePosition;
            // The current place of the mouse in the world
            worldPoint = mainCam.ScreenPointToRay(mousePos);

            #region MAIN LOGIC
            // Check to see if the mouse has been pressed, if yes, do logic
            if (Input.GetButtonDown("Fire1") && !grabbing && FireRay(whatToSelect, rayDistance))
            {
                //RuntimeManager.PlayOneShot(pickup);
                // Check to see if its an AI
                if (CheckAI())
                {
                    // if yes, save it to a local transform
                    target = hit.transform;
                }
                // Set the state to grabbing
                grabbing = true;
                // Turn off the AI Components
               
                ToggleAIComponents(false, "pickUp");
            }
            else if (grabbing)
            {
                // Check to see if the mouse has been pressed, if yes, do logic 
                if (Input.GetButton("Fire1") && FireRay(whatToIgnore, rayDistance))
                {
                    // Create the offset, and then create the dampened new position.
                    Vector3 offset = new Vector3(0, 3, 0);
                    Vector3 newPos = Vector3.SmoothDamp(target.transform.position, hit.point + offset, ref posVelocity, amountOfSmoothing);

                    // Set the target to the new smoothed position.
                    target.transform.position = newPos;

                    // OTIS ADD AUDIO CODE HERE FOR PICKING UP THE GRUTTLES
                   

                }
                else
                {
                    grabbing = false;
                    // Re-enable the components after dropping the AI.

                    // OTIS ADD AUDIO CODE HERE FOR DROPPING THE GRUTTLES
                    //RuntimeManager.PlayOneShot(drop);

                    ToggleAIComponents(true, "putDown");
                }
            }
            #endregion
        }
        #endregion

        #region OTHER FUNCTIONS
        /// <summary>
        /// Mad wizard formatting with a turnery operator.
        /// checks for whether the hit obj has an AIController.
        /// </summary>
        /// <typeparam name="AIController">The AIController</typeparam>
        /// <returns>if yes returns true, no false</returns>
        private bool CheckAI() => (hit.transform.GetComponent<AIController>()) ? true : false;

        /// <summary>
        /// Changes the state of a few of the AIComps based on the passed in bool and type. pickUp disables things in a different order
        /// and putDown will check for litter aswell
        /// </summary>
        /// <param name="state">The state of the components, if you want to turn them off, pass false or true to enable them.</param>
        /// <param name="type">The type of  disable the code does. Only difference is execution and an extra litter check in the putDown</param>
        private void ToggleAIComponents(bool state, string type)
        {
            AIController aiController = target.GetComponent<AIController>();
            if (type == "pickUp" && aiController)
            {
                aiController.agent.enabled = state;
                aiController.enabled = state;
            }else if (type == "putDown" && aiController)
            {
                aiController.enabled = state;
                aiController.agent.enabled = state;
                aiController.CheckForLitter();
            }
        }

        /// <summary>
        /// Fires out the ray from the worldpoint.
        /// </summary>
        /// <param name="lMask">The layermask to be used.</param>
        /// <param name="rDistance">How far to fire the ray.</param>
        /// <returns></returns>
        bool FireRay(LayerMask lMask, float rDistance)
        {
            return (Physics.Raycast(worldPoint.origin, worldPoint.direction, out hit, rDistance, lMask, QueryTriggerInteraction.Collide)) ? true : false;
        }
        #endregion
    }
}