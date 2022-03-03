using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrojanMouse.AI;
using FMODUnity;
using TrojanMouse.StressSystem;

public class DistractionModule : MonoBehaviour
{
    public AIController aIController;

    public bool beingDirected;
    public bool distracted;
    public LayerMask litterLayerMask;
    public GameObject distractionMarker;
    public int distractionChance;
    public Animator animator;
    public EventReference distractedSound;
    public EventReference undistrcatedSound;

    bool useWeightedStressbar = false; // ENABLE THIS TO HAVE THE WEIGHTED STRESS SYSTEM

    private void Start()
    {
        distracted = false;
        distractionMarker.SetActive(false);
        StartCoroutine(GenerateDistractionChance());
    }

    private void Update() {
        if (!distracted)
        {
            distractionMarker.SetActive(false);
        }
    }

    private void OnDisable() {
        
    }

    public IEnumerator GenerateDistractionChance(){
        int randomWait = UnityEngine.Random.Range(5, 20);
        yield return new WaitForSeconds(randomWait);

        if (useWeightedStressbar){
            float dice = (float)UnityEngine.Random.Range(0, 100) / 100; // GET A RANDOM VALUE BETWEEN (0-1)
            float weight = (float)Stress.current.amountOfLitter / (float)Stress.current.maxLitter; // GATHER A PERCENTAGE OF OVERALL STRESS BETWEEN (0-1)
            if (dice <= weight) { // IF DICE IS LESS THAN THE CURRENT WEIGHT, THEN TRIGGER THE DISTRACTION
                RuntimeManager.PlayOneShot(distractedSound);
                distracted = true;
                animator.SetBool("isDistracted", true);
                distractionMarker.SetActive(true);
                aIController.data.Agent.SetDestination(transform.position);
                aIController.currentState = AIState.Nothing;
            }
        }
        else{
            distractionChance = UnityEngine.Random.Range(0, 5);
            if (distractionChance == 0){
                RuntimeManager.PlayOneShot(distractedSound);
                distracted = true;
                animator.SetBool("isDistracted", true);
                distractionMarker.SetActive(true);
                aIController.data.Agent.SetDestination(transform.position);
                aIController.currentState = AIState.Nothing;
            }
        }

        StartCoroutine(GenerateDistractionChance());
    }
}
