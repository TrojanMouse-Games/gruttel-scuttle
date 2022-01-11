using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimationController : MonoBehaviour
{
   [SerializeField] Animator anim;
   Vector3 previousPos;
    void Update(){
        Vector3 dir = (transform.position - previousPos).normalized;
        anim.SetFloat("speed", dir.magnitude);
        previousPos = transform.position;
    }
}
