using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine;

namespace TrojanMouse.Gruttel
{
    [CreateAssetMenu(fileName = "GruttelMeshList", menuName = "ScriptableObjects/Gruttel/MeshList")]
    public class GruttelMeshList : ScriptableObject
    {
        [Serializable]
        public struct GruttelMesh
        {
            public GruttelType type;
            public Mesh mesh;
        }

        public readonly GruttelMesh[] meshes;
        private static Dictionary<GruttelType, Mesh> meshList;


        public Mesh GetMesh(GruttelType type)
        {
            if (meshList == null || meshList.Count < meshes.Length)
            {
                GenerateMeshList();
            }

            return meshList[type];
        }

        private void GenerateMeshList()
        {
            meshList = new Dictionary<GruttelType, Mesh>();
            foreach (GruttelMesh m in meshes)
            {
                meshList.Add(m.type, m.mesh);
            }
        }
    }

}