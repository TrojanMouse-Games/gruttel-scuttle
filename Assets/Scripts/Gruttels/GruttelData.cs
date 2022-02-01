using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.Gruttel
{
    [CreateAssetMenu(fileName = "GruttelData", menuName = "ScriptableObjects/Gruttel/Data")]
    public class GruttelData : ScriptableObject
    {
        [Header("References")]
        public GruttelReference reference;
        public GruttelMeshList meshList;

        [Header("Gruttel Visual Information")]
        public GruttelType type;
        public string nickname;
        public Color baseColor;

        [Header("Gruttel Stats")]
        public int overallStress;


        public GruttelData()
        {
            nickname = "test";
            type = GruttelType.Normal;
        }

        public void UpdateGruttelType(GruttelType _type)
        {
            type = _type;
        }
    }
}