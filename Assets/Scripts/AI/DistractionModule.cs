using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrojanMouse.AI;
using FMODUnity;

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

    public IEnumerator GenerateDistractionChance()
    {
        //Debug.Log("I am running");
        int randomWait = UnityEngine.Random.Range(5, 20);
        yield return new WaitForSeconds(randomWait);
        distractionChance = UnityEngine.Random.Range(0, 5);
        if (distractionChance == 0)
        {
            RuntimeManager.PlayOneShot(distractedSound);
            distracted = true;
            animator.SetBool("isDistracted", true);
            distractionMarker.SetActive(true);
            aIController.data.Agent.SetDestination(transform.position);
            aIController.currentState = AIState.Nothing;
        }
        StartCoroutine(GenerateDistractionChance());
    }
}
