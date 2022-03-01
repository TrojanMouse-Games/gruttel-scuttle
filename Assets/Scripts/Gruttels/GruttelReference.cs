using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.Gruttel
{
    public class GruttelReference : MonoBehaviour
    {
        public GruttelData data;
        public PersonalityLists personalityList;

        private void Start()
        {
            data = new GruttelData(this);
        }
    }
}