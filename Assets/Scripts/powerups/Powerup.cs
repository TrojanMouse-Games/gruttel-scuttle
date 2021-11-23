using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.PowerUps{
    public class Powerup : MonoBehaviour{
        [SerializeField] PowerupType type;
        public PowerupType Type{ 
            get { 
                return type; 
            }
            set{
                type = value;
            }
        }
    }
    public enum PowerupType{
        NORMAL,
        BUFF,
        IRRADIATED
    }
}