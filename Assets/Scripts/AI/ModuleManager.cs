using System;
using UnityEngine;
using TrojanMouse.AI;
using TrojanMouse.AI.Movement;

public class ModuleManager : MonoBehaviour
{
    public WanderModule wander;
    public Patrol patrol;
    public FleeModule fleeModule;
    private AIController aiController;

    private void Start()
    {
        aiController = gameObject.GetComponent<AIController>();
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
    }
}
