using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrojanMouse.AI;

public class DistractionModule : MonoBehaviour
{
    public AIController aIController;

    public bool beingDirected;
    public bool distracted;
    public LayerMask litterLayerMask;
    public GameObject distractionMarker;
    public int distractionChance;
    public Animator animator;

    private void Start()
    {
        distracted = false;
        distractionMarker.SetActive(false);
    }

    private void Update() {
        if (!distracted)
        {
            distractionMarker.SetActive(false);
        }
    }

    public IEnumerator GenerateDistractionChance()
    {
        int randomWait = UnityEngine.Random.Range(5, 15);
        yield return new WaitForSeconds(randomWait);
        distractionChance = UnityEngine.Random.Range(0, 5);
        if (distractionChance == 0)
        {
            distracted = true;
            animator.SetBool("isDistracted", true);
            distractionMarker.SetActive(true);
            aIController.data.Agent.SetDestination(transform.position);
            aIController.currentState = AIState.Nothing;
        }
        StartCoroutine(GenerateDistractionChance());
    }
}
