using System.Collections.Generic;
using System;
using UnityEngine;
using UnityEngine.AI;

/// <summary>
/// Simple class to spawn AI, takes little setup and is relatively
/// efficient, utils Unity's Instantiate method.
/// </summary>
public class AISpawner : MonoBehaviour
{
    // The amount of AI to be spawned, default = 100
    [SerializeField]
    private int amountToSpawn = 100;
    // The amount of currently spawned AI
    private int currentAmount;

    // Two lists, one for tracking the spawned NPCs, the other for what we
    // want to spawn.
    [SerializeField]
    private List<GameObject> spawnedNPCs = new List<GameObject>();
    [SerializeField]
    private List<GameObject> prefabs = new List<GameObject>();

    [SerializeField]
    NavMeshSurface surface;
    [SerializeField]
    private bool rebuildNavMeshOnStart;

    /// <summary>
    /// This function first rebuilds the navmesh, catches errors for that if they appear.
    /// It then spawns the AI if it could build the navmesh.
    /// </summary>
    void Start()
    {
        if (rebuildNavMeshOnStart)
        {
            try
            {
                surface = GameObject.FindGameObjectWithTag("NavMeshSurface").GetComponent<NavMeshSurface>();
                surface.BuildNavMesh();
                Debug.Log("Sucessfully rebuilt navmesh.");
                // Call the spawn at game start
                SpawnAI(amountToSpawn);
            }
            catch (NullReferenceException e)
            {
                Debug.LogError($"No Navmesh has been found! {e.Message}! Please fix by tagging the NavMeshSurface with the correct tag!");
                throw;
            }
        }
    }



    /// <summary>
    /// Simple function to spawn AI depending on whether
    /// the current amount of spawned AI is less than the Max amount
    /// </summary>
    /// <param name="amountToSpawn">This is the amount you want to spawn,
    /// we pass the variable amountToSpawn</param>
    void SpawnAI(int amountToSpawn)
    {
        // Check to see if the current amount of AI is less than how many we need to spawn
        if (currentAmount < amountToSpawn)
        {
            // if i is less than the amount we want to spawn, iterate through the loop again.
            for (int i = 0; i < amountToSpawn; i++)
            {
                // Create a random index to spawn
                int randomIndex = UnityEngine.Random.Range(0, prefabs.Count);
                GameObject NPC = Instantiate(prefabs[randomIndex], transform.position, transform.rotation);
                NPC.name = $"NPC{i.ToString()}";
                spawnedNPCs.Add(NPC);
                currentAmount++;
            }
        }

    }
}
