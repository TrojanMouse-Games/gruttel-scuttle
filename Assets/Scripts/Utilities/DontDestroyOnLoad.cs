using UnityEngine;

namespace TrojanMouse.Utils
{
    /// <summary>
    /// Simple util script to stop something being destroyed between scene loads.
    /// USAGE: Place this script on the thing you want to keep between scene transitions.
    /// </summary>
    public class DontDestroyOnLoad : MonoBehaviour
    {
        void Awake()
        {
            DontDestroyOnLoad(this.gameObject);
        }
    }
}

