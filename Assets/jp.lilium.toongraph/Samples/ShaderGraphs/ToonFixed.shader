Shader "ToonFixed"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset]_BaseMap("Base Map", 2D) = "white" {}
        _ShadeEnvironmentalColor("Shade Environmental Color", Color) = (0.5019608, 0.5019608, 0.5019608, 1)
        _ShadeColor("SSS Color", Color) = (0, 0, 0, 0)
        [NoScaleOffset]_ShadeMap("SSS Map", 2D) = "white" {}
        _Smoothness("Smoothness", Range(0, 1)) = 0.5
        _Metalic("Metalic", Range(0, 1)) = 0
        _Curvature("Curvature", Range(0, 10)) = 1
        [NoScaleOffset]Texture2D_d5a96518bbf24f11aff81031d9fbd97d("Tickness Map", 2D) = "black" {}
        [NoScaleOffset]_MetalicMap("Metalic Map", 2D) = "white" {}
        [NoScaleOffset]_BumpMap("Normal Map", 2D) = "bump" {}
        [NoScaleOffset]_OcclusionMap("Occlusion Map", 2D) = "white" {}
        _Shade("Shade Shift", Range(0, 2)) = 1
        [NoScaleOffset]_ShadowMap("Shade Map", 2D) = "white" {}
        [HDR]_EmissionColor("Emission Color", Color) = (1, 1, 1, 0)
        [NoScaleOffset]_EmissionMap("Emission Map", 2D) = "black" {}
        _OutlineWidth("Outline Width", Float) = 1
        [NoScaleOffset]_OutlineMap("Outline Map", 2D) = "white" {}
        _ShadeToony("Shade Toony", Range(0, 1)) = 1
        _ToonyLighting("Toony Lighting", Range(0, 1)) = 1
        _OutlineIntensity("Outline Intensity", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "Queue"="AlphaTest"
        }
        Pass
        {
            Name "Lilium Toon"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_UNLIT
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if defined(LIGHTMAP_ON)
            float2 interp5 : TEXCOORD5;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp6 : TEXCOORD6;
            #endif
            float4 interp7 : TEXCOORD7;
            float4 interp8 : TEXCOORD8;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            output.interp8.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor;
        float4 _BaseMap_TexelSize;
        float4 _ShadeEnvironmentalColor;
        float4 _ShadeColor;
        float4 _ShadeMap_TexelSize;
        float _Smoothness;
        float _Metalic;
        float _Curvature;
        float4 Texture2D_d5a96518bbf24f11aff81031d9fbd97d_TexelSize;
        float4 _MetalicMap_TexelSize;
        float4 _BumpMap_TexelSize;
        float4 _OcclusionMap_TexelSize;
        float _Shade;
        float4 _ShadowMap_TexelSize;
        float4 _EmissionColor;
        float4 _EmissionMap_TexelSize;
        float _OutlineWidth;
        float4 _OutlineMap_TexelSize;
        float _ShadeToony;
        float _ToonyLighting;
        float _OutlineIntensity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_ShadeMap);
        SAMPLER(sampler_ShadeMap);
        TEXTURE2D(Texture2D_d5a96518bbf24f11aff81031d9fbd97d);
        SAMPLER(samplerTexture2D_d5a96518bbf24f11aff81031d9fbd97d);
        TEXTURE2D(_MetalicMap);
        SAMPLER(sampler_MetalicMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_ShadowMap);
        SAMPLER(sampler_ShadowMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_OutlineMap);
        SAMPLER(sampler_OutlineMap);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        // 45bb95d39362be0a3d23a808df58e263
        #include "Assets/jp.lilium.toongraph/Contents/Shader/ToonLightingSmoothstepRamp.hlsl"

        struct Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
        };

        void SG_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830(float3 Vector3_F836E644, float Vector1_4314B010, float4 Color_c394a829605a4bbd960d0a173370c56d, float Vector1_17cc6dcabd4041ba8c42d4eabd899dc4, float Vector1_328D12DB, float4 Color_625E7FA7, float3 Vector3_A82C1F5A, float Vector1_CA473DD5, float3 Vector3_248C1ED5, float Vector1_13346DDE, float Vector1_A8A74B72, float Vector1_8507BB4B, Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830 IN, out half3 Color_1, out half Alpha_2, out half3 ShadeColor_3)
        {
            float3 _Property_31f568d740a64ee5b41bd1e18b692f82_Out_0 = Vector3_F836E644;
            float4 _Property_ae3ecbd1416b4ae4a46c0860af87b2e9_Out_0 = Color_c394a829605a4bbd960d0a173370c56d;
            float3 _Property_3406a60a3c6d440991096282196a1c46_Out_0 = Vector3_A82C1F5A;
            float4 _Property_d6e67016be4b418e8a3f32de3b94681a_Out_0 = Color_625E7FA7;
            float _Property_e4e4db6a878044c399d4415afbb848c5_Out_0 = Vector1_328D12DB;
            float _Property_a5f2fab578bf4e338f9a1f6d6e4b6d00_Out_0 = Vector1_CA473DD5;
            float3 _Property_22bb99e9d5444c81af92426da216b3f7_Out_0 = Vector3_248C1ED5;
            float _Property_65f25cda39974603b95cf57fdb28e808_Out_0 = Vector1_4314B010;
            float _Property_4e1b490fa0af4c79beb5438b6535e73c_Out_0 = Vector1_13346DDE;
            float _Property_56490d6edc6c4d2ba46855b9cb7f7b49_Out_0 = Vector1_A8A74B72;
            float _Property_7b962570b81342d1b4d72b83e1cb1e3f_Out_0 = Vector1_17cc6dcabd4041ba8c42d4eabd899dc4;
            float _Property_af2080c2481140edaa8dd97ec51452bf_Out_0 = Vector1_8507BB4B;
            half4 _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0;
            half3 _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_ShadeColor_20;
            ToonLight_half(IN.ObjectSpacePosition, IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceViewDirection, _Property_31f568d740a64ee5b41bd1e18b692f82_Out_0, _Property_ae3ecbd1416b4ae4a46c0860af87b2e9_Out_0, _Property_3406a60a3c6d440991096282196a1c46_Out_0, (_Property_d6e67016be4b418e8a3f32de3b94681a_Out_0.xyz), _Property_e4e4db6a878044c399d4415afbb848c5_Out_0, _Property_a5f2fab578bf4e338f9a1f6d6e4b6d00_Out_0, _Property_22bb99e9d5444c81af92426da216b3f7_Out_0, _Property_65f25cda39974603b95cf57fdb28e808_Out_0, _Property_4e1b490fa0af4c79beb5438b6535e73c_Out_0, _Property_56490d6edc6c4d2ba46855b9cb7f7b49_Out_0, _Property_7b962570b81342d1b4d72b83e1cb1e3f_Out_0, _Property_af2080c2481140edaa8dd97ec51452bf_Out_0, _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0, _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_ShadeColor_20);
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_R_1 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[0];
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_G_2 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[1];
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_B_3 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[2];
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_A_4 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[3];
            Color_1 = (_ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0.xyz);
            Alpha_2 = _Split_9e9eebec5ff840fba5de5a2a051495ed_A_4;
            ShadeColor_3 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_ShadeColor_20;
        }

        void Unity_Fog_float(out float4 Color, out float Density, float3 Position)
        {
            SHADERGRAPH_FOG(Position, Color, Density);
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }

        struct Bindings_MixFog_e65d935e3c006a842b7a2fb6063b4b4d
        {
            float3 ObjectSpacePosition;
        };

        void SG_MixFog_e65d935e3c006a842b7a2fb6063b4b4d(float3 Vector3_33E0F5E1, Bindings_MixFog_e65d935e3c006a842b7a2fb6063b4b4d IN, out float3 Color_3)
        {
            float3 _Property_2784bf39139949af90f15cb6ee88a0df_Out_0 = Vector3_33E0F5E1;
            float4 _Fog_d4220d532719413c85621841df5e2098_Color_0;
            float _Fog_d4220d532719413c85621841df5e2098_Density_1;
            Unity_Fog_float(_Fog_d4220d532719413c85621841df5e2098_Color_0, _Fog_d4220d532719413c85621841df5e2098_Density_1, IN.ObjectSpacePosition);
            float _Multiply_6523b09d1d3a45f2ba923f5e9a53f89d_Out_2;
            Unity_Multiply_float(_Fog_d4220d532719413c85621841df5e2098_Density_1, 0.5, _Multiply_6523b09d1d3a45f2ba923f5e9a53f89d_Out_2);
            float _Clamp_54ff10dfa66b48e084bb9a79dfcaabd5_Out_3;
            Unity_Clamp_float(_Multiply_6523b09d1d3a45f2ba923f5e9a53f89d_Out_2, 0, 1, _Clamp_54ff10dfa66b48e084bb9a79dfcaabd5_Out_3);
            float3 _Lerp_0a061577e6824a22b2c504f65c3c4af7_Out_3;
            Unity_Lerp_float3(_Property_2784bf39139949af90f15cb6ee88a0df_Out_0, (_Fog_d4220d532719413c85621841df5e2098_Color_0.xyz), (_Clamp_54ff10dfa66b48e084bb9a79dfcaabd5_Out_3.xxx), _Lerp_0a061577e6824a22b2c504f65c3c4af7_Out_3);
            Color_3 = _Lerp_0a061577e6824a22b2c504f65c3c4af7_Out_3;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_5d8ac4a251d84d4fa7986e1193e70da2_Out_0 = _BaseColor;
            UnityTexture2D _Property_b99b572259ca455cb15668511e3a76c4_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b99b572259ca455cb15668511e3a76c4_Out_0.tex, _Property_b99b572259ca455cb15668511e3a76c4_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_R_4 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.r;
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_G_5 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.g;
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_B_6 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.b;
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_A_7 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.a;
            float4 _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2;
            Unity_Multiply_float(_Property_5d8ac4a251d84d4fa7986e1193e70da2_Out_0, _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0, _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2);
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_R_1 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[0];
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_G_2 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[1];
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_B_3 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[2];
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_A_4 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[3];
            float4 _Property_636d8bdc04954f5497aa4b2cd0510a8e_Out_0 = _ShadeColor;
            UnityTexture2D _Property_94ea4828a0ed4321827fd4247c3e3f6c_Out_0 = UnityBuildTexture2DStructNoScale(_ShadeMap);
            float4 _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_94ea4828a0ed4321827fd4247c3e3f6c_Out_0.tex, _Property_94ea4828a0ed4321827fd4247c3e3f6c_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_R_4 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.r;
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_G_5 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.g;
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_B_6 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.b;
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_A_7 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.a;
            float4 _Multiply_362659b6eca74e09ab45550154f1dc08_Out_2;
            Unity_Multiply_float(_Property_636d8bdc04954f5497aa4b2cd0510a8e_Out_0, _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0, _Multiply_362659b6eca74e09ab45550154f1dc08_Out_2);
            float _Property_fd4f3aeee3af4897956a9bfea83e8ff2_Out_0 = _Curvature;
            UnityTexture2D _Property_b6fbff5e115249c6b7e9d1cfd0b67730_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_d5a96518bbf24f11aff81031d9fbd97d);
            float4 _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b6fbff5e115249c6b7e9d1cfd0b67730_Out_0.tex, _Property_b6fbff5e115249c6b7e9d1cfd0b67730_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_R_4 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.r;
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_G_5 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.g;
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_B_6 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.b;
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_A_7 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.a;
            float _OneMinus_51358182e28d43d786253d9ff413e1ba_Out_1;
            Unity_OneMinus_float(_SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_R_4, _OneMinus_51358182e28d43d786253d9ff413e1ba_Out_1);
            float _Multiply_a09345b9701041799b426d68bdf46c2b_Out_2;
            Unity_Multiply_float(_Property_fd4f3aeee3af4897956a9bfea83e8ff2_Out_0, _OneMinus_51358182e28d43d786253d9ff413e1ba_Out_1, _Multiply_a09345b9701041799b426d68bdf46c2b_Out_2);
            float _Property_25e6c6c8207b4543936545ce21c0f1cf_Out_0 = _Smoothness;
            float _Property_ed24ac9afcec458193f4ca80d3433d26_Out_0 = _Metalic;
            UnityTexture2D _Property_8d46a693a34244728f8994000a7aedf2_Out_0 = UnityBuildTexture2DStructNoScale(_MetalicMap);
            float4 _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_8d46a693a34244728f8994000a7aedf2_Out_0.tex, _Property_8d46a693a34244728f8994000a7aedf2_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_R_4 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.r;
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_G_5 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.g;
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_B_6 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.b;
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_A_7 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.a;
            float4 _Multiply_3cc6f9ea17204e85b475424edb8cf7b4_Out_2;
            Unity_Multiply_float((_Property_ed24ac9afcec458193f4ca80d3433d26_Out_0.xxxx), _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0, _Multiply_3cc6f9ea17204e85b475424edb8cf7b4_Out_2);
            UnityTexture2D _Property_d93c6a66728e4177a22ce3d7ab635285_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            float4 _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d93c6a66728e4177a22ce3d7ab635285_Out_0.tex, _Property_d93c6a66728e4177a22ce3d7ab635285_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0);
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_R_4 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.r;
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_G_5 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.g;
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_B_6 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.b;
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_A_7 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.a;
            UnityTexture2D _Property_4f7e9183e76b43988062dfb0174af827_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            float4 _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4f7e9183e76b43988062dfb0174af827_Out_0.tex, _Property_4f7e9183e76b43988062dfb0174af827_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_R_4 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.r;
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_G_5 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.g;
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_B_6 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.b;
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_A_7 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.a;
            float4 _Property_7586886eeb5f45e6b097de3ce5740b5a_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            UnityTexture2D _Property_9a0067ba56784933a899c04948d4fc14_Out_0 = UnityBuildTexture2DStructNoScale(_EmissionMap);
            float4 _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9a0067ba56784933a899c04948d4fc14_Out_0.tex, _Property_9a0067ba56784933a899c04948d4fc14_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_R_4 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.r;
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_G_5 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.g;
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_B_6 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.b;
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_A_7 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.a;
            float4 _Multiply_5a00473c36a34df08239ece69cc4d8b1_Out_2;
            Unity_Multiply_float(_Property_7586886eeb5f45e6b097de3ce5740b5a_Out_0, _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0, _Multiply_5a00473c36a34df08239ece69cc4d8b1_Out_2);
            float _Property_ba7bcca39adb43e6b719c9a3f7aa42c1_Out_0 = _Shade;
            UnityTexture2D _Property_df41400fc48c4dc0a9116f719671d999_Out_0 = UnityBuildTexture2DStructNoScale(_ShadowMap);
            float4 _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_df41400fc48c4dc0a9116f719671d999_Out_0.tex, _Property_df41400fc48c4dc0a9116f719671d999_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_R_4 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.r;
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_G_5 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.g;
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_B_6 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.b;
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_A_7 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.a;
            float _Multiply_5b18d24ab4984169a8750d5d8bc7c7eb_Out_2;
            Unity_Multiply_float(_Property_ba7bcca39adb43e6b719c9a3f7aa42c1_Out_0, _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_R_4, _Multiply_5b18d24ab4984169a8750d5d8bc7c7eb_Out_2);
            float _Property_2b46e454918e476bbeeaa384671e06c2_Out_0 = _ShadeToony;
            float _Property_9e9482f4911345058781c44dedc65edf_Out_0 = _ToonyLighting;
            Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830 _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceNormal = IN.WorldSpaceNormal;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceTangent = IN.WorldSpaceTangent;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.ObjectSpacePosition = IN.ObjectSpacePosition;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpacePosition = IN.WorldSpacePosition;
            half3 _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Color_1;
            half _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Alpha_2;
            half3 _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_ShadeColor_3;
            SG_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830((_Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2.xyz), _Split_484f417dccca44c8aa91b01ad6e49ac0_A_4, _Multiply_362659b6eca74e09ab45550154f1dc08_Out_2, _Multiply_a09345b9701041799b426d68bdf46c2b_Out_2, _Property_25e6c6c8207b4543936545ce21c0f1cf_Out_0, _Multiply_3cc6f9ea17204e85b475424edb8cf7b4_Out_2, (_SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.xyz), _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_R_4, (_Multiply_5a00473c36a34df08239ece69cc4d8b1_Out_2.xyz), _Multiply_5b18d24ab4984169a8750d5d8bc7c7eb_Out_2, _Property_2b46e454918e476bbeeaa384671e06c2_Out_0, _Property_9e9482f4911345058781c44dedc65edf_Out_0, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Color_1, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Alpha_2, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_ShadeColor_3);
            Bindings_MixFog_e65d935e3c006a842b7a2fb6063b4b4d _MixFog_e5064454c4c144499f876fa4011590de;
            _MixFog_e5064454c4c144499f876fa4011590de.ObjectSpacePosition = IN.ObjectSpacePosition;
            float3 _MixFog_e5064454c4c144499f876fa4011590de_Color_3;
            SG_MixFog_e65d935e3c006a842b7a2fb6063b4b4d(_ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Color_1, _MixFog_e5064454c4c144499f876fa4011590de, _MixFog_e5064454c4c144499f876fa4011590de_Color_3);
            surface.BaseColor = _MixFog_e5064454c4c144499f876fa4011590de_Color_3;
            surface.Alpha = _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Alpha_2;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);

        	// use bitangent on the fly like in hdrp
        	// IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
        	float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);

            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph

        	// to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
        	// This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
        	output.WorldSpaceBiTangent =         renormFactor*bitang;

            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Assets/jp.lilium.toongraph/Editor/ShaderGraph/ToonForwardPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Lilium Outline"
            Tags
            {
                // LightMode: <None>
            }

            // Render State
            Cull Front
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest Less
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float4 uv0;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if defined(LIGHTMAP_ON)
            float2 interp5 : TEXCOORD5;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp6 : TEXCOORD6;
            #endif
            float4 interp7 : TEXCOORD7;
            float4 interp8 : TEXCOORD8;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            output.interp8.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor;
        float4 _BaseMap_TexelSize;
        float4 _ShadeEnvironmentalColor;
        float4 _ShadeColor;
        float4 _ShadeMap_TexelSize;
        float _Smoothness;
        float _Metalic;
        float _Curvature;
        float4 Texture2D_d5a96518bbf24f11aff81031d9fbd97d_TexelSize;
        float4 _MetalicMap_TexelSize;
        float4 _BumpMap_TexelSize;
        float4 _OcclusionMap_TexelSize;
        float _Shade;
        float4 _ShadowMap_TexelSize;
        float4 _EmissionColor;
        float4 _EmissionMap_TexelSize;
        float _OutlineWidth;
        float4 _OutlineMap_TexelSize;
        float _ShadeToony;
        float _ToonyLighting;
        float _OutlineIntensity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_ShadeMap);
        SAMPLER(sampler_ShadeMap);
        TEXTURE2D(Texture2D_d5a96518bbf24f11aff81031d9fbd97d);
        SAMPLER(samplerTexture2D_d5a96518bbf24f11aff81031d9fbd97d);
        TEXTURE2D(_MetalicMap);
        SAMPLER(sampler_MetalicMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_ShadowMap);
        SAMPLER(sampler_ShadowMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_OutlineMap);
        SAMPLER(sampler_OutlineMap);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        // 39a2adacb021fa0c0e1927055b619ca4
        #include "Assets/jp.lilium.toongraph/Contents/Shader/OutlineTransform.hlsl"

        struct Bindings_ToonOutlineTransform_aadd6ff8a7ff83a4fb272240ac26c2b5
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpacePosition;
        };

        void SG_ToonOutlineTransform_aadd6ff8a7ff83a4fb272240ac26c2b5(float Vector1_78aea86254144fde8d0e857fca6e921b, Bindings_ToonOutlineTransform_aadd6ff8a7ff83a4fb272240ac26c2b5 IN, out float3 OutlinePosition_1)
        {
            float _Property_541479427c4a47ed81b50a74cb77d7b6_Out_0 = Vector1_78aea86254144fde8d0e857fca6e921b;
            float3 _TransformOutlineCustomFunction_41e897d5cb2b40f19b4cd6b9c5726a38_OutlinePosition_4;
            TransformOutline_float(IN.ObjectSpacePosition, IN.ObjectSpaceNormal, _Property_541479427c4a47ed81b50a74cb77d7b6_Out_0, _TransformOutlineCustomFunction_41e897d5cb2b40f19b4cd6b9c5726a38_OutlinePosition_4);
            OutlinePosition_1 = _TransformOutlineCustomFunction_41e897d5cb2b40f19b4cd6b9c5726a38_OutlinePosition_4;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        // 45bb95d39362be0a3d23a808df58e263
        #include "Assets/jp.lilium.toongraph/Contents/Shader/ToonLightingSmoothstepRamp.hlsl"

        struct Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
        };

        void SG_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830(float3 Vector3_F836E644, float Vector1_4314B010, float4 Color_c394a829605a4bbd960d0a173370c56d, float Vector1_17cc6dcabd4041ba8c42d4eabd899dc4, float Vector1_328D12DB, float4 Color_625E7FA7, float3 Vector3_A82C1F5A, float Vector1_CA473DD5, float3 Vector3_248C1ED5, float Vector1_13346DDE, float Vector1_A8A74B72, float Vector1_8507BB4B, Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830 IN, out half3 Color_1, out half Alpha_2, out half3 ShadeColor_3)
        {
            float3 _Property_31f568d740a64ee5b41bd1e18b692f82_Out_0 = Vector3_F836E644;
            float4 _Property_ae3ecbd1416b4ae4a46c0860af87b2e9_Out_0 = Color_c394a829605a4bbd960d0a173370c56d;
            float3 _Property_3406a60a3c6d440991096282196a1c46_Out_0 = Vector3_A82C1F5A;
            float4 _Property_d6e67016be4b418e8a3f32de3b94681a_Out_0 = Color_625E7FA7;
            float _Property_e4e4db6a878044c399d4415afbb848c5_Out_0 = Vector1_328D12DB;
            float _Property_a5f2fab578bf4e338f9a1f6d6e4b6d00_Out_0 = Vector1_CA473DD5;
            float3 _Property_22bb99e9d5444c81af92426da216b3f7_Out_0 = Vector3_248C1ED5;
            float _Property_65f25cda39974603b95cf57fdb28e808_Out_0 = Vector1_4314B010;
            float _Property_4e1b490fa0af4c79beb5438b6535e73c_Out_0 = Vector1_13346DDE;
            float _Property_56490d6edc6c4d2ba46855b9cb7f7b49_Out_0 = Vector1_A8A74B72;
            float _Property_7b962570b81342d1b4d72b83e1cb1e3f_Out_0 = Vector1_17cc6dcabd4041ba8c42d4eabd899dc4;
            float _Property_af2080c2481140edaa8dd97ec51452bf_Out_0 = Vector1_8507BB4B;
            half4 _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0;
            half3 _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_ShadeColor_20;
            ToonLight_half(IN.ObjectSpacePosition, IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceViewDirection, _Property_31f568d740a64ee5b41bd1e18b692f82_Out_0, _Property_ae3ecbd1416b4ae4a46c0860af87b2e9_Out_0, _Property_3406a60a3c6d440991096282196a1c46_Out_0, (_Property_d6e67016be4b418e8a3f32de3b94681a_Out_0.xyz), _Property_e4e4db6a878044c399d4415afbb848c5_Out_0, _Property_a5f2fab578bf4e338f9a1f6d6e4b6d00_Out_0, _Property_22bb99e9d5444c81af92426da216b3f7_Out_0, _Property_65f25cda39974603b95cf57fdb28e808_Out_0, _Property_4e1b490fa0af4c79beb5438b6535e73c_Out_0, _Property_56490d6edc6c4d2ba46855b9cb7f7b49_Out_0, _Property_7b962570b81342d1b4d72b83e1cb1e3f_Out_0, _Property_af2080c2481140edaa8dd97ec51452bf_Out_0, _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0, _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_ShadeColor_20);
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_R_1 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[0];
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_G_2 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[1];
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_B_3 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[2];
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_A_4 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[3];
            Color_1 = (_ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0.xyz);
            Alpha_2 = _Split_9e9eebec5ff840fba5de5a2a051495ed_A_4;
            ShadeColor_3 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_ShadeColor_20;
        }

        void Unity_Fog_float(out float4 Color, out float Density, float3 Position)
        {
            SHADERGRAPH_FOG(Position, Color, Density);
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }

        struct Bindings_MixFog_e65d935e3c006a842b7a2fb6063b4b4d
        {
            float3 ObjectSpacePosition;
        };

        void SG_MixFog_e65d935e3c006a842b7a2fb6063b4b4d(float3 Vector3_33E0F5E1, Bindings_MixFog_e65d935e3c006a842b7a2fb6063b4b4d IN, out float3 Color_3)
        {
            float3 _Property_2784bf39139949af90f15cb6ee88a0df_Out_0 = Vector3_33E0F5E1;
            float4 _Fog_d4220d532719413c85621841df5e2098_Color_0;
            float _Fog_d4220d532719413c85621841df5e2098_Density_1;
            Unity_Fog_float(_Fog_d4220d532719413c85621841df5e2098_Color_0, _Fog_d4220d532719413c85621841df5e2098_Density_1, IN.ObjectSpacePosition);
            float _Multiply_6523b09d1d3a45f2ba923f5e9a53f89d_Out_2;
            Unity_Multiply_float(_Fog_d4220d532719413c85621841df5e2098_Density_1, 0.5, _Multiply_6523b09d1d3a45f2ba923f5e9a53f89d_Out_2);
            float _Clamp_54ff10dfa66b48e084bb9a79dfcaabd5_Out_3;
            Unity_Clamp_float(_Multiply_6523b09d1d3a45f2ba923f5e9a53f89d_Out_2, 0, 1, _Clamp_54ff10dfa66b48e084bb9a79dfcaabd5_Out_3);
            float3 _Lerp_0a061577e6824a22b2c504f65c3c4af7_Out_3;
            Unity_Lerp_float3(_Property_2784bf39139949af90f15cb6ee88a0df_Out_0, (_Fog_d4220d532719413c85621841df5e2098_Color_0.xyz), (_Clamp_54ff10dfa66b48e084bb9a79dfcaabd5_Out_3.xxx), _Lerp_0a061577e6824a22b2c504f65c3c4af7_Out_3);
            Color_3 = _Lerp_0a061577e6824a22b2c504f65c3c4af7_Out_3;
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
            float3 OutlinePosition;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_25acdc7ba0074c9da9c38bbf8de829be_Out_0 = _OutlineWidth;
            UnityTexture2D _Property_727b20b6699c40c6a6524706ace804fd_Out_0 = UnityBuildTexture2DStructNoScale(_OutlineMap);
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_66d48423b6af44f380158486e09f2aa5_RGBA_0 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_66d48423b6af44f380158486e09f2aa5_RGBA_0 = SAMPLE_TEXTURE2D_LOD(_Property_727b20b6699c40c6a6524706ace804fd_Out_0.tex, _Property_727b20b6699c40c6a6524706ace804fd_Out_0.samplerstate, IN.uv0.xy, 0);
            #endif
            float _SampleTexture2DLOD_66d48423b6af44f380158486e09f2aa5_R_5 = _SampleTexture2DLOD_66d48423b6af44f380158486e09f2aa5_RGBA_0.r;
            float _SampleTexture2DLOD_66d48423b6af44f380158486e09f2aa5_G_6 = _SampleTexture2DLOD_66d48423b6af44f380158486e09f2aa5_RGBA_0.g;
            float _SampleTexture2DLOD_66d48423b6af44f380158486e09f2aa5_B_7 = _SampleTexture2DLOD_66d48423b6af44f380158486e09f2aa5_RGBA_0.b;
            float _SampleTexture2DLOD_66d48423b6af44f380158486e09f2aa5_A_8 = _SampleTexture2DLOD_66d48423b6af44f380158486e09f2aa5_RGBA_0.a;
            float _Multiply_8c01c8e41feb44b5bf3dbc8665b453ba_Out_2;
            Unity_Multiply_float(_Property_25acdc7ba0074c9da9c38bbf8de829be_Out_0, _SampleTexture2DLOD_66d48423b6af44f380158486e09f2aa5_R_5, _Multiply_8c01c8e41feb44b5bf3dbc8665b453ba_Out_2);
            Bindings_ToonOutlineTransform_aadd6ff8a7ff83a4fb272240ac26c2b5 _ToonOutlineTransform_9c41895a93344de180bdee6de227dbb5;
            _ToonOutlineTransform_9c41895a93344de180bdee6de227dbb5.ObjectSpaceNormal = IN.ObjectSpaceNormal;
            _ToonOutlineTransform_9c41895a93344de180bdee6de227dbb5.ObjectSpacePosition = IN.ObjectSpacePosition;
            float3 _ToonOutlineTransform_9c41895a93344de180bdee6de227dbb5_OutlinePosition_1;
            SG_ToonOutlineTransform_aadd6ff8a7ff83a4fb272240ac26c2b5(_Multiply_8c01c8e41feb44b5bf3dbc8665b453ba_Out_2, _ToonOutlineTransform_9c41895a93344de180bdee6de227dbb5, _ToonOutlineTransform_9c41895a93344de180bdee6de227dbb5_OutlinePosition_1);
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            description.OutlinePosition = _ToonOutlineTransform_9c41895a93344de180bdee6de227dbb5_OutlinePosition_1;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
            float3 OutlineColor;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_5d8ac4a251d84d4fa7986e1193e70da2_Out_0 = _BaseColor;
            UnityTexture2D _Property_b99b572259ca455cb15668511e3a76c4_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b99b572259ca455cb15668511e3a76c4_Out_0.tex, _Property_b99b572259ca455cb15668511e3a76c4_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_R_4 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.r;
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_G_5 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.g;
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_B_6 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.b;
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_A_7 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.a;
            float4 _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2;
            Unity_Multiply_float(_Property_5d8ac4a251d84d4fa7986e1193e70da2_Out_0, _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0, _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2);
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_R_1 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[0];
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_G_2 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[1];
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_B_3 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[2];
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_A_4 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[3];
            float4 _Property_636d8bdc04954f5497aa4b2cd0510a8e_Out_0 = _ShadeColor;
            UnityTexture2D _Property_94ea4828a0ed4321827fd4247c3e3f6c_Out_0 = UnityBuildTexture2DStructNoScale(_ShadeMap);
            float4 _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_94ea4828a0ed4321827fd4247c3e3f6c_Out_0.tex, _Property_94ea4828a0ed4321827fd4247c3e3f6c_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_R_4 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.r;
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_G_5 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.g;
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_B_6 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.b;
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_A_7 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.a;
            float4 _Multiply_362659b6eca74e09ab45550154f1dc08_Out_2;
            Unity_Multiply_float(_Property_636d8bdc04954f5497aa4b2cd0510a8e_Out_0, _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0, _Multiply_362659b6eca74e09ab45550154f1dc08_Out_2);
            float _Property_fd4f3aeee3af4897956a9bfea83e8ff2_Out_0 = _Curvature;
            UnityTexture2D _Property_b6fbff5e115249c6b7e9d1cfd0b67730_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_d5a96518bbf24f11aff81031d9fbd97d);
            float4 _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b6fbff5e115249c6b7e9d1cfd0b67730_Out_0.tex, _Property_b6fbff5e115249c6b7e9d1cfd0b67730_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_R_4 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.r;
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_G_5 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.g;
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_B_6 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.b;
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_A_7 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.a;
            float _OneMinus_51358182e28d43d786253d9ff413e1ba_Out_1;
            Unity_OneMinus_float(_SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_R_4, _OneMinus_51358182e28d43d786253d9ff413e1ba_Out_1);
            float _Multiply_a09345b9701041799b426d68bdf46c2b_Out_2;
            Unity_Multiply_float(_Property_fd4f3aeee3af4897956a9bfea83e8ff2_Out_0, _OneMinus_51358182e28d43d786253d9ff413e1ba_Out_1, _Multiply_a09345b9701041799b426d68bdf46c2b_Out_2);
            float _Property_25e6c6c8207b4543936545ce21c0f1cf_Out_0 = _Smoothness;
            float _Property_ed24ac9afcec458193f4ca80d3433d26_Out_0 = _Metalic;
            UnityTexture2D _Property_8d46a693a34244728f8994000a7aedf2_Out_0 = UnityBuildTexture2DStructNoScale(_MetalicMap);
            float4 _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_8d46a693a34244728f8994000a7aedf2_Out_0.tex, _Property_8d46a693a34244728f8994000a7aedf2_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_R_4 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.r;
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_G_5 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.g;
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_B_6 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.b;
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_A_7 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.a;
            float4 _Multiply_3cc6f9ea17204e85b475424edb8cf7b4_Out_2;
            Unity_Multiply_float((_Property_ed24ac9afcec458193f4ca80d3433d26_Out_0.xxxx), _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0, _Multiply_3cc6f9ea17204e85b475424edb8cf7b4_Out_2);
            UnityTexture2D _Property_d93c6a66728e4177a22ce3d7ab635285_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            float4 _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d93c6a66728e4177a22ce3d7ab635285_Out_0.tex, _Property_d93c6a66728e4177a22ce3d7ab635285_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0);
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_R_4 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.r;
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_G_5 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.g;
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_B_6 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.b;
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_A_7 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.a;
            UnityTexture2D _Property_4f7e9183e76b43988062dfb0174af827_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            float4 _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4f7e9183e76b43988062dfb0174af827_Out_0.tex, _Property_4f7e9183e76b43988062dfb0174af827_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_R_4 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.r;
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_G_5 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.g;
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_B_6 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.b;
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_A_7 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.a;
            float4 _Property_7586886eeb5f45e6b097de3ce5740b5a_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            UnityTexture2D _Property_9a0067ba56784933a899c04948d4fc14_Out_0 = UnityBuildTexture2DStructNoScale(_EmissionMap);
            float4 _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9a0067ba56784933a899c04948d4fc14_Out_0.tex, _Property_9a0067ba56784933a899c04948d4fc14_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_R_4 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.r;
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_G_5 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.g;
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_B_6 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.b;
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_A_7 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.a;
            float4 _Multiply_5a00473c36a34df08239ece69cc4d8b1_Out_2;
            Unity_Multiply_float(_Property_7586886eeb5f45e6b097de3ce5740b5a_Out_0, _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0, _Multiply_5a00473c36a34df08239ece69cc4d8b1_Out_2);
            float _Property_ba7bcca39adb43e6b719c9a3f7aa42c1_Out_0 = _Shade;
            UnityTexture2D _Property_df41400fc48c4dc0a9116f719671d999_Out_0 = UnityBuildTexture2DStructNoScale(_ShadowMap);
            float4 _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_df41400fc48c4dc0a9116f719671d999_Out_0.tex, _Property_df41400fc48c4dc0a9116f719671d999_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_R_4 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.r;
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_G_5 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.g;
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_B_6 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.b;
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_A_7 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.a;
            float _Multiply_5b18d24ab4984169a8750d5d8bc7c7eb_Out_2;
            Unity_Multiply_float(_Property_ba7bcca39adb43e6b719c9a3f7aa42c1_Out_0, _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_R_4, _Multiply_5b18d24ab4984169a8750d5d8bc7c7eb_Out_2);
            float _Property_2b46e454918e476bbeeaa384671e06c2_Out_0 = _ShadeToony;
            float _Property_9e9482f4911345058781c44dedc65edf_Out_0 = _ToonyLighting;
            Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830 _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceNormal = IN.WorldSpaceNormal;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceTangent = IN.WorldSpaceTangent;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.ObjectSpacePosition = IN.ObjectSpacePosition;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpacePosition = IN.WorldSpacePosition;
            half3 _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Color_1;
            half _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Alpha_2;
            half3 _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_ShadeColor_3;
            SG_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830((_Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2.xyz), _Split_484f417dccca44c8aa91b01ad6e49ac0_A_4, _Multiply_362659b6eca74e09ab45550154f1dc08_Out_2, _Multiply_a09345b9701041799b426d68bdf46c2b_Out_2, _Property_25e6c6c8207b4543936545ce21c0f1cf_Out_0, _Multiply_3cc6f9ea17204e85b475424edb8cf7b4_Out_2, (_SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.xyz), _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_R_4, (_Multiply_5a00473c36a34df08239ece69cc4d8b1_Out_2.xyz), _Multiply_5b18d24ab4984169a8750d5d8bc7c7eb_Out_2, _Property_2b46e454918e476bbeeaa384671e06c2_Out_0, _Property_9e9482f4911345058781c44dedc65edf_Out_0, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Color_1, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Alpha_2, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_ShadeColor_3);
            Bindings_MixFog_e65d935e3c006a842b7a2fb6063b4b4d _MixFog_e5064454c4c144499f876fa4011590de;
            _MixFog_e5064454c4c144499f876fa4011590de.ObjectSpacePosition = IN.ObjectSpacePosition;
            float3 _MixFog_e5064454c4c144499f876fa4011590de_Color_3;
            SG_MixFog_e65d935e3c006a842b7a2fb6063b4b4d(_ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Color_1, _MixFog_e5064454c4c144499f876fa4011590de, _MixFog_e5064454c4c144499f876fa4011590de_Color_3);
            float _Property_882cff1dec7a4da98464f7de57dd5f19_Out_0 = _OutlineIntensity;
            float3 _Multiply_e943b2b705324ca59a9fdffa8e1e84dc_Out_2;
            Unity_Multiply_float(_ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_ShadeColor_3, (_Property_882cff1dec7a4da98464f7de57dd5f19_Out_0.xxx), _Multiply_e943b2b705324ca59a9fdffa8e1e84dc_Out_2);
            Bindings_MixFog_e65d935e3c006a842b7a2fb6063b4b4d _MixFog_0976268cece74edf9f0443518d64e07a;
            _MixFog_0976268cece74edf9f0443518d64e07a.ObjectSpacePosition = IN.ObjectSpacePosition;
            float3 _MixFog_0976268cece74edf9f0443518d64e07a_Color_3;
            SG_MixFog_e65d935e3c006a842b7a2fb6063b4b4d(_Multiply_e943b2b705324ca59a9fdffa8e1e84dc_Out_2, _MixFog_0976268cece74edf9f0443518d64e07a, _MixFog_0976268cece74edf9f0443518d64e07a_Color_3);
            surface.BaseColor = _MixFog_e5064454c4c144499f876fa4011590de_Color_3;
            surface.Alpha = _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Alpha_2;
            surface.AlphaClipThreshold = 0.5;
            surface.OutlineColor = _MixFog_0976268cece74edf9f0443518d64e07a_Color_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.uv0 =                         input.uv0;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);

        	// use bitangent on the fly like in hdrp
        	// IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
        	float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);

            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph

        	// to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
        	// This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
        	output.WorldSpaceBiTangent =         renormFactor*bitang;

            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Assets/jp.lilium.toongraph/Editor/ShaderGraph/ToonOutlinePass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Front
        Blend One Zero
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor;
        float4 _BaseMap_TexelSize;
        float4 _ShadeEnvironmentalColor;
        float4 _ShadeColor;
        float4 _ShadeMap_TexelSize;
        float _Smoothness;
        float _Metalic;
        float _Curvature;
        float4 Texture2D_d5a96518bbf24f11aff81031d9fbd97d_TexelSize;
        float4 _MetalicMap_TexelSize;
        float4 _BumpMap_TexelSize;
        float4 _OcclusionMap_TexelSize;
        float _Shade;
        float4 _ShadowMap_TexelSize;
        float4 _EmissionColor;
        float4 _EmissionMap_TexelSize;
        float _OutlineWidth;
        float4 _OutlineMap_TexelSize;
        float _ShadeToony;
        float _ToonyLighting;
        float _OutlineIntensity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_ShadeMap);
        SAMPLER(sampler_ShadeMap);
        TEXTURE2D(Texture2D_d5a96518bbf24f11aff81031d9fbd97d);
        SAMPLER(samplerTexture2D_d5a96518bbf24f11aff81031d9fbd97d);
        TEXTURE2D(_MetalicMap);
        SAMPLER(sampler_MetalicMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_ShadowMap);
        SAMPLER(sampler_ShadowMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_OutlineMap);
        SAMPLER(sampler_OutlineMap);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        // 45bb95d39362be0a3d23a808df58e263
        #include "Assets/jp.lilium.toongraph/Contents/Shader/ToonLightingSmoothstepRamp.hlsl"

        struct Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
        };

        void SG_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830(float3 Vector3_F836E644, float Vector1_4314B010, float4 Color_c394a829605a4bbd960d0a173370c56d, float Vector1_17cc6dcabd4041ba8c42d4eabd899dc4, float Vector1_328D12DB, float4 Color_625E7FA7, float3 Vector3_A82C1F5A, float Vector1_CA473DD5, float3 Vector3_248C1ED5, float Vector1_13346DDE, float Vector1_A8A74B72, float Vector1_8507BB4B, Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830 IN, out half3 Color_1, out half Alpha_2, out half3 ShadeColor_3)
        {
            float3 _Property_31f568d740a64ee5b41bd1e18b692f82_Out_0 = Vector3_F836E644;
            float4 _Property_ae3ecbd1416b4ae4a46c0860af87b2e9_Out_0 = Color_c394a829605a4bbd960d0a173370c56d;
            float3 _Property_3406a60a3c6d440991096282196a1c46_Out_0 = Vector3_A82C1F5A;
            float4 _Property_d6e67016be4b418e8a3f32de3b94681a_Out_0 = Color_625E7FA7;
            float _Property_e4e4db6a878044c399d4415afbb848c5_Out_0 = Vector1_328D12DB;
            float _Property_a5f2fab578bf4e338f9a1f6d6e4b6d00_Out_0 = Vector1_CA473DD5;
            float3 _Property_22bb99e9d5444c81af92426da216b3f7_Out_0 = Vector3_248C1ED5;
            float _Property_65f25cda39974603b95cf57fdb28e808_Out_0 = Vector1_4314B010;
            float _Property_4e1b490fa0af4c79beb5438b6535e73c_Out_0 = Vector1_13346DDE;
            float _Property_56490d6edc6c4d2ba46855b9cb7f7b49_Out_0 = Vector1_A8A74B72;
            float _Property_7b962570b81342d1b4d72b83e1cb1e3f_Out_0 = Vector1_17cc6dcabd4041ba8c42d4eabd899dc4;
            float _Property_af2080c2481140edaa8dd97ec51452bf_Out_0 = Vector1_8507BB4B;
            half4 _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0;
            half3 _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_ShadeColor_20;
            ToonLight_half(IN.ObjectSpacePosition, IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceViewDirection, _Property_31f568d740a64ee5b41bd1e18b692f82_Out_0, _Property_ae3ecbd1416b4ae4a46c0860af87b2e9_Out_0, _Property_3406a60a3c6d440991096282196a1c46_Out_0, (_Property_d6e67016be4b418e8a3f32de3b94681a_Out_0.xyz), _Property_e4e4db6a878044c399d4415afbb848c5_Out_0, _Property_a5f2fab578bf4e338f9a1f6d6e4b6d00_Out_0, _Property_22bb99e9d5444c81af92426da216b3f7_Out_0, _Property_65f25cda39974603b95cf57fdb28e808_Out_0, _Property_4e1b490fa0af4c79beb5438b6535e73c_Out_0, _Property_56490d6edc6c4d2ba46855b9cb7f7b49_Out_0, _Property_7b962570b81342d1b4d72b83e1cb1e3f_Out_0, _Property_af2080c2481140edaa8dd97ec51452bf_Out_0, _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0, _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_ShadeColor_20);
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_R_1 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[0];
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_G_2 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[1];
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_B_3 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[2];
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_A_4 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[3];
            Color_1 = (_ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0.xyz);
            Alpha_2 = _Split_9e9eebec5ff840fba5de5a2a051495ed_A_4;
            ShadeColor_3 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_ShadeColor_20;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_5d8ac4a251d84d4fa7986e1193e70da2_Out_0 = _BaseColor;
            UnityTexture2D _Property_b99b572259ca455cb15668511e3a76c4_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b99b572259ca455cb15668511e3a76c4_Out_0.tex, _Property_b99b572259ca455cb15668511e3a76c4_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_R_4 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.r;
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_G_5 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.g;
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_B_6 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.b;
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_A_7 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.a;
            float4 _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2;
            Unity_Multiply_float(_Property_5d8ac4a251d84d4fa7986e1193e70da2_Out_0, _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0, _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2);
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_R_1 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[0];
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_G_2 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[1];
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_B_3 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[2];
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_A_4 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[3];
            float4 _Property_636d8bdc04954f5497aa4b2cd0510a8e_Out_0 = _ShadeColor;
            UnityTexture2D _Property_94ea4828a0ed4321827fd4247c3e3f6c_Out_0 = UnityBuildTexture2DStructNoScale(_ShadeMap);
            float4 _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_94ea4828a0ed4321827fd4247c3e3f6c_Out_0.tex, _Property_94ea4828a0ed4321827fd4247c3e3f6c_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_R_4 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.r;
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_G_5 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.g;
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_B_6 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.b;
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_A_7 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.a;
            float4 _Multiply_362659b6eca74e09ab45550154f1dc08_Out_2;
            Unity_Multiply_float(_Property_636d8bdc04954f5497aa4b2cd0510a8e_Out_0, _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0, _Multiply_362659b6eca74e09ab45550154f1dc08_Out_2);
            float _Property_fd4f3aeee3af4897956a9bfea83e8ff2_Out_0 = _Curvature;
            UnityTexture2D _Property_b6fbff5e115249c6b7e9d1cfd0b67730_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_d5a96518bbf24f11aff81031d9fbd97d);
            float4 _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b6fbff5e115249c6b7e9d1cfd0b67730_Out_0.tex, _Property_b6fbff5e115249c6b7e9d1cfd0b67730_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_R_4 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.r;
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_G_5 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.g;
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_B_6 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.b;
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_A_7 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.a;
            float _OneMinus_51358182e28d43d786253d9ff413e1ba_Out_1;
            Unity_OneMinus_float(_SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_R_4, _OneMinus_51358182e28d43d786253d9ff413e1ba_Out_1);
            float _Multiply_a09345b9701041799b426d68bdf46c2b_Out_2;
            Unity_Multiply_float(_Property_fd4f3aeee3af4897956a9bfea83e8ff2_Out_0, _OneMinus_51358182e28d43d786253d9ff413e1ba_Out_1, _Multiply_a09345b9701041799b426d68bdf46c2b_Out_2);
            float _Property_25e6c6c8207b4543936545ce21c0f1cf_Out_0 = _Smoothness;
            float _Property_ed24ac9afcec458193f4ca80d3433d26_Out_0 = _Metalic;
            UnityTexture2D _Property_8d46a693a34244728f8994000a7aedf2_Out_0 = UnityBuildTexture2DStructNoScale(_MetalicMap);
            float4 _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_8d46a693a34244728f8994000a7aedf2_Out_0.tex, _Property_8d46a693a34244728f8994000a7aedf2_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_R_4 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.r;
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_G_5 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.g;
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_B_6 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.b;
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_A_7 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.a;
            float4 _Multiply_3cc6f9ea17204e85b475424edb8cf7b4_Out_2;
            Unity_Multiply_float((_Property_ed24ac9afcec458193f4ca80d3433d26_Out_0.xxxx), _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0, _Multiply_3cc6f9ea17204e85b475424edb8cf7b4_Out_2);
            UnityTexture2D _Property_d93c6a66728e4177a22ce3d7ab635285_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            float4 _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d93c6a66728e4177a22ce3d7ab635285_Out_0.tex, _Property_d93c6a66728e4177a22ce3d7ab635285_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0);
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_R_4 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.r;
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_G_5 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.g;
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_B_6 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.b;
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_A_7 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.a;
            UnityTexture2D _Property_4f7e9183e76b43988062dfb0174af827_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            float4 _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4f7e9183e76b43988062dfb0174af827_Out_0.tex, _Property_4f7e9183e76b43988062dfb0174af827_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_R_4 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.r;
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_G_5 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.g;
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_B_6 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.b;
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_A_7 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.a;
            float4 _Property_7586886eeb5f45e6b097de3ce5740b5a_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            UnityTexture2D _Property_9a0067ba56784933a899c04948d4fc14_Out_0 = UnityBuildTexture2DStructNoScale(_EmissionMap);
            float4 _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9a0067ba56784933a899c04948d4fc14_Out_0.tex, _Property_9a0067ba56784933a899c04948d4fc14_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_R_4 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.r;
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_G_5 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.g;
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_B_6 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.b;
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_A_7 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.a;
            float4 _Multiply_5a00473c36a34df08239ece69cc4d8b1_Out_2;
            Unity_Multiply_float(_Property_7586886eeb5f45e6b097de3ce5740b5a_Out_0, _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0, _Multiply_5a00473c36a34df08239ece69cc4d8b1_Out_2);
            float _Property_ba7bcca39adb43e6b719c9a3f7aa42c1_Out_0 = _Shade;
            UnityTexture2D _Property_df41400fc48c4dc0a9116f719671d999_Out_0 = UnityBuildTexture2DStructNoScale(_ShadowMap);
            float4 _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_df41400fc48c4dc0a9116f719671d999_Out_0.tex, _Property_df41400fc48c4dc0a9116f719671d999_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_R_4 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.r;
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_G_5 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.g;
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_B_6 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.b;
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_A_7 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.a;
            float _Multiply_5b18d24ab4984169a8750d5d8bc7c7eb_Out_2;
            Unity_Multiply_float(_Property_ba7bcca39adb43e6b719c9a3f7aa42c1_Out_0, _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_R_4, _Multiply_5b18d24ab4984169a8750d5d8bc7c7eb_Out_2);
            float _Property_2b46e454918e476bbeeaa384671e06c2_Out_0 = _ShadeToony;
            float _Property_9e9482f4911345058781c44dedc65edf_Out_0 = _ToonyLighting;
            Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830 _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceNormal = IN.WorldSpaceNormal;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceTangent = IN.WorldSpaceTangent;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.ObjectSpacePosition = IN.ObjectSpacePosition;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpacePosition = IN.WorldSpacePosition;
            half3 _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Color_1;
            half _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Alpha_2;
            half3 _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_ShadeColor_3;
            SG_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830((_Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2.xyz), _Split_484f417dccca44c8aa91b01ad6e49ac0_A_4, _Multiply_362659b6eca74e09ab45550154f1dc08_Out_2, _Multiply_a09345b9701041799b426d68bdf46c2b_Out_2, _Property_25e6c6c8207b4543936545ce21c0f1cf_Out_0, _Multiply_3cc6f9ea17204e85b475424edb8cf7b4_Out_2, (_SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.xyz), _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_R_4, (_Multiply_5a00473c36a34df08239ece69cc4d8b1_Out_2.xyz), _Multiply_5b18d24ab4984169a8750d5d8bc7c7eb_Out_2, _Property_2b46e454918e476bbeeaa384671e06c2_Out_0, _Property_9e9482f4911345058781c44dedc65edf_Out_0, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Color_1, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Alpha_2, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_ShadeColor_3);
            surface.Alpha = _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Alpha_2;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);

        	// use bitangent on the fly like in hdrp
        	// IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
        	float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);

            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph

        	// to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
        	// This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
        	output.WorldSpaceBiTangent =         renormFactor*bitang;

            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor;
        float4 _BaseMap_TexelSize;
        float4 _ShadeEnvironmentalColor;
        float4 _ShadeColor;
        float4 _ShadeMap_TexelSize;
        float _Smoothness;
        float _Metalic;
        float _Curvature;
        float4 Texture2D_d5a96518bbf24f11aff81031d9fbd97d_TexelSize;
        float4 _MetalicMap_TexelSize;
        float4 _BumpMap_TexelSize;
        float4 _OcclusionMap_TexelSize;
        float _Shade;
        float4 _ShadowMap_TexelSize;
        float4 _EmissionColor;
        float4 _EmissionMap_TexelSize;
        float _OutlineWidth;
        float4 _OutlineMap_TexelSize;
        float _ShadeToony;
        float _ToonyLighting;
        float _OutlineIntensity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_ShadeMap);
        SAMPLER(sampler_ShadeMap);
        TEXTURE2D(Texture2D_d5a96518bbf24f11aff81031d9fbd97d);
        SAMPLER(samplerTexture2D_d5a96518bbf24f11aff81031d9fbd97d);
        TEXTURE2D(_MetalicMap);
        SAMPLER(sampler_MetalicMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_ShadowMap);
        SAMPLER(sampler_ShadowMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_OutlineMap);
        SAMPLER(sampler_OutlineMap);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        // 45bb95d39362be0a3d23a808df58e263
        #include "Assets/jp.lilium.toongraph/Contents/Shader/ToonLightingSmoothstepRamp.hlsl"

        struct Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
        };

        void SG_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830(float3 Vector3_F836E644, float Vector1_4314B010, float4 Color_c394a829605a4bbd960d0a173370c56d, float Vector1_17cc6dcabd4041ba8c42d4eabd899dc4, float Vector1_328D12DB, float4 Color_625E7FA7, float3 Vector3_A82C1F5A, float Vector1_CA473DD5, float3 Vector3_248C1ED5, float Vector1_13346DDE, float Vector1_A8A74B72, float Vector1_8507BB4B, Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830 IN, out half3 Color_1, out half Alpha_2, out half3 ShadeColor_3)
        {
            float3 _Property_31f568d740a64ee5b41bd1e18b692f82_Out_0 = Vector3_F836E644;
            float4 _Property_ae3ecbd1416b4ae4a46c0860af87b2e9_Out_0 = Color_c394a829605a4bbd960d0a173370c56d;
            float3 _Property_3406a60a3c6d440991096282196a1c46_Out_0 = Vector3_A82C1F5A;
            float4 _Property_d6e67016be4b418e8a3f32de3b94681a_Out_0 = Color_625E7FA7;
            float _Property_e4e4db6a878044c399d4415afbb848c5_Out_0 = Vector1_328D12DB;
            float _Property_a5f2fab578bf4e338f9a1f6d6e4b6d00_Out_0 = Vector1_CA473DD5;
            float3 _Property_22bb99e9d5444c81af92426da216b3f7_Out_0 = Vector3_248C1ED5;
            float _Property_65f25cda39974603b95cf57fdb28e808_Out_0 = Vector1_4314B010;
            float _Property_4e1b490fa0af4c79beb5438b6535e73c_Out_0 = Vector1_13346DDE;
            float _Property_56490d6edc6c4d2ba46855b9cb7f7b49_Out_0 = Vector1_A8A74B72;
            float _Property_7b962570b81342d1b4d72b83e1cb1e3f_Out_0 = Vector1_17cc6dcabd4041ba8c42d4eabd899dc4;
            float _Property_af2080c2481140edaa8dd97ec51452bf_Out_0 = Vector1_8507BB4B;
            half4 _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0;
            half3 _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_ShadeColor_20;
            ToonLight_half(IN.ObjectSpacePosition, IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceViewDirection, _Property_31f568d740a64ee5b41bd1e18b692f82_Out_0, _Property_ae3ecbd1416b4ae4a46c0860af87b2e9_Out_0, _Property_3406a60a3c6d440991096282196a1c46_Out_0, (_Property_d6e67016be4b418e8a3f32de3b94681a_Out_0.xyz), _Property_e4e4db6a878044c399d4415afbb848c5_Out_0, _Property_a5f2fab578bf4e338f9a1f6d6e4b6d00_Out_0, _Property_22bb99e9d5444c81af92426da216b3f7_Out_0, _Property_65f25cda39974603b95cf57fdb28e808_Out_0, _Property_4e1b490fa0af4c79beb5438b6535e73c_Out_0, _Property_56490d6edc6c4d2ba46855b9cb7f7b49_Out_0, _Property_7b962570b81342d1b4d72b83e1cb1e3f_Out_0, _Property_af2080c2481140edaa8dd97ec51452bf_Out_0, _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0, _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_ShadeColor_20);
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_R_1 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[0];
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_G_2 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[1];
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_B_3 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[2];
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_A_4 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[3];
            Color_1 = (_ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0.xyz);
            Alpha_2 = _Split_9e9eebec5ff840fba5de5a2a051495ed_A_4;
            ShadeColor_3 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_ShadeColor_20;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_5d8ac4a251d84d4fa7986e1193e70da2_Out_0 = _BaseColor;
            UnityTexture2D _Property_b99b572259ca455cb15668511e3a76c4_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b99b572259ca455cb15668511e3a76c4_Out_0.tex, _Property_b99b572259ca455cb15668511e3a76c4_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_R_4 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.r;
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_G_5 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.g;
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_B_6 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.b;
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_A_7 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.a;
            float4 _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2;
            Unity_Multiply_float(_Property_5d8ac4a251d84d4fa7986e1193e70da2_Out_0, _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0, _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2);
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_R_1 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[0];
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_G_2 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[1];
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_B_3 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[2];
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_A_4 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[3];
            float4 _Property_636d8bdc04954f5497aa4b2cd0510a8e_Out_0 = _ShadeColor;
            UnityTexture2D _Property_94ea4828a0ed4321827fd4247c3e3f6c_Out_0 = UnityBuildTexture2DStructNoScale(_ShadeMap);
            float4 _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_94ea4828a0ed4321827fd4247c3e3f6c_Out_0.tex, _Property_94ea4828a0ed4321827fd4247c3e3f6c_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_R_4 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.r;
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_G_5 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.g;
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_B_6 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.b;
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_A_7 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.a;
            float4 _Multiply_362659b6eca74e09ab45550154f1dc08_Out_2;
            Unity_Multiply_float(_Property_636d8bdc04954f5497aa4b2cd0510a8e_Out_0, _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0, _Multiply_362659b6eca74e09ab45550154f1dc08_Out_2);
            float _Property_fd4f3aeee3af4897956a9bfea83e8ff2_Out_0 = _Curvature;
            UnityTexture2D _Property_b6fbff5e115249c6b7e9d1cfd0b67730_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_d5a96518bbf24f11aff81031d9fbd97d);
            float4 _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b6fbff5e115249c6b7e9d1cfd0b67730_Out_0.tex, _Property_b6fbff5e115249c6b7e9d1cfd0b67730_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_R_4 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.r;
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_G_5 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.g;
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_B_6 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.b;
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_A_7 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.a;
            float _OneMinus_51358182e28d43d786253d9ff413e1ba_Out_1;
            Unity_OneMinus_float(_SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_R_4, _OneMinus_51358182e28d43d786253d9ff413e1ba_Out_1);
            float _Multiply_a09345b9701041799b426d68bdf46c2b_Out_2;
            Unity_Multiply_float(_Property_fd4f3aeee3af4897956a9bfea83e8ff2_Out_0, _OneMinus_51358182e28d43d786253d9ff413e1ba_Out_1, _Multiply_a09345b9701041799b426d68bdf46c2b_Out_2);
            float _Property_25e6c6c8207b4543936545ce21c0f1cf_Out_0 = _Smoothness;
            float _Property_ed24ac9afcec458193f4ca80d3433d26_Out_0 = _Metalic;
            UnityTexture2D _Property_8d46a693a34244728f8994000a7aedf2_Out_0 = UnityBuildTexture2DStructNoScale(_MetalicMap);
            float4 _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_8d46a693a34244728f8994000a7aedf2_Out_0.tex, _Property_8d46a693a34244728f8994000a7aedf2_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_R_4 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.r;
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_G_5 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.g;
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_B_6 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.b;
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_A_7 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.a;
            float4 _Multiply_3cc6f9ea17204e85b475424edb8cf7b4_Out_2;
            Unity_Multiply_float((_Property_ed24ac9afcec458193f4ca80d3433d26_Out_0.xxxx), _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0, _Multiply_3cc6f9ea17204e85b475424edb8cf7b4_Out_2);
            UnityTexture2D _Property_d93c6a66728e4177a22ce3d7ab635285_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            float4 _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d93c6a66728e4177a22ce3d7ab635285_Out_0.tex, _Property_d93c6a66728e4177a22ce3d7ab635285_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0);
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_R_4 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.r;
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_G_5 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.g;
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_B_6 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.b;
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_A_7 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.a;
            UnityTexture2D _Property_4f7e9183e76b43988062dfb0174af827_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            float4 _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4f7e9183e76b43988062dfb0174af827_Out_0.tex, _Property_4f7e9183e76b43988062dfb0174af827_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_R_4 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.r;
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_G_5 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.g;
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_B_6 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.b;
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_A_7 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.a;
            float4 _Property_7586886eeb5f45e6b097de3ce5740b5a_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            UnityTexture2D _Property_9a0067ba56784933a899c04948d4fc14_Out_0 = UnityBuildTexture2DStructNoScale(_EmissionMap);
            float4 _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9a0067ba56784933a899c04948d4fc14_Out_0.tex, _Property_9a0067ba56784933a899c04948d4fc14_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_R_4 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.r;
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_G_5 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.g;
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_B_6 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.b;
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_A_7 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.a;
            float4 _Multiply_5a00473c36a34df08239ece69cc4d8b1_Out_2;
            Unity_Multiply_float(_Property_7586886eeb5f45e6b097de3ce5740b5a_Out_0, _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0, _Multiply_5a00473c36a34df08239ece69cc4d8b1_Out_2);
            float _Property_ba7bcca39adb43e6b719c9a3f7aa42c1_Out_0 = _Shade;
            UnityTexture2D _Property_df41400fc48c4dc0a9116f719671d999_Out_0 = UnityBuildTexture2DStructNoScale(_ShadowMap);
            float4 _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_df41400fc48c4dc0a9116f719671d999_Out_0.tex, _Property_df41400fc48c4dc0a9116f719671d999_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_R_4 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.r;
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_G_5 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.g;
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_B_6 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.b;
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_A_7 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.a;
            float _Multiply_5b18d24ab4984169a8750d5d8bc7c7eb_Out_2;
            Unity_Multiply_float(_Property_ba7bcca39adb43e6b719c9a3f7aa42c1_Out_0, _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_R_4, _Multiply_5b18d24ab4984169a8750d5d8bc7c7eb_Out_2);
            float _Property_2b46e454918e476bbeeaa384671e06c2_Out_0 = _ShadeToony;
            float _Property_9e9482f4911345058781c44dedc65edf_Out_0 = _ToonyLighting;
            Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830 _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceNormal = IN.WorldSpaceNormal;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceTangent = IN.WorldSpaceTangent;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.ObjectSpacePosition = IN.ObjectSpacePosition;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpacePosition = IN.WorldSpacePosition;
            half3 _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Color_1;
            half _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Alpha_2;
            half3 _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_ShadeColor_3;
            SG_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830((_Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2.xyz), _Split_484f417dccca44c8aa91b01ad6e49ac0_A_4, _Multiply_362659b6eca74e09ab45550154f1dc08_Out_2, _Multiply_a09345b9701041799b426d68bdf46c2b_Out_2, _Property_25e6c6c8207b4543936545ce21c0f1cf_Out_0, _Multiply_3cc6f9ea17204e85b475424edb8cf7b4_Out_2, (_SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.xyz), _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_R_4, (_Multiply_5a00473c36a34df08239ece69cc4d8b1_Out_2.xyz), _Multiply_5b18d24ab4984169a8750d5d8bc7c7eb_Out_2, _Property_2b46e454918e476bbeeaa384671e06c2_Out_0, _Property_9e9482f4911345058781c44dedc65edf_Out_0, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Color_1, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Alpha_2, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_ShadeColor_3);
            surface.Alpha = _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Alpha_2;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);

        	// use bitangent on the fly like in hdrp
        	// IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
        	float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);

            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph

        	// to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
        	// This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
        	output.WorldSpaceBiTangent =         renormFactor*bitang;

            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "Queue"="AlphaTest"
        }
        Pass
        {
            Name "Lilium Toon"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_UNLIT
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if defined(LIGHTMAP_ON)
            float2 interp5 : TEXCOORD5;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp6 : TEXCOORD6;
            #endif
            float4 interp7 : TEXCOORD7;
            float4 interp8 : TEXCOORD8;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            output.interp8.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor;
        float4 _BaseMap_TexelSize;
        float4 _ShadeEnvironmentalColor;
        float4 _ShadeColor;
        float4 _ShadeMap_TexelSize;
        float _Smoothness;
        float _Metalic;
        float _Curvature;
        float4 Texture2D_d5a96518bbf24f11aff81031d9fbd97d_TexelSize;
        float4 _MetalicMap_TexelSize;
        float4 _BumpMap_TexelSize;
        float4 _OcclusionMap_TexelSize;
        float _Shade;
        float4 _ShadowMap_TexelSize;
        float4 _EmissionColor;
        float4 _EmissionMap_TexelSize;
        float _OutlineWidth;
        float4 _OutlineMap_TexelSize;
        float _ShadeToony;
        float _ToonyLighting;
        float _OutlineIntensity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_ShadeMap);
        SAMPLER(sampler_ShadeMap);
        TEXTURE2D(Texture2D_d5a96518bbf24f11aff81031d9fbd97d);
        SAMPLER(samplerTexture2D_d5a96518bbf24f11aff81031d9fbd97d);
        TEXTURE2D(_MetalicMap);
        SAMPLER(sampler_MetalicMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_ShadowMap);
        SAMPLER(sampler_ShadowMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_OutlineMap);
        SAMPLER(sampler_OutlineMap);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        // 45bb95d39362be0a3d23a808df58e263
        #include "Assets/jp.lilium.toongraph/Contents/Shader/ToonLightingSmoothstepRamp.hlsl"

        struct Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
        };

        void SG_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830(float3 Vector3_F836E644, float Vector1_4314B010, float4 Color_c394a829605a4bbd960d0a173370c56d, float Vector1_17cc6dcabd4041ba8c42d4eabd899dc4, float Vector1_328D12DB, float4 Color_625E7FA7, float3 Vector3_A82C1F5A, float Vector1_CA473DD5, float3 Vector3_248C1ED5, float Vector1_13346DDE, float Vector1_A8A74B72, float Vector1_8507BB4B, Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830 IN, out half3 Color_1, out half Alpha_2, out half3 ShadeColor_3)
        {
            float3 _Property_31f568d740a64ee5b41bd1e18b692f82_Out_0 = Vector3_F836E644;
            float4 _Property_ae3ecbd1416b4ae4a46c0860af87b2e9_Out_0 = Color_c394a829605a4bbd960d0a173370c56d;
            float3 _Property_3406a60a3c6d440991096282196a1c46_Out_0 = Vector3_A82C1F5A;
            float4 _Property_d6e67016be4b418e8a3f32de3b94681a_Out_0 = Color_625E7FA7;
            float _Property_e4e4db6a878044c399d4415afbb848c5_Out_0 = Vector1_328D12DB;
            float _Property_a5f2fab578bf4e338f9a1f6d6e4b6d00_Out_0 = Vector1_CA473DD5;
            float3 _Property_22bb99e9d5444c81af92426da216b3f7_Out_0 = Vector3_248C1ED5;
            float _Property_65f25cda39974603b95cf57fdb28e808_Out_0 = Vector1_4314B010;
            float _Property_4e1b490fa0af4c79beb5438b6535e73c_Out_0 = Vector1_13346DDE;
            float _Property_56490d6edc6c4d2ba46855b9cb7f7b49_Out_0 = Vector1_A8A74B72;
            float _Property_7b962570b81342d1b4d72b83e1cb1e3f_Out_0 = Vector1_17cc6dcabd4041ba8c42d4eabd899dc4;
            float _Property_af2080c2481140edaa8dd97ec51452bf_Out_0 = Vector1_8507BB4B;
            half4 _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0;
            half3 _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_ShadeColor_20;
            ToonLight_half(IN.ObjectSpacePosition, IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceViewDirection, _Property_31f568d740a64ee5b41bd1e18b692f82_Out_0, _Property_ae3ecbd1416b4ae4a46c0860af87b2e9_Out_0, _Property_3406a60a3c6d440991096282196a1c46_Out_0, (_Property_d6e67016be4b418e8a3f32de3b94681a_Out_0.xyz), _Property_e4e4db6a878044c399d4415afbb848c5_Out_0, _Property_a5f2fab578bf4e338f9a1f6d6e4b6d00_Out_0, _Property_22bb99e9d5444c81af92426da216b3f7_Out_0, _Property_65f25cda39974603b95cf57fdb28e808_Out_0, _Property_4e1b490fa0af4c79beb5438b6535e73c_Out_0, _Property_56490d6edc6c4d2ba46855b9cb7f7b49_Out_0, _Property_7b962570b81342d1b4d72b83e1cb1e3f_Out_0, _Property_af2080c2481140edaa8dd97ec51452bf_Out_0, _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0, _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_ShadeColor_20);
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_R_1 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[0];
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_G_2 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[1];
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_B_3 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[2];
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_A_4 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[3];
            Color_1 = (_ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0.xyz);
            Alpha_2 = _Split_9e9eebec5ff840fba5de5a2a051495ed_A_4;
            ShadeColor_3 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_ShadeColor_20;
        }

        void Unity_Fog_float(out float4 Color, out float Density, float3 Position)
        {
            SHADERGRAPH_FOG(Position, Color, Density);
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }

        struct Bindings_MixFog_e65d935e3c006a842b7a2fb6063b4b4d
        {
            float3 ObjectSpacePosition;
        };

        void SG_MixFog_e65d935e3c006a842b7a2fb6063b4b4d(float3 Vector3_33E0F5E1, Bindings_MixFog_e65d935e3c006a842b7a2fb6063b4b4d IN, out float3 Color_3)
        {
            float3 _Property_2784bf39139949af90f15cb6ee88a0df_Out_0 = Vector3_33E0F5E1;
            float4 _Fog_d4220d532719413c85621841df5e2098_Color_0;
            float _Fog_d4220d532719413c85621841df5e2098_Density_1;
            Unity_Fog_float(_Fog_d4220d532719413c85621841df5e2098_Color_0, _Fog_d4220d532719413c85621841df5e2098_Density_1, IN.ObjectSpacePosition);
            float _Multiply_6523b09d1d3a45f2ba923f5e9a53f89d_Out_2;
            Unity_Multiply_float(_Fog_d4220d532719413c85621841df5e2098_Density_1, 0.5, _Multiply_6523b09d1d3a45f2ba923f5e9a53f89d_Out_2);
            float _Clamp_54ff10dfa66b48e084bb9a79dfcaabd5_Out_3;
            Unity_Clamp_float(_Multiply_6523b09d1d3a45f2ba923f5e9a53f89d_Out_2, 0, 1, _Clamp_54ff10dfa66b48e084bb9a79dfcaabd5_Out_3);
            float3 _Lerp_0a061577e6824a22b2c504f65c3c4af7_Out_3;
            Unity_Lerp_float3(_Property_2784bf39139949af90f15cb6ee88a0df_Out_0, (_Fog_d4220d532719413c85621841df5e2098_Color_0.xyz), (_Clamp_54ff10dfa66b48e084bb9a79dfcaabd5_Out_3.xxx), _Lerp_0a061577e6824a22b2c504f65c3c4af7_Out_3);
            Color_3 = _Lerp_0a061577e6824a22b2c504f65c3c4af7_Out_3;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_5d8ac4a251d84d4fa7986e1193e70da2_Out_0 = _BaseColor;
            UnityTexture2D _Property_b99b572259ca455cb15668511e3a76c4_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b99b572259ca455cb15668511e3a76c4_Out_0.tex, _Property_b99b572259ca455cb15668511e3a76c4_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_R_4 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.r;
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_G_5 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.g;
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_B_6 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.b;
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_A_7 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.a;
            float4 _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2;
            Unity_Multiply_float(_Property_5d8ac4a251d84d4fa7986e1193e70da2_Out_0, _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0, _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2);
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_R_1 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[0];
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_G_2 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[1];
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_B_3 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[2];
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_A_4 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[3];
            float4 _Property_636d8bdc04954f5497aa4b2cd0510a8e_Out_0 = _ShadeColor;
            UnityTexture2D _Property_94ea4828a0ed4321827fd4247c3e3f6c_Out_0 = UnityBuildTexture2DStructNoScale(_ShadeMap);
            float4 _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_94ea4828a0ed4321827fd4247c3e3f6c_Out_0.tex, _Property_94ea4828a0ed4321827fd4247c3e3f6c_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_R_4 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.r;
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_G_5 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.g;
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_B_6 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.b;
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_A_7 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.a;
            float4 _Multiply_362659b6eca74e09ab45550154f1dc08_Out_2;
            Unity_Multiply_float(_Property_636d8bdc04954f5497aa4b2cd0510a8e_Out_0, _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0, _Multiply_362659b6eca74e09ab45550154f1dc08_Out_2);
            float _Property_fd4f3aeee3af4897956a9bfea83e8ff2_Out_0 = _Curvature;
            UnityTexture2D _Property_b6fbff5e115249c6b7e9d1cfd0b67730_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_d5a96518bbf24f11aff81031d9fbd97d);
            float4 _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b6fbff5e115249c6b7e9d1cfd0b67730_Out_0.tex, _Property_b6fbff5e115249c6b7e9d1cfd0b67730_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_R_4 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.r;
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_G_5 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.g;
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_B_6 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.b;
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_A_7 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.a;
            float _OneMinus_51358182e28d43d786253d9ff413e1ba_Out_1;
            Unity_OneMinus_float(_SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_R_4, _OneMinus_51358182e28d43d786253d9ff413e1ba_Out_1);
            float _Multiply_a09345b9701041799b426d68bdf46c2b_Out_2;
            Unity_Multiply_float(_Property_fd4f3aeee3af4897956a9bfea83e8ff2_Out_0, _OneMinus_51358182e28d43d786253d9ff413e1ba_Out_1, _Multiply_a09345b9701041799b426d68bdf46c2b_Out_2);
            float _Property_25e6c6c8207b4543936545ce21c0f1cf_Out_0 = _Smoothness;
            float _Property_ed24ac9afcec458193f4ca80d3433d26_Out_0 = _Metalic;
            UnityTexture2D _Property_8d46a693a34244728f8994000a7aedf2_Out_0 = UnityBuildTexture2DStructNoScale(_MetalicMap);
            float4 _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_8d46a693a34244728f8994000a7aedf2_Out_0.tex, _Property_8d46a693a34244728f8994000a7aedf2_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_R_4 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.r;
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_G_5 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.g;
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_B_6 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.b;
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_A_7 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.a;
            float4 _Multiply_3cc6f9ea17204e85b475424edb8cf7b4_Out_2;
            Unity_Multiply_float((_Property_ed24ac9afcec458193f4ca80d3433d26_Out_0.xxxx), _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0, _Multiply_3cc6f9ea17204e85b475424edb8cf7b4_Out_2);
            UnityTexture2D _Property_d93c6a66728e4177a22ce3d7ab635285_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            float4 _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d93c6a66728e4177a22ce3d7ab635285_Out_0.tex, _Property_d93c6a66728e4177a22ce3d7ab635285_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0);
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_R_4 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.r;
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_G_5 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.g;
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_B_6 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.b;
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_A_7 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.a;
            UnityTexture2D _Property_4f7e9183e76b43988062dfb0174af827_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            float4 _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4f7e9183e76b43988062dfb0174af827_Out_0.tex, _Property_4f7e9183e76b43988062dfb0174af827_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_R_4 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.r;
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_G_5 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.g;
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_B_6 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.b;
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_A_7 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.a;
            float4 _Property_7586886eeb5f45e6b097de3ce5740b5a_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            UnityTexture2D _Property_9a0067ba56784933a899c04948d4fc14_Out_0 = UnityBuildTexture2DStructNoScale(_EmissionMap);
            float4 _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9a0067ba56784933a899c04948d4fc14_Out_0.tex, _Property_9a0067ba56784933a899c04948d4fc14_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_R_4 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.r;
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_G_5 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.g;
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_B_6 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.b;
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_A_7 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.a;
            float4 _Multiply_5a00473c36a34df08239ece69cc4d8b1_Out_2;
            Unity_Multiply_float(_Property_7586886eeb5f45e6b097de3ce5740b5a_Out_0, _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0, _Multiply_5a00473c36a34df08239ece69cc4d8b1_Out_2);
            float _Property_ba7bcca39adb43e6b719c9a3f7aa42c1_Out_0 = _Shade;
            UnityTexture2D _Property_df41400fc48c4dc0a9116f719671d999_Out_0 = UnityBuildTexture2DStructNoScale(_ShadowMap);
            float4 _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_df41400fc48c4dc0a9116f719671d999_Out_0.tex, _Property_df41400fc48c4dc0a9116f719671d999_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_R_4 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.r;
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_G_5 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.g;
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_B_6 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.b;
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_A_7 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.a;
            float _Multiply_5b18d24ab4984169a8750d5d8bc7c7eb_Out_2;
            Unity_Multiply_float(_Property_ba7bcca39adb43e6b719c9a3f7aa42c1_Out_0, _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_R_4, _Multiply_5b18d24ab4984169a8750d5d8bc7c7eb_Out_2);
            float _Property_2b46e454918e476bbeeaa384671e06c2_Out_0 = _ShadeToony;
            float _Property_9e9482f4911345058781c44dedc65edf_Out_0 = _ToonyLighting;
            Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830 _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceNormal = IN.WorldSpaceNormal;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceTangent = IN.WorldSpaceTangent;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.ObjectSpacePosition = IN.ObjectSpacePosition;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpacePosition = IN.WorldSpacePosition;
            half3 _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Color_1;
            half _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Alpha_2;
            half3 _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_ShadeColor_3;
            SG_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830((_Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2.xyz), _Split_484f417dccca44c8aa91b01ad6e49ac0_A_4, _Multiply_362659b6eca74e09ab45550154f1dc08_Out_2, _Multiply_a09345b9701041799b426d68bdf46c2b_Out_2, _Property_25e6c6c8207b4543936545ce21c0f1cf_Out_0, _Multiply_3cc6f9ea17204e85b475424edb8cf7b4_Out_2, (_SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.xyz), _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_R_4, (_Multiply_5a00473c36a34df08239ece69cc4d8b1_Out_2.xyz), _Multiply_5b18d24ab4984169a8750d5d8bc7c7eb_Out_2, _Property_2b46e454918e476bbeeaa384671e06c2_Out_0, _Property_9e9482f4911345058781c44dedc65edf_Out_0, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Color_1, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Alpha_2, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_ShadeColor_3);
            Bindings_MixFog_e65d935e3c006a842b7a2fb6063b4b4d _MixFog_e5064454c4c144499f876fa4011590de;
            _MixFog_e5064454c4c144499f876fa4011590de.ObjectSpacePosition = IN.ObjectSpacePosition;
            float3 _MixFog_e5064454c4c144499f876fa4011590de_Color_3;
            SG_MixFog_e65d935e3c006a842b7a2fb6063b4b4d(_ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Color_1, _MixFog_e5064454c4c144499f876fa4011590de, _MixFog_e5064454c4c144499f876fa4011590de_Color_3);
            surface.BaseColor = _MixFog_e5064454c4c144499f876fa4011590de_Color_3;
            surface.Alpha = _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Alpha_2;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);

        	// use bitangent on the fly like in hdrp
        	// IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
        	float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);

            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph

        	// to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
        	// This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
        	output.WorldSpaceBiTangent =         renormFactor*bitang;

            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Assets/jp.lilium.toongraph/Editor/ShaderGraph/ToonForwardPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Lilium Outline"
            Tags
            {
                // LightMode: <None>
            }

            // Render State
            Cull Front
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest Less
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float4 uv0;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if defined(LIGHTMAP_ON)
            float2 interp5 : TEXCOORD5;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp6 : TEXCOORD6;
            #endif
            float4 interp7 : TEXCOORD7;
            float4 interp8 : TEXCOORD8;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            output.interp8.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor;
        float4 _BaseMap_TexelSize;
        float4 _ShadeEnvironmentalColor;
        float4 _ShadeColor;
        float4 _ShadeMap_TexelSize;
        float _Smoothness;
        float _Metalic;
        float _Curvature;
        float4 Texture2D_d5a96518bbf24f11aff81031d9fbd97d_TexelSize;
        float4 _MetalicMap_TexelSize;
        float4 _BumpMap_TexelSize;
        float4 _OcclusionMap_TexelSize;
        float _Shade;
        float4 _ShadowMap_TexelSize;
        float4 _EmissionColor;
        float4 _EmissionMap_TexelSize;
        float _OutlineWidth;
        float4 _OutlineMap_TexelSize;
        float _ShadeToony;
        float _ToonyLighting;
        float _OutlineIntensity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_ShadeMap);
        SAMPLER(sampler_ShadeMap);
        TEXTURE2D(Texture2D_d5a96518bbf24f11aff81031d9fbd97d);
        SAMPLER(samplerTexture2D_d5a96518bbf24f11aff81031d9fbd97d);
        TEXTURE2D(_MetalicMap);
        SAMPLER(sampler_MetalicMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_ShadowMap);
        SAMPLER(sampler_ShadowMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_OutlineMap);
        SAMPLER(sampler_OutlineMap);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        // 39a2adacb021fa0c0e1927055b619ca4
        #include "Assets/jp.lilium.toongraph/Contents/Shader/OutlineTransform.hlsl"

        struct Bindings_ToonOutlineTransform_aadd6ff8a7ff83a4fb272240ac26c2b5
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpacePosition;
        };

        void SG_ToonOutlineTransform_aadd6ff8a7ff83a4fb272240ac26c2b5(float Vector1_78aea86254144fde8d0e857fca6e921b, Bindings_ToonOutlineTransform_aadd6ff8a7ff83a4fb272240ac26c2b5 IN, out float3 OutlinePosition_1)
        {
            float _Property_541479427c4a47ed81b50a74cb77d7b6_Out_0 = Vector1_78aea86254144fde8d0e857fca6e921b;
            float3 _TransformOutlineCustomFunction_41e897d5cb2b40f19b4cd6b9c5726a38_OutlinePosition_4;
            TransformOutline_float(IN.ObjectSpacePosition, IN.ObjectSpaceNormal, _Property_541479427c4a47ed81b50a74cb77d7b6_Out_0, _TransformOutlineCustomFunction_41e897d5cb2b40f19b4cd6b9c5726a38_OutlinePosition_4);
            OutlinePosition_1 = _TransformOutlineCustomFunction_41e897d5cb2b40f19b4cd6b9c5726a38_OutlinePosition_4;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        // 45bb95d39362be0a3d23a808df58e263
        #include "Assets/jp.lilium.toongraph/Contents/Shader/ToonLightingSmoothstepRamp.hlsl"

        struct Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
        };

        void SG_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830(float3 Vector3_F836E644, float Vector1_4314B010, float4 Color_c394a829605a4bbd960d0a173370c56d, float Vector1_17cc6dcabd4041ba8c42d4eabd899dc4, float Vector1_328D12DB, float4 Color_625E7FA7, float3 Vector3_A82C1F5A, float Vector1_CA473DD5, float3 Vector3_248C1ED5, float Vector1_13346DDE, float Vector1_A8A74B72, float Vector1_8507BB4B, Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830 IN, out half3 Color_1, out half Alpha_2, out half3 ShadeColor_3)
        {
            float3 _Property_31f568d740a64ee5b41bd1e18b692f82_Out_0 = Vector3_F836E644;
            float4 _Property_ae3ecbd1416b4ae4a46c0860af87b2e9_Out_0 = Color_c394a829605a4bbd960d0a173370c56d;
            float3 _Property_3406a60a3c6d440991096282196a1c46_Out_0 = Vector3_A82C1F5A;
            float4 _Property_d6e67016be4b418e8a3f32de3b94681a_Out_0 = Color_625E7FA7;
            float _Property_e4e4db6a878044c399d4415afbb848c5_Out_0 = Vector1_328D12DB;
            float _Property_a5f2fab578bf4e338f9a1f6d6e4b6d00_Out_0 = Vector1_CA473DD5;
            float3 _Property_22bb99e9d5444c81af92426da216b3f7_Out_0 = Vector3_248C1ED5;
            float _Property_65f25cda39974603b95cf57fdb28e808_Out_0 = Vector1_4314B010;
            float _Property_4e1b490fa0af4c79beb5438b6535e73c_Out_0 = Vector1_13346DDE;
            float _Property_56490d6edc6c4d2ba46855b9cb7f7b49_Out_0 = Vector1_A8A74B72;
            float _Property_7b962570b81342d1b4d72b83e1cb1e3f_Out_0 = Vector1_17cc6dcabd4041ba8c42d4eabd899dc4;
            float _Property_af2080c2481140edaa8dd97ec51452bf_Out_0 = Vector1_8507BB4B;
            half4 _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0;
            half3 _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_ShadeColor_20;
            ToonLight_half(IN.ObjectSpacePosition, IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceViewDirection, _Property_31f568d740a64ee5b41bd1e18b692f82_Out_0, _Property_ae3ecbd1416b4ae4a46c0860af87b2e9_Out_0, _Property_3406a60a3c6d440991096282196a1c46_Out_0, (_Property_d6e67016be4b418e8a3f32de3b94681a_Out_0.xyz), _Property_e4e4db6a878044c399d4415afbb848c5_Out_0, _Property_a5f2fab578bf4e338f9a1f6d6e4b6d00_Out_0, _Property_22bb99e9d5444c81af92426da216b3f7_Out_0, _Property_65f25cda39974603b95cf57fdb28e808_Out_0, _Property_4e1b490fa0af4c79beb5438b6535e73c_Out_0, _Property_56490d6edc6c4d2ba46855b9cb7f7b49_Out_0, _Property_7b962570b81342d1b4d72b83e1cb1e3f_Out_0, _Property_af2080c2481140edaa8dd97ec51452bf_Out_0, _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0, _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_ShadeColor_20);
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_R_1 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[0];
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_G_2 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[1];
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_B_3 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[2];
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_A_4 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[3];
            Color_1 = (_ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0.xyz);
            Alpha_2 = _Split_9e9eebec5ff840fba5de5a2a051495ed_A_4;
            ShadeColor_3 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_ShadeColor_20;
        }

        void Unity_Fog_float(out float4 Color, out float Density, float3 Position)
        {
            SHADERGRAPH_FOG(Position, Color, Density);
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }

        struct Bindings_MixFog_e65d935e3c006a842b7a2fb6063b4b4d
        {
            float3 ObjectSpacePosition;
        };

        void SG_MixFog_e65d935e3c006a842b7a2fb6063b4b4d(float3 Vector3_33E0F5E1, Bindings_MixFog_e65d935e3c006a842b7a2fb6063b4b4d IN, out float3 Color_3)
        {
            float3 _Property_2784bf39139949af90f15cb6ee88a0df_Out_0 = Vector3_33E0F5E1;
            float4 _Fog_d4220d532719413c85621841df5e2098_Color_0;
            float _Fog_d4220d532719413c85621841df5e2098_Density_1;
            Unity_Fog_float(_Fog_d4220d532719413c85621841df5e2098_Color_0, _Fog_d4220d532719413c85621841df5e2098_Density_1, IN.ObjectSpacePosition);
            float _Multiply_6523b09d1d3a45f2ba923f5e9a53f89d_Out_2;
            Unity_Multiply_float(_Fog_d4220d532719413c85621841df5e2098_Density_1, 0.5, _Multiply_6523b09d1d3a45f2ba923f5e9a53f89d_Out_2);
            float _Clamp_54ff10dfa66b48e084bb9a79dfcaabd5_Out_3;
            Unity_Clamp_float(_Multiply_6523b09d1d3a45f2ba923f5e9a53f89d_Out_2, 0, 1, _Clamp_54ff10dfa66b48e084bb9a79dfcaabd5_Out_3);
            float3 _Lerp_0a061577e6824a22b2c504f65c3c4af7_Out_3;
            Unity_Lerp_float3(_Property_2784bf39139949af90f15cb6ee88a0df_Out_0, (_Fog_d4220d532719413c85621841df5e2098_Color_0.xyz), (_Clamp_54ff10dfa66b48e084bb9a79dfcaabd5_Out_3.xxx), _Lerp_0a061577e6824a22b2c504f65c3c4af7_Out_3);
            Color_3 = _Lerp_0a061577e6824a22b2c504f65c3c4af7_Out_3;
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
            float3 OutlinePosition;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_25acdc7ba0074c9da9c38bbf8de829be_Out_0 = _OutlineWidth;
            UnityTexture2D _Property_727b20b6699c40c6a6524706ace804fd_Out_0 = UnityBuildTexture2DStructNoScale(_OutlineMap);
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_66d48423b6af44f380158486e09f2aa5_RGBA_0 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_66d48423b6af44f380158486e09f2aa5_RGBA_0 = SAMPLE_TEXTURE2D_LOD(_Property_727b20b6699c40c6a6524706ace804fd_Out_0.tex, _Property_727b20b6699c40c6a6524706ace804fd_Out_0.samplerstate, IN.uv0.xy, 0);
            #endif
            float _SampleTexture2DLOD_66d48423b6af44f380158486e09f2aa5_R_5 = _SampleTexture2DLOD_66d48423b6af44f380158486e09f2aa5_RGBA_0.r;
            float _SampleTexture2DLOD_66d48423b6af44f380158486e09f2aa5_G_6 = _SampleTexture2DLOD_66d48423b6af44f380158486e09f2aa5_RGBA_0.g;
            float _SampleTexture2DLOD_66d48423b6af44f380158486e09f2aa5_B_7 = _SampleTexture2DLOD_66d48423b6af44f380158486e09f2aa5_RGBA_0.b;
            float _SampleTexture2DLOD_66d48423b6af44f380158486e09f2aa5_A_8 = _SampleTexture2DLOD_66d48423b6af44f380158486e09f2aa5_RGBA_0.a;
            float _Multiply_8c01c8e41feb44b5bf3dbc8665b453ba_Out_2;
            Unity_Multiply_float(_Property_25acdc7ba0074c9da9c38bbf8de829be_Out_0, _SampleTexture2DLOD_66d48423b6af44f380158486e09f2aa5_R_5, _Multiply_8c01c8e41feb44b5bf3dbc8665b453ba_Out_2);
            Bindings_ToonOutlineTransform_aadd6ff8a7ff83a4fb272240ac26c2b5 _ToonOutlineTransform_9c41895a93344de180bdee6de227dbb5;
            _ToonOutlineTransform_9c41895a93344de180bdee6de227dbb5.ObjectSpaceNormal = IN.ObjectSpaceNormal;
            _ToonOutlineTransform_9c41895a93344de180bdee6de227dbb5.ObjectSpacePosition = IN.ObjectSpacePosition;
            float3 _ToonOutlineTransform_9c41895a93344de180bdee6de227dbb5_OutlinePosition_1;
            SG_ToonOutlineTransform_aadd6ff8a7ff83a4fb272240ac26c2b5(_Multiply_8c01c8e41feb44b5bf3dbc8665b453ba_Out_2, _ToonOutlineTransform_9c41895a93344de180bdee6de227dbb5, _ToonOutlineTransform_9c41895a93344de180bdee6de227dbb5_OutlinePosition_1);
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            description.OutlinePosition = _ToonOutlineTransform_9c41895a93344de180bdee6de227dbb5_OutlinePosition_1;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
            float3 OutlineColor;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_5d8ac4a251d84d4fa7986e1193e70da2_Out_0 = _BaseColor;
            UnityTexture2D _Property_b99b572259ca455cb15668511e3a76c4_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b99b572259ca455cb15668511e3a76c4_Out_0.tex, _Property_b99b572259ca455cb15668511e3a76c4_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_R_4 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.r;
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_G_5 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.g;
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_B_6 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.b;
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_A_7 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.a;
            float4 _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2;
            Unity_Multiply_float(_Property_5d8ac4a251d84d4fa7986e1193e70da2_Out_0, _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0, _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2);
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_R_1 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[0];
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_G_2 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[1];
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_B_3 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[2];
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_A_4 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[3];
            float4 _Property_636d8bdc04954f5497aa4b2cd0510a8e_Out_0 = _ShadeColor;
            UnityTexture2D _Property_94ea4828a0ed4321827fd4247c3e3f6c_Out_0 = UnityBuildTexture2DStructNoScale(_ShadeMap);
            float4 _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_94ea4828a0ed4321827fd4247c3e3f6c_Out_0.tex, _Property_94ea4828a0ed4321827fd4247c3e3f6c_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_R_4 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.r;
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_G_5 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.g;
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_B_6 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.b;
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_A_7 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.a;
            float4 _Multiply_362659b6eca74e09ab45550154f1dc08_Out_2;
            Unity_Multiply_float(_Property_636d8bdc04954f5497aa4b2cd0510a8e_Out_0, _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0, _Multiply_362659b6eca74e09ab45550154f1dc08_Out_2);
            float _Property_fd4f3aeee3af4897956a9bfea83e8ff2_Out_0 = _Curvature;
            UnityTexture2D _Property_b6fbff5e115249c6b7e9d1cfd0b67730_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_d5a96518bbf24f11aff81031d9fbd97d);
            float4 _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b6fbff5e115249c6b7e9d1cfd0b67730_Out_0.tex, _Property_b6fbff5e115249c6b7e9d1cfd0b67730_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_R_4 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.r;
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_G_5 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.g;
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_B_6 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.b;
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_A_7 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.a;
            float _OneMinus_51358182e28d43d786253d9ff413e1ba_Out_1;
            Unity_OneMinus_float(_SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_R_4, _OneMinus_51358182e28d43d786253d9ff413e1ba_Out_1);
            float _Multiply_a09345b9701041799b426d68bdf46c2b_Out_2;
            Unity_Multiply_float(_Property_fd4f3aeee3af4897956a9bfea83e8ff2_Out_0, _OneMinus_51358182e28d43d786253d9ff413e1ba_Out_1, _Multiply_a09345b9701041799b426d68bdf46c2b_Out_2);
            float _Property_25e6c6c8207b4543936545ce21c0f1cf_Out_0 = _Smoothness;
            float _Property_ed24ac9afcec458193f4ca80d3433d26_Out_0 = _Metalic;
            UnityTexture2D _Property_8d46a693a34244728f8994000a7aedf2_Out_0 = UnityBuildTexture2DStructNoScale(_MetalicMap);
            float4 _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_8d46a693a34244728f8994000a7aedf2_Out_0.tex, _Property_8d46a693a34244728f8994000a7aedf2_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_R_4 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.r;
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_G_5 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.g;
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_B_6 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.b;
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_A_7 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.a;
            float4 _Multiply_3cc6f9ea17204e85b475424edb8cf7b4_Out_2;
            Unity_Multiply_float((_Property_ed24ac9afcec458193f4ca80d3433d26_Out_0.xxxx), _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0, _Multiply_3cc6f9ea17204e85b475424edb8cf7b4_Out_2);
            UnityTexture2D _Property_d93c6a66728e4177a22ce3d7ab635285_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            float4 _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d93c6a66728e4177a22ce3d7ab635285_Out_0.tex, _Property_d93c6a66728e4177a22ce3d7ab635285_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0);
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_R_4 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.r;
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_G_5 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.g;
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_B_6 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.b;
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_A_7 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.a;
            UnityTexture2D _Property_4f7e9183e76b43988062dfb0174af827_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            float4 _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4f7e9183e76b43988062dfb0174af827_Out_0.tex, _Property_4f7e9183e76b43988062dfb0174af827_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_R_4 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.r;
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_G_5 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.g;
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_B_6 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.b;
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_A_7 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.a;
            float4 _Property_7586886eeb5f45e6b097de3ce5740b5a_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            UnityTexture2D _Property_9a0067ba56784933a899c04948d4fc14_Out_0 = UnityBuildTexture2DStructNoScale(_EmissionMap);
            float4 _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9a0067ba56784933a899c04948d4fc14_Out_0.tex, _Property_9a0067ba56784933a899c04948d4fc14_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_R_4 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.r;
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_G_5 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.g;
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_B_6 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.b;
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_A_7 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.a;
            float4 _Multiply_5a00473c36a34df08239ece69cc4d8b1_Out_2;
            Unity_Multiply_float(_Property_7586886eeb5f45e6b097de3ce5740b5a_Out_0, _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0, _Multiply_5a00473c36a34df08239ece69cc4d8b1_Out_2);
            float _Property_ba7bcca39adb43e6b719c9a3f7aa42c1_Out_0 = _Shade;
            UnityTexture2D _Property_df41400fc48c4dc0a9116f719671d999_Out_0 = UnityBuildTexture2DStructNoScale(_ShadowMap);
            float4 _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_df41400fc48c4dc0a9116f719671d999_Out_0.tex, _Property_df41400fc48c4dc0a9116f719671d999_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_R_4 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.r;
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_G_5 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.g;
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_B_6 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.b;
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_A_7 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.a;
            float _Multiply_5b18d24ab4984169a8750d5d8bc7c7eb_Out_2;
            Unity_Multiply_float(_Property_ba7bcca39adb43e6b719c9a3f7aa42c1_Out_0, _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_R_4, _Multiply_5b18d24ab4984169a8750d5d8bc7c7eb_Out_2);
            float _Property_2b46e454918e476bbeeaa384671e06c2_Out_0 = _ShadeToony;
            float _Property_9e9482f4911345058781c44dedc65edf_Out_0 = _ToonyLighting;
            Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830 _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceNormal = IN.WorldSpaceNormal;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceTangent = IN.WorldSpaceTangent;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.ObjectSpacePosition = IN.ObjectSpacePosition;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpacePosition = IN.WorldSpacePosition;
            half3 _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Color_1;
            half _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Alpha_2;
            half3 _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_ShadeColor_3;
            SG_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830((_Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2.xyz), _Split_484f417dccca44c8aa91b01ad6e49ac0_A_4, _Multiply_362659b6eca74e09ab45550154f1dc08_Out_2, _Multiply_a09345b9701041799b426d68bdf46c2b_Out_2, _Property_25e6c6c8207b4543936545ce21c0f1cf_Out_0, _Multiply_3cc6f9ea17204e85b475424edb8cf7b4_Out_2, (_SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.xyz), _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_R_4, (_Multiply_5a00473c36a34df08239ece69cc4d8b1_Out_2.xyz), _Multiply_5b18d24ab4984169a8750d5d8bc7c7eb_Out_2, _Property_2b46e454918e476bbeeaa384671e06c2_Out_0, _Property_9e9482f4911345058781c44dedc65edf_Out_0, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Color_1, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Alpha_2, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_ShadeColor_3);
            Bindings_MixFog_e65d935e3c006a842b7a2fb6063b4b4d _MixFog_e5064454c4c144499f876fa4011590de;
            _MixFog_e5064454c4c144499f876fa4011590de.ObjectSpacePosition = IN.ObjectSpacePosition;
            float3 _MixFog_e5064454c4c144499f876fa4011590de_Color_3;
            SG_MixFog_e65d935e3c006a842b7a2fb6063b4b4d(_ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Color_1, _MixFog_e5064454c4c144499f876fa4011590de, _MixFog_e5064454c4c144499f876fa4011590de_Color_3);
            float _Property_882cff1dec7a4da98464f7de57dd5f19_Out_0 = _OutlineIntensity;
            float3 _Multiply_e943b2b705324ca59a9fdffa8e1e84dc_Out_2;
            Unity_Multiply_float(_ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_ShadeColor_3, (_Property_882cff1dec7a4da98464f7de57dd5f19_Out_0.xxx), _Multiply_e943b2b705324ca59a9fdffa8e1e84dc_Out_2);
            Bindings_MixFog_e65d935e3c006a842b7a2fb6063b4b4d _MixFog_0976268cece74edf9f0443518d64e07a;
            _MixFog_0976268cece74edf9f0443518d64e07a.ObjectSpacePosition = IN.ObjectSpacePosition;
            float3 _MixFog_0976268cece74edf9f0443518d64e07a_Color_3;
            SG_MixFog_e65d935e3c006a842b7a2fb6063b4b4d(_Multiply_e943b2b705324ca59a9fdffa8e1e84dc_Out_2, _MixFog_0976268cece74edf9f0443518d64e07a, _MixFog_0976268cece74edf9f0443518d64e07a_Color_3);
            surface.BaseColor = _MixFog_e5064454c4c144499f876fa4011590de_Color_3;
            surface.Alpha = _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Alpha_2;
            surface.AlphaClipThreshold = 0.5;
            surface.OutlineColor = _MixFog_0976268cece74edf9f0443518d64e07a_Color_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.uv0 =                         input.uv0;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);

        	// use bitangent on the fly like in hdrp
        	// IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
        	float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);

            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph

        	// to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
        	// This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
        	output.WorldSpaceBiTangent =         renormFactor*bitang;

            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Assets/jp.lilium.toongraph/Editor/ShaderGraph/ToonOutlinePass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Front
        Blend One Zero
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor;
        float4 _BaseMap_TexelSize;
        float4 _ShadeEnvironmentalColor;
        float4 _ShadeColor;
        float4 _ShadeMap_TexelSize;
        float _Smoothness;
        float _Metalic;
        float _Curvature;
        float4 Texture2D_d5a96518bbf24f11aff81031d9fbd97d_TexelSize;
        float4 _MetalicMap_TexelSize;
        float4 _BumpMap_TexelSize;
        float4 _OcclusionMap_TexelSize;
        float _Shade;
        float4 _ShadowMap_TexelSize;
        float4 _EmissionColor;
        float4 _EmissionMap_TexelSize;
        float _OutlineWidth;
        float4 _OutlineMap_TexelSize;
        float _ShadeToony;
        float _ToonyLighting;
        float _OutlineIntensity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_ShadeMap);
        SAMPLER(sampler_ShadeMap);
        TEXTURE2D(Texture2D_d5a96518bbf24f11aff81031d9fbd97d);
        SAMPLER(samplerTexture2D_d5a96518bbf24f11aff81031d9fbd97d);
        TEXTURE2D(_MetalicMap);
        SAMPLER(sampler_MetalicMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_ShadowMap);
        SAMPLER(sampler_ShadowMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_OutlineMap);
        SAMPLER(sampler_OutlineMap);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        // 45bb95d39362be0a3d23a808df58e263
        #include "Assets/jp.lilium.toongraph/Contents/Shader/ToonLightingSmoothstepRamp.hlsl"

        struct Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
        };

        void SG_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830(float3 Vector3_F836E644, float Vector1_4314B010, float4 Color_c394a829605a4bbd960d0a173370c56d, float Vector1_17cc6dcabd4041ba8c42d4eabd899dc4, float Vector1_328D12DB, float4 Color_625E7FA7, float3 Vector3_A82C1F5A, float Vector1_CA473DD5, float3 Vector3_248C1ED5, float Vector1_13346DDE, float Vector1_A8A74B72, float Vector1_8507BB4B, Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830 IN, out half3 Color_1, out half Alpha_2, out half3 ShadeColor_3)
        {
            float3 _Property_31f568d740a64ee5b41bd1e18b692f82_Out_0 = Vector3_F836E644;
            float4 _Property_ae3ecbd1416b4ae4a46c0860af87b2e9_Out_0 = Color_c394a829605a4bbd960d0a173370c56d;
            float3 _Property_3406a60a3c6d440991096282196a1c46_Out_0 = Vector3_A82C1F5A;
            float4 _Property_d6e67016be4b418e8a3f32de3b94681a_Out_0 = Color_625E7FA7;
            float _Property_e4e4db6a878044c399d4415afbb848c5_Out_0 = Vector1_328D12DB;
            float _Property_a5f2fab578bf4e338f9a1f6d6e4b6d00_Out_0 = Vector1_CA473DD5;
            float3 _Property_22bb99e9d5444c81af92426da216b3f7_Out_0 = Vector3_248C1ED5;
            float _Property_65f25cda39974603b95cf57fdb28e808_Out_0 = Vector1_4314B010;
            float _Property_4e1b490fa0af4c79beb5438b6535e73c_Out_0 = Vector1_13346DDE;
            float _Property_56490d6edc6c4d2ba46855b9cb7f7b49_Out_0 = Vector1_A8A74B72;
            float _Property_7b962570b81342d1b4d72b83e1cb1e3f_Out_0 = Vector1_17cc6dcabd4041ba8c42d4eabd899dc4;
            float _Property_af2080c2481140edaa8dd97ec51452bf_Out_0 = Vector1_8507BB4B;
            half4 _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0;
            half3 _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_ShadeColor_20;
            ToonLight_half(IN.ObjectSpacePosition, IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceViewDirection, _Property_31f568d740a64ee5b41bd1e18b692f82_Out_0, _Property_ae3ecbd1416b4ae4a46c0860af87b2e9_Out_0, _Property_3406a60a3c6d440991096282196a1c46_Out_0, (_Property_d6e67016be4b418e8a3f32de3b94681a_Out_0.xyz), _Property_e4e4db6a878044c399d4415afbb848c5_Out_0, _Property_a5f2fab578bf4e338f9a1f6d6e4b6d00_Out_0, _Property_22bb99e9d5444c81af92426da216b3f7_Out_0, _Property_65f25cda39974603b95cf57fdb28e808_Out_0, _Property_4e1b490fa0af4c79beb5438b6535e73c_Out_0, _Property_56490d6edc6c4d2ba46855b9cb7f7b49_Out_0, _Property_7b962570b81342d1b4d72b83e1cb1e3f_Out_0, _Property_af2080c2481140edaa8dd97ec51452bf_Out_0, _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0, _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_ShadeColor_20);
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_R_1 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[0];
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_G_2 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[1];
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_B_3 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[2];
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_A_4 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[3];
            Color_1 = (_ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0.xyz);
            Alpha_2 = _Split_9e9eebec5ff840fba5de5a2a051495ed_A_4;
            ShadeColor_3 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_ShadeColor_20;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_5d8ac4a251d84d4fa7986e1193e70da2_Out_0 = _BaseColor;
            UnityTexture2D _Property_b99b572259ca455cb15668511e3a76c4_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b99b572259ca455cb15668511e3a76c4_Out_0.tex, _Property_b99b572259ca455cb15668511e3a76c4_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_R_4 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.r;
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_G_5 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.g;
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_B_6 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.b;
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_A_7 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.a;
            float4 _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2;
            Unity_Multiply_float(_Property_5d8ac4a251d84d4fa7986e1193e70da2_Out_0, _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0, _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2);
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_R_1 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[0];
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_G_2 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[1];
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_B_3 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[2];
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_A_4 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[3];
            float4 _Property_636d8bdc04954f5497aa4b2cd0510a8e_Out_0 = _ShadeColor;
            UnityTexture2D _Property_94ea4828a0ed4321827fd4247c3e3f6c_Out_0 = UnityBuildTexture2DStructNoScale(_ShadeMap);
            float4 _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_94ea4828a0ed4321827fd4247c3e3f6c_Out_0.tex, _Property_94ea4828a0ed4321827fd4247c3e3f6c_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_R_4 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.r;
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_G_5 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.g;
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_B_6 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.b;
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_A_7 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.a;
            float4 _Multiply_362659b6eca74e09ab45550154f1dc08_Out_2;
            Unity_Multiply_float(_Property_636d8bdc04954f5497aa4b2cd0510a8e_Out_0, _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0, _Multiply_362659b6eca74e09ab45550154f1dc08_Out_2);
            float _Property_fd4f3aeee3af4897956a9bfea83e8ff2_Out_0 = _Curvature;
            UnityTexture2D _Property_b6fbff5e115249c6b7e9d1cfd0b67730_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_d5a96518bbf24f11aff81031d9fbd97d);
            float4 _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b6fbff5e115249c6b7e9d1cfd0b67730_Out_0.tex, _Property_b6fbff5e115249c6b7e9d1cfd0b67730_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_R_4 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.r;
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_G_5 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.g;
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_B_6 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.b;
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_A_7 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.a;
            float _OneMinus_51358182e28d43d786253d9ff413e1ba_Out_1;
            Unity_OneMinus_float(_SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_R_4, _OneMinus_51358182e28d43d786253d9ff413e1ba_Out_1);
            float _Multiply_a09345b9701041799b426d68bdf46c2b_Out_2;
            Unity_Multiply_float(_Property_fd4f3aeee3af4897956a9bfea83e8ff2_Out_0, _OneMinus_51358182e28d43d786253d9ff413e1ba_Out_1, _Multiply_a09345b9701041799b426d68bdf46c2b_Out_2);
            float _Property_25e6c6c8207b4543936545ce21c0f1cf_Out_0 = _Smoothness;
            float _Property_ed24ac9afcec458193f4ca80d3433d26_Out_0 = _Metalic;
            UnityTexture2D _Property_8d46a693a34244728f8994000a7aedf2_Out_0 = UnityBuildTexture2DStructNoScale(_MetalicMap);
            float4 _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_8d46a693a34244728f8994000a7aedf2_Out_0.tex, _Property_8d46a693a34244728f8994000a7aedf2_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_R_4 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.r;
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_G_5 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.g;
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_B_6 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.b;
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_A_7 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.a;
            float4 _Multiply_3cc6f9ea17204e85b475424edb8cf7b4_Out_2;
            Unity_Multiply_float((_Property_ed24ac9afcec458193f4ca80d3433d26_Out_0.xxxx), _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0, _Multiply_3cc6f9ea17204e85b475424edb8cf7b4_Out_2);
            UnityTexture2D _Property_d93c6a66728e4177a22ce3d7ab635285_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            float4 _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d93c6a66728e4177a22ce3d7ab635285_Out_0.tex, _Property_d93c6a66728e4177a22ce3d7ab635285_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0);
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_R_4 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.r;
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_G_5 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.g;
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_B_6 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.b;
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_A_7 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.a;
            UnityTexture2D _Property_4f7e9183e76b43988062dfb0174af827_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            float4 _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4f7e9183e76b43988062dfb0174af827_Out_0.tex, _Property_4f7e9183e76b43988062dfb0174af827_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_R_4 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.r;
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_G_5 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.g;
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_B_6 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.b;
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_A_7 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.a;
            float4 _Property_7586886eeb5f45e6b097de3ce5740b5a_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            UnityTexture2D _Property_9a0067ba56784933a899c04948d4fc14_Out_0 = UnityBuildTexture2DStructNoScale(_EmissionMap);
            float4 _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9a0067ba56784933a899c04948d4fc14_Out_0.tex, _Property_9a0067ba56784933a899c04948d4fc14_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_R_4 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.r;
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_G_5 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.g;
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_B_6 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.b;
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_A_7 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.a;
            float4 _Multiply_5a00473c36a34df08239ece69cc4d8b1_Out_2;
            Unity_Multiply_float(_Property_7586886eeb5f45e6b097de3ce5740b5a_Out_0, _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0, _Multiply_5a00473c36a34df08239ece69cc4d8b1_Out_2);
            float _Property_ba7bcca39adb43e6b719c9a3f7aa42c1_Out_0 = _Shade;
            UnityTexture2D _Property_df41400fc48c4dc0a9116f719671d999_Out_0 = UnityBuildTexture2DStructNoScale(_ShadowMap);
            float4 _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_df41400fc48c4dc0a9116f719671d999_Out_0.tex, _Property_df41400fc48c4dc0a9116f719671d999_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_R_4 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.r;
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_G_5 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.g;
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_B_6 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.b;
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_A_7 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.a;
            float _Multiply_5b18d24ab4984169a8750d5d8bc7c7eb_Out_2;
            Unity_Multiply_float(_Property_ba7bcca39adb43e6b719c9a3f7aa42c1_Out_0, _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_R_4, _Multiply_5b18d24ab4984169a8750d5d8bc7c7eb_Out_2);
            float _Property_2b46e454918e476bbeeaa384671e06c2_Out_0 = _ShadeToony;
            float _Property_9e9482f4911345058781c44dedc65edf_Out_0 = _ToonyLighting;
            Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830 _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceNormal = IN.WorldSpaceNormal;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceTangent = IN.WorldSpaceTangent;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.ObjectSpacePosition = IN.ObjectSpacePosition;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpacePosition = IN.WorldSpacePosition;
            half3 _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Color_1;
            half _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Alpha_2;
            half3 _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_ShadeColor_3;
            SG_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830((_Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2.xyz), _Split_484f417dccca44c8aa91b01ad6e49ac0_A_4, _Multiply_362659b6eca74e09ab45550154f1dc08_Out_2, _Multiply_a09345b9701041799b426d68bdf46c2b_Out_2, _Property_25e6c6c8207b4543936545ce21c0f1cf_Out_0, _Multiply_3cc6f9ea17204e85b475424edb8cf7b4_Out_2, (_SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.xyz), _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_R_4, (_Multiply_5a00473c36a34df08239ece69cc4d8b1_Out_2.xyz), _Multiply_5b18d24ab4984169a8750d5d8bc7c7eb_Out_2, _Property_2b46e454918e476bbeeaa384671e06c2_Out_0, _Property_9e9482f4911345058781c44dedc65edf_Out_0, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Color_1, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Alpha_2, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_ShadeColor_3);
            surface.Alpha = _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Alpha_2;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);

        	// use bitangent on the fly like in hdrp
        	// IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
        	float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);

            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph

        	// to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
        	// This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
        	output.WorldSpaceBiTangent =         renormFactor*bitang;

            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _BaseColor;
        float4 _BaseMap_TexelSize;
        float4 _ShadeEnvironmentalColor;
        float4 _ShadeColor;
        float4 _ShadeMap_TexelSize;
        float _Smoothness;
        float _Metalic;
        float _Curvature;
        float4 Texture2D_d5a96518bbf24f11aff81031d9fbd97d_TexelSize;
        float4 _MetalicMap_TexelSize;
        float4 _BumpMap_TexelSize;
        float4 _OcclusionMap_TexelSize;
        float _Shade;
        float4 _ShadowMap_TexelSize;
        float4 _EmissionColor;
        float4 _EmissionMap_TexelSize;
        float _OutlineWidth;
        float4 _OutlineMap_TexelSize;
        float _ShadeToony;
        float _ToonyLighting;
        float _OutlineIntensity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_ShadeMap);
        SAMPLER(sampler_ShadeMap);
        TEXTURE2D(Texture2D_d5a96518bbf24f11aff81031d9fbd97d);
        SAMPLER(samplerTexture2D_d5a96518bbf24f11aff81031d9fbd97d);
        TEXTURE2D(_MetalicMap);
        SAMPLER(sampler_MetalicMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_ShadowMap);
        SAMPLER(sampler_ShadowMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_OutlineMap);
        SAMPLER(sampler_OutlineMap);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        // 45bb95d39362be0a3d23a808df58e263
        #include "Assets/jp.lilium.toongraph/Contents/Shader/ToonLightingSmoothstepRamp.hlsl"

        struct Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
        };

        void SG_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830(float3 Vector3_F836E644, float Vector1_4314B010, float4 Color_c394a829605a4bbd960d0a173370c56d, float Vector1_17cc6dcabd4041ba8c42d4eabd899dc4, float Vector1_328D12DB, float4 Color_625E7FA7, float3 Vector3_A82C1F5A, float Vector1_CA473DD5, float3 Vector3_248C1ED5, float Vector1_13346DDE, float Vector1_A8A74B72, float Vector1_8507BB4B, Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830 IN, out half3 Color_1, out half Alpha_2, out half3 ShadeColor_3)
        {
            float3 _Property_31f568d740a64ee5b41bd1e18b692f82_Out_0 = Vector3_F836E644;
            float4 _Property_ae3ecbd1416b4ae4a46c0860af87b2e9_Out_0 = Color_c394a829605a4bbd960d0a173370c56d;
            float3 _Property_3406a60a3c6d440991096282196a1c46_Out_0 = Vector3_A82C1F5A;
            float4 _Property_d6e67016be4b418e8a3f32de3b94681a_Out_0 = Color_625E7FA7;
            float _Property_e4e4db6a878044c399d4415afbb848c5_Out_0 = Vector1_328D12DB;
            float _Property_a5f2fab578bf4e338f9a1f6d6e4b6d00_Out_0 = Vector1_CA473DD5;
            float3 _Property_22bb99e9d5444c81af92426da216b3f7_Out_0 = Vector3_248C1ED5;
            float _Property_65f25cda39974603b95cf57fdb28e808_Out_0 = Vector1_4314B010;
            float _Property_4e1b490fa0af4c79beb5438b6535e73c_Out_0 = Vector1_13346DDE;
            float _Property_56490d6edc6c4d2ba46855b9cb7f7b49_Out_0 = Vector1_A8A74B72;
            float _Property_7b962570b81342d1b4d72b83e1cb1e3f_Out_0 = Vector1_17cc6dcabd4041ba8c42d4eabd899dc4;
            float _Property_af2080c2481140edaa8dd97ec51452bf_Out_0 = Vector1_8507BB4B;
            half4 _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0;
            half3 _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_ShadeColor_20;
            ToonLight_half(IN.ObjectSpacePosition, IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceViewDirection, _Property_31f568d740a64ee5b41bd1e18b692f82_Out_0, _Property_ae3ecbd1416b4ae4a46c0860af87b2e9_Out_0, _Property_3406a60a3c6d440991096282196a1c46_Out_0, (_Property_d6e67016be4b418e8a3f32de3b94681a_Out_0.xyz), _Property_e4e4db6a878044c399d4415afbb848c5_Out_0, _Property_a5f2fab578bf4e338f9a1f6d6e4b6d00_Out_0, _Property_22bb99e9d5444c81af92426da216b3f7_Out_0, _Property_65f25cda39974603b95cf57fdb28e808_Out_0, _Property_4e1b490fa0af4c79beb5438b6535e73c_Out_0, _Property_56490d6edc6c4d2ba46855b9cb7f7b49_Out_0, _Property_7b962570b81342d1b4d72b83e1cb1e3f_Out_0, _Property_af2080c2481140edaa8dd97ec51452bf_Out_0, _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0, _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_ShadeColor_20);
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_R_1 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[0];
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_G_2 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[1];
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_B_3 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[2];
            half _Split_9e9eebec5ff840fba5de5a2a051495ed_A_4 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0[3];
            Color_1 = (_ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_Color_0.xyz);
            Alpha_2 = _Split_9e9eebec5ff840fba5de5a2a051495ed_A_4;
            ShadeColor_3 = _ToonLightCustomFunction_bb929d0fd24b47ba9893d8a9a3b1fcae_ShadeColor_20;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_5d8ac4a251d84d4fa7986e1193e70da2_Out_0 = _BaseColor;
            UnityTexture2D _Property_b99b572259ca455cb15668511e3a76c4_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b99b572259ca455cb15668511e3a76c4_Out_0.tex, _Property_b99b572259ca455cb15668511e3a76c4_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_R_4 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.r;
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_G_5 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.g;
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_B_6 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.b;
            float _SampleTexture2D_030b0496b1c2459191da022f4bc03428_A_7 = _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0.a;
            float4 _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2;
            Unity_Multiply_float(_Property_5d8ac4a251d84d4fa7986e1193e70da2_Out_0, _SampleTexture2D_030b0496b1c2459191da022f4bc03428_RGBA_0, _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2);
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_R_1 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[0];
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_G_2 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[1];
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_B_3 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[2];
            float _Split_484f417dccca44c8aa91b01ad6e49ac0_A_4 = _Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2[3];
            float4 _Property_636d8bdc04954f5497aa4b2cd0510a8e_Out_0 = _ShadeColor;
            UnityTexture2D _Property_94ea4828a0ed4321827fd4247c3e3f6c_Out_0 = UnityBuildTexture2DStructNoScale(_ShadeMap);
            float4 _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_94ea4828a0ed4321827fd4247c3e3f6c_Out_0.tex, _Property_94ea4828a0ed4321827fd4247c3e3f6c_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_R_4 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.r;
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_G_5 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.g;
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_B_6 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.b;
            float _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_A_7 = _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0.a;
            float4 _Multiply_362659b6eca74e09ab45550154f1dc08_Out_2;
            Unity_Multiply_float(_Property_636d8bdc04954f5497aa4b2cd0510a8e_Out_0, _SampleTexture2D_8c165ffd91884fb48580686e82a6a18b_RGBA_0, _Multiply_362659b6eca74e09ab45550154f1dc08_Out_2);
            float _Property_fd4f3aeee3af4897956a9bfea83e8ff2_Out_0 = _Curvature;
            UnityTexture2D _Property_b6fbff5e115249c6b7e9d1cfd0b67730_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_d5a96518bbf24f11aff81031d9fbd97d);
            float4 _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b6fbff5e115249c6b7e9d1cfd0b67730_Out_0.tex, _Property_b6fbff5e115249c6b7e9d1cfd0b67730_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_R_4 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.r;
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_G_5 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.g;
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_B_6 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.b;
            float _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_A_7 = _SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_RGBA_0.a;
            float _OneMinus_51358182e28d43d786253d9ff413e1ba_Out_1;
            Unity_OneMinus_float(_SampleTexture2D_670a58b1c91c4d1f86968153f8ffb026_R_4, _OneMinus_51358182e28d43d786253d9ff413e1ba_Out_1);
            float _Multiply_a09345b9701041799b426d68bdf46c2b_Out_2;
            Unity_Multiply_float(_Property_fd4f3aeee3af4897956a9bfea83e8ff2_Out_0, _OneMinus_51358182e28d43d786253d9ff413e1ba_Out_1, _Multiply_a09345b9701041799b426d68bdf46c2b_Out_2);
            float _Property_25e6c6c8207b4543936545ce21c0f1cf_Out_0 = _Smoothness;
            float _Property_ed24ac9afcec458193f4ca80d3433d26_Out_0 = _Metalic;
            UnityTexture2D _Property_8d46a693a34244728f8994000a7aedf2_Out_0 = UnityBuildTexture2DStructNoScale(_MetalicMap);
            float4 _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_8d46a693a34244728f8994000a7aedf2_Out_0.tex, _Property_8d46a693a34244728f8994000a7aedf2_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_R_4 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.r;
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_G_5 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.g;
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_B_6 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.b;
            float _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_A_7 = _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0.a;
            float4 _Multiply_3cc6f9ea17204e85b475424edb8cf7b4_Out_2;
            Unity_Multiply_float((_Property_ed24ac9afcec458193f4ca80d3433d26_Out_0.xxxx), _SampleTexture2D_b54ef747b2f7488bb1d2684c918711f8_RGBA_0, _Multiply_3cc6f9ea17204e85b475424edb8cf7b4_Out_2);
            UnityTexture2D _Property_d93c6a66728e4177a22ce3d7ab635285_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            float4 _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d93c6a66728e4177a22ce3d7ab635285_Out_0.tex, _Property_d93c6a66728e4177a22ce3d7ab635285_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0);
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_R_4 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.r;
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_G_5 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.g;
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_B_6 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.b;
            float _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_A_7 = _SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.a;
            UnityTexture2D _Property_4f7e9183e76b43988062dfb0174af827_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            float4 _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4f7e9183e76b43988062dfb0174af827_Out_0.tex, _Property_4f7e9183e76b43988062dfb0174af827_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_R_4 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.r;
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_G_5 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.g;
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_B_6 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.b;
            float _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_A_7 = _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_RGBA_0.a;
            float4 _Property_7586886eeb5f45e6b097de3ce5740b5a_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            UnityTexture2D _Property_9a0067ba56784933a899c04948d4fc14_Out_0 = UnityBuildTexture2DStructNoScale(_EmissionMap);
            float4 _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9a0067ba56784933a899c04948d4fc14_Out_0.tex, _Property_9a0067ba56784933a899c04948d4fc14_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_R_4 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.r;
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_G_5 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.g;
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_B_6 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.b;
            float _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_A_7 = _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0.a;
            float4 _Multiply_5a00473c36a34df08239ece69cc4d8b1_Out_2;
            Unity_Multiply_float(_Property_7586886eeb5f45e6b097de3ce5740b5a_Out_0, _SampleTexture2D_33d959bc3dde482ab9efb6d07c06fa22_RGBA_0, _Multiply_5a00473c36a34df08239ece69cc4d8b1_Out_2);
            float _Property_ba7bcca39adb43e6b719c9a3f7aa42c1_Out_0 = _Shade;
            UnityTexture2D _Property_df41400fc48c4dc0a9116f719671d999_Out_0 = UnityBuildTexture2DStructNoScale(_ShadowMap);
            float4 _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_df41400fc48c4dc0a9116f719671d999_Out_0.tex, _Property_df41400fc48c4dc0a9116f719671d999_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_R_4 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.r;
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_G_5 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.g;
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_B_6 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.b;
            float _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_A_7 = _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_RGBA_0.a;
            float _Multiply_5b18d24ab4984169a8750d5d8bc7c7eb_Out_2;
            Unity_Multiply_float(_Property_ba7bcca39adb43e6b719c9a3f7aa42c1_Out_0, _SampleTexture2D_2019cf8aadb140738bfdeae2b29594a0_R_4, _Multiply_5b18d24ab4984169a8750d5d8bc7c7eb_Out_2);
            float _Property_2b46e454918e476bbeeaa384671e06c2_Out_0 = _ShadeToony;
            float _Property_9e9482f4911345058781c44dedc65edf_Out_0 = _ToonyLighting;
            Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830 _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceNormal = IN.WorldSpaceNormal;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceTangent = IN.WorldSpaceTangent;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.ObjectSpacePosition = IN.ObjectSpacePosition;
            _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1.WorldSpacePosition = IN.WorldSpacePosition;
            half3 _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Color_1;
            half _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Alpha_2;
            half3 _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_ShadeColor_3;
            SG_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830((_Multiply_b45da41c08c4456fbd10798adb8b7e3c_Out_2.xyz), _Split_484f417dccca44c8aa91b01ad6e49ac0_A_4, _Multiply_362659b6eca74e09ab45550154f1dc08_Out_2, _Multiply_a09345b9701041799b426d68bdf46c2b_Out_2, _Property_25e6c6c8207b4543936545ce21c0f1cf_Out_0, _Multiply_3cc6f9ea17204e85b475424edb8cf7b4_Out_2, (_SampleTexture2D_8088b5d5756e434db42d079978bc1a5c_RGBA_0.xyz), _SampleTexture2D_7adccddcf2364d30b757f87bbe25d76a_R_4, (_Multiply_5a00473c36a34df08239ece69cc4d8b1_Out_2.xyz), _Multiply_5b18d24ab4984169a8750d5d8bc7c7eb_Out_2, _Property_2b46e454918e476bbeeaa384671e06c2_Out_0, _Property_9e9482f4911345058781c44dedc65edf_Out_0, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Color_1, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Alpha_2, _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_ShadeColor_3);
            surface.Alpha = _ToonLightingSmoothstepRamp_0988ec60b37e4d8aa158a87d8afa3ca1_Alpha_2;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);

        	// use bitangent on the fly like in hdrp
        	// IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
        	float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);

            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph

        	// to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
        	// This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
        	output.WorldSpaceBiTangent =         renormFactor*bitang;

            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
    }
    FallBack "Hidden/Shader Graph/FallbackError"
}