using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrojanMouse.AI;

public class DistractionModule : MonoBehaviour
{
    public AIData data;
    AIController aIController;

    public bool beingDirected;
    public bool distracted;
    public LayerMask litterLayerMask;
    public float timer = 0f; // Internal timer used for state changes and tracking.
    public GameObject distractionMarker;
    public int distractionChance;
    public Animator animator;

    private void Start()
    {
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
        int randomWait = UnityEngine.Random.Range(5, 20);
        yield return new WaitForSeconds(randomWait);
        distractionChance = UnityEngine.Random.Range(0, 5);
        if (distractionChance == 0)
        {
            distracted = true;
            animator.SetBool("isDistracted", true);
            distractionMarker.SetActive(true);
            data.Agent.SetDestination(transform.position);
            aIController.currentState = AIState.Nothing;
        }
        StartCoroutine(GenerateDistractionChance());
    }
}
