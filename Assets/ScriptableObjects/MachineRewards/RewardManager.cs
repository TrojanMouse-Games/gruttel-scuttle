using UnityEngine;

[CreateAssetMenu(fileName = "", menuName = "ScriptableObjects/MachineRewards/Create Reward", order = 1)]
public class RewardManager : ScriptableObject
{
    public GameObject rewardPrefab;

    public RewardType rewardType;
    public enum RewardType
    {
        ClothingCoins,
        NPCSpecial,
        NanaBetsy,
        StressDecrease
    }
    public int stressReduction;
}