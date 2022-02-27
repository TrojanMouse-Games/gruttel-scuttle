using System.Collections.Generic;

namespace TrojanMouse.GameplayLoop{ 
    public class GLSelector : GLNode{
        protected List<GLNode> nodes = new List<GLNode>();

        public GLSelector(List<GLNode> _nodes){ this.nodes = _nodes; }
        public override NodeState Evaluate(){
            
            foreach(GLNode node in nodes){
                switch(node.Evaluate()){
                    case NodeState.RUNNING:                        
                        return NodeState.RUNNING;
                    case NodeState.SUCCESS:
                        return NodeState.SUCCESS;
                    case NodeState.FAILURE:                        
                        break;                      
                    default:
                        break;
                }
            }            
            return NodeState.FAILURE;
        }
    }
}