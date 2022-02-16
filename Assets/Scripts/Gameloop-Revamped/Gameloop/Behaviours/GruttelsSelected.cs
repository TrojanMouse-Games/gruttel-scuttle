using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.GameplayLoop{   
    public class GruttelsSelected : GLNode{
        HashSet<Transform> gruttelsSelected = new HashSet<Transform>();
        int gruttelsNeededToSelect;
        float maxDistance;
        LayerMask whatIsGruttel;
        Camera cam;

        Transform villageFolder, playFolder;
        public GruttelsSelected(int quantity, float maxRayDistance, LayerMask whatIsGruttel, Camera cam, Transform villageFolder, Transform playFolder){
            this.gruttelsNeededToSelect = quantity;
            this.maxDistance = maxRayDistance;
            this.whatIsGruttel = whatIsGruttel;
            this.cam = cam;
            this.villageFolder = villageFolder;
            this.playFolder = playFolder;
        } 
        public override NodeState Evaluate(){
            // IF NOT X AMT OF GRUTTELS ARE NOT SELECTED RETURN FAILURE OTHERWISE RETURN SUCCESS!
            if(gruttelsSelected.Count >= gruttelsNeededToSelect){
                return NodeState.SUCCESS;
            }            
            RaycastHit hit;
            if(Physics.Raycast(GameLoopBT.GetMouse(cam), out hit, maxDistance, whatIsGruttel)){
                if(!gruttelsSelected.Contains(hit.collider.transform)){
                    gruttelsSelected.Add(hit.collider.transform);
                    hit.collider.transform.localScale = Vector3.one * 1.25f;          
                    hit.collider.transform.parent = playFolder;          
                }
                else{
                    gruttelsSelected.Remove(hit.collider.transform);
                    hit.collider.transform.localScale = Vector3.one;           
                    hit.collider.transform.parent = villageFolder;         
                }
            }                   
            return NodeState.FAILURE;
        }
    }
}