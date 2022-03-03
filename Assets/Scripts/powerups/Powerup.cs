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
        public void UpdateType(PowerupType newType, bool changeColour = true){
            type = newType;
            if (!changeColour){
                return;
            }

            Color color = Color.white;
            switch (type){
                case PowerupType.NORMAL:
                    color = Color.white;
                    break;
                case PowerupType.BUFF:
                    color = Color.yellow;
                    transform.localScale = Vector3.one * 1.2f;                    
                    break;
                case PowerupType.IRRADIATED:
                    color = Color.green;
                    transform.localScale = Vector3.one * .8f;
                    break;
            }            
            GetComponentInChildren<SkinnedMeshRenderer>().materials[0].SetColor("_BaseColor", color);            
        }
    }
    
    // THIS HOLDS THE VALUES ALL POWERUPS WILL INHERIT FROM
    public enum PowerupType{
        NORMAL,
        BUFF,
        IRRADIATED
    }
}