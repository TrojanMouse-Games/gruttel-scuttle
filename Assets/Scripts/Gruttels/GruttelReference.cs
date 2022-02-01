using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.Gruttel
{
    public class GruttelReference : MonoBehaviour
    {
        public GruttelData data;

        private void Start()
        {
            if (data == null)
            {
                data = new GruttelData();
            }
            data.reference = this;
        }
    }
}