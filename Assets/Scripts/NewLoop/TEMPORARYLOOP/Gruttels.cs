using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

//15/10/21 by Cassy I'm sorry
namespace CassyScripts.Gruttels
{
    [CreateAssetMenu(menuName = "ScriptableObjects/Gruttels", order = 1)]

    public class Gruttels : ScriptableObject
    {
        //name of Gruttel
        public string GruttelName;
        //gender of Gruttel, F for female, M for male
        
        [Serializable]public enum GruttelGender
        {
            Female,
            Male
        }
        public GruttelGender gruttelGender;
        //current power up of Gruttel, currently of None, strong, or radiation proof
        [Serializable]public enum PowerUp
        {
            None,
            Strength,
            RadiationProof
        }
        public PowerUp powerUp;
        //current outfit for Gruttel
        [Serializable]public enum GruttelOutfit
        {
            None,
            Chef,
            Spy,
            Pirate
        }
        public GruttelOutfit gruttelOutfit;
    }
}

