using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FireProjectile : MonoBehaviour
{
    [SerializeField] Vector3 tempTargetPos;
    [SerializeField] GameObject projectile;
    [SerializeField] Transform parent;
    public float projectileSpeed;
    [SerializeField] float reloadSpeed;
    private void Update()
    {
        LaunchAtPos(transform.position, transform.position + tempTargetPos);

    }

    public void LaunchAtPos(Vector3 startPos, Vector3 endPos)
    {

    }

    private void Start()
    {
        StartCoroutine(Fire());
    }

    public IEnumerator Fire()
    {
        GameObject newProjectile = Instantiate(projectile, transform.position, transform.rotation, parent);
        newProjectile.GetComponent<Rigidbody>().velocity = transform.forward * projectileSpeed;

        yield return new WaitForSeconds(reloadSpeed);
        StartCoroutine(Fire());
    }
}
