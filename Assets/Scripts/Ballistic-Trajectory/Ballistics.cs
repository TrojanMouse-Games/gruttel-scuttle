using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// DEVELOPED BY JOSH THOMPSON
namespace TrojanMouse.BallisticTrajectory{
    public class Ballistics : MonoBehaviour{
        public Transform shooterObj;
        //public Vector3 targetPos;
        //public float projectileSpeed = 20f;
        [SerializeField] bool artillaryMode;
        float h; // step size

        public static Ballistics current;

        private void Awake(){
            h = Time.fixedDeltaTime * 1f;
            current = this;
        }

        private void Update(){ 
            //RotateShooter(); 
        }


        public void RotateShooter(Vector3 targetPos, float speed){
            // GET ANGLES
            float? highAngle = 0f,
                  lowAngle = 0f;
            CalculateAngleToHitTarget(ref highAngle, ref lowAngle, targetPos, speed);


            // LOW ANGLE -- DIRECT SHOT
            // HIGH ANGLE -- ARTILLARY TYPE SHOT     
            float? angle = (artillaryMode) ? highAngle : lowAngle;
            if(angle != null){
                shooterObj.localEulerAngles = new Vector3(360f - (float)angle, 0f, 0f);
                transform.LookAt(targetPos);
                transform.eulerAngles = new Vector3(0f, transform.rotation.eulerAngles.y, 0f);
            }
            else{
                Debug.LogError("OUT OF REACH: Brute forcing speed improvement");                
            }
        }

        void CalculateAngleToHitTarget(ref float? thetaA, ref float? thetaB, Vector3 targetPos, float speed)
        {
            float v = speed;
            Vector3 targetVec = targetPos - shooterObj.position; // DIRECTION

            float y = targetVec.y; // VERTICAL DISTANCE
            targetVec.y = 0f; // RESETS IT SO WE CAN CALCULATE THE HORIZONTAL DISTANCE OF X/Z
            float x = targetVec.magnitude; // HORIZONTAL DISTANCE TO TARGET
            float g = 9.81f; // GRAVITY

            // ANGLE CALCULATION
            float vSqr = v * v;
            float underTheRoot = (vSqr * vSqr) - g * (g * x * x + 2 * y * vSqr);

            if (underTheRoot < 0)
            {
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
