using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Fungus;

public class FungusGruttelClick : MonoBehaviour

{
    public string Message;
    public Flowchart Flowchart;
    // Update is called once per frame
    void OnMouseDown()
    {
        Fungus.Flowchart.BroadcastFungusMessage(Message);
    }
}
