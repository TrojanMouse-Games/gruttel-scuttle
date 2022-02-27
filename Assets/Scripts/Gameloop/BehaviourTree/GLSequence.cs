using System.Collections.Generic;

namespace TrojanMouse.GameplayLoop{ 
    public class GLSequence : GLNode{
        protected List<GLNode> nodes = new List<GLNode>();
        public List<GLNode> realTimeNodes = new List<GLNode>();

        bool isRealtime;
        public GLSequence(List<GLNode> _nodes, bool isRealtime = false){ 
            this.nodes = _nodes; 
            this.realTimeNodes = _nodes;
            this.isRealtime = isRealtime;
        }
        public override NodeState Evaluate(){
            bool isAnyRunning = false;
            foreach(GLNode node in (!isRealtime)? nodes: realTimeNodes){
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