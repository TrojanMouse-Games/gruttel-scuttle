using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrojanMouse.GameplayLoop;
public class GameloopResetter : MonoBehaviour
{
    void Awake(){
        GetComponent<GameLoopBT>().Awake();
    }
}
