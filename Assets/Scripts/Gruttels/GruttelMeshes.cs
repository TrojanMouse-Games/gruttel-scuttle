using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine;

namespace TrojanMouse.Gruttel
{
    [CreateAssetMenu(fileName = "Gruttel Mesh List", menuName = "ScriptableObjects/Gruttel/GruttelMeshList")]
    public class GruttelMeshes : ScriptableObject
    {
        [Serializable]
        public struct GruttelMesh
        {
            public GruttelType type;
            public GameObject mesh;
        }

        public GruttelMesh[] meshes;
        private static Dictionary<GruttelType, GameObject> meshList;

        public GameObject GetMesh(GruttelType type)
        {
            if (meshList == null || meshList.Count < meshes.Length)
            {
                GenerateMeshList();
            }

            return meshList[type];
        }

        private void GenerateMeshList()
        {
            meshList = new Dictionary<GruttelType, GameObject>();
            foreach (GruttelMesh m in meshes)
            {
                meshList.Add(m.type, m.mesh);
            }
        }
    }

}