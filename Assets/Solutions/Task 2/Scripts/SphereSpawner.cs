using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SphereSpawner : MonoBehaviour
{
    [SerializeField] private List<Transform> _spawnPoints = new List<Transform>();
    [SerializeField] private GameObject _sphere;
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Q))
        {
            StartCoroutine(SpawnSphere(0));
        }
        else if (Input.GetKeyDown(KeyCode.W))
        {
            StartCoroutine(SpawnSphere(1));
        }
        else if (Input.GetKeyDown(KeyCode.E))
        {
            StartCoroutine(SpawnSphere(2));
        }
    }

    IEnumerator SpawnSphere(int i)
    {
        GameObject sphere = Instantiate(_sphere, _spawnPoints[i].position, Quaternion.identity);
        yield return new WaitForSeconds(5);
        Destroy(sphere);
    }
}
