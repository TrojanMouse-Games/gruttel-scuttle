using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Ballistics : MonoBehaviour{
    [SerializeField] Transform targetObj, shooterObj;
    float projectileSpeed{get{return transform.GetChild(0).GetComponent<FireProjectile>().projectileSpeed; }}
    [SerializeField] bool artillaryMode;
    float h; // step size

    private void Awake() {
        h = Time.fixedDeltaTime  * 1f;         
    }

    private void Update() {
        RotateShooter();        
    }


    void RotateShooter(){
        // GET ANGLES
        float? highAngle = 0f, 
              lowAngle = 0f;
        CalculateAngleToHitTarget(ref highAngle, ref lowAngle);

        
        // LOW ANGLE -- DIRECT SHOT
        // HIGH ANGLE -- ARTILLARY TYPE SHOT     
        float angle = (artillaryMode)? (float)highAngle : (float)lowAngle;

        shooterObj.localEulerAngles = new Vector3(360f - angle, 0f, 0f);
        transform.LookAt(targetObj);
        transform.eulerAngles = new Vector3(0f, transform.rotation.eulerAngles.y, 0f);     
    }

    void CalculateAngleToHitTarget(ref float? thetaA, ref float? thetaB){
        float v = projectileSpeed;
        Vector3 targetVec = targetObj.position - shooterObj.position; // DIRECTION

        float y = targetVec.y; // VERTICAL DISTANCE
        targetVec.y = 0f; // RESETS IT SO WE CAN CALCULATE THE HORIZONTAL DISTANCE OF X/Z
        float x = targetVec.magnitude; // HORIZONTAL DISTANCE TO TARGET
        float g = 9.81f; // GRAVITY

        // ANGLE CALCULATION
        float vSqr = v * v;
        float underTheRoot = (vSqr * vSqr) - g * (g * x * x + 2 * y * vSqr);
        
        if(underTheRoot < 0){
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
