using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.Gruttel
{
    [CreateAssetMenu(fileName = "GruttelBase", menuName = "ScriptableObjects/Gruttel/Base")]
    public class GruttelBase : ScriptableObject
    {
        public Mesh mesh;
        public GruttelGender gender;
        public GruttelType type;
    }
}