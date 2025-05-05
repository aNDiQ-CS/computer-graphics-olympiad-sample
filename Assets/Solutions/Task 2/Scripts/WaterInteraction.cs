using UnityEngine;
using System.Collections.Generic;

public class WaterInteraction : MonoBehaviour
{
    public Material waterMaterial;
    public float forceMultiplier = 1.0f;
    public LayerMask waterLayer;

    private struct ImpactInfo
    {
        public Vector3 position;
        public float force;
        public float time;
    }

    private List<ImpactInfo> activeImpacts = new List<ImpactInfo>();
    private ComputeBuffer impactsBuffer;
    private Dictionary<Collider, Vector3> velocityCache = new Dictionary<Collider, Vector3>();

    void OnEnable()
    {
        impactsBuffer = new ComputeBuffer(100, sizeof(float) * 5);
        waterMaterial.SetBuffer("_ImpactsBuffer", impactsBuffer);
    }

    void OnDisable()
    {
        impactsBuffer.Release();
    }

    void FixedUpdate()
    {
        // Кэшируем скорости объектов перед физическим обновлением
        velocityCache.Clear();
        foreach (var obj in FindObjectsOfType<Rigidbody>())
        {
            velocityCache[obj.GetComponent<Collider>()] = obj.velocity;
        }
    }

    void Update()
    {
        UpdateImpacts();
    }

    void OnTriggerEnter(Collider other)
    {
        if (((1 << other.gameObject.layer) & waterLayer) != 0)
        {
            // Рассчитываем точку входа в воду
            Vector3 surfacePoint = GetWaterSurfacePoint(other);

            // Получаем скорость из кэша
            Vector3 velocity = velocityCache.ContainsKey(other)
                ? velocityCache[other]
                : Vector3.zero;

            AddImpact(
                surfacePoint,
                velocity.magnitude * forceMultiplier
            );
        }
    }

    Vector3 GetWaterSurfacePoint(Collider enteringObject)
    {
        // Для простоты используем позицию объекта
        // Для точного расчета можно использовать Raycast
        return enteringObject.bounds.center;
    }

    void AddImpact(Vector3 position, float force)
    {
        activeImpacts.Add(new ImpactInfo
        {
            position = position,
            force = Mathf.Clamp(force, 0.1f, 5.0f),
            time = Time.time
        });
    }

    void UpdateImpacts()
    {
        // Удаляем старые воздействия
        activeImpacts.RemoveAll(i => Time.time - i.time > 5.0f);

        // Обновляем буфер
        ImpactInfo[] data = new ImpactInfo[100];
        int count = Mathf.Min(activeImpacts.Count, 100);
        for (int i = 0; i < count; i++)
        {
            data[i] = activeImpacts[i];
        }

        impactsBuffer.SetData(data);
        waterMaterial.SetInt("_ActiveImpactsCount", count);
    }
}