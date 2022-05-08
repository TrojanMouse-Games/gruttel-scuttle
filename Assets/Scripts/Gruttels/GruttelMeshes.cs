using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine;

namespace TrojanMouse.Gruttel
{
    [Serializable]
    public struct GruttelMeshInfo
    {
        public GruttelType type;
        public GameObject mesh;
        public Material material;
    }

    [CreateAssetMenu(fileName = "Gruttel Mesh List", menuName = "ScriptableObjects/Gruttel/GruttelMeshList")]
    public class GruttelMeshes : ScriptableObject
    {
        public GruttelMeshInfo[] meshes;
        private static Dictionary<GruttelType, GruttelMeshInfo> meshList;

        public GruttelMeshInfo GetMeshInfo(GruttelType type)
        {
            if (meshList == null || meshList.Count < meshes.Length)
            {
                GenerateMeshList();
            }

            return meshList[type];
        }

        private void GenerateMeshList()
        {
            meshList = new Dictionary<GruttelType, GruttelMeshInfo>();
            foreach (GruttelMeshInfo m in meshes)
            {
                meshList.Add(m.type, m);
            }
        }
    }

}