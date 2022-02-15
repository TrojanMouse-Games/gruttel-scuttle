namespace TrojanMouse.GameplayLoop{   
    public abstract class GLNode{
        protected NodeState state;
        public NodeState State{ get { return state; } }

        public abstract NodeState Evaluate();
    }

    public enum NodeState{
        FAILURE,
        SUCCESS,
        RUNNING
    }
}