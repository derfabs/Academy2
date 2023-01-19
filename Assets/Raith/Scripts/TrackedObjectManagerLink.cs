using UnityEngine.XR.ARSubsystems;
using UnityEngine.XR.ARFoundation;
using System.Collections.Generic;
using UnityEngine;

// Copyright Maximilian Schecklmann 2022
// Made for Fabian Raith
namespace Raith
{
    public class TrackedObjectManagerLink : MonoBehaviour
    {
        [SerializeField] ARTrackedObjectManager _manager;
        [SerializeField] [TextArea] string _debug;
        [Space]
        [SerializeField] TMObject[] prefabs;

        Dictionary<string, TMObject> references;
        Dictionary<string, int> counters;

        void OnEnable()
        {
            _manager.trackedObjectsChanged += OnChange;
            Setup();
        }

        void OnDisable()
        {
            _manager.trackedObjectsChanged -= OnChange;
        }

        void Setup()
        {
            _debug = "Started";

            references = new Dictionary<string, TMObject>();
            counters = new Dictionary<string, int>();
            if (prefabs != null)
                foreach (TMObject tmo in prefabs)
                {
                    if (!references.ContainsKey(tmo.name)) continue;
                    references.Add(tmo.name, tmo);

                    // Create Counter limit
                    if (tmo.countLimit > 0) counters.Add(tmo.name, 0);
                }

            _debug += $"\n+Dictionary finished with {references.Count} entries\n";
        }

        void OnChange(ARTrackedObjectsChangedEventArgs args)
        {
            foreach (ARTrackedObject obj in args.added)
            {
                // Do stuff with the object
                XRReferenceObject XRO = obj.referenceObject;
                if (references.TryGetValue(XRO.name, out TMObject tmo))
                {
                    _debug += $"\nReference found {XRO.name}";

                    // Handle counts
                    if (tmo.countLimit > 0 && counters.TryGetValue(tmo.name, out int count))
                    {
                        if (count >= tmo.countLimit)
                        {
                            _debug += $"\n >Max Count has been reached already";
                            continue;
                        }

                        counters[tmo.name]++;
                    }

                    GameObject go = GameObject.Instantiate(tmo.prefab);
                }

                else _debug += "\nNo reference found";
            }
        }
    }

    [System.Serializable]
    public struct TMObject
    {
        public string name;
        public GameObject prefab;
        [Space]
        [Tooltip("If <= 0: No limit")] public int countLimit;
    }
}