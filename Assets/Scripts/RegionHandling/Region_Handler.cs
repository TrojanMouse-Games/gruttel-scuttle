using System.Collections.Generic;
using System.Collections;
using UnityEngine;
using System;

// DEVELOPED BY JOSH THOMPSON
namespace TrojanMouse.RegionManagement
{
    public class Region_Handler : MonoBehaviour{

        public static Region_Handler current; // SINGLETON
        private void Awake() {
            #region SINGLETON CREATION
            if (current){
                Destroy(this);
                return;
            }
            current = this;
            #endregion
        }

        #region SINGLE-TIME  VARIABLES
        bool hasBooted;
        public bool HasBooted { 
            get { 
                return hasBooted; 
            } 
        }
        #endregion
        private void Update(){
            #region SETUP
            if (!hasBooted){ // This variable is in place so that it is only called once. 
                hasBooted = true;
                _PingRegions(); // THIS FUNCTION INVOKES ALL REGIONS IN A SCENE WHICH ULTIMATELY CALL BACK TO THIS SCRIPT TO LET IT KNOW THAT IT EXISTS AND THUS USED TO SPAWN LITTER TO
            }
            #endregion
        }

        #region REGION MANIPULATION
        Dictionary<Region.RegionType, List<Region>> regions = new Dictionary<Region.RegionType, List<Region>>();

        ///<summary>This function returns all regions of a given passed type e.g. 'Litter_Region'</summary>
        public Region[] GetRegions(Region.RegionType _type){ 
            return (!regions.ContainsKey(_type)) ? null : regions[_type].ToArray();
        } // QUERY FUNCTION, PASS IN A TYPE YOU WANT AND IT WILL OUTPUT ALL REQUESTED REGIONS OF A TYPE


        /// <summary>THIS FUNCTION GETS THE CLOSEST REGION TO A GIVEN POSITION</summary>
        /// <param name="_type">The litter type you request to find</param>
        /// <param name="position">the origin position from the closest region will be found upon</param>
        /// <returns>THE CLOSEST REGION TO A GIVEN POSITION</returns>
        public Region GetClosestRegion(Region.RegionType _type, Vector3 position){
            Region[] regionsOfType = regions[_type].ToArray();
            Region closestRegion = null;

            float closestNumber = Mathf.Infinity;
            foreach (Region region in regionsOfType){
                float curDist = (region.transform.position - position).magnitude;
                if (curDist < closestNumber){
                    if (_type == Region.RegionType.LITTER_REGION && region.transform.childCount <= 0){
                        continue;
                    }
                    closestNumber = curDist;
                    closestRegion = region;
                }
            }
            return closestRegion;
        }
        #endregion
        #region REGION COLLECTION
        // THIS REGION IS PURELY FOR COLLECTING REGIONS IN THE HIERARCHY AND STORING THEM IN THIS SCRIPT FOR LATER MANIPULATION
        public event Action PingRegions;
        ///<summary>THIS WILL TRIGGER ALL REGIONS TO CALLBACK AND TELL US INFORMATION ABOUT ITSELF</summary>
        public void _PingRegions() => PingRegions?.Invoke();
        ///<summary>MANUALLY ADDS A GIVEN REGION TO OUR REGION DICTIONARY</summary>
        public void AddRegion(Region _region){
            if (regions.ContainsKey(_region.Type) && !regions[_region.Type].Contains(_region)){ // IF THERE IS A DICTIONARY HOLDING THE CORRECT REGION TYPE THEN ADD SUCH VALUE
                regions[_region.Type].Add(_region);
            }
            else{
                regions.Add(_region.Type, new List<Region> { _region }); // CREATES A NEW DICTIONARY KEY AND ADDS THE REGION TO IT
            }
        }
        #endregion







        // IN-EDITOR VISUAL DISPLAY - OF REGIONS
        private void OnDrawGizmosSelected(){
            if (!Application.isEditor) { return; }
            foreach (Transform child in transform){
                Region region = child.GetComponent<Region>();
                Gizmos.color = region.DebugColour;

                Gizmos.DrawWireSphere(child.position, .1f);
            }
        }
    }
}