using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.Gruttel
{
    using Personalities;
    using Inventory;
    public class GruttelReference : MonoBehaviour
    {
        public GruttelData data;
        public PersonalityLists personalityList;
        public GruttelMeshes meshList;
        public SkinnedMeshRenderer meshRenderer;
        public GameObject model;
        public GruttelType gruttelType;

        private void Start()
        {
            data = new GruttelData(this, gruttelType);
            data.meshList = meshList;
        }

        public void UpdateMesh(GruttelMeshInfo meshInfo)
        {
            Destroy(model);
            model = Instantiate(meshInfo.mesh, this.transform);

            Animator anim = model.GetComponent<Animator>();

            GetComponent<AnimationController>().anim = anim;

            Inventory inv = GetComponent<Inventory>();

            inv.holdPosition = model.GetComponentInChildren<TrashHoldPosition>().transform;
            inv.animator = anim;
        }
    }
}