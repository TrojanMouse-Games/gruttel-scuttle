using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.PowerUps
{
    public class Powerup : MonoBehaviour{
        [SerializeField] PowerupType type;        
        public PowerupType Type{
            get{
                return type;
            }
            set{
                type = value;
            }
        }

        public void UpdateType(PowerupType newType){
            type = newType;
            Color color = Color.white;
            switch (type){
                case PowerupType.NORMAL:
                    color = Color.white;
                    break;
                case PowerupType.BUFF:
                    color = Color.yellow;
                    transform.localScale = Vector3.one * 1.5f;                    
                    break;
                case PowerupType.IRRADIATED:
                    color = Color.green;
                    transform.localScale = Vector3.one * .75f;
                    break;
            }

            GetComponentInChildren<SkinnedMeshRenderer>().materials[0].SetColor("_BaseColor", color);
        }
    }
    public enum PowerupType{
        NORMAL,
        BUFF,
        IRRADIATED
    }
}