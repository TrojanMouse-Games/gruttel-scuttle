using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.Gruttel
{
    using Personalities;
    using Inventory;
    using AI;
    public class GruttelReference : MonoBehaviour
    {
        public GruttelData data;
        public PersonalityLists personalityList;
        public GruttelMeshes meshList;
        public SkinnedMeshRenderer meshRenderer;
        public GameObject model;
        public GruttelType gruttelType;

        public ParticleSystem smokeParticles;

        private void Start()
        {
            data = new GruttelData(this, gruttelType);
            data.meshList = meshList;
        }

        public void UpdateMesh(GruttelMeshInfo meshInfo, bool isInit)
        {
            if (!isInit)
            {
                smokeParticles.Play();
            }
            Destroy(model);
            model = Instantiate(meshInfo.mesh, this.transform);

            Animator anim = model.GetComponent<Animator>();

            GetComponent<AnimationController>().anim = anim;

            Inventory inv = GetComponent<Inventory>();

            inv.holdPosition = model.GetComponentInChildren<TrashHoldPosition>().transform;
            inv.animator = anim;

            GetComponent<AIController>().animator = anim;
            GetComponent<DistractionModule>().animator = anim;
        }
    }
}