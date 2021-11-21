using System.Collections;
using System.Collections.Generic;
using UnityEngine;


// MADE BY JOSHUA THOMPSON
namespace TrojanMouse.Inventory {
    public class TestEquipper : MonoBehaviour{
        [SerializeField] LayerMask whatIsGruttel;
        [SerializeField] float distToPickUp;

        [SerializeField] float cooldown;
        float _cooldown;


        void Start(){
            _cooldown = cooldown;
        }

        void Update(){
            Collider[] collider = Physics.OverlapSphere(transform.position, distToPickUp, whatIsGruttel);
            if(collider.Length >0){
                _cooldown -= (_cooldown >0)? Time.deltaTime : 0;
                
                if(_cooldown > 0){
                    return;
                }
                LitterObjectHolder holder = GetComponent<LitterObjectHolder>();
                if(holder.parent != transform.parent){
                    collider[0].GetComponent<Equipper>().PickUp(transform, holder.type); 
                }
                else{
                    collider[0].GetComponent<Equipper>().Drop();
                }
            }
        }


        private void OnDrawGizmosSelected() {
            Gizmos.DrawWireSphere(transform.position, distToPickUp);
        }
    }
}