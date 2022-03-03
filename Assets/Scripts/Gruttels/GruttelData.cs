using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.Gruttel
{
    public class Data
    {
        public GruttelBaseType baseType;
        public string gruttelName;
        public Color baseColor;
        public int overallStress;

        public bool UpdateGruttelType(GruttelBaseType type)
        {
            try
            {
                baseType = type;
            }
            catch
            {
                return false;
            }

            return true;
        }
    }
}