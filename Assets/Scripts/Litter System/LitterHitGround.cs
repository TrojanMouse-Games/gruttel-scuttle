using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.Litter
{
    public class LitterHitGround : MonoBehaviour
    {
        public float slowdownPercentage = 0.8f;
        Rigidbody rb;

        // Start is called before the first frame update
        void Start()
        {
            rb = GetComponent<Rigidbody>();
        }

        // Update is called once per frame
        void Update()
        {

        }

        private void OnCollisionEnter(Collision other)
        {
            StartCoroutine(AffectSlowdown());
        }

        private IEnumerator AffectSlowdown()
        {
            yield return new WaitForEndOfFrame();
            rb.velocity *= slowdownPercentage * Time.deltaTime;

            if (rb.velocity != Vector3.zero)
            {
                StartCoroutine(AffectSlowdown());
            }
            else
            {
                Destroy(this);
            }
        }
    }
}