using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.Gruttel
{
    using Personalities;
    using SaveSystem;
    public class GruttelReference : MonoBehaviour
    {
        public GruttelData data;
        public PersonalityLists personalityList;
        public GruttelMeshes meshList;
        public SkinnedMeshRenderer meshRenderer;
        public GameObject model;
        public int index;

        private void Start()
        {
            data = new GruttelData(this);
            data.meshList = meshList;
        }

        public void UpdateMesh(GameObject mesh)
        {
            Destroy(model);
            model = Instantiate(mesh, this.transform);
        }
    }
}