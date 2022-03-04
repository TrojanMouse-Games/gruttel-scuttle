using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace TrojanMouse.Gruttel
{
    public class AnimationController : MonoBehaviour
    {
        [SerializeField] Animator anim;
        Vector3 previousPos;
        [SerializeField] float smoothingSpeed;
        float velocity, curSpeed;
        void Update()
        {
            Vector3 dir = (transform.position - previousPos).normalized;
            curSpeed = Mathf.SmoothDamp(curSpeed, dir.magnitude, ref velocity, smoothingSpeed);
            previousPos = transform.position;
        }
    }
}