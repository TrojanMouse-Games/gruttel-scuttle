using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.PowerUps
{
    public class Powerup : MonoBehaviour
    {
        [SerializeField] PowerupType type; // PRIVATE VALUE WHICH CAN ONLY BE SET IN THIS SCRIPT
        public PowerupType Type
        { // PUBLIC VALUE WHICH CAN ONLY BE READ FROM
            get
            {
                return type;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="newType"></param>
        public void UpdateType(PowerupType newType)
        {
            UpdateType(newType, null, null);
        }

        /// <summary>THIS FUNCTION UPDATES THE VALUE OF THE POWERUP TYPE THIS SCRIPT IS ATTACHED TO</summary>
        /// <param name="newType">VALUE YOU WISH TO UPDATE THE OBJ TO</param>
        public void UpdateType(PowerupType newType, Mesh mesh, Material mat)
        {
            type = newType;
            Color color = Color.white;

            if (mesh == null)
            {
                return;
            }

            SkinnedMeshRenderer meshRenderer = GetComponentInChildren<SkinnedMeshRenderer>();

            meshRenderer.sharedMesh = mesh;
            meshRenderer.material = mat;
            //TEMPORARY CODE -- PELASE REMOVE WHEN RIGGED VERSION COMES OUT
            transform.GetComponent<Animator>().enabled = false;
            transform.GetChild(8).rotation = Quaternion.identity;
            transform.GetChild(8).localPosition = new Vector3(0, 1.25f, 0);

            meshRenderer.materials[0].SetColor("_BaseColor", color);
        }
    }

    // THIS HOLDS THE VALUES ALL POWERUPS WILL INHERIT FROM
    public enum PowerupType
    {
        NORMAL,
        BUFF,
        IRRADIATED
    }
}