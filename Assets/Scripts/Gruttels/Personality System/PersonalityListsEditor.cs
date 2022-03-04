using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace TrojanMouse.Gruttel.Personalities
{
    [CustomEditor(typeof(PersonalityLists))]
    public class PersonalityListsEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();

            PersonalityLists lists = (PersonalityLists)target;
            if (GUILayout.Button("Import List"))
            {
                lists.ImportList();
            }
        }
    }
}