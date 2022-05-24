using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FadeOut : MonoBehaviour
{
    private float alpha = 1f;
    public float fadeTime = 1f;

    // Start is called before the first frame update
    void Start()
    {
        StartCoroutine(Fade());
    }

    // Update is called once per frame
    void Update()
    {

    }

    IEnumerator Fade()
    {
        yield return new WaitForEndOfFrame();
        GetComponent<CanvasGroup>().alpha = alpha;
        alpha -= Time.deltaTime * fadeTime;
        if (alpha <= 0f)
        {
            gameObject.SetActive(false);
        }
        else
        {
            StartCoroutine(Fade());
        }
    }
}
