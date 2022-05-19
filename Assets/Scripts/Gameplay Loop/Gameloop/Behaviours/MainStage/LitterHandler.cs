using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrojanMouse.Litter.Region;
using TrojanMouse.BallisticTrajectory;
using UnityEngine.UI;

namespace TrojanMouse.GameplayLoop
{
    public class LitterHandler : GLNode
    {
        Level level;

        GLSequence spawnManager = new GLSequence(new List<GLNode> { }, true); // CREATE A NEW SEQUENCE FOR ITERATING THROUGH ALL THE WAVES
        public LitterHandler(Level level, UIText uiText)
        { // CONSTRUCTOR TO PREDEFINE THIS CLASS VARIABLES
            int count = 1;
            foreach (Waves wave in level.wavesInLevel)
            { // ITERATES THROUGH EVERY WAVE IN THE LEVEL AND SEARCHES FOR THE THE OBJECTS STATED AS STRINGS IN THE WAVE E.G. THE SHOOTERS, THEN POPULATES THE LISTS
                List<Ballistics> shootersInWave = new List<Ballistics>();
                List<LitterRegion> regionsInWave = new List<LitterRegion>();
                #region POPULATE LISTS
                foreach (string shooterObj in wave.shootersInThisWave)
                {
                    GameObject shooterGObj = GameObject.Find(shooterObj);
                    if (shooterGObj)
                    {
                        shootersInWave.Add(shooterGObj.GetComponent<Ballistics>());
                    }
                }
                foreach (string regionObj in wave.regionsToLandAtInThisWave)
                {
                    GameObject regionGObj = GameObject.Find(regionObj);
                    if (regionGObj)
                    {
                        regionsInWave.Add(regionGObj.GetComponent<LitterRegion>());
                    }
                }
                #endregion
                spawnManager.realTimeNodes.Add(new ChangeUIText(uiText, $"Wave: {count}/{level.wavesInLevel.Length}", -1f));
                spawnManager.realTimeNodes.Add(
                    new SpawnLitter(shootersInWave.ToArray(), regionsInWave.ToArray(), wave.litterToSpawnForWave, wave.timeToSpawnAllLitter, count, level.wavesInLevel.Length) // ADDS THE WAVE TO THE SEQUENCE, FILLING ALL PARAMETERS NEEDED
                );
                spawnManager.realTimeNodes.Add(new Intermission(wave.intermissionBeforeNextWave)); // ADDS AN INTERMISSION TO THE SEQUENCE, UNTIL THE NEXT WAVE STARTS
                count++;
            }
        }
        public override NodeState Evaluate()
        {
            switch (spawnManager.Evaluate())
            {
                case NodeState.SUCCESS:
                    return NodeState.SUCCESS;
                case NodeState.FAILURE:
                    return NodeState.FAILURE;
                case NodeState.RUNNING:
                    return NodeState.RUNNING;
            }
            return NodeState.FAILURE;
        }
    }
}