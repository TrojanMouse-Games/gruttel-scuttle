using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FMODUnity;

namespace TrojanMouse.PowerUps
{
    public class Powerup : MonoBehaviour{
        [SerializeField] PowerupType type; // PRIVATE VALUE WHICH CAN ONLY BE SET IN THIS SCRIPT
        public EventReference eatSoundBuff;
        public EventReference eatSoundIrr;
        public PowerupType Type{ // PUBLIC VALUE WHICH CAN ONLY BE READ FROM
            get{
                return type;
            }            
        }

        /// <summary>THIS FUNCTION UPDATES THE VALUE OF THE POWERUP TYPE THIS SCRIPT IS ATTACHED TO</summary>
        /// <param name="newType">VALUE YOU WISH TO UPDATE THE OBJ TO</param>
        public void UpdateType(PowerupType newType, bool setModel = false, Mesh mesh = null, Material mat = null){
            type = newType;
            Color color = Color.white;
            if (!setModel){
                return;
            }

            
            SkinnedMeshRenderer meshRenderer = GetComponentInChildren<SkinnedMeshRenderer>();

            switch (type){                
                case PowerupType.BUFF:
                    // meshRenderer.sharedMesh = mesh;
                    // meshRenderer.material = mat;
                    // //TEMPORARY CODE -- PELASE REMOVE WHEN RIGGED VERSION COMES OUT
                    // transform.GetComponent<Animator>().enabled = false;
                    // transform.GetChild(8).rotation = Quaternion.identity;
                    // transform.GetChild(8).localPosition = new Vector3(0,1.25f,0);  
                    RuntimeManager.PlayOneShot(eatSoundBuff);

                    color = Color.yellow;
                    transform.localScale = Vector3.one * 1.5f;       
                    break;
                case PowerupType.IRRADIATED:
                    // meshRenderer.sharedMesh = mesh;
                    // meshRenderer.material = mat;
                    // //TEMPORARY CODE -- PELASE REMOVE WHEN RIGGED VERSION COMES OUT
                    // transform.GetComponent<Animator>().enabled = false;
                    // transform.GetChild(8).rotation = Quaternion.identity;
                    // transform.GetChild(8).localPosition = new Vector3(0,1.25f,0);
                    RuntimeManager.PlayOneShot(eatSoundIrr);

                    color = Color.green;
                    transform.localScale = Vector3.one * .75f;
                    break;

                    
            }

            meshRenderer.materials[0].SetColor("_BaseColor", color);       
        }
    }
    
    // THIS HOLDS THE VALUES ALL POWERUPS WILL INHERIT FROM
    public enum PowerupType{
        NORMAL,
        BUFF,
        IRRADIATED
    }
}