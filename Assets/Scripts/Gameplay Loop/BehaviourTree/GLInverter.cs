namespace TrojanMouse.GameplayLoop{   
    public class GLInverter : GLNode{
        protected GLNode node;

        public GLInverter(GLNode _node){ this.node = _node; }
        public override NodeState Evaluate(){
            switch(node.Evaluate()){
                case NodeState.RUNNING:                        
                    return NodeState.RUNNING;
                case NodeState.SUCCESS:
                    return NodeState.FAILURE;
                case NodeState.FAILURE:                        
                    return NodeState.SUCCESS;                   
                default:
                    break;
            }
            return NodeState.FAILURE;
        }
    }
}