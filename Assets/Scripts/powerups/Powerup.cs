using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.PowerUps
{
    public class Powerup : MonoBehaviour{
        [SerializeField] PowerupType type; // PRIVATE VALUE WHICH CAN ONLY BE SET IN THIS SCRIPT
        public PowerupType Type{ // PUBLIC VALUE WHICH CAN ONLY BE READ FROM
            get{
                return type;
            }            
        }

        /// <summary>THIS FUNCTION UPDATES THE VALUE OF THE POWERUP TYPE THIS SCRIPT IS ATTACHED TO</summary>
        /// <param name="newType">VALUE YOU WISH TO UPDATE THE OBJ TO</param>
        public void UpdateType(PowerupType newType, bool setModel = false, Mesh mesh = null, Material mat = null){
            type = newType;
            if (!setModel){
                return;
            }

            
            SkinnedMeshRenderer meshRenderer = GetComponentInChildren<SkinnedMeshRenderer>();

            switch (type){                
                case PowerupType.BUFF:                    
                    transform.localScale = Vector3.one * 1.2f;   
                    meshRenderer.materials[0].SetColor("_BaseColor", Color.yellow);                 
                    break;
                case PowerupType.IRRADIATED:
                    meshRenderer.sharedMesh = mesh;
                    meshRenderer.material = mat;
                    break;
            }       
        }
    }
    
    // THIS HOLDS THE VALUES ALL POWERUPS WILL INHERIT FROM
    public enum PowerupType{
        NORMAL,
        BUFF,
        IRRADIATED
    }
}