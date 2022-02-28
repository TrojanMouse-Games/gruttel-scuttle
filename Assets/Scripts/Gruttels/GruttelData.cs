using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.Gruttel
{

    [System.Serializable]
    public class GruttelData
    {
        [Header("References")]
        public GruttelReference reference;
        public GruttelMeshList meshList;

        [Header("Personality")]
        public string nickname;
        public string notableAchievement;
        public string[] traits;
        public string[] bios;


        [Header("Gruttel Visual Information")]
        public GruttelType type;
        public Color baseColor;

        [Header("Gruttel Stats")]
        public int overallStress;


        public GruttelData(GruttelReference _reference)
        {
            reference = _reference;
            GenerateRandomGruttel();
            type = GruttelType.Normal;
        }

        public void UpdateGruttelType(GruttelType _type)
        {
            type = _type;
        }

        public void GenerateRandomGruttel()
        {
            nickname = GetRandomName();
            notableAchievement = GetRandomNotableAchievement();
            traits = GetRandomTraits(3);
            bios = GetRandomBios();
        }

        public string GetRandomName()
        {

            int i = Random.Range(0, reference.personalityList.listOfNames.Count);

            return reference.personalityList.listOfNames[i];
        }

        public string GetRandomNotableAchievement()
        {
            int i = Random.Range(0, reference.personalityList.listOfNotableAchievements.Count);

            return reference.personalityList.listOfNotableAchievements[i];
        }

        public string[] GetRandomTraits(int numberOfTraits)
        {
            List<string> traitValues = new List<string>();
            List<int> traitIndexes = new List<int>();

            while (traitValues.Count < numberOfTraits)
            {
                int i = Random.Range(0, reference.personalityList.listOfTraits.Count);
                if (!traitIndexes.Contains(i))
                {
                    traitIndexes.Add(i);
                    traitValues.Add(reference.personalityList.listOfTraits[i]);
                }
            }

            return traitValues.ToArray();
        }

        public string[] GetRandomBios()
        {
            List<string> bioValues = new List<string>();

            int i = Random.Range(0, reference.personalityList.listOfPrimaryBios.Count);
            bioValues.Add(reference.personalityList.listOfPrimaryBios[i]);

            i = Random.Range(0, reference.personalityList.listOfSecondaryBios.Count);
            bioValues.Add(reference.personalityList.listOfSecondaryBios[i]);

            i = Random.Range(0, reference.personalityList.listOfTertiaryBios.Count);
            bioValues.Add(reference.personalityList.listOfTertiaryBios[i]);

            return bioValues.ToArray();
        }
    }
}