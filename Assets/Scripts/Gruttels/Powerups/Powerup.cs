using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.Gruttel
{
    public class Powerup : MonoBehaviour
    {
        [SerializeField] public GruttelType powerupType; // PRIVATE VALUE WHICH CAN ONLY BE SET IN THIS SCRIPT

        /// <summary>
        /// 
        /// </summary>
        /// <param name="newType"></param>
        public void UpdateType(GruttelType newType)
        {
            UpdateType(newType, null, null);
        }

        /// <summary>THIS FUNCTION UPDATES THE VALUE OF THE POWERUP TYPE THIS SCRIPT IS ATTACHED TO</summary>
        /// <param name="newType">VALUE YOU WISH TO UPDATE THE OBJ TO</param>
        public void UpdateType(GruttelType newType, Mesh mesh, Material mat)
        {
            powerupType = newType;
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