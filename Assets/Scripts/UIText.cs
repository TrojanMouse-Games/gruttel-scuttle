using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIText : MonoBehaviour{
    [SerializeField] GameObject tipBar;
    [SerializeField] Text label;
    float timeTillFade; // THIS WILL BE UPDATED AS TIME PASSES
    float duration;
    public struct tooltips{
        public string tip;
        public float duration;

        public tooltips(string tip, float duration){
            this.tip = tip;
            this.duration = duration;
        }
    }
    public Queue<tooltips> textQueue = new Queue<tooltips>();

    void Update(){
        if(textQueue.Count <= 0 && Time.time > timeTillFade && duration >=0){
            tipBar.SetActive(false);
            return;
        }

        if(Time.time > timeTillFade && textQueue.Count >0){
            tipBar.SetActive(true);
            tooltips tip = textQueue.Dequeue();
            timeTillFade = Time.time + tip.duration;
            duration = tip.duration;
            label.text = tip.tip;
        }
    }
}
