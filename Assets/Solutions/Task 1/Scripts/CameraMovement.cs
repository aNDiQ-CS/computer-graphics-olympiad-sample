using UnityEngine;

public class CameraMovement : MonoBehaviour
{
    [Header("Movement Settings")]
    public float baseSpeed = 5f;
    public float fastSpeed = 15f;
    public float riseSpeed = 5f;
    public float lookSensitivity = 2f;

    private float currentSpeed;
    private bool isCursorLocked = false;
    private Vector2 rotation = Vector2.zero;

    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            Cursor.lockState = CursorLockMode.Locked;
            isCursorLocked = true;
        }

        if (Input.GetKeyDown(KeyCode.Escape) || Input.GetMouseButtonDown(1))
        {
            Cursor.lockState = CursorLockMode.None;
            isCursorLocked = false;
        }

        if (isCursorLocked)
        {
            HandleRotation();
            HandleMovement();
        }
    }

    void HandleRotation()
    {
        rotation.x += Input.GetAxis("Mouse X") * lookSensitivity;
        rotation.y -= Input.GetAxis("Mouse Y") * lookSensitivity;
        rotation.y = Mathf.Clamp(rotation.y, -90f, 90f);

        transform.localRotation = Quaternion.Euler(rotation.y, rotation.x, 0);
    }

    void HandleMovement()
    {
        currentSpeed = Input.GetKey(KeyCode.LeftShift) ? fastSpeed : baseSpeed;

        Vector3 direction = new Vector3(
            Input.GetAxis("Horizontal"),
            0,
            Input.GetAxis("Vertical")
        );
        
        Vector3 move = transform.TransformDirection(direction) * currentSpeed;

        float vertical = 0;
        if (Input.GetKey(KeyCode.Q)) vertical = -1;
        if (Input.GetKey(KeyCode.E)) vertical = 1;

        transform.position += move * Time.deltaTime;
        transform.position += transform.up * vertical * riseSpeed * Time.deltaTime;
    }
}