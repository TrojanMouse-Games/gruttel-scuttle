using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.Gruttel {

    [CreateAssetMenu(fileName = "GruttelBaseType", menuName = "ScriptableObjects/Gruttel/GruttelBaseType", order = 1)]
    public class GruttelBaseType : ScriptableObject {
        public GameObject character { get; }
        public Gruttel.Gender gender { get; }
        public Gruttel.Type type { get; }

        public string GetName() {
            return name;
        }
    }
}