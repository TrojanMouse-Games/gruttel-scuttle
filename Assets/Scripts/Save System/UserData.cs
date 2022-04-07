using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.SaveSystem
{
    using Gruttel;

    /// <summary>
    /// SAVING:
    /// SETTINGS
    /// GRUTTEL DATA
    /// PROGRESSION
    /// CURRENCY
    /// </summary>
    [Serializable]
    public class UserData
    {
        private static UserData data;
        public SettingsData settings;
        public List<GruttelData> gruttels = new List<GruttelData>();
        public ProgressionData progression;


        public static UserData GetSingleton()
        {
            if (data == null)
            {
                data = new UserData();
            }
            return data;
        }

        public void Save()
        {
            string json = JsonUtility.ToJson(GetSingleton());

            Debug.Log(json);
        }

        public static void Load()
        {

        }

        public void AddGruttelData(GruttelData data)
        {
            gruttels.Add(data);
        }
    }

    [Serializable]
    public class SettingsData
    {
        int test = 0;
    }

    [Serializable]
    public class ProgressionData
    {
        int test = 15;
    }
}