using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

[CreateAssetMenu(fileName = "LevelSettings", menuName = "ScriptableObjects/GameplayLoop/LevelSettings", order = 1)]
public class LevelSettings : ScriptableObject {
    public int numberOfGruttels;
    public Scene levelScene;
}