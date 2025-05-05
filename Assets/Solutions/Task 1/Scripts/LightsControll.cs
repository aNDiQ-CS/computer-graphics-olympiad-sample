using UnityEngine;

public class LightsControll : MonoBehaviour
{
    [SerializeField] private GameObject _lightR;
    [SerializeField] private GameObject _lightG;
    [SerializeField] private GameObject _lightB;
    [SerializeField] private GameObject _globalLight;
    [SerializeField] private float _rotationSpeed = 50f;

    private bool _isRotating = true;

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.R))
        {
            _lightR.SetActive(!_lightR.activeSelf);
        }
        if (Input.GetKeyDown(KeyCode.G))
        {
            _lightG.SetActive(!_lightG.activeSelf);
        }
        if (Input.GetKeyDown(KeyCode.B))
        {
            _lightB.SetActive(!_lightB.activeSelf);
        }

        if (Input.GetKeyDown(KeyCode.T))
        {
            _isRotating = !_isRotating;
        }

        if (_isRotating)
        {
            _globalLight.transform.Rotate(Vector3.up * _rotationSpeed * Time.deltaTime);
        }
    }
}