using System;
using UnityEngine;
using TrojanMouse.AI;
using TrojanMouse.AI.Movement;
using TrojanMouse.GameplayLoop;

public class ModuleManager : MonoBehaviour
{
    public WanderModule wander;
    public Patrol patrol;
    public FleeModule fleeModule;
    public DistractionModule distractionModule;

    public MoveWithMouseClick moveWithMouseClick;
    public MoveWithMouseGrab moveWithMouseGrab;

    private AIController aiController;

    private void Start()
    {
        aiController = gameObject.GetComponent<AIController>();
        GameLoop.current.CheckStage += CheckStage;
    }

    public void CheckScripts()
    {
        try
        {
            wander = gameObject.GetComponent<WanderModule>();
        }
        catch (NullReferenceException err)
        {
            Debug.LogError($"No wander module found on this {this.gameObject.name}, adding one..");
            Debug.LogWarning($"{err.Message}, should be fixed now. Disabling module to avoid errors");
            wander = gameObject.AddComponent<WanderModule>();
            wander.enabled = false;
        }

        try
        {
            patrol = gameObject.GetComponent<Patrol>();
        }
        catch (NullReferenceException err)
        {
            Debug.LogError($"No patrol module found on this {this.gameObject.name}, adding one..");
            Debug.LogWarning($"{err.Message}, should be fixed now. Disabling module to avoid errors");
            patrol = gameObject.AddComponent<Patrol>();
            try
            {
                patrol.StopPatrol();
            }
            catch (NullReferenceException)
            {
                Debug.LogWarningFormat("Tried to stop patrol, error occured. Forcefully stopping it.");
                patrol.enabled = false;
            }
        }

        try
        {
            fleeModule = gameObject.GetComponent<FleeModule>();
        }
        catch (NullReferenceException err)
        {
            Debug.LogError($"No flee module found on this {this.gameObject.name}, adding one..");
            Debug.LogWarning($"{err.Message}, should be fixed now. Disabling module to avoid errors");
            fleeModule = gameObject.AddComponent<FleeModule>();
            fleeModule.enabled = false;
        }

        try
        {
            distractionModule = gameObject.GetComponent<DistractionModule>();
        }
        catch (NullReferenceException err)
        {
            Debug.LogError($"No distraction module found on this {this.gameObject.name}, adding one..");
            Debug.LogWarning($"{err.Message}, should be fixed now. Disabling module to avoid errors");
            distractionModule = gameObject.AddComponent<DistractionModule>();
            distractionModule.enabled = false;
        }

        try
        {
            moveWithMouseClick = Camera.main.GetComponent<MoveWithMouseClick>();
        }
        catch (NullReferenceException err)
        {
            Debug.LogError($"No MoveWithMouseClick module found on this {Camera.main.gameObject.name}, adding one..");
            Debug.LogWarning($"{err.Message}, should be fixed now. Disabling module to avoid errors");
            moveWithMouseClick = Camera.main.gameObject.AddComponent<MoveWithMouseClick>();
            moveWithMouseClick.enabled = false;
        }

        try
        {
            moveWithMouseGrab = Camera.main.GetComponent<MoveWithMouseGrab>();
        }
        catch (NullReferenceException err)
        {
            Debug.LogError($"No MoveWithMouseGrab module found on this {Camera.main.gameObject.name}, adding one..");
            Debug.LogWarning($"{err.Message}, should be fixed now. Disabling module to avoid errors");
            moveWithMouseGrab = Camera.main.gameObject.AddComponent<MoveWithMouseGrab>();
            moveWithMouseGrab.enabled = false;
        }
    }

    bool poop;
    public void CheckStage(bool state)
    {
        
        if(state){
            //enable distraction
            distractionModule.enabled = true;
            moveWithMouseClick.enabled = true;
            moveWithMouseGrab.ToggleAIComponents(true, "putDown");
            moveWithMouseGrab.enabled = false;
            if(!poop){
                poop = true;
                StartCoroutine(distractionModule.GenerateDistractionChance());
            }
            //Debug.Log("checked");
        }
        else{
            distractionModule.enabled = false;
            moveWithMouseClick.enabled = false;
            moveWithMouseGrab.enabled = true;
            //Debug.Log("checked2");
        }
    }

    public void DisableAllModules()
    {
        aiController.currentState = AIState.Nothing;
    DisableAllModules:
        try
        {
            wander.enabled = false;
        }
        catch (NullReferenceException)
        {
            Debug.LogError("Couldn't disable the wandering module, trying again...");
            wander.enabled = false;
            goto DisableAllModules; // Not sure if this is a good way to go about it..
        }

        try
        {
            patrol.enabled = false;
        }
        catch (NullReferenceException)
        {
            Debug.LogError("Tried to stop the patrol module, error occured. Forcefully stopping it.");
            patrol.enabled = false;
            goto DisableAllModules; // Not sure if this is a good way to go about it..
        }

        try
        {
            fleeModule.enabled = false;
        }
        catch (NullReferenceException)
        {
            Debug.LogError("Tried to stop flee module, error occured. Forcefully stopping it.");
            fleeModule.enabled = false;
            goto DisableAllModules; // Not sure if this is a good way to go about it..
        }

        try
        {
            distractionModule.enabled = false;
        }
        catch (NullReferenceException)
        {
            Debug.LogError("Tried to stop distraction module, error occured. Forcefully stopping it.");
            fleeModule.enabled = false;
            goto DisableAllModules; // Not sure if this is a good way to go about it..
        }
    }
}
