using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// DEVELOPED BY JOSH THOMPSON
namespace TrojanMouse.BallisticTrajectory{
    public class Ballistics : MonoBehaviour{
        public Transform shooterObj; // THE POINT AT WHICH PROJECTILES WILL SPAWN - AND THUS SHOOT OUT OF (THIS WILL BE THE PART WHICH AIMS UP/DOWN)
        [SerializeField] bool artillaryMode; // IF DISABLED, IT WILL ENTER DIRECT SHOOTING MODE AND THEREFORE WILL SHOOT LIEK A GUN
        

        public static Ballistics current; // SINGLETON SO THAT ANY SCRIPT CAN EASILY ACCESS THIS SCRIPT

        private void Awake(){            
            current = this;
        }

        ///<summary>THIS FUNCTION WILL ROTATE THIS TRANSFORM ON THE Y AXIS</summary>
        public bool RotateShooter(Vector3 targetPos, float speed){           
            // GET ANGLES
            float? highAngle = 0f,
                  lowAngle = 0f;
            CalculateAngleToHitTarget(ref highAngle, ref lowAngle, targetPos, speed);


            // LOW ANGLE -- DIRECT SHOT
            // HIGH ANGLE -- ARTILLARY TYPE SHOT     
            float? angle = (artillaryMode) ? highAngle : lowAngle; // "float?" - Means that the float can contain a 'null' value which is handy when comparing values ||| SIMPLY A FLIP FLOP IF CONDITION WHICH SETS ANGLE TO X ANGLE BASED ON THE BOOLEAN
            if(angle != null){
                shooterObj.localEulerAngles = new Vector3(360f - (float)angle, 0f, 0f); // ROTATES THE GUN UP/DOWN
                transform.LookAt(targetPos); // FORCES THIS TRANSFORM TO FACE THE TARGET VECTOR
                transform.eulerAngles = new Vector3(0f, transform.rotation.eulerAngles.y, 0f); // RESETS THE X/Z ANGLES SO THAT IT ONLY ROTATES ON THE Y AXIS
            }
            else{
                Debug.LogError("SHOOTER OUT OF REACH");
                return false;                
            }
            return true;
        }

        ///<summary>THIS FUNCTION WILL ROTATE THE SHOOTER OBJECT ON THE X/Z AXIS - WILL RETURN A HIGH/LOW ANGLE</summary>
        void CalculateAngleToHitTarget(ref float? thetaA, ref float? thetaB, Vector3 targetPos, float speed){
            float v = speed; // VELOCITY
            Vector3 targetVec = targetPos - shooterObj.position; // DIRECTION

            float y = targetVec.y; // VERTICAL DISTANCE
            targetVec.y = 0f; // RESETS IT SO WE CAN CALCULATE THE HORIZONTAL DISTANCE OF X/Z
            float x = targetVec.magnitude; // HORIZONTAL DISTANCE TO TARGET
            float g = 9.81f; // GRAVITY

            // ANGLE CALCULATION
            float vSqr = v * v; // VELOCITY SQUARED
            float underTheRoot = (vSqr * vSqr) - g 
                                * (g * x * x + 2 * y * vSqr);

            if (underTheRoot < 0){
                thetaA = null;
                thetaB = null;
                return;
            }

            float rightSide = Mathf.Sqrt(underTheRoot);
            float top1 = vSqr + rightSide;
            float top2 = vSqr - rightSide;

            float bottom = g * x;

            thetaA = Mathf.Atan2(top1, bottom) * Mathf.Rad2Deg;
            thetaB = Mathf.Atan2(top2, bottom) * Mathf.Rad2Deg;
        }
    }
}
