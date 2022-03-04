using TrojanMouse.Litter.Region;

namespace TrojanMouse.GameplayLoop
{
    public class IsLitterCleared : GLNode
    {

        // DISCLAIMER: THIS NEEDS TO BE UPDATED TO INSTEAD CHECK TO SEE IF LITTER HAS BEEN RECYCLED
        public override NodeState Evaluate()
        {
            LitterRegion[] regions = RegionHandler.current.GetRegions(RegionType.LITTER_REGION);
            int childCount = 0;
            foreach (LitterRegion region in regions)
            {
                childCount += region.transform.childCount;
            }

            if (childCount <= 0/*INSTEAD JUST CHECK TO SEE IF IT ALL HAS BEEN RECYCLED!!!*/)
            {
                return NodeState.SUCCESS;
            }
            return NodeState.FAILURE;
        }
    }
}