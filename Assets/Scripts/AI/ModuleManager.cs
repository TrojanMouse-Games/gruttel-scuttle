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
    public LitterModule litterModule;

    public MoveWithMouseClick moveWithMouseClick;
    public MoveWithMouseGrab moveWithMouseGrab;

    private AIController aiController;


    private void Start()
    {
        //GameLoop.current.CheckStage += CheckStage; // UN-COMMENT THIS! JUST TO SUPPRESS THE ERROR!
    }

    private void Awake()
    {
        aiController = GetComponent<AIController>();
        if (GameLoopBT.instance != null)
        {
            GameLoopBT.instance.SetAIState += SetState;
        }
    }

    void SetState(EnableAI.AIState state)
    {
        if (!moveWithMouseClick || !moveWithMouseGrab || !distractionModule)
        {
            CheckScripts();
        }
        switch (state)
        {
            case EnableAI.AIState.Enabled: // ENABLE AI
                distractionModule.enabled = true;
                moveWithMouseClick.enabled = true;
                moveWithMouseGrab.enabled = false;
                break;
            case EnableAI.AIState.Disabled: // DISABLE ALL MODULES
                ChangeAllModuleStates(1, false);
                ChangeAllModuleStates(2, false);
                break;
            case EnableAI.AIState.Dragable: // DISABLES ALL BUT GRAB MODULE
                ChangeAllModuleStates(1, false);
                ChangeAllModuleStates(2, false);
                moveWithMouseGrab.enabled = true; // enable this manually, which leaves only the grab module enabled.
                break;
        }


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
            litterModule = gameObject.GetComponent<LitterModule>();
        }
        catch (NullReferenceException err)
        {
            Debug.LogError($"No LitterModule module found on this {this.gameObject.name}, adding one..");
            Debug.LogWarning($"{err.Message}, should be fixed now. Disabling module to avoid errors");
            litterModule = gameObject.AddComponent<LitterModule>();
            litterModule.enabled = false;
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

    /// <summary>
    /// Needs additional work, avoid passing in a true bool for now.
    /// </summary>
    /// <param name="type">Determines what it disables, 1 disable AI movement modules or 2 disable mouse modules</param>
    /// <param name="state">determines whether the AI is enabled or disabled</param>
    public void ChangeAllModuleStates(int type, bool state)
    {
        aiController.currentState = AIState.Nothing;
        switch (type)
        {
            case 1:
            DisableAllAIMovementModules:
                try
                {
                    wander.enabled = state;
                }
                catch (NullReferenceException)
                {
                    Debug.LogError("Couldn't disable the wandering module, trying again...");
                    wander.enabled = false;
                    goto DisableAllAIMovementModules; // Not sure if this is a good way to go about it..
                }

                try
                {
                    patrol.enabled = state;
                }
                catch (NullReferenceException)
                {
                    Debug.LogError("Tried to stop the patrol module, error occured. Forcefully stopping it.");
                    patrol.enabled = false;
                    goto DisableAllAIMovementModules; // Not sure if this is a good way to go about it..
                }

                try
                {
                    fleeModule.enabled = state;
                }
                catch (NullReferenceException)
                {
                    Debug.LogError("Tried to stop flee module, error occured. Forcefully stopping it.");
                    fleeModule.enabled = false;
                    goto DisableAllAIMovementModules; // Not sure if this is a good way to go about it..
                }

                try
                {
                    distractionModule.enabled = state;
                }
                catch (NullReferenceException)
                {
                    Debug.LogError("Tried to stop distraction module, error occured. Forcefully stopping it.");
                    fleeModule.enabled = false;
                    goto DisableAllAIMovementModules; // Not sure if this is a good way to go about it..
                }
                break;

            // Mouse related stuff
            case 2:
            DisableAllMouseModules:
                try
                {
                    moveWithMouseGrab.enabled = state;
                }
                catch (NullReferenceException)
                {
                    Debug.LogError("Tried to stop grab module, error occured. Forcefully stopping it.");
                    moveWithMouseGrab.enabled = false;
                    goto DisableAllMouseModules; // Not sure if this is a good way to go about it..
                }

                try
                {
                    moveWithMouseClick.enabled = state;
                }
                catch (NullReferenceException)
                {
                    Debug.LogError("Tried to stop click module, error occured. Forcefully stopping it.");
                    moveWithMouseGrab.enabled = false;
                    goto DisableAllMouseModules; // Not sure if this is a good way to go about it..
                }
                break;
            default:
                Debug.LogError("Invalid type was entered. Please enter 1 or 2. Stopping script to avoid errors.");
                break;
        }
    }
}
