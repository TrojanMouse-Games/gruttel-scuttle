using UnityEngine;

[CreateAssetMenu(fileName = "", menuName = "ScriptableObjects/MachineRewards/Create Reward", order = 1)]
public class RewardManager : ScriptableObject
{
    [Header("Reward and Type")]
    [Tooltip("Add the prefab that you want to be shown and obtained by the player.")]
    public Sprite rewardImage;
    public RewardType rewardType;
    [System.Serializable]
    public enum RewardType
    {
        None = 0,
        ClothingCoins,
        NPCSpecial,
        NanaBetsy,
        StressDecrease
    }
    [Header("Stress Reduction Amount")]
    [Tooltip("Only choose an option if the reward type is Stress Decrease. Small is 10%, Medium is 20%, and Large is 40%.")]
    public StressReduction stressReduction;
    public enum StressReduction
    {
        None = 0,
        Small = 10,
        Medium = 20,
        Large = 40
    }
    public void RewardFunction()
    {
        switch (rewardType)
        {
            case RewardType.ClothingCoins:
                ClothingCoinFunction();
                break;
            case RewardType.NPCSpecial:
                NPCSpecialFunction();
                break;
            case RewardType.NanaBetsy:
                NanaBetsyFunction();
                break;
            case RewardType.StressDecrease:
                StressRedFunction();
                break;
        }
    }
    void ClothingCoinFunction()
    {
        Debug.Log("clothing coin declared");
    }
    void NPCSpecialFunction()
    {
        Debug.Log("npc item declared");
    }
    void NanaBetsyFunction()
    {
        Debug.Log("nana betsy item declared");
    }
    void StressRedFunction()
    {
        Debug.Log("stress red declared");
    }
}