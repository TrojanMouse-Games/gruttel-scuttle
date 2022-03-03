using TrojanMouse.StressSystem;

namespace TrojanMouse.GameplayLoop{ 
    public class EnableStress : GLNode{
         
        bool isEnabled;
        bool hasApplied = false;
        public EnableStress(bool isEnabled){ // CONSTRUCTOR TO PREDEFINE THIS CLASS VARIABLES
            this.isEnabled = isEnabled;
        }
        public override NodeState Evaluate(){
            if(hasApplied){ // MAKES SURE THIS IS ONLY RAN ONCE BY CREATING THIS SAFETY BLANKET
                return NodeState.SUCCESS;
            }   
            Stress.current.startStress = isEnabled;
            hasApplied = true;
            return NodeState.SUCCESS;
        }
    }
}