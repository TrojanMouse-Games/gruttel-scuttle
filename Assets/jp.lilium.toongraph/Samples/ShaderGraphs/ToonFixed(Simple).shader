Shader "Toon Fixed(Simple)"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset]_BaseMap("Base Map", 2D) = "white" {}
        _SssColor("SSS Color", Color) = (0, 0, 0, 0)
        [NoScaleOffset]_SssMap("SSS Map", 2D) = "white" {}
        _Metalic("Metalic", Range(0, 1)) = 0
        _Smoothness("Smoothness", Range(0, 1)) = 1
        _Curvature("Curvature", Range(0, 1)) = 0
        [NoScaleOffset]_BumpMap("Normal Map", 2D) = "bump" {}
        [NoScaleOffset]_OcclusionMap("Occlusion Map", 2D) = "white" {}
        _Shade("Shade Shift", Range(0, 2)) = 1
        [NoScaleOffset]_ShadowMap("Shade Map", 2D) = "white" {}
        _OutlineWidth("Outline Width", Float) = 1
        _ShadeToony("Shade Toony", Range(0, 1)) = 1
        _ToonyLighting("Toony Lighting", Range(0, 1)) = 1
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
        half4 _BaseColor;
        float4 _BaseMap_TexelSize;
        half4 _SssColor;
        float4 _SssMap_TexelSize;
        half _Metalic;
        half _Smoothness;
        half _Curvature;
        float4 _BumpMap_TexelSize;
        float4 _OcclusionMap_TexelSize;
        half _Shade;
        float4 _ShadowMap_TexelSize;
        half _OutlineWidth;
        half _ShadeToony;
        half _ToonyLighting;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_SssMap);
        SAMPLER(sampler_SssMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_ShadowMap);
        SAMPLER(sampler_ShadowMap);

            // Graph Functions
            
        void Unity_Multiply_half(half4 A, half4 B, out half4 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_half(half A, half B, out half Out)
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

        void Unity_Fog_float(out half4 Color, out half Density, half3 Position)
        {
            SHADERGRAPH_FOG(Position, Color, Density);
        }

        void Unity_Multiply_float(half A, half B, out half Out)
        {
            Out = A * B;
        }

        void Unity_Clamp_float(half In, half Min, half Max, out half Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Lerp_float3(half3 A, half3 B, half3 T, out half3 Out)
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
            half3 Position;
            half3 Normal;
            half3 Tangent;
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
            half3 BaseColor;
            half Alpha;
            half AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            half4 _Property_3df23279bda04973984baae490a2d207_Out_0 = _BaseColor;
            UnityTexture2D _Property_667d1921191e43f18fcbcf55f831acbb_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            half4 _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_667d1921191e43f18fcbcf55f831acbb_Out_0.tex, _Property_667d1921191e43f18fcbcf55f831acbb_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_R_4 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.r;
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_G_5 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.g;
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_B_6 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.b;
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_A_7 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.a;
            half4 _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2;
            Unity_Multiply_half(_Property_3df23279bda04973984baae490a2d207_Out_0, _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0, _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2);
            half _Split_ccedce2765a149818f9e74db6b51d2ec_R_1 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[0];
            half _Split_ccedce2765a149818f9e74db6b51d2ec_G_2 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[1];
            half _Split_ccedce2765a149818f9e74db6b51d2ec_B_3 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[2];
            half _Split_ccedce2765a149818f9e74db6b51d2ec_A_4 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[3];
            half4 _Property_97f47d1158bb46d3b08685c745435b06_Out_0 = _SssColor;
            UnityTexture2D _Property_89783adf056c43c0b027affff717d430_Out_0 = UnityBuildTexture2DStructNoScale(_SssMap);
            half4 _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0 = SAMPLE_TEXTURE2D(_Property_89783adf056c43c0b027affff717d430_Out_0.tex, _Property_89783adf056c43c0b027affff717d430_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_R_4 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.r;
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_G_5 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.g;
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_B_6 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.b;
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_A_7 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.a;
            half4 _Multiply_5dd907f0b6bd418c82dbc1034c506ea5_Out_2;
            Unity_Multiply_half(_Property_97f47d1158bb46d3b08685c745435b06_Out_0, _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0, _Multiply_5dd907f0b6bd418c82dbc1034c506ea5_Out_2);
            half _Property_5acf053d54a247ca9c67136a62ded025_Out_0 = _Curvature;
            half _Property_e2e7b4b4046844469edada1a89545fda_Out_0 = _Smoothness;
            half _Property_e80420b13b6d42d59661e072a2dc41ae_Out_0 = _Metalic;
            UnityTexture2D _Property_9b16b8201d244080835656749dbf50fd_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            half4 _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9b16b8201d244080835656749dbf50fd_Out_0.tex, _Property_9b16b8201d244080835656749dbf50fd_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0);
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_R_4 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.r;
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_G_5 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.g;
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_B_6 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.b;
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_A_7 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.a;
            UnityTexture2D _Property_c40f6aff0210464987dd4f7ef80b22ed_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            half4 _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0 = SAMPLE_TEXTURE2D(_Property_c40f6aff0210464987dd4f7ef80b22ed_Out_0.tex, _Property_c40f6aff0210464987dd4f7ef80b22ed_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_R_4 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.r;
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_G_5 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.g;
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_B_6 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.b;
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_A_7 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.a;
            half _Property_f5545b7615f9400e9b3a7e8c64d84154_Out_0 = _Shade;
            UnityTexture2D _Property_2da17a6d8a9b4d9794fa49029c020494_Out_0 = UnityBuildTexture2DStructNoScale(_ShadowMap);
            half4 _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_2da17a6d8a9b4d9794fa49029c020494_Out_0.tex, _Property_2da17a6d8a9b4d9794fa49029c020494_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_R_4 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.r;
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_G_5 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.g;
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_B_6 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.b;
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_A_7 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.a;
            half _Multiply_8ca141df72a74e338da52212e8d6e2c0_Out_2;
            Unity_Multiply_half(_Property_f5545b7615f9400e9b3a7e8c64d84154_Out_0, _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_R_4, _Multiply_8ca141df72a74e338da52212e8d6e2c0_Out_2);
            half _Property_6465a8de9d5d4c2698e734c26122def1_Out_0 = _ShadeToony;
            half _Property_f327aeab29c44190813949f1fc7752a7_Out_0 = _ToonyLighting;
            Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830 _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceNormal = IN.WorldSpaceNormal;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceTangent = IN.WorldSpaceTangent;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.ObjectSpacePosition = IN.ObjectSpacePosition;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpacePosition = IN.WorldSpacePosition;
            half3 _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Color_1;
            half _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Alpha_2;
            half3 _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_ShadeColor_3;
            SG_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830((_Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2.xyz), _Split_ccedce2765a149818f9e74db6b51d2ec_A_4, _Multiply_5dd907f0b6bd418c82dbc1034c506ea5_Out_2, _Property_5acf053d54a247ca9c67136a62ded025_Out_0, _Property_e2e7b4b4046844469edada1a89545fda_Out_0, (_Property_e80420b13b6d42d59661e072a2dc41ae_Out_0.xxxx), (_SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.xyz), (_SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0).x, float3 (0, 0, 0), _Multiply_8ca141df72a74e338da52212e8d6e2c0_Out_2, _Property_6465a8de9d5d4c2698e734c26122def1_Out_0, _Property_f327aeab29c44190813949f1fc7752a7_Out_0, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Color_1, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Alpha_2, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_ShadeColor_3);
            Bindings_MixFog_e65d935e3c006a842b7a2fb6063b4b4d _MixFog_5eb6003dc4f349a9a0ba27d8cbc137cc;
            _MixFog_5eb6003dc4f349a9a0ba27d8cbc137cc.ObjectSpacePosition = IN.ObjectSpacePosition;
            float3 _MixFog_5eb6003dc4f349a9a0ba27d8cbc137cc_Color_3;
            SG_MixFog_e65d935e3c006a842b7a2fb6063b4b4d(_ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Color_1, _MixFog_5eb6003dc4f349a9a0ba27d8cbc137cc, _MixFog_5eb6003dc4f349a9a0ba27d8cbc137cc_Color_3);
            surface.BaseColor = _MixFog_5eb6003dc4f349a9a0ba27d8cbc137cc_Color_3;
            surface.Alpha = _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Alpha_2;
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
        half4 _BaseColor;
        float4 _BaseMap_TexelSize;
        half4 _SssColor;
        float4 _SssMap_TexelSize;
        half _Metalic;
        half _Smoothness;
        half _Curvature;
        float4 _BumpMap_TexelSize;
        float4 _OcclusionMap_TexelSize;
        half _Shade;
        float4 _ShadowMap_TexelSize;
        half _OutlineWidth;
        half _ShadeToony;
        half _ToonyLighting;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_SssMap);
        SAMPLER(sampler_SssMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_ShadowMap);
        SAMPLER(sampler_ShadowMap);

            // Graph Functions
            
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

        void Unity_Multiply_half(half4 A, half4 B, out half4 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_half(half A, half B, out half Out)
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

        void Unity_Fog_float(out half4 Color, out half Density, half3 Position)
        {
            SHADERGRAPH_FOG(Position, Color, Density);
        }

        void Unity_Multiply_float(half A, half B, out half Out)
        {
            Out = A * B;
        }

        void Unity_Clamp_float(half In, half Min, half Max, out half Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Lerp_float3(half3 A, half3 B, half3 T, out half3 Out)
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

        void Unity_Multiply_half(half3 A, half3 B, out half3 Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            half3 Position;
            half3 Normal;
            half3 Tangent;
            half3 OutlinePosition;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            half _Property_a8970ba1ccd84de9b80fb72a0f9ce25e_Out_0 = _OutlineWidth;
            Bindings_ToonOutlineTransform_aadd6ff8a7ff83a4fb272240ac26c2b5 _ToonOutlineTransform_2223ce9ace444d2b949168108aff26bb;
            _ToonOutlineTransform_2223ce9ace444d2b949168108aff26bb.ObjectSpaceNormal = IN.ObjectSpaceNormal;
            _ToonOutlineTransform_2223ce9ace444d2b949168108aff26bb.ObjectSpacePosition = IN.ObjectSpacePosition;
            float3 _ToonOutlineTransform_2223ce9ace444d2b949168108aff26bb_OutlinePosition_1;
            SG_ToonOutlineTransform_aadd6ff8a7ff83a4fb272240ac26c2b5(_Property_a8970ba1ccd84de9b80fb72a0f9ce25e_Out_0, _ToonOutlineTransform_2223ce9ace444d2b949168108aff26bb, _ToonOutlineTransform_2223ce9ace444d2b949168108aff26bb_OutlinePosition_1);
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            description.OutlinePosition = _ToonOutlineTransform_2223ce9ace444d2b949168108aff26bb_OutlinePosition_1;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            half3 BaseColor;
            half Alpha;
            half AlphaClipThreshold;
            half3 OutlineColor;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            half4 _Property_3df23279bda04973984baae490a2d207_Out_0 = _BaseColor;
            UnityTexture2D _Property_667d1921191e43f18fcbcf55f831acbb_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            half4 _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_667d1921191e43f18fcbcf55f831acbb_Out_0.tex, _Property_667d1921191e43f18fcbcf55f831acbb_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_R_4 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.r;
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_G_5 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.g;
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_B_6 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.b;
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_A_7 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.a;
            half4 _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2;
            Unity_Multiply_half(_Property_3df23279bda04973984baae490a2d207_Out_0, _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0, _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2);
            half _Split_ccedce2765a149818f9e74db6b51d2ec_R_1 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[0];
            half _Split_ccedce2765a149818f9e74db6b51d2ec_G_2 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[1];
            half _Split_ccedce2765a149818f9e74db6b51d2ec_B_3 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[2];
            half _Split_ccedce2765a149818f9e74db6b51d2ec_A_4 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[3];
            half4 _Property_97f47d1158bb46d3b08685c745435b06_Out_0 = _SssColor;
            UnityTexture2D _Property_89783adf056c43c0b027affff717d430_Out_0 = UnityBuildTexture2DStructNoScale(_SssMap);
            half4 _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0 = SAMPLE_TEXTURE2D(_Property_89783adf056c43c0b027affff717d430_Out_0.tex, _Property_89783adf056c43c0b027affff717d430_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_R_4 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.r;
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_G_5 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.g;
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_B_6 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.b;
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_A_7 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.a;
            half4 _Multiply_5dd907f0b6bd418c82dbc1034c506ea5_Out_2;
            Unity_Multiply_half(_Property_97f47d1158bb46d3b08685c745435b06_Out_0, _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0, _Multiply_5dd907f0b6bd418c82dbc1034c506ea5_Out_2);
            half _Property_5acf053d54a247ca9c67136a62ded025_Out_0 = _Curvature;
            half _Property_e2e7b4b4046844469edada1a89545fda_Out_0 = _Smoothness;
            half _Property_e80420b13b6d42d59661e072a2dc41ae_Out_0 = _Metalic;
            UnityTexture2D _Property_9b16b8201d244080835656749dbf50fd_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            half4 _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9b16b8201d244080835656749dbf50fd_Out_0.tex, _Property_9b16b8201d244080835656749dbf50fd_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0);
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_R_4 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.r;
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_G_5 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.g;
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_B_6 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.b;
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_A_7 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.a;
            UnityTexture2D _Property_c40f6aff0210464987dd4f7ef80b22ed_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            half4 _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0 = SAMPLE_TEXTURE2D(_Property_c40f6aff0210464987dd4f7ef80b22ed_Out_0.tex, _Property_c40f6aff0210464987dd4f7ef80b22ed_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_R_4 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.r;
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_G_5 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.g;
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_B_6 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.b;
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_A_7 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.a;
            half _Property_f5545b7615f9400e9b3a7e8c64d84154_Out_0 = _Shade;
            UnityTexture2D _Property_2da17a6d8a9b4d9794fa49029c020494_Out_0 = UnityBuildTexture2DStructNoScale(_ShadowMap);
            half4 _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_2da17a6d8a9b4d9794fa49029c020494_Out_0.tex, _Property_2da17a6d8a9b4d9794fa49029c020494_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_R_4 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.r;
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_G_5 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.g;
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_B_6 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.b;
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_A_7 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.a;
            half _Multiply_8ca141df72a74e338da52212e8d6e2c0_Out_2;
            Unity_Multiply_half(_Property_f5545b7615f9400e9b3a7e8c64d84154_Out_0, _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_R_4, _Multiply_8ca141df72a74e338da52212e8d6e2c0_Out_2);
            half _Property_6465a8de9d5d4c2698e734c26122def1_Out_0 = _ShadeToony;
            half _Property_f327aeab29c44190813949f1fc7752a7_Out_0 = _ToonyLighting;
            Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830 _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceNormal = IN.WorldSpaceNormal;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceTangent = IN.WorldSpaceTangent;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.ObjectSpacePosition = IN.ObjectSpacePosition;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpacePosition = IN.WorldSpacePosition;
            half3 _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Color_1;
            half _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Alpha_2;
            half3 _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_ShadeColor_3;
            SG_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830((_Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2.xyz), _Split_ccedce2765a149818f9e74db6b51d2ec_A_4, _Multiply_5dd907f0b6bd418c82dbc1034c506ea5_Out_2, _Property_5acf053d54a247ca9c67136a62ded025_Out_0, _Property_e2e7b4b4046844469edada1a89545fda_Out_0, (_Property_e80420b13b6d42d59661e072a2dc41ae_Out_0.xxxx), (_SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.xyz), (_SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0).x, float3 (0, 0, 0), _Multiply_8ca141df72a74e338da52212e8d6e2c0_Out_2, _Property_6465a8de9d5d4c2698e734c26122def1_Out_0, _Property_f327aeab29c44190813949f1fc7752a7_Out_0, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Color_1, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Alpha_2, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_ShadeColor_3);
            Bindings_MixFog_e65d935e3c006a842b7a2fb6063b4b4d _MixFog_5eb6003dc4f349a9a0ba27d8cbc137cc;
            _MixFog_5eb6003dc4f349a9a0ba27d8cbc137cc.ObjectSpacePosition = IN.ObjectSpacePosition;
            float3 _MixFog_5eb6003dc4f349a9a0ba27d8cbc137cc_Color_3;
            SG_MixFog_e65d935e3c006a842b7a2fb6063b4b4d(_ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Color_1, _MixFog_5eb6003dc4f349a9a0ba27d8cbc137cc, _MixFog_5eb6003dc4f349a9a0ba27d8cbc137cc_Color_3);
            half _Float_aa047094cee542c28eeaa6eb94604431_Out_0 = 0.25;
            half3 _Multiply_e17367eab8ea40a29cca498bc52e544f_Out_2;
            Unity_Multiply_half(_ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_ShadeColor_3, (_Float_aa047094cee542c28eeaa6eb94604431_Out_0.xxx), _Multiply_e17367eab8ea40a29cca498bc52e544f_Out_2);
            Bindings_MixFog_e65d935e3c006a842b7a2fb6063b4b4d _MixFog_a23de110706d44bea5decbd42efa95da;
            _MixFog_a23de110706d44bea5decbd42efa95da.ObjectSpacePosition = IN.ObjectSpacePosition;
            float3 _MixFog_a23de110706d44bea5decbd42efa95da_Color_3;
            SG_MixFog_e65d935e3c006a842b7a2fb6063b4b4d(_Multiply_e17367eab8ea40a29cca498bc52e544f_Out_2, _MixFog_a23de110706d44bea5decbd42efa95da, _MixFog_a23de110706d44bea5decbd42efa95da_Color_3);
            surface.BaseColor = _MixFog_5eb6003dc4f349a9a0ba27d8cbc137cc_Color_3;
            surface.Alpha = _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Alpha_2;
            surface.AlphaClipThreshold = 0.5;
            surface.OutlineColor = _MixFog_a23de110706d44bea5decbd42efa95da_Color_3;
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
        half4 _BaseColor;
        float4 _BaseMap_TexelSize;
        half4 _SssColor;
        float4 _SssMap_TexelSize;
        half _Metalic;
        half _Smoothness;
        half _Curvature;
        float4 _BumpMap_TexelSize;
        float4 _OcclusionMap_TexelSize;
        half _Shade;
        float4 _ShadowMap_TexelSize;
        half _OutlineWidth;
        half _ShadeToony;
        half _ToonyLighting;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_SssMap);
        SAMPLER(sampler_SssMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_ShadowMap);
        SAMPLER(sampler_ShadowMap);

            // Graph Functions
            
        void Unity_Multiply_half(half4 A, half4 B, out half4 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_half(half A, half B, out half Out)
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
            half3 Position;
            half3 Normal;
            half3 Tangent;
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
            half Alpha;
            half AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            half4 _Property_3df23279bda04973984baae490a2d207_Out_0 = _BaseColor;
            UnityTexture2D _Property_667d1921191e43f18fcbcf55f831acbb_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            half4 _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_667d1921191e43f18fcbcf55f831acbb_Out_0.tex, _Property_667d1921191e43f18fcbcf55f831acbb_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_R_4 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.r;
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_G_5 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.g;
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_B_6 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.b;
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_A_7 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.a;
            half4 _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2;
            Unity_Multiply_half(_Property_3df23279bda04973984baae490a2d207_Out_0, _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0, _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2);
            half _Split_ccedce2765a149818f9e74db6b51d2ec_R_1 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[0];
            half _Split_ccedce2765a149818f9e74db6b51d2ec_G_2 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[1];
            half _Split_ccedce2765a149818f9e74db6b51d2ec_B_3 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[2];
            half _Split_ccedce2765a149818f9e74db6b51d2ec_A_4 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[3];
            half4 _Property_97f47d1158bb46d3b08685c745435b06_Out_0 = _SssColor;
            UnityTexture2D _Property_89783adf056c43c0b027affff717d430_Out_0 = UnityBuildTexture2DStructNoScale(_SssMap);
            half4 _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0 = SAMPLE_TEXTURE2D(_Property_89783adf056c43c0b027affff717d430_Out_0.tex, _Property_89783adf056c43c0b027affff717d430_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_R_4 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.r;
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_G_5 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.g;
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_B_6 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.b;
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_A_7 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.a;
            half4 _Multiply_5dd907f0b6bd418c82dbc1034c506ea5_Out_2;
            Unity_Multiply_half(_Property_97f47d1158bb46d3b08685c745435b06_Out_0, _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0, _Multiply_5dd907f0b6bd418c82dbc1034c506ea5_Out_2);
            half _Property_5acf053d54a247ca9c67136a62ded025_Out_0 = _Curvature;
            half _Property_e2e7b4b4046844469edada1a89545fda_Out_0 = _Smoothness;
            half _Property_e80420b13b6d42d59661e072a2dc41ae_Out_0 = _Metalic;
            UnityTexture2D _Property_9b16b8201d244080835656749dbf50fd_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            half4 _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9b16b8201d244080835656749dbf50fd_Out_0.tex, _Property_9b16b8201d244080835656749dbf50fd_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0);
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_R_4 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.r;
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_G_5 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.g;
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_B_6 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.b;
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_A_7 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.a;
            UnityTexture2D _Property_c40f6aff0210464987dd4f7ef80b22ed_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            half4 _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0 = SAMPLE_TEXTURE2D(_Property_c40f6aff0210464987dd4f7ef80b22ed_Out_0.tex, _Property_c40f6aff0210464987dd4f7ef80b22ed_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_R_4 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.r;
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_G_5 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.g;
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_B_6 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.b;
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_A_7 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.a;
            half _Property_f5545b7615f9400e9b3a7e8c64d84154_Out_0 = _Shade;
            UnityTexture2D _Property_2da17a6d8a9b4d9794fa49029c020494_Out_0 = UnityBuildTexture2DStructNoScale(_ShadowMap);
            half4 _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_2da17a6d8a9b4d9794fa49029c020494_Out_0.tex, _Property_2da17a6d8a9b4d9794fa49029c020494_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_R_4 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.r;
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_G_5 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.g;
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_B_6 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.b;
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_A_7 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.a;
            half _Multiply_8ca141df72a74e338da52212e8d6e2c0_Out_2;
            Unity_Multiply_half(_Property_f5545b7615f9400e9b3a7e8c64d84154_Out_0, _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_R_4, _Multiply_8ca141df72a74e338da52212e8d6e2c0_Out_2);
            half _Property_6465a8de9d5d4c2698e734c26122def1_Out_0 = _ShadeToony;
            half _Property_f327aeab29c44190813949f1fc7752a7_Out_0 = _ToonyLighting;
            Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830 _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceNormal = IN.WorldSpaceNormal;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceTangent = IN.WorldSpaceTangent;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.ObjectSpacePosition = IN.ObjectSpacePosition;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpacePosition = IN.WorldSpacePosition;
            half3 _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Color_1;
            half _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Alpha_2;
            half3 _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_ShadeColor_3;
            SG_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830((_Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2.xyz), _Split_ccedce2765a149818f9e74db6b51d2ec_A_4, _Multiply_5dd907f0b6bd418c82dbc1034c506ea5_Out_2, _Property_5acf053d54a247ca9c67136a62ded025_Out_0, _Property_e2e7b4b4046844469edada1a89545fda_Out_0, (_Property_e80420b13b6d42d59661e072a2dc41ae_Out_0.xxxx), (_SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.xyz), (_SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0).x, float3 (0, 0, 0), _Multiply_8ca141df72a74e338da52212e8d6e2c0_Out_2, _Property_6465a8de9d5d4c2698e734c26122def1_Out_0, _Property_f327aeab29c44190813949f1fc7752a7_Out_0, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Color_1, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Alpha_2, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_ShadeColor_3);
            surface.Alpha = _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Alpha_2;
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
        half4 _BaseColor;
        float4 _BaseMap_TexelSize;
        half4 _SssColor;
        float4 _SssMap_TexelSize;
        half _Metalic;
        half _Smoothness;
        half _Curvature;
        float4 _BumpMap_TexelSize;
        float4 _OcclusionMap_TexelSize;
        half _Shade;
        float4 _ShadowMap_TexelSize;
        half _OutlineWidth;
        half _ShadeToony;
        half _ToonyLighting;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_SssMap);
        SAMPLER(sampler_SssMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_ShadowMap);
        SAMPLER(sampler_ShadowMap);

            // Graph Functions
            
        void Unity_Multiply_half(half4 A, half4 B, out half4 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_half(half A, half B, out half Out)
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
            half3 Position;
            half3 Normal;
            half3 Tangent;
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
            half Alpha;
            half AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            half4 _Property_3df23279bda04973984baae490a2d207_Out_0 = _BaseColor;
            UnityTexture2D _Property_667d1921191e43f18fcbcf55f831acbb_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            half4 _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_667d1921191e43f18fcbcf55f831acbb_Out_0.tex, _Property_667d1921191e43f18fcbcf55f831acbb_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_R_4 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.r;
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_G_5 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.g;
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_B_6 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.b;
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_A_7 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.a;
            half4 _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2;
            Unity_Multiply_half(_Property_3df23279bda04973984baae490a2d207_Out_0, _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0, _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2);
            half _Split_ccedce2765a149818f9e74db6b51d2ec_R_1 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[0];
            half _Split_ccedce2765a149818f9e74db6b51d2ec_G_2 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[1];
            half _Split_ccedce2765a149818f9e74db6b51d2ec_B_3 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[2];
            half _Split_ccedce2765a149818f9e74db6b51d2ec_A_4 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[3];
            half4 _Property_97f47d1158bb46d3b08685c745435b06_Out_0 = _SssColor;
            UnityTexture2D _Property_89783adf056c43c0b027affff717d430_Out_0 = UnityBuildTexture2DStructNoScale(_SssMap);
            half4 _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0 = SAMPLE_TEXTURE2D(_Property_89783adf056c43c0b027affff717d430_Out_0.tex, _Property_89783adf056c43c0b027affff717d430_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_R_4 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.r;
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_G_5 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.g;
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_B_6 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.b;
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_A_7 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.a;
            half4 _Multiply_5dd907f0b6bd418c82dbc1034c506ea5_Out_2;
            Unity_Multiply_half(_Property_97f47d1158bb46d3b08685c745435b06_Out_0, _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0, _Multiply_5dd907f0b6bd418c82dbc1034c506ea5_Out_2);
            half _Property_5acf053d54a247ca9c67136a62ded025_Out_0 = _Curvature;
            half _Property_e2e7b4b4046844469edada1a89545fda_Out_0 = _Smoothness;
            half _Property_e80420b13b6d42d59661e072a2dc41ae_Out_0 = _Metalic;
            UnityTexture2D _Property_9b16b8201d244080835656749dbf50fd_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            half4 _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9b16b8201d244080835656749dbf50fd_Out_0.tex, _Property_9b16b8201d244080835656749dbf50fd_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0);
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_R_4 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.r;
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_G_5 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.g;
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_B_6 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.b;
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_A_7 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.a;
            UnityTexture2D _Property_c40f6aff0210464987dd4f7ef80b22ed_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            half4 _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0 = SAMPLE_TEXTURE2D(_Property_c40f6aff0210464987dd4f7ef80b22ed_Out_0.tex, _Property_c40f6aff0210464987dd4f7ef80b22ed_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_R_4 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.r;
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_G_5 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.g;
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_B_6 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.b;
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_A_7 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.a;
            half _Property_f5545b7615f9400e9b3a7e8c64d84154_Out_0 = _Shade;
            UnityTexture2D _Property_2da17a6d8a9b4d9794fa49029c020494_Out_0 = UnityBuildTexture2DStructNoScale(_ShadowMap);
            half4 _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_2da17a6d8a9b4d9794fa49029c020494_Out_0.tex, _Property_2da17a6d8a9b4d9794fa49029c020494_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_R_4 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.r;
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_G_5 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.g;
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_B_6 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.b;
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_A_7 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.a;
            half _Multiply_8ca141df72a74e338da52212e8d6e2c0_Out_2;
            Unity_Multiply_half(_Property_f5545b7615f9400e9b3a7e8c64d84154_Out_0, _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_R_4, _Multiply_8ca141df72a74e338da52212e8d6e2c0_Out_2);
            half _Property_6465a8de9d5d4c2698e734c26122def1_Out_0 = _ShadeToony;
            half _Property_f327aeab29c44190813949f1fc7752a7_Out_0 = _ToonyLighting;
            Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830 _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceNormal = IN.WorldSpaceNormal;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceTangent = IN.WorldSpaceTangent;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.ObjectSpacePosition = IN.ObjectSpacePosition;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpacePosition = IN.WorldSpacePosition;
            half3 _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Color_1;
            half _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Alpha_2;
            half3 _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_ShadeColor_3;
            SG_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830((_Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2.xyz), _Split_ccedce2765a149818f9e74db6b51d2ec_A_4, _Multiply_5dd907f0b6bd418c82dbc1034c506ea5_Out_2, _Property_5acf053d54a247ca9c67136a62ded025_Out_0, _Property_e2e7b4b4046844469edada1a89545fda_Out_0, (_Property_e80420b13b6d42d59661e072a2dc41ae_Out_0.xxxx), (_SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.xyz), (_SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0).x, float3 (0, 0, 0), _Multiply_8ca141df72a74e338da52212e8d6e2c0_Out_2, _Property_6465a8de9d5d4c2698e734c26122def1_Out_0, _Property_f327aeab29c44190813949f1fc7752a7_Out_0, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Color_1, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Alpha_2, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_ShadeColor_3);
            surface.Alpha = _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Alpha_2;
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
        half4 _BaseColor;
        float4 _BaseMap_TexelSize;
        half4 _SssColor;
        float4 _SssMap_TexelSize;
        half _Metalic;
        half _Smoothness;
        half _Curvature;
        float4 _BumpMap_TexelSize;
        float4 _OcclusionMap_TexelSize;
        half _Shade;
        float4 _ShadowMap_TexelSize;
        half _OutlineWidth;
        half _ShadeToony;
        half _ToonyLighting;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_SssMap);
        SAMPLER(sampler_SssMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_ShadowMap);
        SAMPLER(sampler_ShadowMap);

            // Graph Functions
            
        void Unity_Multiply_half(half4 A, half4 B, out half4 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_half(half A, half B, out half Out)
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

        void Unity_Fog_float(out half4 Color, out half Density, half3 Position)
        {
            SHADERGRAPH_FOG(Position, Color, Density);
        }

        void Unity_Multiply_float(half A, half B, out half Out)
        {
            Out = A * B;
        }

        void Unity_Clamp_float(half In, half Min, half Max, out half Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Lerp_float3(half3 A, half3 B, half3 T, out half3 Out)
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
            half3 Position;
            half3 Normal;
            half3 Tangent;
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
            half3 BaseColor;
            half Alpha;
            half AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            half4 _Property_3df23279bda04973984baae490a2d207_Out_0 = _BaseColor;
            UnityTexture2D _Property_667d1921191e43f18fcbcf55f831acbb_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            half4 _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_667d1921191e43f18fcbcf55f831acbb_Out_0.tex, _Property_667d1921191e43f18fcbcf55f831acbb_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_R_4 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.r;
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_G_5 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.g;
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_B_6 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.b;
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_A_7 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.a;
            half4 _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2;
            Unity_Multiply_half(_Property_3df23279bda04973984baae490a2d207_Out_0, _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0, _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2);
            half _Split_ccedce2765a149818f9e74db6b51d2ec_R_1 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[0];
            half _Split_ccedce2765a149818f9e74db6b51d2ec_G_2 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[1];
            half _Split_ccedce2765a149818f9e74db6b51d2ec_B_3 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[2];
            half _Split_ccedce2765a149818f9e74db6b51d2ec_A_4 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[3];
            half4 _Property_97f47d1158bb46d3b08685c745435b06_Out_0 = _SssColor;
            UnityTexture2D _Property_89783adf056c43c0b027affff717d430_Out_0 = UnityBuildTexture2DStructNoScale(_SssMap);
            half4 _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0 = SAMPLE_TEXTURE2D(_Property_89783adf056c43c0b027affff717d430_Out_0.tex, _Property_89783adf056c43c0b027affff717d430_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_R_4 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.r;
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_G_5 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.g;
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_B_6 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.b;
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_A_7 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.a;
            half4 _Multiply_5dd907f0b6bd418c82dbc1034c506ea5_Out_2;
            Unity_Multiply_half(_Property_97f47d1158bb46d3b08685c745435b06_Out_0, _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0, _Multiply_5dd907f0b6bd418c82dbc1034c506ea5_Out_2);
            half _Property_5acf053d54a247ca9c67136a62ded025_Out_0 = _Curvature;
            half _Property_e2e7b4b4046844469edada1a89545fda_Out_0 = _Smoothness;
            half _Property_e80420b13b6d42d59661e072a2dc41ae_Out_0 = _Metalic;
            UnityTexture2D _Property_9b16b8201d244080835656749dbf50fd_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            half4 _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9b16b8201d244080835656749dbf50fd_Out_0.tex, _Property_9b16b8201d244080835656749dbf50fd_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0);
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_R_4 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.r;
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_G_5 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.g;
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_B_6 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.b;
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_A_7 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.a;
            UnityTexture2D _Property_c40f6aff0210464987dd4f7ef80b22ed_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            half4 _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0 = SAMPLE_TEXTURE2D(_Property_c40f6aff0210464987dd4f7ef80b22ed_Out_0.tex, _Property_c40f6aff0210464987dd4f7ef80b22ed_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_R_4 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.r;
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_G_5 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.g;
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_B_6 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.b;
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_A_7 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.a;
            half _Property_f5545b7615f9400e9b3a7e8c64d84154_Out_0 = _Shade;
            UnityTexture2D _Property_2da17a6d8a9b4d9794fa49029c020494_Out_0 = UnityBuildTexture2DStructNoScale(_ShadowMap);
            half4 _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_2da17a6d8a9b4d9794fa49029c020494_Out_0.tex, _Property_2da17a6d8a9b4d9794fa49029c020494_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_R_4 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.r;
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_G_5 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.g;
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_B_6 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.b;
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_A_7 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.a;
            half _Multiply_8ca141df72a74e338da52212e8d6e2c0_Out_2;
            Unity_Multiply_half(_Property_f5545b7615f9400e9b3a7e8c64d84154_Out_0, _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_R_4, _Multiply_8ca141df72a74e338da52212e8d6e2c0_Out_2);
            half _Property_6465a8de9d5d4c2698e734c26122def1_Out_0 = _ShadeToony;
            half _Property_f327aeab29c44190813949f1fc7752a7_Out_0 = _ToonyLighting;
            Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830 _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceNormal = IN.WorldSpaceNormal;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceTangent = IN.WorldSpaceTangent;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.ObjectSpacePosition = IN.ObjectSpacePosition;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpacePosition = IN.WorldSpacePosition;
            half3 _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Color_1;
            half _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Alpha_2;
            half3 _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_ShadeColor_3;
            SG_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830((_Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2.xyz), _Split_ccedce2765a149818f9e74db6b51d2ec_A_4, _Multiply_5dd907f0b6bd418c82dbc1034c506ea5_Out_2, _Property_5acf053d54a247ca9c67136a62ded025_Out_0, _Property_e2e7b4b4046844469edada1a89545fda_Out_0, (_Property_e80420b13b6d42d59661e072a2dc41ae_Out_0.xxxx), (_SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.xyz), (_SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0).x, float3 (0, 0, 0), _Multiply_8ca141df72a74e338da52212e8d6e2c0_Out_2, _Property_6465a8de9d5d4c2698e734c26122def1_Out_0, _Property_f327aeab29c44190813949f1fc7752a7_Out_0, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Color_1, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Alpha_2, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_ShadeColor_3);
            Bindings_MixFog_e65d935e3c006a842b7a2fb6063b4b4d _MixFog_5eb6003dc4f349a9a0ba27d8cbc137cc;
            _MixFog_5eb6003dc4f349a9a0ba27d8cbc137cc.ObjectSpacePosition = IN.ObjectSpacePosition;
            float3 _MixFog_5eb6003dc4f349a9a0ba27d8cbc137cc_Color_3;
            SG_MixFog_e65d935e3c006a842b7a2fb6063b4b4d(_ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Color_1, _MixFog_5eb6003dc4f349a9a0ba27d8cbc137cc, _MixFog_5eb6003dc4f349a9a0ba27d8cbc137cc_Color_3);
            surface.BaseColor = _MixFog_5eb6003dc4f349a9a0ba27d8cbc137cc_Color_3;
            surface.Alpha = _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Alpha_2;
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
        half4 _BaseColor;
        float4 _BaseMap_TexelSize;
        half4 _SssColor;
        float4 _SssMap_TexelSize;
        half _Metalic;
        half _Smoothness;
        half _Curvature;
        float4 _BumpMap_TexelSize;
        float4 _OcclusionMap_TexelSize;
        half _Shade;
        float4 _ShadowMap_TexelSize;
        half _OutlineWidth;
        half _ShadeToony;
        half _ToonyLighting;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_SssMap);
        SAMPLER(sampler_SssMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_ShadowMap);
        SAMPLER(sampler_ShadowMap);

            // Graph Functions
            
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

        void Unity_Multiply_half(half4 A, half4 B, out half4 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_half(half A, half B, out half Out)
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

        void Unity_Fog_float(out half4 Color, out half Density, half3 Position)
        {
            SHADERGRAPH_FOG(Position, Color, Density);
        }

        void Unity_Multiply_float(half A, half B, out half Out)
        {
            Out = A * B;
        }

        void Unity_Clamp_float(half In, half Min, half Max, out half Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Lerp_float3(half3 A, half3 B, half3 T, out half3 Out)
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

        void Unity_Multiply_half(half3 A, half3 B, out half3 Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            half3 Position;
            half3 Normal;
            half3 Tangent;
            half3 OutlinePosition;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            half _Property_a8970ba1ccd84de9b80fb72a0f9ce25e_Out_0 = _OutlineWidth;
            Bindings_ToonOutlineTransform_aadd6ff8a7ff83a4fb272240ac26c2b5 _ToonOutlineTransform_2223ce9ace444d2b949168108aff26bb;
            _ToonOutlineTransform_2223ce9ace444d2b949168108aff26bb.ObjectSpaceNormal = IN.ObjectSpaceNormal;
            _ToonOutlineTransform_2223ce9ace444d2b949168108aff26bb.ObjectSpacePosition = IN.ObjectSpacePosition;
            float3 _ToonOutlineTransform_2223ce9ace444d2b949168108aff26bb_OutlinePosition_1;
            SG_ToonOutlineTransform_aadd6ff8a7ff83a4fb272240ac26c2b5(_Property_a8970ba1ccd84de9b80fb72a0f9ce25e_Out_0, _ToonOutlineTransform_2223ce9ace444d2b949168108aff26bb, _ToonOutlineTransform_2223ce9ace444d2b949168108aff26bb_OutlinePosition_1);
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            description.OutlinePosition = _ToonOutlineTransform_2223ce9ace444d2b949168108aff26bb_OutlinePosition_1;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            half3 BaseColor;
            half Alpha;
            half AlphaClipThreshold;
            half3 OutlineColor;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            half4 _Property_3df23279bda04973984baae490a2d207_Out_0 = _BaseColor;
            UnityTexture2D _Property_667d1921191e43f18fcbcf55f831acbb_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            half4 _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_667d1921191e43f18fcbcf55f831acbb_Out_0.tex, _Property_667d1921191e43f18fcbcf55f831acbb_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_R_4 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.r;
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_G_5 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.g;
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_B_6 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.b;
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_A_7 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.a;
            half4 _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2;
            Unity_Multiply_half(_Property_3df23279bda04973984baae490a2d207_Out_0, _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0, _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2);
            half _Split_ccedce2765a149818f9e74db6b51d2ec_R_1 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[0];
            half _Split_ccedce2765a149818f9e74db6b51d2ec_G_2 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[1];
            half _Split_ccedce2765a149818f9e74db6b51d2ec_B_3 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[2];
            half _Split_ccedce2765a149818f9e74db6b51d2ec_A_4 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[3];
            half4 _Property_97f47d1158bb46d3b08685c745435b06_Out_0 = _SssColor;
            UnityTexture2D _Property_89783adf056c43c0b027affff717d430_Out_0 = UnityBuildTexture2DStructNoScale(_SssMap);
            half4 _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0 = SAMPLE_TEXTURE2D(_Property_89783adf056c43c0b027affff717d430_Out_0.tex, _Property_89783adf056c43c0b027affff717d430_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_R_4 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.r;
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_G_5 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.g;
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_B_6 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.b;
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_A_7 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.a;
            half4 _Multiply_5dd907f0b6bd418c82dbc1034c506ea5_Out_2;
            Unity_Multiply_half(_Property_97f47d1158bb46d3b08685c745435b06_Out_0, _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0, _Multiply_5dd907f0b6bd418c82dbc1034c506ea5_Out_2);
            half _Property_5acf053d54a247ca9c67136a62ded025_Out_0 = _Curvature;
            half _Property_e2e7b4b4046844469edada1a89545fda_Out_0 = _Smoothness;
            half _Property_e80420b13b6d42d59661e072a2dc41ae_Out_0 = _Metalic;
            UnityTexture2D _Property_9b16b8201d244080835656749dbf50fd_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            half4 _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9b16b8201d244080835656749dbf50fd_Out_0.tex, _Property_9b16b8201d244080835656749dbf50fd_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0);
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_R_4 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.r;
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_G_5 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.g;
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_B_6 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.b;
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_A_7 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.a;
            UnityTexture2D _Property_c40f6aff0210464987dd4f7ef80b22ed_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            half4 _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0 = SAMPLE_TEXTURE2D(_Property_c40f6aff0210464987dd4f7ef80b22ed_Out_0.tex, _Property_c40f6aff0210464987dd4f7ef80b22ed_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_R_4 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.r;
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_G_5 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.g;
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_B_6 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.b;
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_A_7 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.a;
            half _Property_f5545b7615f9400e9b3a7e8c64d84154_Out_0 = _Shade;
            UnityTexture2D _Property_2da17a6d8a9b4d9794fa49029c020494_Out_0 = UnityBuildTexture2DStructNoScale(_ShadowMap);
            half4 _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_2da17a6d8a9b4d9794fa49029c020494_Out_0.tex, _Property_2da17a6d8a9b4d9794fa49029c020494_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_R_4 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.r;
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_G_5 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.g;
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_B_6 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.b;
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_A_7 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.a;
            half _Multiply_8ca141df72a74e338da52212e8d6e2c0_Out_2;
            Unity_Multiply_half(_Property_f5545b7615f9400e9b3a7e8c64d84154_Out_0, _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_R_4, _Multiply_8ca141df72a74e338da52212e8d6e2c0_Out_2);
            half _Property_6465a8de9d5d4c2698e734c26122def1_Out_0 = _ShadeToony;
            half _Property_f327aeab29c44190813949f1fc7752a7_Out_0 = _ToonyLighting;
            Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830 _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceNormal = IN.WorldSpaceNormal;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceTangent = IN.WorldSpaceTangent;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.ObjectSpacePosition = IN.ObjectSpacePosition;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpacePosition = IN.WorldSpacePosition;
            half3 _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Color_1;
            half _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Alpha_2;
            half3 _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_ShadeColor_3;
            SG_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830((_Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2.xyz), _Split_ccedce2765a149818f9e74db6b51d2ec_A_4, _Multiply_5dd907f0b6bd418c82dbc1034c506ea5_Out_2, _Property_5acf053d54a247ca9c67136a62ded025_Out_0, _Property_e2e7b4b4046844469edada1a89545fda_Out_0, (_Property_e80420b13b6d42d59661e072a2dc41ae_Out_0.xxxx), (_SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.xyz), (_SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0).x, float3 (0, 0, 0), _Multiply_8ca141df72a74e338da52212e8d6e2c0_Out_2, _Property_6465a8de9d5d4c2698e734c26122def1_Out_0, _Property_f327aeab29c44190813949f1fc7752a7_Out_0, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Color_1, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Alpha_2, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_ShadeColor_3);
            Bindings_MixFog_e65d935e3c006a842b7a2fb6063b4b4d _MixFog_5eb6003dc4f349a9a0ba27d8cbc137cc;
            _MixFog_5eb6003dc4f349a9a0ba27d8cbc137cc.ObjectSpacePosition = IN.ObjectSpacePosition;
            float3 _MixFog_5eb6003dc4f349a9a0ba27d8cbc137cc_Color_3;
            SG_MixFog_e65d935e3c006a842b7a2fb6063b4b4d(_ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Color_1, _MixFog_5eb6003dc4f349a9a0ba27d8cbc137cc, _MixFog_5eb6003dc4f349a9a0ba27d8cbc137cc_Color_3);
            half _Float_aa047094cee542c28eeaa6eb94604431_Out_0 = 0.25;
            half3 _Multiply_e17367eab8ea40a29cca498bc52e544f_Out_2;
            Unity_Multiply_half(_ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_ShadeColor_3, (_Float_aa047094cee542c28eeaa6eb94604431_Out_0.xxx), _Multiply_e17367eab8ea40a29cca498bc52e544f_Out_2);
            Bindings_MixFog_e65d935e3c006a842b7a2fb6063b4b4d _MixFog_a23de110706d44bea5decbd42efa95da;
            _MixFog_a23de110706d44bea5decbd42efa95da.ObjectSpacePosition = IN.ObjectSpacePosition;
            float3 _MixFog_a23de110706d44bea5decbd42efa95da_Color_3;
            SG_MixFog_e65d935e3c006a842b7a2fb6063b4b4d(_Multiply_e17367eab8ea40a29cca498bc52e544f_Out_2, _MixFog_a23de110706d44bea5decbd42efa95da, _MixFog_a23de110706d44bea5decbd42efa95da_Color_3);
            surface.BaseColor = _MixFog_5eb6003dc4f349a9a0ba27d8cbc137cc_Color_3;
            surface.Alpha = _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Alpha_2;
            surface.AlphaClipThreshold = 0.5;
            surface.OutlineColor = _MixFog_a23de110706d44bea5decbd42efa95da_Color_3;
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
        half4 _BaseColor;
        float4 _BaseMap_TexelSize;
        half4 _SssColor;
        float4 _SssMap_TexelSize;
        half _Metalic;
        half _Smoothness;
        half _Curvature;
        float4 _BumpMap_TexelSize;
        float4 _OcclusionMap_TexelSize;
        half _Shade;
        float4 _ShadowMap_TexelSize;
        half _OutlineWidth;
        half _ShadeToony;
        half _ToonyLighting;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_SssMap);
        SAMPLER(sampler_SssMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_ShadowMap);
        SAMPLER(sampler_ShadowMap);

            // Graph Functions
            
        void Unity_Multiply_half(half4 A, half4 B, out half4 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_half(half A, half B, out half Out)
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
            half3 Position;
            half3 Normal;
            half3 Tangent;
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
            half Alpha;
            half AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            half4 _Property_3df23279bda04973984baae490a2d207_Out_0 = _BaseColor;
            UnityTexture2D _Property_667d1921191e43f18fcbcf55f831acbb_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            half4 _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_667d1921191e43f18fcbcf55f831acbb_Out_0.tex, _Property_667d1921191e43f18fcbcf55f831acbb_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_R_4 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.r;
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_G_5 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.g;
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_B_6 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.b;
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_A_7 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.a;
            half4 _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2;
            Unity_Multiply_half(_Property_3df23279bda04973984baae490a2d207_Out_0, _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0, _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2);
            half _Split_ccedce2765a149818f9e74db6b51d2ec_R_1 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[0];
            half _Split_ccedce2765a149818f9e74db6b51d2ec_G_2 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[1];
            half _Split_ccedce2765a149818f9e74db6b51d2ec_B_3 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[2];
            half _Split_ccedce2765a149818f9e74db6b51d2ec_A_4 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[3];
            half4 _Property_97f47d1158bb46d3b08685c745435b06_Out_0 = _SssColor;
            UnityTexture2D _Property_89783adf056c43c0b027affff717d430_Out_0 = UnityBuildTexture2DStructNoScale(_SssMap);
            half4 _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0 = SAMPLE_TEXTURE2D(_Property_89783adf056c43c0b027affff717d430_Out_0.tex, _Property_89783adf056c43c0b027affff717d430_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_R_4 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.r;
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_G_5 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.g;
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_B_6 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.b;
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_A_7 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.a;
            half4 _Multiply_5dd907f0b6bd418c82dbc1034c506ea5_Out_2;
            Unity_Multiply_half(_Property_97f47d1158bb46d3b08685c745435b06_Out_0, _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0, _Multiply_5dd907f0b6bd418c82dbc1034c506ea5_Out_2);
            half _Property_5acf053d54a247ca9c67136a62ded025_Out_0 = _Curvature;
            half _Property_e2e7b4b4046844469edada1a89545fda_Out_0 = _Smoothness;
            half _Property_e80420b13b6d42d59661e072a2dc41ae_Out_0 = _Metalic;
            UnityTexture2D _Property_9b16b8201d244080835656749dbf50fd_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            half4 _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9b16b8201d244080835656749dbf50fd_Out_0.tex, _Property_9b16b8201d244080835656749dbf50fd_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0);
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_R_4 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.r;
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_G_5 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.g;
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_B_6 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.b;
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_A_7 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.a;
            UnityTexture2D _Property_c40f6aff0210464987dd4f7ef80b22ed_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            half4 _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0 = SAMPLE_TEXTURE2D(_Property_c40f6aff0210464987dd4f7ef80b22ed_Out_0.tex, _Property_c40f6aff0210464987dd4f7ef80b22ed_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_R_4 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.r;
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_G_5 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.g;
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_B_6 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.b;
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_A_7 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.a;
            half _Property_f5545b7615f9400e9b3a7e8c64d84154_Out_0 = _Shade;
            UnityTexture2D _Property_2da17a6d8a9b4d9794fa49029c020494_Out_0 = UnityBuildTexture2DStructNoScale(_ShadowMap);
            half4 _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_2da17a6d8a9b4d9794fa49029c020494_Out_0.tex, _Property_2da17a6d8a9b4d9794fa49029c020494_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_R_4 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.r;
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_G_5 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.g;
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_B_6 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.b;
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_A_7 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.a;
            half _Multiply_8ca141df72a74e338da52212e8d6e2c0_Out_2;
            Unity_Multiply_half(_Property_f5545b7615f9400e9b3a7e8c64d84154_Out_0, _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_R_4, _Multiply_8ca141df72a74e338da52212e8d6e2c0_Out_2);
            half _Property_6465a8de9d5d4c2698e734c26122def1_Out_0 = _ShadeToony;
            half _Property_f327aeab29c44190813949f1fc7752a7_Out_0 = _ToonyLighting;
            Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830 _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceNormal = IN.WorldSpaceNormal;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceTangent = IN.WorldSpaceTangent;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.ObjectSpacePosition = IN.ObjectSpacePosition;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpacePosition = IN.WorldSpacePosition;
            half3 _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Color_1;
            half _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Alpha_2;
            half3 _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_ShadeColor_3;
            SG_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830((_Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2.xyz), _Split_ccedce2765a149818f9e74db6b51d2ec_A_4, _Multiply_5dd907f0b6bd418c82dbc1034c506ea5_Out_2, _Property_5acf053d54a247ca9c67136a62ded025_Out_0, _Property_e2e7b4b4046844469edada1a89545fda_Out_0, (_Property_e80420b13b6d42d59661e072a2dc41ae_Out_0.xxxx), (_SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.xyz), (_SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0).x, float3 (0, 0, 0), _Multiply_8ca141df72a74e338da52212e8d6e2c0_Out_2, _Property_6465a8de9d5d4c2698e734c26122def1_Out_0, _Property_f327aeab29c44190813949f1fc7752a7_Out_0, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Color_1, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Alpha_2, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_ShadeColor_3);
            surface.Alpha = _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Alpha_2;
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
        half4 _BaseColor;
        float4 _BaseMap_TexelSize;
        half4 _SssColor;
        float4 _SssMap_TexelSize;
        half _Metalic;
        half _Smoothness;
        half _Curvature;
        float4 _BumpMap_TexelSize;
        float4 _OcclusionMap_TexelSize;
        half _Shade;
        float4 _ShadowMap_TexelSize;
        half _OutlineWidth;
        half _ShadeToony;
        half _ToonyLighting;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_SssMap);
        SAMPLER(sampler_SssMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_ShadowMap);
        SAMPLER(sampler_ShadowMap);

            // Graph Functions
            
        void Unity_Multiply_half(half4 A, half4 B, out half4 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_half(half A, half B, out half Out)
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
            half3 Position;
            half3 Normal;
            half3 Tangent;
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
            half Alpha;
            half AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            half4 _Property_3df23279bda04973984baae490a2d207_Out_0 = _BaseColor;
            UnityTexture2D _Property_667d1921191e43f18fcbcf55f831acbb_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            half4 _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_667d1921191e43f18fcbcf55f831acbb_Out_0.tex, _Property_667d1921191e43f18fcbcf55f831acbb_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_R_4 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.r;
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_G_5 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.g;
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_B_6 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.b;
            half _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_A_7 = _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0.a;
            half4 _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2;
            Unity_Multiply_half(_Property_3df23279bda04973984baae490a2d207_Out_0, _SampleTexture2D_8aed6911616b462cb9dfbee7d468c6ed_RGBA_0, _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2);
            half _Split_ccedce2765a149818f9e74db6b51d2ec_R_1 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[0];
            half _Split_ccedce2765a149818f9e74db6b51d2ec_G_2 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[1];
            half _Split_ccedce2765a149818f9e74db6b51d2ec_B_3 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[2];
            half _Split_ccedce2765a149818f9e74db6b51d2ec_A_4 = _Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2[3];
            half4 _Property_97f47d1158bb46d3b08685c745435b06_Out_0 = _SssColor;
            UnityTexture2D _Property_89783adf056c43c0b027affff717d430_Out_0 = UnityBuildTexture2DStructNoScale(_SssMap);
            half4 _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0 = SAMPLE_TEXTURE2D(_Property_89783adf056c43c0b027affff717d430_Out_0.tex, _Property_89783adf056c43c0b027affff717d430_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_R_4 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.r;
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_G_5 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.g;
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_B_6 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.b;
            half _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_A_7 = _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0.a;
            half4 _Multiply_5dd907f0b6bd418c82dbc1034c506ea5_Out_2;
            Unity_Multiply_half(_Property_97f47d1158bb46d3b08685c745435b06_Out_0, _SampleTexture2D_a6ed0bef0c86481a9421e9c80b416212_RGBA_0, _Multiply_5dd907f0b6bd418c82dbc1034c506ea5_Out_2);
            half _Property_5acf053d54a247ca9c67136a62ded025_Out_0 = _Curvature;
            half _Property_e2e7b4b4046844469edada1a89545fda_Out_0 = _Smoothness;
            half _Property_e80420b13b6d42d59661e072a2dc41ae_Out_0 = _Metalic;
            UnityTexture2D _Property_9b16b8201d244080835656749dbf50fd_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            half4 _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9b16b8201d244080835656749dbf50fd_Out_0.tex, _Property_9b16b8201d244080835656749dbf50fd_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0);
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_R_4 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.r;
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_G_5 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.g;
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_B_6 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.b;
            half _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_A_7 = _SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.a;
            UnityTexture2D _Property_c40f6aff0210464987dd4f7ef80b22ed_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            half4 _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0 = SAMPLE_TEXTURE2D(_Property_c40f6aff0210464987dd4f7ef80b22ed_Out_0.tex, _Property_c40f6aff0210464987dd4f7ef80b22ed_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_R_4 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.r;
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_G_5 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.g;
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_B_6 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.b;
            half _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_A_7 = _SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0.a;
            half _Property_f5545b7615f9400e9b3a7e8c64d84154_Out_0 = _Shade;
            UnityTexture2D _Property_2da17a6d8a9b4d9794fa49029c020494_Out_0 = UnityBuildTexture2DStructNoScale(_ShadowMap);
            half4 _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_2da17a6d8a9b4d9794fa49029c020494_Out_0.tex, _Property_2da17a6d8a9b4d9794fa49029c020494_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_R_4 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.r;
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_G_5 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.g;
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_B_6 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.b;
            half _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_A_7 = _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_RGBA_0.a;
            half _Multiply_8ca141df72a74e338da52212e8d6e2c0_Out_2;
            Unity_Multiply_half(_Property_f5545b7615f9400e9b3a7e8c64d84154_Out_0, _SampleTexture2D_e62cba5db765450f8400d148f9fc1fbc_R_4, _Multiply_8ca141df72a74e338da52212e8d6e2c0_Out_2);
            half _Property_6465a8de9d5d4c2698e734c26122def1_Out_0 = _ShadeToony;
            half _Property_f327aeab29c44190813949f1fc7752a7_Out_0 = _ToonyLighting;
            Bindings_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830 _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceNormal = IN.WorldSpaceNormal;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceTangent = IN.WorldSpaceTangent;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.ObjectSpacePosition = IN.ObjectSpacePosition;
            _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45.WorldSpacePosition = IN.WorldSpacePosition;
            half3 _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Color_1;
            half _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Alpha_2;
            half3 _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_ShadeColor_3;
            SG_ToonLightingSmoothstepRamp_03a34668227e68d4696c470dae27f830((_Multiply_beb489c6fe6543ddbeb036bcd6c3073f_Out_2.xyz), _Split_ccedce2765a149818f9e74db6b51d2ec_A_4, _Multiply_5dd907f0b6bd418c82dbc1034c506ea5_Out_2, _Property_5acf053d54a247ca9c67136a62ded025_Out_0, _Property_e2e7b4b4046844469edada1a89545fda_Out_0, (_Property_e80420b13b6d42d59661e072a2dc41ae_Out_0.xxxx), (_SampleTexture2D_4df56d58ba7f49b2a8b620c97eb912cc_RGBA_0.xyz), (_SampleTexture2D_1fe4296985ec4bd2ad617e2e2a683beb_RGBA_0).x, float3 (0, 0, 0), _Multiply_8ca141df72a74e338da52212e8d6e2c0_Out_2, _Property_6465a8de9d5d4c2698e734c26122def1_Out_0, _Property_f327aeab29c44190813949f1fc7752a7_Out_0, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Color_1, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Alpha_2, _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_ShadeColor_3);
            surface.Alpha = _ToonLightingSmoothstepRamp_7490ec7b752e4ec8a91b1b1951ed1e45_Alpha_2;
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