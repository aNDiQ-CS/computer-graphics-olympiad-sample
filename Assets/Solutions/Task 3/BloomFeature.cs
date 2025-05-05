using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class BloomFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class Settings
    {
        public Material bloomMaterial;
        [Range(0.1f, 3f)] public float blurSize = 1.5f;
        [Range(1, 6)] public int iterations = 3;
        [Range(0f, 5f)] public float intensity = 1.2f;
        [Range(0f, 1f)] public float threshold = 0.7f;
    }

    class BloomRenderPass : ScriptableRenderPass
    {
        private Settings settings;
        private RenderTargetHandle tempTex1;
        private RenderTargetHandle tempTex2;
        private RenderTextureDescriptor descriptor;

        public BloomRenderPass(Settings settings)
        {
            this.settings = settings;
            tempTex1.Init("_BloomTemp1");
            tempTex2.Init("_BloomTemp2");
            renderPassEvent = RenderPassEvent.AfterRenderingTransparents + 1;
        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            descriptor = cameraTextureDescriptor;
            descriptor.useMipMap = false;
            descriptor.autoGenerateMips = false;
            descriptor.depthBufferBits = 0;
            descriptor.graphicsFormat = UnityEngine.Experimental.Rendering.GraphicsFormat.R16G16B16A16_SFloat;
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (settings.bloomMaterial == null ||
                renderingData.cameraData.cameraType == CameraType.Preview ||
                (renderingData.cameraData.isSceneViewCamera && !renderingData.cameraData.isHdrEnabled))
            {
                return;
            }

            CommandBuffer cmd = CommandBufferPool.Get("Bloom Effect");
            var source = renderingData.cameraData.renderer.cameraColorTarget;
            bool isSceneView = renderingData.cameraData.isSceneViewCamera;

            cmd.GetTemporaryRT(tempTex1.id, descriptor, FilterMode.Bilinear);
            cmd.SetGlobalFloat("_BloomThreshold", settings.threshold);
            Blit(cmd, source, tempTex1.Identifier(), settings.bloomMaterial, 0);

            for (int i = 0; i < settings.iterations; i++)
            {
                cmd.GetTemporaryRT(tempTex2.id, descriptor, FilterMode.Bilinear);
                cmd.SetGlobalFloat("_BlurSize", settings.blurSize);
                
                // Horizontal blur
                Blit(cmd, tempTex1.Identifier(), tempTex2.Identifier(), settings.bloomMaterial, 1);
                cmd.ReleaseTemporaryRT(tempTex1.id);

                // Vertical blur
                cmd.GetTemporaryRT(tempTex1.id, descriptor, FilterMode.Bilinear);
                Blit(cmd, tempTex2.Identifier(), tempTex1.Identifier(), settings.bloomMaterial, 2);
                cmd.ReleaseTemporaryRT(tempTex2.id);
            }

            // Combine pass
            float finalIntensity = isSceneView ? Mathf.Clamp(settings.intensity, 0f, 1f) : settings.intensity;
            cmd.SetGlobalTexture("_BloomTex", tempTex1.Identifier());
            cmd.SetGlobalFloat("_Intensity", finalIntensity);

            RenderTargetHandle finalTex = new RenderTargetHandle();
            finalTex.Init("_FinalTex");
            cmd.GetTemporaryRT(finalTex.id, descriptor);
            Blit(cmd, source, finalTex.Identifier(), settings.bloomMaterial, 3);
            Blit(cmd, finalTex.Identifier(), source);
            cmd.ReleaseTemporaryRT(finalTex.id);

            cmd.ReleaseTemporaryRT(tempTex1.id);
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }
    }

    public Settings settings = new Settings();
    private BloomRenderPass bloomPass;

    public override void Create()
    {
        bloomPass = new BloomRenderPass(settings);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(bloomPass);
    }
}