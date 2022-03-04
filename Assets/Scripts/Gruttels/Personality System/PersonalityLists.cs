using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

namespace TrojanMouse.Gruttel.Personalities
{
    [CreateAssetMenu(fileName = "PersonalityLists", menuName = "ScriptableObjects/Gruttel/PersonalityLists")]
    public class PersonalityLists : ScriptableObject
    {
        public string resourceName;
        public char separator;

        public List<string> listOfNames;
        public List<string> listOfTraits;
        public List<string> listOfNotableAchievements;
        public List<string> listOfPrimaryBios;
        public List<string> listOfSecondaryBios;
        public List<string> listOfTertiaryBios;

        public Vector2Int traitsMinMax;

        private List<List<string>> lists;

        public void ImportList()
        {
            // create new lists - this avoids adding to the old lists
            lists = new List<List<string>>();
            listOfNames = new List<string>();
            listOfTraits = new List<string>();
            listOfNotableAchievements = new List<string>();
            listOfPrimaryBios = new List<string>();
            listOfSecondaryBios = new List<string>();
            listOfTertiaryBios = new List<string>();

            // we do this here to make our life easier later
            // THIS MUST BE IN THE SAME ORDER AS THE CSV FILE
            lists.Add(listOfNames);
            lists.Add(listOfTraits);
            lists.Add(listOfNotableAchievements);
            lists.Add(listOfPrimaryBios);
            lists.Add(listOfSecondaryBios);
            lists.Add(listOfTertiaryBios);

            // load the data
            TextAsset dataSet = Resources.Load<TextAsset>(resourceName);
            string[] dataLines = dataSet.text.Split('\n');

            // if the data is 1 entry or less, declare it as an error and stop the function
            if (dataLines.Length <= 1)
            {
                Debug.LogError("There seems to be an error with the file. Please try again?");
                return;
            }

            // start at 1 to ignore the headings
            for (int i = 1; i < dataLines.Length; i++)
            {
                string[] data = dataLines[i].Split(separator);

                for (int d = 0; d < data.Length; d++)
                {
                    Debug.Log(data[d]);
                    // if there is data
                    if (data[d].Length > 1)
                    {
                        // as csv files can't contain commas, replace semi colons with commas
                        lists[d].Add(data[d].Replace(';', ','));
                    }
                }
            }

            // remove all data from lists as its no longer needed
            lists = null;
            dataSet = null;
        }
    }
}