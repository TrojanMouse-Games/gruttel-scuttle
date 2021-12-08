using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using CassyScripts.GameController;
public class CyclesUI : MonoBehaviour{
        [SerializeField]  Text cycle, stage;

        GameController gameController;

        private void Start() {
            gameController = GameObject.FindObjectOfType<GameController>();
        }
        private void Update() {
            cycle.text = $"Cycle: {gameController.cycleIndex + 1}";
            stage.text = $"Stage: {gameController.GetSettings()[gameController.cycleIndex].stages[Mathf.FloorToInt(Mathf.Clamp(gameController.stageIndex-1, 0, Mathf.Infinity))].stageName}";
        }
}
