using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using System;

namespace TrojanMouse.PowerUps{
    [Serializable] public class OnInteractWithGruttel : UnityEvent { }

    public class DestroyOnGruttelTouch : MonoBehaviour{
        [Header("This event below could be used to trigger stuff such as animation on a Gruttel")]
        [SerializeField] OnInteractWithGruttel onInteract;

        [SerializeField] LayerMask whatIsGruttel;
        private void OnTriggerEnter(Collider other){
            if (whatIsGruttel == (whatIsGruttel | (1 << other.gameObject.layer))){
                onInteract?.Invoke();
                Destroy(gameObject);
            }
        }
    }
}