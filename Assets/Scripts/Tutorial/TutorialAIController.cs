using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using TrojanMouse.Inventory;
using TrojanMouse.PowerUps;

/// <summary>
/// Class used for controlling the gruttels in the Tutorial scene, hardcoded for the sake of time
/// </summary>
public class TutorialAIController : MonoBehaviour
{
    public NavMeshAgent agent;
    public LayerMask litterLayerMask;
    [SerializeField] float pickupRange;
    public bool holdingLitter;
    public Animator animator;

    private Inventory inventory; // reference to the equipper script
    private Equipper equipper; // reference to the equipper script
    private Powerup powerUp; // reference to the equipper script
    Vector3 lastPosition;

    /// <summary>
    /// Update is called every frame, if the MonoBehaviour is enabled.
    /// </summary>
    void Update()
    {
        animator.SetBool("isMoving", ((transform.position - lastPosition).magnitude > 0) ? true : false);
    }

    /// <summary>
    /// LateUpdate is called every frame, if the Behaviour is enabled.
    /// It is called after all Update functions have been called.
    /// </summary>
    void LateUpdate()
    {
        lastPosition = transform.position;
    }

    /// <summary>
    /// Moves the gruttel to a point
    /// </summary>
    public void MoveToPoint(GameObject destination)
    {
        Debug.Log("Method Called, moving gruttel");

        StartCoroutine(Move(destination.transform.position));
    }

    public void Wait(float time)
    {
        StartCoroutine(Delay(time));
    }

    IEnumerator Move(Vector3 destination)
    {
        agent.SetDestination(destination);
        if (agent.remainingDistance <= .1f)
        {
            yield return new WaitForSeconds(.1f);
            Debug.Log("waited");
        }
    }

    IEnumerator Delay(float timeToWait)
    {
        yield return new WaitForSeconds(timeToWait);
    }

    void pickupLitter()
    {
        // if the inventory has slots left
        if (inventory.HasSlotsLeft())
        {
            // Pass in the last arg, this is the place we're telling the gruttle to go to, moveToClick.hit.point
            //Region closestRegion = Region_Handler.current.GetClosestRegion(Region.RegionType.LITTER_REGION, transform.position); // FROM ORIGINAL POINT
            //if (!closestRegion)
            //{
            //    return AIState.Nothing;
            //}
            Collider[] litter = Physics.OverlapSphere(transform.position, 15, litterLayerMask);
            LitterObject litterType = null;
            Transform litterObj = null;

            foreach (Collider obj in litter)
            {
                LitterObject type = obj.GetComponent<LitterObjectHolder>().type;
                bool cantPickup = powerUp.Type != type.type && type.type != PowerupType.NORMAL;

                if (!cantPickup)
                {
                    agent.SetDestination(obj.transform.position);
                    litterType = type;
                    litterObj = obj.transform;
                    break;
                }
            }
            if (litterType && Mathf.Abs((litterObj.position - transform.position).magnitude) <= pickupRange)
            {
                equipper.PickUp(litterObj, powerUp.Type, litterType);
            }
        }
    }

    private void OnDrawGizmosSelected()
    {
        // JOSHS STUFF
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, pickupRange);
    }

    public void SetGameObject(GameObject obj)
    {
        obj.SetActive(!obj.activeInHierarchy);
    }
}
