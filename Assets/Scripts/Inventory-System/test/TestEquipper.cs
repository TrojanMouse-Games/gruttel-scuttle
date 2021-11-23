using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrojanMouse.PowerUps;

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
                    _cooldown = cooldown;
                    collider[0].GetComponent<Equipper>().PickUp(transform, collider[0].GetComponent<Powerup>().Type, holder.type); 
                }
                else{
                    _cooldown = cooldown;
                    collider[0].GetComponent<Equipper>().Drop(RegionManagement.Region.RegionType.LITTER_REGION);
                }
            }
        }


        private void OnDrawGizmosSelected() {
            Gizmos.DrawWireSphere(transform.position, distToPickUp);
        }
    }
}