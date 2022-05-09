using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TrojanMouse.Gruttel
{
    using Personalities;

    [System.Serializable]
    public class GruttelData
    {
        [Header("Static Variables")]
        public static List<string> listOfNames;
        public static List<string> listOfTraits;
        public static List<string> listOfNotableAchievements;
        public static List<string> listOfPrimaryBios;
        public static List<string> listOfSecondaryBios;
        public static List<string> listOfTertiaryBios;

        public static bool staticsInitialized = false;

        [Header("References")]
        public GruttelMeshes meshList;
        public GruttelReference gruttelReference;

        [Header("Personality")]
        public string nickname;
        public string notableAchievement;
        public string[] traits;
        public string[] bios;
        public Vector2Int traitsMinMax;


        [Header("Gruttel Visual Information")]
        public GruttelType type;
        public Color baseColor;

        [Header("Gruttel Stats")]
        public int overallStress;


        public GruttelData(GruttelReference reference, GruttelType gruttelType)
        {
            gruttelReference = reference;
            meshList = gruttelReference.meshList;
            PersonalityLists lists = gruttelReference.personalityList;

            traitsMinMax = lists.traitsMinMax;

            if (!staticsInitialized)
            {
                listOfNames = new List<string>(lists.listOfNames);
                listOfTraits = new List<string>(lists.listOfTraits);
                listOfNotableAchievements = new List<string>(lists.listOfNotableAchievements);
                listOfPrimaryBios = new List<string>(lists.listOfPrimaryBios);
                listOfSecondaryBios = new List<string>(lists.listOfSecondaryBios);
                listOfTertiaryBios = new List<string>(lists.listOfTertiaryBios);

                staticsInitialized = true;
            }

            GenerateRandomGruttel();
            UpdateGruttelType(gruttelType);
        }

        public void UpdateGruttelType(GruttelType _type)
        {
            Debug.Log(type);
            Debug.Log(meshList);
            type = _type;
            gruttelReference.UpdateMesh(meshList.GetMeshInfo(type));

            if (type == GruttelType.Buff) {
                gruttelReference.GetComponent<CapsuleCollider>().height *= 2;
                gruttelReference.GetComponent<CapsuleCollider>().radius *= 2;
            }
        }

        public void GenerateRandomGruttel()
        {
            nickname = GetRandomName();
            notableAchievement = GetRandomNotableAchievement();
            traits = GetRandomTraits();
            bios = GetRandomBios();
        }

        public string GetRandomName()
        {
            string name = CutRandomFromList(listOfNames);

            return name;
        }

        public string GetRandomNotableAchievement()
        {
            string notableAchievement = CutRandomFromList(listOfNotableAchievements);

            return notableAchievement;
        }

        public string[] GetRandomTraits()
        {
            int randomTraitAmount = Random.Range(traitsMinMax.x, traitsMinMax.y + 1);

            List<string> traitValues = new List<string>();

            for (int i = 0; i < randomTraitAmount; i++)
            {
                string trait = CutRandomFromList(listOfTraits);

                traitValues.Add(trait);
            }

            return traitValues.ToArray();
        }

        public string[] GetRandomBios()
        {
            List<string> bioValues = new List<string>();

            bioValues.Add(CutRandomFromList(listOfPrimaryBios));

            bioValues.Add(CutRandomFromList(listOfSecondaryBios));

            bioValues.Add(CutRandomFromList(listOfTertiaryBios));

            return bioValues.ToArray();
        }

        /// <summary>
        /// Generate a random value at within the list and remove the value, returning the value removed.
        /// </summary>
        /// <param name="list">The list to remove a value from</param>
        /// <typeparam name="T">Generic Type</typeparam>
        /// <returns>The value at the index</returns>
        public T CutRandomFromList<T>(List<T> list)
        {
            if (list.Count == 0)
            {
                Debug.LogError($"We have run out of to give out. Try generating less Gruttels or adding more traits!");
                return default(T);
            }

            int index = Random.Range(0, list.Count);

            T value = list[index];

            list.RemoveAt(index);

            return value;
        }
    }
}