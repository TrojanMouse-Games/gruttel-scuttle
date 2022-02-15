using System.Collections.Generic;

namespace TrojanMouse.GameplayLoop{ 
    public class GLSequence : GLNode{
        protected List<GLNode> nodes = new List<GLNode>();

        public GLSequence(List<GLNode> _nodes){ this.nodes = _nodes; }
        public override NodeState Evaluate(){
            bool isAnyRunning = false;
            foreach(GLNode node in nodes){
                switch(node.Evaluate()){
                    case NodeState.RUNNING:
                        isAnyRunning = true;
                        break;
                    case NodeState.SUCCESS:
                        break;
                    case NodeState.FAILURE:                        
                        return NodeState.FAILURE;                        
                    default:
                        break;
                }
            }            
            return (isAnyRunning)? NodeState.RUNNING : NodeState.SUCCESS;
        }
    }
}