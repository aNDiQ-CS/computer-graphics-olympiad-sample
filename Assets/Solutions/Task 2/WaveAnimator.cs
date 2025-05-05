using UnityEngine;

[RequireComponent(typeof(Renderer))]
public class WaveAnimator : MonoBehaviour
{
    [Header("Wave Settings")]
    [SerializeField] private float waveSpeed = 1f;
    [SerializeField] private float waveStrength = 0.5f;

    [Header("Impact Settings")]
    [SerializeField] private float impactDuration = 1f;
    [SerializeField] private float impactRadius = 2f;

    private Material material;
    private float impactTime;
    private Vector3 impactPosition;

    void Start()
    {
        material = GetComponent<Renderer>().material;
        material.SetFloat("_ImpactStrength", 0);
    }

    void Update()
    {
        // Обновление параметров волн
        material.SetFloat("_WaveSpeed", waveSpeed);
        material.SetFloat("_WaveStrength", waveStrength);

        // Затухание эффекта удара
        if (Time.time < impactTime + impactDuration)
        {
            float strength = Mathf.Lerp(1, 0, (Time.time - impactTime) / impactDuration);
            material.SetFloat("_ImpactStrength", strength);
        }
    }

    void OnCollisionEnter(Collision collision)
    {
        // Получаем точку контакта
        if (collision.contacts.Length > 0)
        {
            impactPosition = collision.contacts[0].point;
            impactTime = Time.time;

            // Передаем параметры в шейдер
            material.SetVector("_ImpactPos", new Vector4(
                impactPosition.x,
                impactPosition.y,
                impactPosition.z,
                0));
            material.SetFloat("_ImpactRadius", impactRadius);
            material.SetFloat("_ImpactStrength", 1);
        }
    }
}