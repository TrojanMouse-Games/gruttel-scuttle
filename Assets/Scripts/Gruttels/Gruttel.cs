using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.Gruttel {

    public class Gruttel {
        public enum Gender {
            Male,
            Female
        }

        [CreateAssetMenu(fileName = "GruttelData", menuName = "ScriptableObjects/Gruttel/GruttelData", order = 1)]
        public class Data : ScriptableObject {
            public GruttelBaseType baseType;
            public string gruttelName;
            public Gruttel.Gender gender;
            public Color baseColor;
            public int overallStress;
        }
    }

}