using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace TrojanMouse.Gruttel
{
    using AI;
    public class AnimationController : MonoBehaviour
    {
        public Animator anim;
        Vector3 previousPos;
        [SerializeField] float smoothingSpeed;
        float velocity, curSpeed;

        private void Start()
        {
            GetComponent<AIController>().animator = anim;
        }

        void Update()
        {
            Vector3 dir = (transform.position - previousPos).normalized;
            curSpeed = Mathf.SmoothDamp(curSpeed, dir.magnitude, ref velocity, smoothingSpeed);
            previousPos = transform.position;
        }
    }
}