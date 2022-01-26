Shader "Toon (Texture Ramp)"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset]_BaseMap("Base Map", 2D) = "white" {}
        _ShadeColor("SSS Color", Color) = (0, 0, 0, 0)
        [NoScaleOffset]_ShadeMap("SSS Map", 2D) = "white" {}
        _Smoothness("Smoothness", Range(0, 1)) = 0.5
        _Metalic("Metalic", Range(0, 1)) = 0
        [NoScaleOffset]_MetalicMap("Metalic Map", 2D) = "white" {}
        [NoScaleOffset]_BumpMap("Normal Map", 2D) = "bump" {}
        Vector1_812be4631501458ea83339c066bed988("Shade Shift", Range(0, 2)) = 1
        [NoScaleOffset]_OcclusionMap("Shade Map", 2D) = "white" {}
        [NoScaleOffset]_EmissionMap("Emission Map", 2D) = "black" {}
        [HDR]_EmissionColor("Emission Color", Color) = (1, 1, 1, 0)
        _OutlineWidth("Outline Width", Float) = 1
        _OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
        _ShadeToony("Shade Toony", Range(0, 1)) = 1
        [NoScaleOffset]_ShadeRamp("Shade Ramp", 2D) = "white" {}
        _ShadeEnvironmentalColor("Shade Environmental Color", Color) = (0.5019608, 0.5019608, 0.5019608, 1)
        _Curvature("Curvature", Range(0, 1)) = 1
        _ToonyLighting("Toony Lighting", Range(0, 1)) = 1
        _SilColor("Silouette Color", Color) = (0, 0, 0, 1)
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
            #pragma shader_feature_local _ SHADEMODEL_RAMP



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
            float3 AbsoluteWorldSpacePosition;
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
        half4 _ShadeColor;
        float4 _ShadeMap_TexelSize;
        half _Smoothness;
        half _Metalic;
        float4 _MetalicMap_TexelSize;
        float4 _BumpMap_TexelSize;
        half Vector1_812be4631501458ea83339c066bed988;
        float4 _OcclusionMap_TexelSize;
        float4 _EmissionMap_TexelSize;
        half4 _EmissionColor;
        half _OutlineWidth;
        half4 _OutlineColor;
        half _ShadeToony;
        float4 _ShadeRamp_TexelSize;
        half4 _ShadeEnvironmentalColor;
        half _Curvature;
        half _ToonyLighting;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_ShadeMap);
        SAMPLER(sampler_ShadeMap);
        TEXTURE2D(_MetalicMap);
        SAMPLER(sampler_MetalicMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_ShadeRamp);
        SAMPLER(sampler_ShadeRamp);

            // Graph Functions
            
        void Unity_Multiply_half(half4 A, half4 B, out half4 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_half(half A, half B, out half Out)
        {
            Out = A * B;
        }

        // 76f53fe8936248969bc5201998a191c2
        #include "Assets/jp.lilium.toongraph/Contents/Shader/ToonLightingTextureRamp.hlsl"

        struct Bindings_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 ObjectSpacePosition;
            float3 AbsoluteWorldSpacePosition;
        };

        void SG_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5(float3 Vector3_65F6C04, float Vector1_4C8E34DF, float4 Color_1d3a761e471e4de7902496d49c375f8d, float4 Color_149A5746, float Vector1_328D12DB, float3 Vector3_A82C1F5A, float Vector1_CA473DD5, float3 Vector3_6818DD95, float Vector1_13346DDE, float Vector1_A8A74B72, UnityTexture2D Texture2D_ED058F03, float Vector1_a444e4171473481c8e0c83879e47165f, float Vector1_89971EC3, Bindings_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5 IN, out half3 Color_1, out half Aloha_2, out half3 ShadeColor_3)
        {
            float3 _Property_100e7faf3a4b402a9feb960d09e5ae4d_Out_0 = Vector3_65F6C04;
            float4 _Property_81825652062f4ba69f97553e28ca0e82_Out_0 = Color_1d3a761e471e4de7902496d49c375f8d;
            float3 _Property_b663d0ce9edf4b9aa573c97c4a9d8a3e_Out_0 = Vector3_A82C1F5A;
            float4 _Property_a6b1df0e799e4081847d4fb6db35a457_Out_0 = Color_149A5746;
            float _Property_1fa9bb2cd2b640f08167086e8f7446f4_Out_0 = Vector1_328D12DB;
            float _Property_6afdfaf017914a668ddae91b64c1235d_Out_0 = Vector1_CA473DD5;
            float3 _Property_6219660fe08e4e73aaaeb556524789b0_Out_0 = Vector3_6818DD95;
            float _Property_81f811dd2cf44ad38ec59bc1501fade3_Out_0 = Vector1_4C8E34DF;
            float _Property_97349003e4ae4e37a1b998f0ea011627_Out_0 = Vector1_13346DDE;
            float _Property_6fadb645726e432ab26a6a72a8acf4ee_Out_0 = Vector1_A8A74B72;
            UnityTexture2D _Property_5a4edac20031400494580c4e0f7da972_Out_0 = Texture2D_ED058F03;
            float _Property_b019a5b269ce4ce2baedaf3aff7c0289_Out_0 = Vector1_a444e4171473481c8e0c83879e47165f;
            float _Property_6c07cc6a832b4faab0ca314c175599f4_Out_0 = Vector1_89971EC3;
            half4 _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0;
            half3 _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_ShadeColor_20;
            ToonLight_half(IN.ObjectSpacePosition, IN.AbsoluteWorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceViewDirection, _Property_100e7faf3a4b402a9feb960d09e5ae4d_Out_0, _Property_81825652062f4ba69f97553e28ca0e82_Out_0, _Property_b663d0ce9edf4b9aa573c97c4a9d8a3e_Out_0, (_Property_a6b1df0e799e4081847d4fb6db35a457_Out_0.xyz), _Property_1fa9bb2cd2b640f08167086e8f7446f4_Out_0, _Property_6afdfaf017914a668ddae91b64c1235d_Out_0, _Property_6219660fe08e4e73aaaeb556524789b0_Out_0, _Property_81f811dd2cf44ad38ec59bc1501fade3_Out_0, _Property_97349003e4ae4e37a1b998f0ea011627_Out_0, _Property_6fadb645726e432ab26a6a72a8acf4ee_Out_0, _Property_5a4edac20031400494580c4e0f7da972_Out_0.tex, _Property_b019a5b269ce4ce2baedaf3aff7c0289_Out_0, _Property_6c07cc6a832b4faab0ca314c175599f4_Out_0, _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0, _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_ShadeColor_20);
            half _Split_308656dd68824b28897ed650e60e4017_R_1 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[0];
            half _Split_308656dd68824b28897ed650e60e4017_G_2 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[1];
            half _Split_308656dd68824b28897ed650e60e4017_B_3 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[2];
            half _Split_308656dd68824b28897ed650e60e4017_A_4 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[3];
            Color_1 = (_ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0.xyz);
            Aloha_2 = _Split_308656dd68824b28897ed650e60e4017_A_4;
            ShadeColor_3 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_ShadeColor_20;
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
            half4 _Property_dc0ba5482ecc4b09a32264f12a7f96bf_Out_0 = _BaseColor;
            UnityTexture2D _Property_6d01542dab39454f96244b27f2302104_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            half4 _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_6d01542dab39454f96244b27f2302104_Out_0.tex, _Property_6d01542dab39454f96244b27f2302104_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_R_4 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.r;
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_G_5 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.g;
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_B_6 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.b;
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_A_7 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.a;
            half4 _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2;
            Unity_Multiply_half(_Property_dc0ba5482ecc4b09a32264f12a7f96bf_Out_0, _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0, _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2);
            half _Split_8a190d5587d140a98b725b1618be5378_R_1 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[0];
            half _Split_8a190d5587d140a98b725b1618be5378_G_2 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[1];
            half _Split_8a190d5587d140a98b725b1618be5378_B_3 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[2];
            half _Split_8a190d5587d140a98b725b1618be5378_A_4 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[3];
            half4 _Property_e669a7f35e9046b78538aa00b5a760b5_Out_0 = _ShadeColor;
            UnityTexture2D _Property_e2a0e185d2994abba5cd08ed1aed0260_Out_0 = UnityBuildTexture2DStructNoScale(_ShadeMap);
            half4 _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e2a0e185d2994abba5cd08ed1aed0260_Out_0.tex, _Property_e2a0e185d2994abba5cd08ed1aed0260_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_R_4 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.r;
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_G_5 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.g;
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_B_6 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.b;
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_A_7 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.a;
            half4 _Multiply_041495d9da724630a886735576fb2bd4_Out_2;
            Unity_Multiply_half(_Property_e669a7f35e9046b78538aa00b5a760b5_Out_0, _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0, _Multiply_041495d9da724630a886735576fb2bd4_Out_2);
            half _Property_d229fb937937488fa027e9f96980225e_Out_0 = _Metalic;
            UnityTexture2D _Property_dd2afd9183d24597a6bfdc8475c1cee6_Out_0 = UnityBuildTexture2DStructNoScale(_MetalicMap);
            half4 _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0 = SAMPLE_TEXTURE2D(_Property_dd2afd9183d24597a6bfdc8475c1cee6_Out_0.tex, _Property_dd2afd9183d24597a6bfdc8475c1cee6_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_R_4 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.r;
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_G_5 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.g;
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_B_6 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.b;
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_A_7 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.a;
            half4 _Multiply_b549bc066fe64ffbb69174bcda8c8f7a_Out_2;
            Unity_Multiply_half((_Property_d229fb937937488fa027e9f96980225e_Out_0.xxxx), _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0, _Multiply_b549bc066fe64ffbb69174bcda8c8f7a_Out_2);
            half _Property_72cbd81e07b74b149bcacc8e4ec541ef_Out_0 = _Smoothness;
            UnityTexture2D _Property_da6be2aaf4da4e1a8e7dbdaacb83f1c4_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            half4 _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_da6be2aaf4da4e1a8e7dbdaacb83f1c4_Out_0.tex, _Property_da6be2aaf4da4e1a8e7dbdaacb83f1c4_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0);
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_R_4 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.r;
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_G_5 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.g;
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_B_6 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.b;
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_A_7 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.a;
            half4 _Property_bd135e9c7d464f2aac018c888c1c19e4_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            UnityTexture2D _Property_da66f2d54e5e4f1d9b4e6169fb9833bf_Out_0 = UnityBuildTexture2DStructNoScale(_EmissionMap);
            half4 _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0 = SAMPLE_TEXTURE2D(_Property_da66f2d54e5e4f1d9b4e6169fb9833bf_Out_0.tex, _Property_da66f2d54e5e4f1d9b4e6169fb9833bf_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_R_4 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.r;
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_G_5 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.g;
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_B_6 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.b;
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_A_7 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.a;
            half4 _Multiply_97980ed117bc43fe8c3652f77084429d_Out_2;
            Unity_Multiply_half(_Property_bd135e9c7d464f2aac018c888c1c19e4_Out_0, _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0, _Multiply_97980ed117bc43fe8c3652f77084429d_Out_2);
            half _Property_d326b8f6ddb54a138dffb63b47a2ce0a_Out_0 = Vector1_812be4631501458ea83339c066bed988;
            UnityTexture2D _Property_500c6a1cc2cb40e2bc0c4e72674299f7_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            half4 _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0 = SAMPLE_TEXTURE2D(_Property_500c6a1cc2cb40e2bc0c4e72674299f7_Out_0.tex, _Property_500c6a1cc2cb40e2bc0c4e72674299f7_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_R_4 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.r;
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_G_5 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.g;
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_B_6 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.b;
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_A_7 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.a;
            half _Multiply_180ff739424a4186accb3226ed998abe_Out_2;
            Unity_Multiply_half(_Property_d326b8f6ddb54a138dffb63b47a2ce0a_Out_0, _SampleTexture2D_3defb7d0d466445a95386d6845502441_R_4, _Multiply_180ff739424a4186accb3226ed998abe_Out_2);
            half _Property_13f4cc575f2542cea2938b11a825b7a6_Out_0 = _ShadeToony;
            UnityTexture2D _Property_c8f5752f4359405bbbdb833daa5ecb49_Out_0 = UnityBuildTexture2DStructNoScale(_ShadeRamp);
            half _Property_3df8d2a5beba45b9bd543d1bae33268b_Out_0 = _Curvature;
            half _Property_f21b961a69e3401bbd7673eed435785a_Out_0 = _ToonyLighting;
            Bindings_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5 _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceNormal = IN.WorldSpaceNormal;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceTangent = IN.WorldSpaceTangent;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.ObjectSpacePosition = IN.ObjectSpacePosition;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
            half3 _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Color_1;
            half _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Aloha_2;
            half3 _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_ShadeColor_3;
            SG_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5((_Multiply_ed762052df704f3b992bcd126a4ce227_Out_2.xyz), _Split_8a190d5587d140a98b725b1618be5378_A_4, _Multiply_041495d9da724630a886735576fb2bd4_Out_2, _Multiply_b549bc066fe64ffbb69174bcda8c8f7a_Out_2, _Property_72cbd81e07b74b149bcacc8e4ec541ef_Out_0, (_SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.xyz), 1, (_Multiply_97980ed117bc43fe8c3652f77084429d_Out_2.xyz), _Multiply_180ff739424a4186accb3226ed998abe_Out_2, _Property_13f4cc575f2542cea2938b11a825b7a6_Out_0, _Property_c8f5752f4359405bbbdb833daa5ecb49_Out_0, _Property_3df8d2a5beba45b9bd543d1bae33268b_Out_0, _Property_f21b961a69e3401bbd7673eed435785a_Out_0, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Color_1, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Aloha_2, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_ShadeColor_3);
            Bindings_MixFog_e65d935e3c006a842b7a2fb6063b4b4d _MixFog_89e264823ce74a9b8d51f6b69cc5c3c8;
            _MixFog_89e264823ce74a9b8d51f6b69cc5c3c8.ObjectSpacePosition = IN.ObjectSpacePosition;
            float3 _MixFog_89e264823ce74a9b8d51f6b69cc5c3c8_Color_3;
            SG_MixFog_e65d935e3c006a842b7a2fb6063b4b4d(_ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Color_1, _MixFog_89e264823ce74a9b8d51f6b69cc5c3c8, _MixFog_89e264823ce74a9b8d51f6b69cc5c3c8_Color_3);
            surface.BaseColor = _MixFog_89e264823ce74a9b8d51f6b69cc5c3c8_Color_3;
            surface.Alpha = _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Aloha_2;
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
            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(input.positionWS);
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
            #pragma shader_feature_local _ SHADEMODEL_RAMP



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
            float3 AbsoluteWorldSpacePosition;
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
        half4 _ShadeColor;
        float4 _ShadeMap_TexelSize;
        half _Smoothness;
        half _Metalic;
        float4 _MetalicMap_TexelSize;
        float4 _BumpMap_TexelSize;
        half Vector1_812be4631501458ea83339c066bed988;
        float4 _OcclusionMap_TexelSize;
        float4 _EmissionMap_TexelSize;
        half4 _EmissionColor;
        half _OutlineWidth;
        half4 _OutlineColor;
        half _ShadeToony;
        float4 _ShadeRamp_TexelSize;
        half4 _ShadeEnvironmentalColor;
        half _Curvature;
        half _ToonyLighting;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_ShadeMap);
        SAMPLER(sampler_ShadeMap);
        TEXTURE2D(_MetalicMap);
        SAMPLER(sampler_MetalicMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_ShadeRamp);
        SAMPLER(sampler_ShadeRamp);

            // Graph Functions
            
        // 49735d9b5dbe4bddc0f32ad2f736db4c
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

        // 76f53fe8936248969bc5201998a191c2
        #include "Assets/jp.lilium.toongraph/Contents/Shader/ToonLightingTextureRamp.hlsl"

        struct Bindings_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 ObjectSpacePosition;
            float3 AbsoluteWorldSpacePosition;
        };

        void SG_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5(float3 Vector3_65F6C04, float Vector1_4C8E34DF, float4 Color_1d3a761e471e4de7902496d49c375f8d, float4 Color_149A5746, float Vector1_328D12DB, float3 Vector3_A82C1F5A, float Vector1_CA473DD5, float3 Vector3_6818DD95, float Vector1_13346DDE, float Vector1_A8A74B72, UnityTexture2D Texture2D_ED058F03, float Vector1_a444e4171473481c8e0c83879e47165f, float Vector1_89971EC3, Bindings_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5 IN, out half3 Color_1, out half Aloha_2, out half3 ShadeColor_3)
        {
            float3 _Property_100e7faf3a4b402a9feb960d09e5ae4d_Out_0 = Vector3_65F6C04;
            float4 _Property_81825652062f4ba69f97553e28ca0e82_Out_0 = Color_1d3a761e471e4de7902496d49c375f8d;
            float3 _Property_b663d0ce9edf4b9aa573c97c4a9d8a3e_Out_0 = Vector3_A82C1F5A;
            float4 _Property_a6b1df0e799e4081847d4fb6db35a457_Out_0 = Color_149A5746;
            float _Property_1fa9bb2cd2b640f08167086e8f7446f4_Out_0 = Vector1_328D12DB;
            float _Property_6afdfaf017914a668ddae91b64c1235d_Out_0 = Vector1_CA473DD5;
            float3 _Property_6219660fe08e4e73aaaeb556524789b0_Out_0 = Vector3_6818DD95;
            float _Property_81f811dd2cf44ad38ec59bc1501fade3_Out_0 = Vector1_4C8E34DF;
            float _Property_97349003e4ae4e37a1b998f0ea011627_Out_0 = Vector1_13346DDE;
            float _Property_6fadb645726e432ab26a6a72a8acf4ee_Out_0 = Vector1_A8A74B72;
            UnityTexture2D _Property_5a4edac20031400494580c4e0f7da972_Out_0 = Texture2D_ED058F03;
            float _Property_b019a5b269ce4ce2baedaf3aff7c0289_Out_0 = Vector1_a444e4171473481c8e0c83879e47165f;
            float _Property_6c07cc6a832b4faab0ca314c175599f4_Out_0 = Vector1_89971EC3;
            half4 _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0;
            half3 _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_ShadeColor_20;
            ToonLight_half(IN.ObjectSpacePosition, IN.AbsoluteWorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceViewDirection, _Property_100e7faf3a4b402a9feb960d09e5ae4d_Out_0, _Property_81825652062f4ba69f97553e28ca0e82_Out_0, _Property_b663d0ce9edf4b9aa573c97c4a9d8a3e_Out_0, (_Property_a6b1df0e799e4081847d4fb6db35a457_Out_0.xyz), _Property_1fa9bb2cd2b640f08167086e8f7446f4_Out_0, _Property_6afdfaf017914a668ddae91b64c1235d_Out_0, _Property_6219660fe08e4e73aaaeb556524789b0_Out_0, _Property_81f811dd2cf44ad38ec59bc1501fade3_Out_0, _Property_97349003e4ae4e37a1b998f0ea011627_Out_0, _Property_6fadb645726e432ab26a6a72a8acf4ee_Out_0, _Property_5a4edac20031400494580c4e0f7da972_Out_0.tex, _Property_b019a5b269ce4ce2baedaf3aff7c0289_Out_0, _Property_6c07cc6a832b4faab0ca314c175599f4_Out_0, _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0, _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_ShadeColor_20);
            half _Split_308656dd68824b28897ed650e60e4017_R_1 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[0];
            half _Split_308656dd68824b28897ed650e60e4017_G_2 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[1];
            half _Split_308656dd68824b28897ed650e60e4017_B_3 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[2];
            half _Split_308656dd68824b28897ed650e60e4017_A_4 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[3];
            Color_1 = (_ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0.xyz);
            Aloha_2 = _Split_308656dd68824b28897ed650e60e4017_A_4;
            ShadeColor_3 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_ShadeColor_20;
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
            half3 OutlinePosition;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            half _Property_23a4f2ebe14845a095c2c5f4c5c4b4f4_Out_0 = _OutlineWidth;
            Bindings_ToonOutlineTransform_aadd6ff8a7ff83a4fb272240ac26c2b5 _ToonOutlineTransform_652306bda77e43328a84fa5b38e21cab;
            _ToonOutlineTransform_652306bda77e43328a84fa5b38e21cab.ObjectSpaceNormal = IN.ObjectSpaceNormal;
            _ToonOutlineTransform_652306bda77e43328a84fa5b38e21cab.ObjectSpacePosition = IN.ObjectSpacePosition;
            float3 _ToonOutlineTransform_652306bda77e43328a84fa5b38e21cab_OutlinePosition_1;
            SG_ToonOutlineTransform_aadd6ff8a7ff83a4fb272240ac26c2b5(_Property_23a4f2ebe14845a095c2c5f4c5c4b4f4_Out_0, _ToonOutlineTransform_652306bda77e43328a84fa5b38e21cab, _ToonOutlineTransform_652306bda77e43328a84fa5b38e21cab_OutlinePosition_1);
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            description.OutlinePosition = _ToonOutlineTransform_652306bda77e43328a84fa5b38e21cab_OutlinePosition_1;
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
            half4 _Property_dc0ba5482ecc4b09a32264f12a7f96bf_Out_0 = _BaseColor;
            UnityTexture2D _Property_6d01542dab39454f96244b27f2302104_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            half4 _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_6d01542dab39454f96244b27f2302104_Out_0.tex, _Property_6d01542dab39454f96244b27f2302104_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_R_4 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.r;
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_G_5 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.g;
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_B_6 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.b;
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_A_7 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.a;
            half4 _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2;
            Unity_Multiply_half(_Property_dc0ba5482ecc4b09a32264f12a7f96bf_Out_0, _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0, _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2);
            half _Split_8a190d5587d140a98b725b1618be5378_R_1 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[0];
            half _Split_8a190d5587d140a98b725b1618be5378_G_2 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[1];
            half _Split_8a190d5587d140a98b725b1618be5378_B_3 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[2];
            half _Split_8a190d5587d140a98b725b1618be5378_A_4 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[3];
            half4 _Property_e669a7f35e9046b78538aa00b5a760b5_Out_0 = _ShadeColor;
            UnityTexture2D _Property_e2a0e185d2994abba5cd08ed1aed0260_Out_0 = UnityBuildTexture2DStructNoScale(_ShadeMap);
            half4 _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e2a0e185d2994abba5cd08ed1aed0260_Out_0.tex, _Property_e2a0e185d2994abba5cd08ed1aed0260_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_R_4 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.r;
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_G_5 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.g;
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_B_6 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.b;
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_A_7 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.a;
            half4 _Multiply_041495d9da724630a886735576fb2bd4_Out_2;
            Unity_Multiply_half(_Property_e669a7f35e9046b78538aa00b5a760b5_Out_0, _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0, _Multiply_041495d9da724630a886735576fb2bd4_Out_2);
            half _Property_d229fb937937488fa027e9f96980225e_Out_0 = _Metalic;
            UnityTexture2D _Property_dd2afd9183d24597a6bfdc8475c1cee6_Out_0 = UnityBuildTexture2DStructNoScale(_MetalicMap);
            half4 _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0 = SAMPLE_TEXTURE2D(_Property_dd2afd9183d24597a6bfdc8475c1cee6_Out_0.tex, _Property_dd2afd9183d24597a6bfdc8475c1cee6_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_R_4 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.r;
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_G_5 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.g;
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_B_6 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.b;
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_A_7 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.a;
            half4 _Multiply_b549bc066fe64ffbb69174bcda8c8f7a_Out_2;
            Unity_Multiply_half((_Property_d229fb937937488fa027e9f96980225e_Out_0.xxxx), _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0, _Multiply_b549bc066fe64ffbb69174bcda8c8f7a_Out_2);
            half _Property_72cbd81e07b74b149bcacc8e4ec541ef_Out_0 = _Smoothness;
            UnityTexture2D _Property_da6be2aaf4da4e1a8e7dbdaacb83f1c4_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            half4 _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_da6be2aaf4da4e1a8e7dbdaacb83f1c4_Out_0.tex, _Property_da6be2aaf4da4e1a8e7dbdaacb83f1c4_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0);
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_R_4 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.r;
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_G_5 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.g;
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_B_6 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.b;
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_A_7 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.a;
            half4 _Property_bd135e9c7d464f2aac018c888c1c19e4_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            UnityTexture2D _Property_da66f2d54e5e4f1d9b4e6169fb9833bf_Out_0 = UnityBuildTexture2DStructNoScale(_EmissionMap);
            half4 _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0 = SAMPLE_TEXTURE2D(_Property_da66f2d54e5e4f1d9b4e6169fb9833bf_Out_0.tex, _Property_da66f2d54e5e4f1d9b4e6169fb9833bf_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_R_4 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.r;
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_G_5 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.g;
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_B_6 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.b;
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_A_7 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.a;
            half4 _Multiply_97980ed117bc43fe8c3652f77084429d_Out_2;
            Unity_Multiply_half(_Property_bd135e9c7d464f2aac018c888c1c19e4_Out_0, _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0, _Multiply_97980ed117bc43fe8c3652f77084429d_Out_2);
            half _Property_d326b8f6ddb54a138dffb63b47a2ce0a_Out_0 = Vector1_812be4631501458ea83339c066bed988;
            UnityTexture2D _Property_500c6a1cc2cb40e2bc0c4e72674299f7_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            half4 _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0 = SAMPLE_TEXTURE2D(_Property_500c6a1cc2cb40e2bc0c4e72674299f7_Out_0.tex, _Property_500c6a1cc2cb40e2bc0c4e72674299f7_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_R_4 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.r;
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_G_5 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.g;
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_B_6 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.b;
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_A_7 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.a;
            half _Multiply_180ff739424a4186accb3226ed998abe_Out_2;
            Unity_Multiply_half(_Property_d326b8f6ddb54a138dffb63b47a2ce0a_Out_0, _SampleTexture2D_3defb7d0d466445a95386d6845502441_R_4, _Multiply_180ff739424a4186accb3226ed998abe_Out_2);
            half _Property_13f4cc575f2542cea2938b11a825b7a6_Out_0 = _ShadeToony;
            UnityTexture2D _Property_c8f5752f4359405bbbdb833daa5ecb49_Out_0 = UnityBuildTexture2DStructNoScale(_ShadeRamp);
            half _Property_3df8d2a5beba45b9bd543d1bae33268b_Out_0 = _Curvature;
            half _Property_f21b961a69e3401bbd7673eed435785a_Out_0 = _ToonyLighting;
            Bindings_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5 _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceNormal = IN.WorldSpaceNormal;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceTangent = IN.WorldSpaceTangent;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.ObjectSpacePosition = IN.ObjectSpacePosition;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
            half3 _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Color_1;
            half _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Aloha_2;
            half3 _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_ShadeColor_3;
            SG_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5((_Multiply_ed762052df704f3b992bcd126a4ce227_Out_2.xyz), _Split_8a190d5587d140a98b725b1618be5378_A_4, _Multiply_041495d9da724630a886735576fb2bd4_Out_2, _Multiply_b549bc066fe64ffbb69174bcda8c8f7a_Out_2, _Property_72cbd81e07b74b149bcacc8e4ec541ef_Out_0, (_SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.xyz), 1, (_Multiply_97980ed117bc43fe8c3652f77084429d_Out_2.xyz), _Multiply_180ff739424a4186accb3226ed998abe_Out_2, _Property_13f4cc575f2542cea2938b11a825b7a6_Out_0, _Property_c8f5752f4359405bbbdb833daa5ecb49_Out_0, _Property_3df8d2a5beba45b9bd543d1bae33268b_Out_0, _Property_f21b961a69e3401bbd7673eed435785a_Out_0, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Color_1, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Aloha_2, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_ShadeColor_3);
            Bindings_MixFog_e65d935e3c006a842b7a2fb6063b4b4d _MixFog_89e264823ce74a9b8d51f6b69cc5c3c8;
            _MixFog_89e264823ce74a9b8d51f6b69cc5c3c8.ObjectSpacePosition = IN.ObjectSpacePosition;
            float3 _MixFog_89e264823ce74a9b8d51f6b69cc5c3c8_Color_3;
            SG_MixFog_e65d935e3c006a842b7a2fb6063b4b4d(_ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Color_1, _MixFog_89e264823ce74a9b8d51f6b69cc5c3c8, _MixFog_89e264823ce74a9b8d51f6b69cc5c3c8_Color_3);
            half4 _Property_a85bb0fd8bbe4267af1a4a8ec5c6957d_Out_0 = _OutlineColor;
            surface.BaseColor = _MixFog_89e264823ce74a9b8d51f6b69cc5c3c8_Color_3;
            surface.Alpha = _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Aloha_2;
            surface.AlphaClipThreshold = 0.5;
            surface.OutlineColor = (_Property_a85bb0fd8bbe4267af1a4a8ec5c6957d_Out_0.xyz);
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
            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(input.positionWS);
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
            #pragma shader_feature_local _ SHADEMODEL_RAMP



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
            float3 AbsoluteWorldSpacePosition;
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
        half4 _ShadeColor;
        float4 _ShadeMap_TexelSize;
        half _Smoothness;
        half _Metalic;
        float4 _MetalicMap_TexelSize;
        float4 _BumpMap_TexelSize;
        half Vector1_812be4631501458ea83339c066bed988;
        float4 _OcclusionMap_TexelSize;
        float4 _EmissionMap_TexelSize;
        half4 _EmissionColor;
        half _OutlineWidth;
        half4 _OutlineColor;
        half _ShadeToony;
        float4 _ShadeRamp_TexelSize;
        half4 _ShadeEnvironmentalColor;
        half _Curvature;
        half _ToonyLighting;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_ShadeMap);
        SAMPLER(sampler_ShadeMap);
        TEXTURE2D(_MetalicMap);
        SAMPLER(sampler_MetalicMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_ShadeRamp);
        SAMPLER(sampler_ShadeRamp);

            // Graph Functions
            
        void Unity_Multiply_half(half4 A, half4 B, out half4 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_half(half A, half B, out half Out)
        {
            Out = A * B;
        }

        // 76f53fe8936248969bc5201998a191c2
        #include "Assets/jp.lilium.toongraph/Contents/Shader/ToonLightingTextureRamp.hlsl"

        struct Bindings_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 ObjectSpacePosition;
            float3 AbsoluteWorldSpacePosition;
        };

        void SG_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5(float3 Vector3_65F6C04, float Vector1_4C8E34DF, float4 Color_1d3a761e471e4de7902496d49c375f8d, float4 Color_149A5746, float Vector1_328D12DB, float3 Vector3_A82C1F5A, float Vector1_CA473DD5, float3 Vector3_6818DD95, float Vector1_13346DDE, float Vector1_A8A74B72, UnityTexture2D Texture2D_ED058F03, float Vector1_a444e4171473481c8e0c83879e47165f, float Vector1_89971EC3, Bindings_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5 IN, out half3 Color_1, out half Aloha_2, out half3 ShadeColor_3)
        {
            float3 _Property_100e7faf3a4b402a9feb960d09e5ae4d_Out_0 = Vector3_65F6C04;
            float4 _Property_81825652062f4ba69f97553e28ca0e82_Out_0 = Color_1d3a761e471e4de7902496d49c375f8d;
            float3 _Property_b663d0ce9edf4b9aa573c97c4a9d8a3e_Out_0 = Vector3_A82C1F5A;
            float4 _Property_a6b1df0e799e4081847d4fb6db35a457_Out_0 = Color_149A5746;
            float _Property_1fa9bb2cd2b640f08167086e8f7446f4_Out_0 = Vector1_328D12DB;
            float _Property_6afdfaf017914a668ddae91b64c1235d_Out_0 = Vector1_CA473DD5;
            float3 _Property_6219660fe08e4e73aaaeb556524789b0_Out_0 = Vector3_6818DD95;
            float _Property_81f811dd2cf44ad38ec59bc1501fade3_Out_0 = Vector1_4C8E34DF;
            float _Property_97349003e4ae4e37a1b998f0ea011627_Out_0 = Vector1_13346DDE;
            float _Property_6fadb645726e432ab26a6a72a8acf4ee_Out_0 = Vector1_A8A74B72;
            UnityTexture2D _Property_5a4edac20031400494580c4e0f7da972_Out_0 = Texture2D_ED058F03;
            float _Property_b019a5b269ce4ce2baedaf3aff7c0289_Out_0 = Vector1_a444e4171473481c8e0c83879e47165f;
            float _Property_6c07cc6a832b4faab0ca314c175599f4_Out_0 = Vector1_89971EC3;
            half4 _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0;
            half3 _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_ShadeColor_20;
            ToonLight_half(IN.ObjectSpacePosition, IN.AbsoluteWorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceViewDirection, _Property_100e7faf3a4b402a9feb960d09e5ae4d_Out_0, _Property_81825652062f4ba69f97553e28ca0e82_Out_0, _Property_b663d0ce9edf4b9aa573c97c4a9d8a3e_Out_0, (_Property_a6b1df0e799e4081847d4fb6db35a457_Out_0.xyz), _Property_1fa9bb2cd2b640f08167086e8f7446f4_Out_0, _Property_6afdfaf017914a668ddae91b64c1235d_Out_0, _Property_6219660fe08e4e73aaaeb556524789b0_Out_0, _Property_81f811dd2cf44ad38ec59bc1501fade3_Out_0, _Property_97349003e4ae4e37a1b998f0ea011627_Out_0, _Property_6fadb645726e432ab26a6a72a8acf4ee_Out_0, _Property_5a4edac20031400494580c4e0f7da972_Out_0.tex, _Property_b019a5b269ce4ce2baedaf3aff7c0289_Out_0, _Property_6c07cc6a832b4faab0ca314c175599f4_Out_0, _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0, _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_ShadeColor_20);
            half _Split_308656dd68824b28897ed650e60e4017_R_1 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[0];
            half _Split_308656dd68824b28897ed650e60e4017_G_2 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[1];
            half _Split_308656dd68824b28897ed650e60e4017_B_3 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[2];
            half _Split_308656dd68824b28897ed650e60e4017_A_4 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[3];
            Color_1 = (_ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0.xyz);
            Aloha_2 = _Split_308656dd68824b28897ed650e60e4017_A_4;
            ShadeColor_3 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_ShadeColor_20;
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
            half4 _Property_dc0ba5482ecc4b09a32264f12a7f96bf_Out_0 = _BaseColor;
            UnityTexture2D _Property_6d01542dab39454f96244b27f2302104_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            half4 _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_6d01542dab39454f96244b27f2302104_Out_0.tex, _Property_6d01542dab39454f96244b27f2302104_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_R_4 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.r;
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_G_5 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.g;
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_B_6 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.b;
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_A_7 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.a;
            half4 _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2;
            Unity_Multiply_half(_Property_dc0ba5482ecc4b09a32264f12a7f96bf_Out_0, _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0, _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2);
            half _Split_8a190d5587d140a98b725b1618be5378_R_1 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[0];
            half _Split_8a190d5587d140a98b725b1618be5378_G_2 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[1];
            half _Split_8a190d5587d140a98b725b1618be5378_B_3 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[2];
            half _Split_8a190d5587d140a98b725b1618be5378_A_4 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[3];
            half4 _Property_e669a7f35e9046b78538aa00b5a760b5_Out_0 = _ShadeColor;
            UnityTexture2D _Property_e2a0e185d2994abba5cd08ed1aed0260_Out_0 = UnityBuildTexture2DStructNoScale(_ShadeMap);
            half4 _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e2a0e185d2994abba5cd08ed1aed0260_Out_0.tex, _Property_e2a0e185d2994abba5cd08ed1aed0260_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_R_4 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.r;
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_G_5 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.g;
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_B_6 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.b;
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_A_7 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.a;
            half4 _Multiply_041495d9da724630a886735576fb2bd4_Out_2;
            Unity_Multiply_half(_Property_e669a7f35e9046b78538aa00b5a760b5_Out_0, _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0, _Multiply_041495d9da724630a886735576fb2bd4_Out_2);
            half _Property_d229fb937937488fa027e9f96980225e_Out_0 = _Metalic;
            UnityTexture2D _Property_dd2afd9183d24597a6bfdc8475c1cee6_Out_0 = UnityBuildTexture2DStructNoScale(_MetalicMap);
            half4 _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0 = SAMPLE_TEXTURE2D(_Property_dd2afd9183d24597a6bfdc8475c1cee6_Out_0.tex, _Property_dd2afd9183d24597a6bfdc8475c1cee6_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_R_4 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.r;
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_G_5 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.g;
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_B_6 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.b;
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_A_7 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.a;
            half4 _Multiply_b549bc066fe64ffbb69174bcda8c8f7a_Out_2;
            Unity_Multiply_half((_Property_d229fb937937488fa027e9f96980225e_Out_0.xxxx), _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0, _Multiply_b549bc066fe64ffbb69174bcda8c8f7a_Out_2);
            half _Property_72cbd81e07b74b149bcacc8e4ec541ef_Out_0 = _Smoothness;
            UnityTexture2D _Property_da6be2aaf4da4e1a8e7dbdaacb83f1c4_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            half4 _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_da6be2aaf4da4e1a8e7dbdaacb83f1c4_Out_0.tex, _Property_da6be2aaf4da4e1a8e7dbdaacb83f1c4_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0);
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_R_4 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.r;
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_G_5 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.g;
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_B_6 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.b;
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_A_7 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.a;
            half4 _Property_bd135e9c7d464f2aac018c888c1c19e4_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            UnityTexture2D _Property_da66f2d54e5e4f1d9b4e6169fb9833bf_Out_0 = UnityBuildTexture2DStructNoScale(_EmissionMap);
            half4 _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0 = SAMPLE_TEXTURE2D(_Property_da66f2d54e5e4f1d9b4e6169fb9833bf_Out_0.tex, _Property_da66f2d54e5e4f1d9b4e6169fb9833bf_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_R_4 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.r;
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_G_5 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.g;
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_B_6 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.b;
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_A_7 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.a;
            half4 _Multiply_97980ed117bc43fe8c3652f77084429d_Out_2;
            Unity_Multiply_half(_Property_bd135e9c7d464f2aac018c888c1c19e4_Out_0, _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0, _Multiply_97980ed117bc43fe8c3652f77084429d_Out_2);
            half _Property_d326b8f6ddb54a138dffb63b47a2ce0a_Out_0 = Vector1_812be4631501458ea83339c066bed988;
            UnityTexture2D _Property_500c6a1cc2cb40e2bc0c4e72674299f7_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            half4 _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0 = SAMPLE_TEXTURE2D(_Property_500c6a1cc2cb40e2bc0c4e72674299f7_Out_0.tex, _Property_500c6a1cc2cb40e2bc0c4e72674299f7_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_R_4 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.r;
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_G_5 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.g;
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_B_6 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.b;
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_A_7 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.a;
            half _Multiply_180ff739424a4186accb3226ed998abe_Out_2;
            Unity_Multiply_half(_Property_d326b8f6ddb54a138dffb63b47a2ce0a_Out_0, _SampleTexture2D_3defb7d0d466445a95386d6845502441_R_4, _Multiply_180ff739424a4186accb3226ed998abe_Out_2);
            half _Property_13f4cc575f2542cea2938b11a825b7a6_Out_0 = _ShadeToony;
            UnityTexture2D _Property_c8f5752f4359405bbbdb833daa5ecb49_Out_0 = UnityBuildTexture2DStructNoScale(_ShadeRamp);
            half _Property_3df8d2a5beba45b9bd543d1bae33268b_Out_0 = _Curvature;
            half _Property_f21b961a69e3401bbd7673eed435785a_Out_0 = _ToonyLighting;
            Bindings_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5 _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceNormal = IN.WorldSpaceNormal;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceTangent = IN.WorldSpaceTangent;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.ObjectSpacePosition = IN.ObjectSpacePosition;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
            half3 _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Color_1;
            half _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Aloha_2;
            half3 _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_ShadeColor_3;
            SG_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5((_Multiply_ed762052df704f3b992bcd126a4ce227_Out_2.xyz), _Split_8a190d5587d140a98b725b1618be5378_A_4, _Multiply_041495d9da724630a886735576fb2bd4_Out_2, _Multiply_b549bc066fe64ffbb69174bcda8c8f7a_Out_2, _Property_72cbd81e07b74b149bcacc8e4ec541ef_Out_0, (_SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.xyz), 1, (_Multiply_97980ed117bc43fe8c3652f77084429d_Out_2.xyz), _Multiply_180ff739424a4186accb3226ed998abe_Out_2, _Property_13f4cc575f2542cea2938b11a825b7a6_Out_0, _Property_c8f5752f4359405bbbdb833daa5ecb49_Out_0, _Property_3df8d2a5beba45b9bd543d1bae33268b_Out_0, _Property_f21b961a69e3401bbd7673eed435785a_Out_0, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Color_1, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Aloha_2, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_ShadeColor_3);
            surface.Alpha = _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Aloha_2;
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
            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(input.positionWS);
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
            #pragma shader_feature_local _ SHADEMODEL_RAMP



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
            float3 AbsoluteWorldSpacePosition;
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
        half4 _ShadeColor;
        float4 _ShadeMap_TexelSize;
        half _Smoothness;
        half _Metalic;
        float4 _MetalicMap_TexelSize;
        float4 _BumpMap_TexelSize;
        half Vector1_812be4631501458ea83339c066bed988;
        float4 _OcclusionMap_TexelSize;
        float4 _EmissionMap_TexelSize;
        half4 _EmissionColor;
        half _OutlineWidth;
        half4 _OutlineColor;
        half _ShadeToony;
        float4 _ShadeRamp_TexelSize;
        half4 _ShadeEnvironmentalColor;
        half _Curvature;
        half _ToonyLighting;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_ShadeMap);
        SAMPLER(sampler_ShadeMap);
        TEXTURE2D(_MetalicMap);
        SAMPLER(sampler_MetalicMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_ShadeRamp);
        SAMPLER(sampler_ShadeRamp);

            // Graph Functions
            
        void Unity_Multiply_half(half4 A, half4 B, out half4 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_half(half A, half B, out half Out)
        {
            Out = A * B;
        }

        // 76f53fe8936248969bc5201998a191c2
        #include "Assets/jp.lilium.toongraph/Contents/Shader/ToonLightingTextureRamp.hlsl"

        struct Bindings_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 ObjectSpacePosition;
            float3 AbsoluteWorldSpacePosition;
        };

        void SG_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5(float3 Vector3_65F6C04, float Vector1_4C8E34DF, float4 Color_1d3a761e471e4de7902496d49c375f8d, float4 Color_149A5746, float Vector1_328D12DB, float3 Vector3_A82C1F5A, float Vector1_CA473DD5, float3 Vector3_6818DD95, float Vector1_13346DDE, float Vector1_A8A74B72, UnityTexture2D Texture2D_ED058F03, float Vector1_a444e4171473481c8e0c83879e47165f, float Vector1_89971EC3, Bindings_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5 IN, out half3 Color_1, out half Aloha_2, out half3 ShadeColor_3)
        {
            float3 _Property_100e7faf3a4b402a9feb960d09e5ae4d_Out_0 = Vector3_65F6C04;
            float4 _Property_81825652062f4ba69f97553e28ca0e82_Out_0 = Color_1d3a761e471e4de7902496d49c375f8d;
            float3 _Property_b663d0ce9edf4b9aa573c97c4a9d8a3e_Out_0 = Vector3_A82C1F5A;
            float4 _Property_a6b1df0e799e4081847d4fb6db35a457_Out_0 = Color_149A5746;
            float _Property_1fa9bb2cd2b640f08167086e8f7446f4_Out_0 = Vector1_328D12DB;
            float _Property_6afdfaf017914a668ddae91b64c1235d_Out_0 = Vector1_CA473DD5;
            float3 _Property_6219660fe08e4e73aaaeb556524789b0_Out_0 = Vector3_6818DD95;
            float _Property_81f811dd2cf44ad38ec59bc1501fade3_Out_0 = Vector1_4C8E34DF;
            float _Property_97349003e4ae4e37a1b998f0ea011627_Out_0 = Vector1_13346DDE;
            float _Property_6fadb645726e432ab26a6a72a8acf4ee_Out_0 = Vector1_A8A74B72;
            UnityTexture2D _Property_5a4edac20031400494580c4e0f7da972_Out_0 = Texture2D_ED058F03;
            float _Property_b019a5b269ce4ce2baedaf3aff7c0289_Out_0 = Vector1_a444e4171473481c8e0c83879e47165f;
            float _Property_6c07cc6a832b4faab0ca314c175599f4_Out_0 = Vector1_89971EC3;
            half4 _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0;
            half3 _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_ShadeColor_20;
            ToonLight_half(IN.ObjectSpacePosition, IN.AbsoluteWorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceViewDirection, _Property_100e7faf3a4b402a9feb960d09e5ae4d_Out_0, _Property_81825652062f4ba69f97553e28ca0e82_Out_0, _Property_b663d0ce9edf4b9aa573c97c4a9d8a3e_Out_0, (_Property_a6b1df0e799e4081847d4fb6db35a457_Out_0.xyz), _Property_1fa9bb2cd2b640f08167086e8f7446f4_Out_0, _Property_6afdfaf017914a668ddae91b64c1235d_Out_0, _Property_6219660fe08e4e73aaaeb556524789b0_Out_0, _Property_81f811dd2cf44ad38ec59bc1501fade3_Out_0, _Property_97349003e4ae4e37a1b998f0ea011627_Out_0, _Property_6fadb645726e432ab26a6a72a8acf4ee_Out_0, _Property_5a4edac20031400494580c4e0f7da972_Out_0.tex, _Property_b019a5b269ce4ce2baedaf3aff7c0289_Out_0, _Property_6c07cc6a832b4faab0ca314c175599f4_Out_0, _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0, _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_ShadeColor_20);
            half _Split_308656dd68824b28897ed650e60e4017_R_1 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[0];
            half _Split_308656dd68824b28897ed650e60e4017_G_2 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[1];
            half _Split_308656dd68824b28897ed650e60e4017_B_3 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[2];
            half _Split_308656dd68824b28897ed650e60e4017_A_4 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[3];
            Color_1 = (_ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0.xyz);
            Aloha_2 = _Split_308656dd68824b28897ed650e60e4017_A_4;
            ShadeColor_3 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_ShadeColor_20;
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
            half4 _Property_dc0ba5482ecc4b09a32264f12a7f96bf_Out_0 = _BaseColor;
            UnityTexture2D _Property_6d01542dab39454f96244b27f2302104_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            half4 _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_6d01542dab39454f96244b27f2302104_Out_0.tex, _Property_6d01542dab39454f96244b27f2302104_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_R_4 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.r;
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_G_5 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.g;
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_B_6 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.b;
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_A_7 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.a;
            half4 _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2;
            Unity_Multiply_half(_Property_dc0ba5482ecc4b09a32264f12a7f96bf_Out_0, _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0, _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2);
            half _Split_8a190d5587d140a98b725b1618be5378_R_1 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[0];
            half _Split_8a190d5587d140a98b725b1618be5378_G_2 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[1];
            half _Split_8a190d5587d140a98b725b1618be5378_B_3 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[2];
            half _Split_8a190d5587d140a98b725b1618be5378_A_4 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[3];
            half4 _Property_e669a7f35e9046b78538aa00b5a760b5_Out_0 = _ShadeColor;
            UnityTexture2D _Property_e2a0e185d2994abba5cd08ed1aed0260_Out_0 = UnityBuildTexture2DStructNoScale(_ShadeMap);
            half4 _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e2a0e185d2994abba5cd08ed1aed0260_Out_0.tex, _Property_e2a0e185d2994abba5cd08ed1aed0260_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_R_4 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.r;
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_G_5 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.g;
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_B_6 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.b;
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_A_7 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.a;
            half4 _Multiply_041495d9da724630a886735576fb2bd4_Out_2;
            Unity_Multiply_half(_Property_e669a7f35e9046b78538aa00b5a760b5_Out_0, _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0, _Multiply_041495d9da724630a886735576fb2bd4_Out_2);
            half _Property_d229fb937937488fa027e9f96980225e_Out_0 = _Metalic;
            UnityTexture2D _Property_dd2afd9183d24597a6bfdc8475c1cee6_Out_0 = UnityBuildTexture2DStructNoScale(_MetalicMap);
            half4 _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0 = SAMPLE_TEXTURE2D(_Property_dd2afd9183d24597a6bfdc8475c1cee6_Out_0.tex, _Property_dd2afd9183d24597a6bfdc8475c1cee6_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_R_4 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.r;
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_G_5 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.g;
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_B_6 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.b;
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_A_7 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.a;
            half4 _Multiply_b549bc066fe64ffbb69174bcda8c8f7a_Out_2;
            Unity_Multiply_half((_Property_d229fb937937488fa027e9f96980225e_Out_0.xxxx), _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0, _Multiply_b549bc066fe64ffbb69174bcda8c8f7a_Out_2);
            half _Property_72cbd81e07b74b149bcacc8e4ec541ef_Out_0 = _Smoothness;
            UnityTexture2D _Property_da6be2aaf4da4e1a8e7dbdaacb83f1c4_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            half4 _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_da6be2aaf4da4e1a8e7dbdaacb83f1c4_Out_0.tex, _Property_da6be2aaf4da4e1a8e7dbdaacb83f1c4_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0);
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_R_4 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.r;
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_G_5 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.g;
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_B_6 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.b;
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_A_7 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.a;
            half4 _Property_bd135e9c7d464f2aac018c888c1c19e4_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            UnityTexture2D _Property_da66f2d54e5e4f1d9b4e6169fb9833bf_Out_0 = UnityBuildTexture2DStructNoScale(_EmissionMap);
            half4 _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0 = SAMPLE_TEXTURE2D(_Property_da66f2d54e5e4f1d9b4e6169fb9833bf_Out_0.tex, _Property_da66f2d54e5e4f1d9b4e6169fb9833bf_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_R_4 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.r;
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_G_5 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.g;
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_B_6 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.b;
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_A_7 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.a;
            half4 _Multiply_97980ed117bc43fe8c3652f77084429d_Out_2;
            Unity_Multiply_half(_Property_bd135e9c7d464f2aac018c888c1c19e4_Out_0, _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0, _Multiply_97980ed117bc43fe8c3652f77084429d_Out_2);
            half _Property_d326b8f6ddb54a138dffb63b47a2ce0a_Out_0 = Vector1_812be4631501458ea83339c066bed988;
            UnityTexture2D _Property_500c6a1cc2cb40e2bc0c4e72674299f7_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            half4 _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0 = SAMPLE_TEXTURE2D(_Property_500c6a1cc2cb40e2bc0c4e72674299f7_Out_0.tex, _Property_500c6a1cc2cb40e2bc0c4e72674299f7_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_R_4 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.r;
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_G_5 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.g;
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_B_6 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.b;
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_A_7 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.a;
            half _Multiply_180ff739424a4186accb3226ed998abe_Out_2;
            Unity_Multiply_half(_Property_d326b8f6ddb54a138dffb63b47a2ce0a_Out_0, _SampleTexture2D_3defb7d0d466445a95386d6845502441_R_4, _Multiply_180ff739424a4186accb3226ed998abe_Out_2);
            half _Property_13f4cc575f2542cea2938b11a825b7a6_Out_0 = _ShadeToony;
            UnityTexture2D _Property_c8f5752f4359405bbbdb833daa5ecb49_Out_0 = UnityBuildTexture2DStructNoScale(_ShadeRamp);
            half _Property_3df8d2a5beba45b9bd543d1bae33268b_Out_0 = _Curvature;
            half _Property_f21b961a69e3401bbd7673eed435785a_Out_0 = _ToonyLighting;
            Bindings_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5 _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceNormal = IN.WorldSpaceNormal;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceTangent = IN.WorldSpaceTangent;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.ObjectSpacePosition = IN.ObjectSpacePosition;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
            half3 _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Color_1;
            half _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Aloha_2;
            half3 _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_ShadeColor_3;
            SG_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5((_Multiply_ed762052df704f3b992bcd126a4ce227_Out_2.xyz), _Split_8a190d5587d140a98b725b1618be5378_A_4, _Multiply_041495d9da724630a886735576fb2bd4_Out_2, _Multiply_b549bc066fe64ffbb69174bcda8c8f7a_Out_2, _Property_72cbd81e07b74b149bcacc8e4ec541ef_Out_0, (_SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.xyz), 1, (_Multiply_97980ed117bc43fe8c3652f77084429d_Out_2.xyz), _Multiply_180ff739424a4186accb3226ed998abe_Out_2, _Property_13f4cc575f2542cea2938b11a825b7a6_Out_0, _Property_c8f5752f4359405bbbdb833daa5ecb49_Out_0, _Property_3df8d2a5beba45b9bd543d1bae33268b_Out_0, _Property_f21b961a69e3401bbd7673eed435785a_Out_0, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Color_1, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Aloha_2, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_ShadeColor_3);
            surface.Alpha = _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Aloha_2;
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
            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(input.positionWS);
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
            #pragma shader_feature_local _ SHADEMODEL_RAMP



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
            float3 AbsoluteWorldSpacePosition;
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
        half4 _ShadeColor;
        float4 _ShadeMap_TexelSize;
        half _Smoothness;
        half _Metalic;
        float4 _MetalicMap_TexelSize;
        float4 _BumpMap_TexelSize;
        half Vector1_812be4631501458ea83339c066bed988;
        float4 _OcclusionMap_TexelSize;
        float4 _EmissionMap_TexelSize;
        half4 _EmissionColor;
        half _OutlineWidth;
        half4 _OutlineColor;
        half _ShadeToony;
        float4 _ShadeRamp_TexelSize;
        half4 _ShadeEnvironmentalColor;
        half _Curvature;
        half _ToonyLighting;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_ShadeMap);
        SAMPLER(sampler_ShadeMap);
        TEXTURE2D(_MetalicMap);
        SAMPLER(sampler_MetalicMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_ShadeRamp);
        SAMPLER(sampler_ShadeRamp);

            // Graph Functions
            
        void Unity_Multiply_half(half4 A, half4 B, out half4 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_half(half A, half B, out half Out)
        {
            Out = A * B;
        }

        // 76f53fe8936248969bc5201998a191c2
        #include "Assets/jp.lilium.toongraph/Contents/Shader/ToonLightingTextureRamp.hlsl"

        struct Bindings_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 ObjectSpacePosition;
            float3 AbsoluteWorldSpacePosition;
        };

        void SG_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5(float3 Vector3_65F6C04, float Vector1_4C8E34DF, float4 Color_1d3a761e471e4de7902496d49c375f8d, float4 Color_149A5746, float Vector1_328D12DB, float3 Vector3_A82C1F5A, float Vector1_CA473DD5, float3 Vector3_6818DD95, float Vector1_13346DDE, float Vector1_A8A74B72, UnityTexture2D Texture2D_ED058F03, float Vector1_a444e4171473481c8e0c83879e47165f, float Vector1_89971EC3, Bindings_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5 IN, out half3 Color_1, out half Aloha_2, out half3 ShadeColor_3)
        {
            float3 _Property_100e7faf3a4b402a9feb960d09e5ae4d_Out_0 = Vector3_65F6C04;
            float4 _Property_81825652062f4ba69f97553e28ca0e82_Out_0 = Color_1d3a761e471e4de7902496d49c375f8d;
            float3 _Property_b663d0ce9edf4b9aa573c97c4a9d8a3e_Out_0 = Vector3_A82C1F5A;
            float4 _Property_a6b1df0e799e4081847d4fb6db35a457_Out_0 = Color_149A5746;
            float _Property_1fa9bb2cd2b640f08167086e8f7446f4_Out_0 = Vector1_328D12DB;
            float _Property_6afdfaf017914a668ddae91b64c1235d_Out_0 = Vector1_CA473DD5;
            float3 _Property_6219660fe08e4e73aaaeb556524789b0_Out_0 = Vector3_6818DD95;
            float _Property_81f811dd2cf44ad38ec59bc1501fade3_Out_0 = Vector1_4C8E34DF;
            float _Property_97349003e4ae4e37a1b998f0ea011627_Out_0 = Vector1_13346DDE;
            float _Property_6fadb645726e432ab26a6a72a8acf4ee_Out_0 = Vector1_A8A74B72;
            UnityTexture2D _Property_5a4edac20031400494580c4e0f7da972_Out_0 = Texture2D_ED058F03;
            float _Property_b019a5b269ce4ce2baedaf3aff7c0289_Out_0 = Vector1_a444e4171473481c8e0c83879e47165f;
            float _Property_6c07cc6a832b4faab0ca314c175599f4_Out_0 = Vector1_89971EC3;
            half4 _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0;
            half3 _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_ShadeColor_20;
            ToonLight_half(IN.ObjectSpacePosition, IN.AbsoluteWorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceViewDirection, _Property_100e7faf3a4b402a9feb960d09e5ae4d_Out_0, _Property_81825652062f4ba69f97553e28ca0e82_Out_0, _Property_b663d0ce9edf4b9aa573c97c4a9d8a3e_Out_0, (_Property_a6b1df0e799e4081847d4fb6db35a457_Out_0.xyz), _Property_1fa9bb2cd2b640f08167086e8f7446f4_Out_0, _Property_6afdfaf017914a668ddae91b64c1235d_Out_0, _Property_6219660fe08e4e73aaaeb556524789b0_Out_0, _Property_81f811dd2cf44ad38ec59bc1501fade3_Out_0, _Property_97349003e4ae4e37a1b998f0ea011627_Out_0, _Property_6fadb645726e432ab26a6a72a8acf4ee_Out_0, _Property_5a4edac20031400494580c4e0f7da972_Out_0.tex, _Property_b019a5b269ce4ce2baedaf3aff7c0289_Out_0, _Property_6c07cc6a832b4faab0ca314c175599f4_Out_0, _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0, _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_ShadeColor_20);
            half _Split_308656dd68824b28897ed650e60e4017_R_1 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[0];
            half _Split_308656dd68824b28897ed650e60e4017_G_2 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[1];
            half _Split_308656dd68824b28897ed650e60e4017_B_3 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[2];
            half _Split_308656dd68824b28897ed650e60e4017_A_4 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[3];
            Color_1 = (_ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0.xyz);
            Aloha_2 = _Split_308656dd68824b28897ed650e60e4017_A_4;
            ShadeColor_3 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_ShadeColor_20;
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
            half4 _Property_dc0ba5482ecc4b09a32264f12a7f96bf_Out_0 = _BaseColor;
            UnityTexture2D _Property_6d01542dab39454f96244b27f2302104_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            half4 _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_6d01542dab39454f96244b27f2302104_Out_0.tex, _Property_6d01542dab39454f96244b27f2302104_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_R_4 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.r;
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_G_5 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.g;
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_B_6 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.b;
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_A_7 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.a;
            half4 _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2;
            Unity_Multiply_half(_Property_dc0ba5482ecc4b09a32264f12a7f96bf_Out_0, _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0, _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2);
            half _Split_8a190d5587d140a98b725b1618be5378_R_1 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[0];
            half _Split_8a190d5587d140a98b725b1618be5378_G_2 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[1];
            half _Split_8a190d5587d140a98b725b1618be5378_B_3 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[2];
            half _Split_8a190d5587d140a98b725b1618be5378_A_4 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[3];
            half4 _Property_e669a7f35e9046b78538aa00b5a760b5_Out_0 = _ShadeColor;
            UnityTexture2D _Property_e2a0e185d2994abba5cd08ed1aed0260_Out_0 = UnityBuildTexture2DStructNoScale(_ShadeMap);
            half4 _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e2a0e185d2994abba5cd08ed1aed0260_Out_0.tex, _Property_e2a0e185d2994abba5cd08ed1aed0260_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_R_4 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.r;
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_G_5 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.g;
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_B_6 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.b;
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_A_7 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.a;
            half4 _Multiply_041495d9da724630a886735576fb2bd4_Out_2;
            Unity_Multiply_half(_Property_e669a7f35e9046b78538aa00b5a760b5_Out_0, _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0, _Multiply_041495d9da724630a886735576fb2bd4_Out_2);
            half _Property_d229fb937937488fa027e9f96980225e_Out_0 = _Metalic;
            UnityTexture2D _Property_dd2afd9183d24597a6bfdc8475c1cee6_Out_0 = UnityBuildTexture2DStructNoScale(_MetalicMap);
            half4 _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0 = SAMPLE_TEXTURE2D(_Property_dd2afd9183d24597a6bfdc8475c1cee6_Out_0.tex, _Property_dd2afd9183d24597a6bfdc8475c1cee6_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_R_4 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.r;
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_G_5 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.g;
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_B_6 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.b;
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_A_7 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.a;
            half4 _Multiply_b549bc066fe64ffbb69174bcda8c8f7a_Out_2;
            Unity_Multiply_half((_Property_d229fb937937488fa027e9f96980225e_Out_0.xxxx), _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0, _Multiply_b549bc066fe64ffbb69174bcda8c8f7a_Out_2);
            half _Property_72cbd81e07b74b149bcacc8e4ec541ef_Out_0 = _Smoothness;
            UnityTexture2D _Property_da6be2aaf4da4e1a8e7dbdaacb83f1c4_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            half4 _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_da6be2aaf4da4e1a8e7dbdaacb83f1c4_Out_0.tex, _Property_da6be2aaf4da4e1a8e7dbdaacb83f1c4_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0);
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_R_4 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.r;
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_G_5 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.g;
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_B_6 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.b;
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_A_7 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.a;
            half4 _Property_bd135e9c7d464f2aac018c888c1c19e4_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            UnityTexture2D _Property_da66f2d54e5e4f1d9b4e6169fb9833bf_Out_0 = UnityBuildTexture2DStructNoScale(_EmissionMap);
            half4 _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0 = SAMPLE_TEXTURE2D(_Property_da66f2d54e5e4f1d9b4e6169fb9833bf_Out_0.tex, _Property_da66f2d54e5e4f1d9b4e6169fb9833bf_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_R_4 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.r;
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_G_5 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.g;
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_B_6 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.b;
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_A_7 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.a;
            half4 _Multiply_97980ed117bc43fe8c3652f77084429d_Out_2;
            Unity_Multiply_half(_Property_bd135e9c7d464f2aac018c888c1c19e4_Out_0, _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0, _Multiply_97980ed117bc43fe8c3652f77084429d_Out_2);
            half _Property_d326b8f6ddb54a138dffb63b47a2ce0a_Out_0 = Vector1_812be4631501458ea83339c066bed988;
            UnityTexture2D _Property_500c6a1cc2cb40e2bc0c4e72674299f7_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            half4 _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0 = SAMPLE_TEXTURE2D(_Property_500c6a1cc2cb40e2bc0c4e72674299f7_Out_0.tex, _Property_500c6a1cc2cb40e2bc0c4e72674299f7_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_R_4 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.r;
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_G_5 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.g;
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_B_6 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.b;
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_A_7 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.a;
            half _Multiply_180ff739424a4186accb3226ed998abe_Out_2;
            Unity_Multiply_half(_Property_d326b8f6ddb54a138dffb63b47a2ce0a_Out_0, _SampleTexture2D_3defb7d0d466445a95386d6845502441_R_4, _Multiply_180ff739424a4186accb3226ed998abe_Out_2);
            half _Property_13f4cc575f2542cea2938b11a825b7a6_Out_0 = _ShadeToony;
            UnityTexture2D _Property_c8f5752f4359405bbbdb833daa5ecb49_Out_0 = UnityBuildTexture2DStructNoScale(_ShadeRamp);
            half _Property_3df8d2a5beba45b9bd543d1bae33268b_Out_0 = _Curvature;
            half _Property_f21b961a69e3401bbd7673eed435785a_Out_0 = _ToonyLighting;
            Bindings_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5 _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceNormal = IN.WorldSpaceNormal;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceTangent = IN.WorldSpaceTangent;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.ObjectSpacePosition = IN.ObjectSpacePosition;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
            half3 _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Color_1;
            half _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Aloha_2;
            half3 _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_ShadeColor_3;
            SG_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5((_Multiply_ed762052df704f3b992bcd126a4ce227_Out_2.xyz), _Split_8a190d5587d140a98b725b1618be5378_A_4, _Multiply_041495d9da724630a886735576fb2bd4_Out_2, _Multiply_b549bc066fe64ffbb69174bcda8c8f7a_Out_2, _Property_72cbd81e07b74b149bcacc8e4ec541ef_Out_0, (_SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.xyz), 1, (_Multiply_97980ed117bc43fe8c3652f77084429d_Out_2.xyz), _Multiply_180ff739424a4186accb3226ed998abe_Out_2, _Property_13f4cc575f2542cea2938b11a825b7a6_Out_0, _Property_c8f5752f4359405bbbdb833daa5ecb49_Out_0, _Property_3df8d2a5beba45b9bd543d1bae33268b_Out_0, _Property_f21b961a69e3401bbd7673eed435785a_Out_0, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Color_1, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Aloha_2, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_ShadeColor_3);
            Bindings_MixFog_e65d935e3c006a842b7a2fb6063b4b4d _MixFog_89e264823ce74a9b8d51f6b69cc5c3c8;
            _MixFog_89e264823ce74a9b8d51f6b69cc5c3c8.ObjectSpacePosition = IN.ObjectSpacePosition;
            float3 _MixFog_89e264823ce74a9b8d51f6b69cc5c3c8_Color_3;
            SG_MixFog_e65d935e3c006a842b7a2fb6063b4b4d(_ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Color_1, _MixFog_89e264823ce74a9b8d51f6b69cc5c3c8, _MixFog_89e264823ce74a9b8d51f6b69cc5c3c8_Color_3);
            surface.BaseColor = _MixFog_89e264823ce74a9b8d51f6b69cc5c3c8_Color_3;
            surface.Alpha = _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Aloha_2;
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
            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(input.positionWS);
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
            #pragma shader_feature_local _ SHADEMODEL_RAMP



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
            float3 AbsoluteWorldSpacePosition;
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
        half4 _ShadeColor;
        float4 _ShadeMap_TexelSize;
        half _Smoothness;
        half _Metalic;
        float4 _MetalicMap_TexelSize;
        float4 _BumpMap_TexelSize;
        half Vector1_812be4631501458ea83339c066bed988;
        float4 _OcclusionMap_TexelSize;
        float4 _EmissionMap_TexelSize;
        half4 _EmissionColor;
        half _OutlineWidth;
        half4 _OutlineColor;
        half _ShadeToony;
        float4 _ShadeRamp_TexelSize;
        half4 _ShadeEnvironmentalColor;
        half _Curvature;
        half _ToonyLighting;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_ShadeMap);
        SAMPLER(sampler_ShadeMap);
        TEXTURE2D(_MetalicMap);
        SAMPLER(sampler_MetalicMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_ShadeRamp);
        SAMPLER(sampler_ShadeRamp);

            // Graph Functions
            
        // 49735d9b5dbe4bddc0f32ad2f736db4c
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

        // 76f53fe8936248969bc5201998a191c2
        #include "Assets/jp.lilium.toongraph/Contents/Shader/ToonLightingTextureRamp.hlsl"

        struct Bindings_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 ObjectSpacePosition;
            float3 AbsoluteWorldSpacePosition;
        };

        void SG_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5(float3 Vector3_65F6C04, float Vector1_4C8E34DF, float4 Color_1d3a761e471e4de7902496d49c375f8d, float4 Color_149A5746, float Vector1_328D12DB, float3 Vector3_A82C1F5A, float Vector1_CA473DD5, float3 Vector3_6818DD95, float Vector1_13346DDE, float Vector1_A8A74B72, UnityTexture2D Texture2D_ED058F03, float Vector1_a444e4171473481c8e0c83879e47165f, float Vector1_89971EC3, Bindings_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5 IN, out half3 Color_1, out half Aloha_2, out half3 ShadeColor_3)
        {
            float3 _Property_100e7faf3a4b402a9feb960d09e5ae4d_Out_0 = Vector3_65F6C04;
            float4 _Property_81825652062f4ba69f97553e28ca0e82_Out_0 = Color_1d3a761e471e4de7902496d49c375f8d;
            float3 _Property_b663d0ce9edf4b9aa573c97c4a9d8a3e_Out_0 = Vector3_A82C1F5A;
            float4 _Property_a6b1df0e799e4081847d4fb6db35a457_Out_0 = Color_149A5746;
            float _Property_1fa9bb2cd2b640f08167086e8f7446f4_Out_0 = Vector1_328D12DB;
            float _Property_6afdfaf017914a668ddae91b64c1235d_Out_0 = Vector1_CA473DD5;
            float3 _Property_6219660fe08e4e73aaaeb556524789b0_Out_0 = Vector3_6818DD95;
            float _Property_81f811dd2cf44ad38ec59bc1501fade3_Out_0 = Vector1_4C8E34DF;
            float _Property_97349003e4ae4e37a1b998f0ea011627_Out_0 = Vector1_13346DDE;
            float _Property_6fadb645726e432ab26a6a72a8acf4ee_Out_0 = Vector1_A8A74B72;
            UnityTexture2D _Property_5a4edac20031400494580c4e0f7da972_Out_0 = Texture2D_ED058F03;
            float _Property_b019a5b269ce4ce2baedaf3aff7c0289_Out_0 = Vector1_a444e4171473481c8e0c83879e47165f;
            float _Property_6c07cc6a832b4faab0ca314c175599f4_Out_0 = Vector1_89971EC3;
            half4 _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0;
            half3 _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_ShadeColor_20;
            ToonLight_half(IN.ObjectSpacePosition, IN.AbsoluteWorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceViewDirection, _Property_100e7faf3a4b402a9feb960d09e5ae4d_Out_0, _Property_81825652062f4ba69f97553e28ca0e82_Out_0, _Property_b663d0ce9edf4b9aa573c97c4a9d8a3e_Out_0, (_Property_a6b1df0e799e4081847d4fb6db35a457_Out_0.xyz), _Property_1fa9bb2cd2b640f08167086e8f7446f4_Out_0, _Property_6afdfaf017914a668ddae91b64c1235d_Out_0, _Property_6219660fe08e4e73aaaeb556524789b0_Out_0, _Property_81f811dd2cf44ad38ec59bc1501fade3_Out_0, _Property_97349003e4ae4e37a1b998f0ea011627_Out_0, _Property_6fadb645726e432ab26a6a72a8acf4ee_Out_0, _Property_5a4edac20031400494580c4e0f7da972_Out_0.tex, _Property_b019a5b269ce4ce2baedaf3aff7c0289_Out_0, _Property_6c07cc6a832b4faab0ca314c175599f4_Out_0, _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0, _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_ShadeColor_20);
            half _Split_308656dd68824b28897ed650e60e4017_R_1 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[0];
            half _Split_308656dd68824b28897ed650e60e4017_G_2 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[1];
            half _Split_308656dd68824b28897ed650e60e4017_B_3 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[2];
            half _Split_308656dd68824b28897ed650e60e4017_A_4 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[3];
            Color_1 = (_ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0.xyz);
            Aloha_2 = _Split_308656dd68824b28897ed650e60e4017_A_4;
            ShadeColor_3 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_ShadeColor_20;
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
            half3 OutlinePosition;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            half _Property_23a4f2ebe14845a095c2c5f4c5c4b4f4_Out_0 = _OutlineWidth;
            Bindings_ToonOutlineTransform_aadd6ff8a7ff83a4fb272240ac26c2b5 _ToonOutlineTransform_652306bda77e43328a84fa5b38e21cab;
            _ToonOutlineTransform_652306bda77e43328a84fa5b38e21cab.ObjectSpaceNormal = IN.ObjectSpaceNormal;
            _ToonOutlineTransform_652306bda77e43328a84fa5b38e21cab.ObjectSpacePosition = IN.ObjectSpacePosition;
            float3 _ToonOutlineTransform_652306bda77e43328a84fa5b38e21cab_OutlinePosition_1;
            SG_ToonOutlineTransform_aadd6ff8a7ff83a4fb272240ac26c2b5(_Property_23a4f2ebe14845a095c2c5f4c5c4b4f4_Out_0, _ToonOutlineTransform_652306bda77e43328a84fa5b38e21cab, _ToonOutlineTransform_652306bda77e43328a84fa5b38e21cab_OutlinePosition_1);
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            description.OutlinePosition = _ToonOutlineTransform_652306bda77e43328a84fa5b38e21cab_OutlinePosition_1;
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
            half4 _Property_dc0ba5482ecc4b09a32264f12a7f96bf_Out_0 = _BaseColor;
            UnityTexture2D _Property_6d01542dab39454f96244b27f2302104_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            half4 _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_6d01542dab39454f96244b27f2302104_Out_0.tex, _Property_6d01542dab39454f96244b27f2302104_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_R_4 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.r;
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_G_5 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.g;
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_B_6 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.b;
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_A_7 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.a;
            half4 _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2;
            Unity_Multiply_half(_Property_dc0ba5482ecc4b09a32264f12a7f96bf_Out_0, _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0, _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2);
            half _Split_8a190d5587d140a98b725b1618be5378_R_1 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[0];
            half _Split_8a190d5587d140a98b725b1618be5378_G_2 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[1];
            half _Split_8a190d5587d140a98b725b1618be5378_B_3 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[2];
            half _Split_8a190d5587d140a98b725b1618be5378_A_4 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[3];
            half4 _Property_e669a7f35e9046b78538aa00b5a760b5_Out_0 = _ShadeColor;
            UnityTexture2D _Property_e2a0e185d2994abba5cd08ed1aed0260_Out_0 = UnityBuildTexture2DStructNoScale(_ShadeMap);
            half4 _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e2a0e185d2994abba5cd08ed1aed0260_Out_0.tex, _Property_e2a0e185d2994abba5cd08ed1aed0260_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_R_4 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.r;
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_G_5 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.g;
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_B_6 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.b;
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_A_7 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.a;
            half4 _Multiply_041495d9da724630a886735576fb2bd4_Out_2;
            Unity_Multiply_half(_Property_e669a7f35e9046b78538aa00b5a760b5_Out_0, _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0, _Multiply_041495d9da724630a886735576fb2bd4_Out_2);
            half _Property_d229fb937937488fa027e9f96980225e_Out_0 = _Metalic;
            UnityTexture2D _Property_dd2afd9183d24597a6bfdc8475c1cee6_Out_0 = UnityBuildTexture2DStructNoScale(_MetalicMap);
            half4 _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0 = SAMPLE_TEXTURE2D(_Property_dd2afd9183d24597a6bfdc8475c1cee6_Out_0.tex, _Property_dd2afd9183d24597a6bfdc8475c1cee6_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_R_4 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.r;
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_G_5 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.g;
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_B_6 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.b;
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_A_7 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.a;
            half4 _Multiply_b549bc066fe64ffbb69174bcda8c8f7a_Out_2;
            Unity_Multiply_half((_Property_d229fb937937488fa027e9f96980225e_Out_0.xxxx), _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0, _Multiply_b549bc066fe64ffbb69174bcda8c8f7a_Out_2);
            half _Property_72cbd81e07b74b149bcacc8e4ec541ef_Out_0 = _Smoothness;
            UnityTexture2D _Property_da6be2aaf4da4e1a8e7dbdaacb83f1c4_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            half4 _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_da6be2aaf4da4e1a8e7dbdaacb83f1c4_Out_0.tex, _Property_da6be2aaf4da4e1a8e7dbdaacb83f1c4_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0);
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_R_4 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.r;
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_G_5 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.g;
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_B_6 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.b;
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_A_7 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.a;
            half4 _Property_bd135e9c7d464f2aac018c888c1c19e4_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            UnityTexture2D _Property_da66f2d54e5e4f1d9b4e6169fb9833bf_Out_0 = UnityBuildTexture2DStructNoScale(_EmissionMap);
            half4 _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0 = SAMPLE_TEXTURE2D(_Property_da66f2d54e5e4f1d9b4e6169fb9833bf_Out_0.tex, _Property_da66f2d54e5e4f1d9b4e6169fb9833bf_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_R_4 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.r;
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_G_5 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.g;
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_B_6 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.b;
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_A_7 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.a;
            half4 _Multiply_97980ed117bc43fe8c3652f77084429d_Out_2;
            Unity_Multiply_half(_Property_bd135e9c7d464f2aac018c888c1c19e4_Out_0, _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0, _Multiply_97980ed117bc43fe8c3652f77084429d_Out_2);
            half _Property_d326b8f6ddb54a138dffb63b47a2ce0a_Out_0 = Vector1_812be4631501458ea83339c066bed988;
            UnityTexture2D _Property_500c6a1cc2cb40e2bc0c4e72674299f7_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            half4 _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0 = SAMPLE_TEXTURE2D(_Property_500c6a1cc2cb40e2bc0c4e72674299f7_Out_0.tex, _Property_500c6a1cc2cb40e2bc0c4e72674299f7_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_R_4 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.r;
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_G_5 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.g;
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_B_6 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.b;
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_A_7 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.a;
            half _Multiply_180ff739424a4186accb3226ed998abe_Out_2;
            Unity_Multiply_half(_Property_d326b8f6ddb54a138dffb63b47a2ce0a_Out_0, _SampleTexture2D_3defb7d0d466445a95386d6845502441_R_4, _Multiply_180ff739424a4186accb3226ed998abe_Out_2);
            half _Property_13f4cc575f2542cea2938b11a825b7a6_Out_0 = _ShadeToony;
            UnityTexture2D _Property_c8f5752f4359405bbbdb833daa5ecb49_Out_0 = UnityBuildTexture2DStructNoScale(_ShadeRamp);
            half _Property_3df8d2a5beba45b9bd543d1bae33268b_Out_0 = _Curvature;
            half _Property_f21b961a69e3401bbd7673eed435785a_Out_0 = _ToonyLighting;
            Bindings_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5 _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceNormal = IN.WorldSpaceNormal;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceTangent = IN.WorldSpaceTangent;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.ObjectSpacePosition = IN.ObjectSpacePosition;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
            half3 _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Color_1;
            half _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Aloha_2;
            half3 _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_ShadeColor_3;
            SG_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5((_Multiply_ed762052df704f3b992bcd126a4ce227_Out_2.xyz), _Split_8a190d5587d140a98b725b1618be5378_A_4, _Multiply_041495d9da724630a886735576fb2bd4_Out_2, _Multiply_b549bc066fe64ffbb69174bcda8c8f7a_Out_2, _Property_72cbd81e07b74b149bcacc8e4ec541ef_Out_0, (_SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.xyz), 1, (_Multiply_97980ed117bc43fe8c3652f77084429d_Out_2.xyz), _Multiply_180ff739424a4186accb3226ed998abe_Out_2, _Property_13f4cc575f2542cea2938b11a825b7a6_Out_0, _Property_c8f5752f4359405bbbdb833daa5ecb49_Out_0, _Property_3df8d2a5beba45b9bd543d1bae33268b_Out_0, _Property_f21b961a69e3401bbd7673eed435785a_Out_0, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Color_1, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Aloha_2, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_ShadeColor_3);
            Bindings_MixFog_e65d935e3c006a842b7a2fb6063b4b4d _MixFog_89e264823ce74a9b8d51f6b69cc5c3c8;
            _MixFog_89e264823ce74a9b8d51f6b69cc5c3c8.ObjectSpacePosition = IN.ObjectSpacePosition;
            float3 _MixFog_89e264823ce74a9b8d51f6b69cc5c3c8_Color_3;
            SG_MixFog_e65d935e3c006a842b7a2fb6063b4b4d(_ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Color_1, _MixFog_89e264823ce74a9b8d51f6b69cc5c3c8, _MixFog_89e264823ce74a9b8d51f6b69cc5c3c8_Color_3);
            half4 _Property_a85bb0fd8bbe4267af1a4a8ec5c6957d_Out_0 = _OutlineColor;
            surface.BaseColor = _MixFog_89e264823ce74a9b8d51f6b69cc5c3c8_Color_3;
            surface.Alpha = _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Aloha_2;
            surface.AlphaClipThreshold = 0.5;
            surface.OutlineColor = (_Property_a85bb0fd8bbe4267af1a4a8ec5c6957d_Out_0.xyz);
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
            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(input.positionWS);
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
            #pragma shader_feature_local _ SHADEMODEL_RAMP



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
            float3 AbsoluteWorldSpacePosition;
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
        half4 _ShadeColor;
        float4 _ShadeMap_TexelSize;
        half _Smoothness;
        half _Metalic;
        float4 _MetalicMap_TexelSize;
        float4 _BumpMap_TexelSize;
        half Vector1_812be4631501458ea83339c066bed988;
        float4 _OcclusionMap_TexelSize;
        float4 _EmissionMap_TexelSize;
        half4 _EmissionColor;
        half _OutlineWidth;
        half4 _OutlineColor;
        half _ShadeToony;
        float4 _ShadeRamp_TexelSize;
        half4 _ShadeEnvironmentalColor;
        half _Curvature;
        half _ToonyLighting;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_ShadeMap);
        SAMPLER(sampler_ShadeMap);
        TEXTURE2D(_MetalicMap);
        SAMPLER(sampler_MetalicMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_ShadeRamp);
        SAMPLER(sampler_ShadeRamp);

            // Graph Functions
            
        void Unity_Multiply_half(half4 A, half4 B, out half4 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_half(half A, half B, out half Out)
        {
            Out = A * B;
        }

        // 76f53fe8936248969bc5201998a191c2
        #include "Assets/jp.lilium.toongraph/Contents/Shader/ToonLightingTextureRamp.hlsl"

        struct Bindings_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 ObjectSpacePosition;
            float3 AbsoluteWorldSpacePosition;
        };

        void SG_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5(float3 Vector3_65F6C04, float Vector1_4C8E34DF, float4 Color_1d3a761e471e4de7902496d49c375f8d, float4 Color_149A5746, float Vector1_328D12DB, float3 Vector3_A82C1F5A, float Vector1_CA473DD5, float3 Vector3_6818DD95, float Vector1_13346DDE, float Vector1_A8A74B72, UnityTexture2D Texture2D_ED058F03, float Vector1_a444e4171473481c8e0c83879e47165f, float Vector1_89971EC3, Bindings_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5 IN, out half3 Color_1, out half Aloha_2, out half3 ShadeColor_3)
        {
            float3 _Property_100e7faf3a4b402a9feb960d09e5ae4d_Out_0 = Vector3_65F6C04;
            float4 _Property_81825652062f4ba69f97553e28ca0e82_Out_0 = Color_1d3a761e471e4de7902496d49c375f8d;
            float3 _Property_b663d0ce9edf4b9aa573c97c4a9d8a3e_Out_0 = Vector3_A82C1F5A;
            float4 _Property_a6b1df0e799e4081847d4fb6db35a457_Out_0 = Color_149A5746;
            float _Property_1fa9bb2cd2b640f08167086e8f7446f4_Out_0 = Vector1_328D12DB;
            float _Property_6afdfaf017914a668ddae91b64c1235d_Out_0 = Vector1_CA473DD5;
            float3 _Property_6219660fe08e4e73aaaeb556524789b0_Out_0 = Vector3_6818DD95;
            float _Property_81f811dd2cf44ad38ec59bc1501fade3_Out_0 = Vector1_4C8E34DF;
            float _Property_97349003e4ae4e37a1b998f0ea011627_Out_0 = Vector1_13346DDE;
            float _Property_6fadb645726e432ab26a6a72a8acf4ee_Out_0 = Vector1_A8A74B72;
            UnityTexture2D _Property_5a4edac20031400494580c4e0f7da972_Out_0 = Texture2D_ED058F03;
            float _Property_b019a5b269ce4ce2baedaf3aff7c0289_Out_0 = Vector1_a444e4171473481c8e0c83879e47165f;
            float _Property_6c07cc6a832b4faab0ca314c175599f4_Out_0 = Vector1_89971EC3;
            half4 _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0;
            half3 _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_ShadeColor_20;
            ToonLight_half(IN.ObjectSpacePosition, IN.AbsoluteWorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceViewDirection, _Property_100e7faf3a4b402a9feb960d09e5ae4d_Out_0, _Property_81825652062f4ba69f97553e28ca0e82_Out_0, _Property_b663d0ce9edf4b9aa573c97c4a9d8a3e_Out_0, (_Property_a6b1df0e799e4081847d4fb6db35a457_Out_0.xyz), _Property_1fa9bb2cd2b640f08167086e8f7446f4_Out_0, _Property_6afdfaf017914a668ddae91b64c1235d_Out_0, _Property_6219660fe08e4e73aaaeb556524789b0_Out_0, _Property_81f811dd2cf44ad38ec59bc1501fade3_Out_0, _Property_97349003e4ae4e37a1b998f0ea011627_Out_0, _Property_6fadb645726e432ab26a6a72a8acf4ee_Out_0, _Property_5a4edac20031400494580c4e0f7da972_Out_0.tex, _Property_b019a5b269ce4ce2baedaf3aff7c0289_Out_0, _Property_6c07cc6a832b4faab0ca314c175599f4_Out_0, _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0, _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_ShadeColor_20);
            half _Split_308656dd68824b28897ed650e60e4017_R_1 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[0];
            half _Split_308656dd68824b28897ed650e60e4017_G_2 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[1];
            half _Split_308656dd68824b28897ed650e60e4017_B_3 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[2];
            half _Split_308656dd68824b28897ed650e60e4017_A_4 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[3];
            Color_1 = (_ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0.xyz);
            Aloha_2 = _Split_308656dd68824b28897ed650e60e4017_A_4;
            ShadeColor_3 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_ShadeColor_20;
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
            half4 _Property_dc0ba5482ecc4b09a32264f12a7f96bf_Out_0 = _BaseColor;
            UnityTexture2D _Property_6d01542dab39454f96244b27f2302104_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            half4 _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_6d01542dab39454f96244b27f2302104_Out_0.tex, _Property_6d01542dab39454f96244b27f2302104_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_R_4 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.r;
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_G_5 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.g;
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_B_6 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.b;
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_A_7 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.a;
            half4 _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2;
            Unity_Multiply_half(_Property_dc0ba5482ecc4b09a32264f12a7f96bf_Out_0, _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0, _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2);
            half _Split_8a190d5587d140a98b725b1618be5378_R_1 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[0];
            half _Split_8a190d5587d140a98b725b1618be5378_G_2 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[1];
            half _Split_8a190d5587d140a98b725b1618be5378_B_3 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[2];
            half _Split_8a190d5587d140a98b725b1618be5378_A_4 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[3];
            half4 _Property_e669a7f35e9046b78538aa00b5a760b5_Out_0 = _ShadeColor;
            UnityTexture2D _Property_e2a0e185d2994abba5cd08ed1aed0260_Out_0 = UnityBuildTexture2DStructNoScale(_ShadeMap);
            half4 _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e2a0e185d2994abba5cd08ed1aed0260_Out_0.tex, _Property_e2a0e185d2994abba5cd08ed1aed0260_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_R_4 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.r;
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_G_5 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.g;
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_B_6 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.b;
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_A_7 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.a;
            half4 _Multiply_041495d9da724630a886735576fb2bd4_Out_2;
            Unity_Multiply_half(_Property_e669a7f35e9046b78538aa00b5a760b5_Out_0, _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0, _Multiply_041495d9da724630a886735576fb2bd4_Out_2);
            half _Property_d229fb937937488fa027e9f96980225e_Out_0 = _Metalic;
            UnityTexture2D _Property_dd2afd9183d24597a6bfdc8475c1cee6_Out_0 = UnityBuildTexture2DStructNoScale(_MetalicMap);
            half4 _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0 = SAMPLE_TEXTURE2D(_Property_dd2afd9183d24597a6bfdc8475c1cee6_Out_0.tex, _Property_dd2afd9183d24597a6bfdc8475c1cee6_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_R_4 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.r;
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_G_5 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.g;
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_B_6 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.b;
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_A_7 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.a;
            half4 _Multiply_b549bc066fe64ffbb69174bcda8c8f7a_Out_2;
            Unity_Multiply_half((_Property_d229fb937937488fa027e9f96980225e_Out_0.xxxx), _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0, _Multiply_b549bc066fe64ffbb69174bcda8c8f7a_Out_2);
            half _Property_72cbd81e07b74b149bcacc8e4ec541ef_Out_0 = _Smoothness;
            UnityTexture2D _Property_da6be2aaf4da4e1a8e7dbdaacb83f1c4_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            half4 _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_da6be2aaf4da4e1a8e7dbdaacb83f1c4_Out_0.tex, _Property_da6be2aaf4da4e1a8e7dbdaacb83f1c4_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0);
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_R_4 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.r;
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_G_5 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.g;
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_B_6 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.b;
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_A_7 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.a;
            half4 _Property_bd135e9c7d464f2aac018c888c1c19e4_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            UnityTexture2D _Property_da66f2d54e5e4f1d9b4e6169fb9833bf_Out_0 = UnityBuildTexture2DStructNoScale(_EmissionMap);
            half4 _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0 = SAMPLE_TEXTURE2D(_Property_da66f2d54e5e4f1d9b4e6169fb9833bf_Out_0.tex, _Property_da66f2d54e5e4f1d9b4e6169fb9833bf_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_R_4 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.r;
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_G_5 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.g;
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_B_6 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.b;
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_A_7 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.a;
            half4 _Multiply_97980ed117bc43fe8c3652f77084429d_Out_2;
            Unity_Multiply_half(_Property_bd135e9c7d464f2aac018c888c1c19e4_Out_0, _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0, _Multiply_97980ed117bc43fe8c3652f77084429d_Out_2);
            half _Property_d326b8f6ddb54a138dffb63b47a2ce0a_Out_0 = Vector1_812be4631501458ea83339c066bed988;
            UnityTexture2D _Property_500c6a1cc2cb40e2bc0c4e72674299f7_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            half4 _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0 = SAMPLE_TEXTURE2D(_Property_500c6a1cc2cb40e2bc0c4e72674299f7_Out_0.tex, _Property_500c6a1cc2cb40e2bc0c4e72674299f7_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_R_4 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.r;
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_G_5 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.g;
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_B_6 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.b;
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_A_7 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.a;
            half _Multiply_180ff739424a4186accb3226ed998abe_Out_2;
            Unity_Multiply_half(_Property_d326b8f6ddb54a138dffb63b47a2ce0a_Out_0, _SampleTexture2D_3defb7d0d466445a95386d6845502441_R_4, _Multiply_180ff739424a4186accb3226ed998abe_Out_2);
            half _Property_13f4cc575f2542cea2938b11a825b7a6_Out_0 = _ShadeToony;
            UnityTexture2D _Property_c8f5752f4359405bbbdb833daa5ecb49_Out_0 = UnityBuildTexture2DStructNoScale(_ShadeRamp);
            half _Property_3df8d2a5beba45b9bd543d1bae33268b_Out_0 = _Curvature;
            half _Property_f21b961a69e3401bbd7673eed435785a_Out_0 = _ToonyLighting;
            Bindings_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5 _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceNormal = IN.WorldSpaceNormal;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceTangent = IN.WorldSpaceTangent;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.ObjectSpacePosition = IN.ObjectSpacePosition;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
            half3 _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Color_1;
            half _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Aloha_2;
            half3 _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_ShadeColor_3;
            SG_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5((_Multiply_ed762052df704f3b992bcd126a4ce227_Out_2.xyz), _Split_8a190d5587d140a98b725b1618be5378_A_4, _Multiply_041495d9da724630a886735576fb2bd4_Out_2, _Multiply_b549bc066fe64ffbb69174bcda8c8f7a_Out_2, _Property_72cbd81e07b74b149bcacc8e4ec541ef_Out_0, (_SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.xyz), 1, (_Multiply_97980ed117bc43fe8c3652f77084429d_Out_2.xyz), _Multiply_180ff739424a4186accb3226ed998abe_Out_2, _Property_13f4cc575f2542cea2938b11a825b7a6_Out_0, _Property_c8f5752f4359405bbbdb833daa5ecb49_Out_0, _Property_3df8d2a5beba45b9bd543d1bae33268b_Out_0, _Property_f21b961a69e3401bbd7673eed435785a_Out_0, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Color_1, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Aloha_2, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_ShadeColor_3);
            surface.Alpha = _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Aloha_2;
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
            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(input.positionWS);
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
            #pragma shader_feature_local _ SHADEMODEL_RAMP



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
            float3 AbsoluteWorldSpacePosition;
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
        half4 _ShadeColor;
        float4 _ShadeMap_TexelSize;
        half _Smoothness;
        half _Metalic;
        float4 _MetalicMap_TexelSize;
        float4 _BumpMap_TexelSize;
        half Vector1_812be4631501458ea83339c066bed988;
        float4 _OcclusionMap_TexelSize;
        float4 _EmissionMap_TexelSize;
        half4 _EmissionColor;
        half _OutlineWidth;
        half4 _OutlineColor;
        half _ShadeToony;
        float4 _ShadeRamp_TexelSize;
        half4 _ShadeEnvironmentalColor;
        half _Curvature;
        half _ToonyLighting;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_ShadeMap);
        SAMPLER(sampler_ShadeMap);
        TEXTURE2D(_MetalicMap);
        SAMPLER(sampler_MetalicMap);
        TEXTURE2D(_BumpMap);
        SAMPLER(sampler_BumpMap);
        TEXTURE2D(_OcclusionMap);
        SAMPLER(sampler_OcclusionMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_ShadeRamp);
        SAMPLER(sampler_ShadeRamp);

            // Graph Functions
            
        void Unity_Multiply_half(half4 A, half4 B, out half4 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_half(half A, half B, out half Out)
        {
            Out = A * B;
        }

        // 76f53fe8936248969bc5201998a191c2
        #include "Assets/jp.lilium.toongraph/Contents/Shader/ToonLightingTextureRamp.hlsl"

        struct Bindings_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 ObjectSpacePosition;
            float3 AbsoluteWorldSpacePosition;
        };

        void SG_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5(float3 Vector3_65F6C04, float Vector1_4C8E34DF, float4 Color_1d3a761e471e4de7902496d49c375f8d, float4 Color_149A5746, float Vector1_328D12DB, float3 Vector3_A82C1F5A, float Vector1_CA473DD5, float3 Vector3_6818DD95, float Vector1_13346DDE, float Vector1_A8A74B72, UnityTexture2D Texture2D_ED058F03, float Vector1_a444e4171473481c8e0c83879e47165f, float Vector1_89971EC3, Bindings_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5 IN, out half3 Color_1, out half Aloha_2, out half3 ShadeColor_3)
        {
            float3 _Property_100e7faf3a4b402a9feb960d09e5ae4d_Out_0 = Vector3_65F6C04;
            float4 _Property_81825652062f4ba69f97553e28ca0e82_Out_0 = Color_1d3a761e471e4de7902496d49c375f8d;
            float3 _Property_b663d0ce9edf4b9aa573c97c4a9d8a3e_Out_0 = Vector3_A82C1F5A;
            float4 _Property_a6b1df0e799e4081847d4fb6db35a457_Out_0 = Color_149A5746;
            float _Property_1fa9bb2cd2b640f08167086e8f7446f4_Out_0 = Vector1_328D12DB;
            float _Property_6afdfaf017914a668ddae91b64c1235d_Out_0 = Vector1_CA473DD5;
            float3 _Property_6219660fe08e4e73aaaeb556524789b0_Out_0 = Vector3_6818DD95;
            float _Property_81f811dd2cf44ad38ec59bc1501fade3_Out_0 = Vector1_4C8E34DF;
            float _Property_97349003e4ae4e37a1b998f0ea011627_Out_0 = Vector1_13346DDE;
            float _Property_6fadb645726e432ab26a6a72a8acf4ee_Out_0 = Vector1_A8A74B72;
            UnityTexture2D _Property_5a4edac20031400494580c4e0f7da972_Out_0 = Texture2D_ED058F03;
            float _Property_b019a5b269ce4ce2baedaf3aff7c0289_Out_0 = Vector1_a444e4171473481c8e0c83879e47165f;
            float _Property_6c07cc6a832b4faab0ca314c175599f4_Out_0 = Vector1_89971EC3;
            half4 _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0;
            half3 _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_ShadeColor_20;
            ToonLight_half(IN.ObjectSpacePosition, IN.AbsoluteWorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceViewDirection, _Property_100e7faf3a4b402a9feb960d09e5ae4d_Out_0, _Property_81825652062f4ba69f97553e28ca0e82_Out_0, _Property_b663d0ce9edf4b9aa573c97c4a9d8a3e_Out_0, (_Property_a6b1df0e799e4081847d4fb6db35a457_Out_0.xyz), _Property_1fa9bb2cd2b640f08167086e8f7446f4_Out_0, _Property_6afdfaf017914a668ddae91b64c1235d_Out_0, _Property_6219660fe08e4e73aaaeb556524789b0_Out_0, _Property_81f811dd2cf44ad38ec59bc1501fade3_Out_0, _Property_97349003e4ae4e37a1b998f0ea011627_Out_0, _Property_6fadb645726e432ab26a6a72a8acf4ee_Out_0, _Property_5a4edac20031400494580c4e0f7da972_Out_0.tex, _Property_b019a5b269ce4ce2baedaf3aff7c0289_Out_0, _Property_6c07cc6a832b4faab0ca314c175599f4_Out_0, _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0, _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_ShadeColor_20);
            half _Split_308656dd68824b28897ed650e60e4017_R_1 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[0];
            half _Split_308656dd68824b28897ed650e60e4017_G_2 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[1];
            half _Split_308656dd68824b28897ed650e60e4017_B_3 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[2];
            half _Split_308656dd68824b28897ed650e60e4017_A_4 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0[3];
            Color_1 = (_ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_Color_0.xyz);
            Aloha_2 = _Split_308656dd68824b28897ed650e60e4017_A_4;
            ShadeColor_3 = _ToonLightCustomFunction_515679d119e449238cc92bb5205571c9_ShadeColor_20;
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
            half4 _Property_dc0ba5482ecc4b09a32264f12a7f96bf_Out_0 = _BaseColor;
            UnityTexture2D _Property_6d01542dab39454f96244b27f2302104_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            half4 _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_6d01542dab39454f96244b27f2302104_Out_0.tex, _Property_6d01542dab39454f96244b27f2302104_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_R_4 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.r;
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_G_5 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.g;
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_B_6 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.b;
            half _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_A_7 = _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0.a;
            half4 _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2;
            Unity_Multiply_half(_Property_dc0ba5482ecc4b09a32264f12a7f96bf_Out_0, _SampleTexture2D_404d3a7d1b0c4defadd1eece05d8b87e_RGBA_0, _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2);
            half _Split_8a190d5587d140a98b725b1618be5378_R_1 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[0];
            half _Split_8a190d5587d140a98b725b1618be5378_G_2 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[1];
            half _Split_8a190d5587d140a98b725b1618be5378_B_3 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[2];
            half _Split_8a190d5587d140a98b725b1618be5378_A_4 = _Multiply_ed762052df704f3b992bcd126a4ce227_Out_2[3];
            half4 _Property_e669a7f35e9046b78538aa00b5a760b5_Out_0 = _ShadeColor;
            UnityTexture2D _Property_e2a0e185d2994abba5cd08ed1aed0260_Out_0 = UnityBuildTexture2DStructNoScale(_ShadeMap);
            half4 _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e2a0e185d2994abba5cd08ed1aed0260_Out_0.tex, _Property_e2a0e185d2994abba5cd08ed1aed0260_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_R_4 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.r;
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_G_5 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.g;
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_B_6 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.b;
            half _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_A_7 = _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0.a;
            half4 _Multiply_041495d9da724630a886735576fb2bd4_Out_2;
            Unity_Multiply_half(_Property_e669a7f35e9046b78538aa00b5a760b5_Out_0, _SampleTexture2D_0636c2b583534f30bcfffbcca56344dc_RGBA_0, _Multiply_041495d9da724630a886735576fb2bd4_Out_2);
            half _Property_d229fb937937488fa027e9f96980225e_Out_0 = _Metalic;
            UnityTexture2D _Property_dd2afd9183d24597a6bfdc8475c1cee6_Out_0 = UnityBuildTexture2DStructNoScale(_MetalicMap);
            half4 _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0 = SAMPLE_TEXTURE2D(_Property_dd2afd9183d24597a6bfdc8475c1cee6_Out_0.tex, _Property_dd2afd9183d24597a6bfdc8475c1cee6_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_R_4 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.r;
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_G_5 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.g;
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_B_6 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.b;
            half _SampleTexture2D_b592494333b9420385ef055bf939d6ef_A_7 = _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0.a;
            half4 _Multiply_b549bc066fe64ffbb69174bcda8c8f7a_Out_2;
            Unity_Multiply_half((_Property_d229fb937937488fa027e9f96980225e_Out_0.xxxx), _SampleTexture2D_b592494333b9420385ef055bf939d6ef_RGBA_0, _Multiply_b549bc066fe64ffbb69174bcda8c8f7a_Out_2);
            half _Property_72cbd81e07b74b149bcacc8e4ec541ef_Out_0 = _Smoothness;
            UnityTexture2D _Property_da6be2aaf4da4e1a8e7dbdaacb83f1c4_Out_0 = UnityBuildTexture2DStructNoScale(_BumpMap);
            half4 _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_da6be2aaf4da4e1a8e7dbdaacb83f1c4_Out_0.tex, _Property_da6be2aaf4da4e1a8e7dbdaacb83f1c4_Out_0.samplerstate, IN.uv0.xy);
            _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0);
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_R_4 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.r;
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_G_5 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.g;
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_B_6 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.b;
            half _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_A_7 = _SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.a;
            half4 _Property_bd135e9c7d464f2aac018c888c1c19e4_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            UnityTexture2D _Property_da66f2d54e5e4f1d9b4e6169fb9833bf_Out_0 = UnityBuildTexture2DStructNoScale(_EmissionMap);
            half4 _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0 = SAMPLE_TEXTURE2D(_Property_da66f2d54e5e4f1d9b4e6169fb9833bf_Out_0.tex, _Property_da66f2d54e5e4f1d9b4e6169fb9833bf_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_R_4 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.r;
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_G_5 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.g;
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_B_6 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.b;
            half _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_A_7 = _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0.a;
            half4 _Multiply_97980ed117bc43fe8c3652f77084429d_Out_2;
            Unity_Multiply_half(_Property_bd135e9c7d464f2aac018c888c1c19e4_Out_0, _SampleTexture2D_110f7305d6ea4204baa19ec3445151db_RGBA_0, _Multiply_97980ed117bc43fe8c3652f77084429d_Out_2);
            half _Property_d326b8f6ddb54a138dffb63b47a2ce0a_Out_0 = Vector1_812be4631501458ea83339c066bed988;
            UnityTexture2D _Property_500c6a1cc2cb40e2bc0c4e72674299f7_Out_0 = UnityBuildTexture2DStructNoScale(_OcclusionMap);
            half4 _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0 = SAMPLE_TEXTURE2D(_Property_500c6a1cc2cb40e2bc0c4e72674299f7_Out_0.tex, _Property_500c6a1cc2cb40e2bc0c4e72674299f7_Out_0.samplerstate, IN.uv0.xy);
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_R_4 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.r;
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_G_5 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.g;
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_B_6 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.b;
            half _SampleTexture2D_3defb7d0d466445a95386d6845502441_A_7 = _SampleTexture2D_3defb7d0d466445a95386d6845502441_RGBA_0.a;
            half _Multiply_180ff739424a4186accb3226ed998abe_Out_2;
            Unity_Multiply_half(_Property_d326b8f6ddb54a138dffb63b47a2ce0a_Out_0, _SampleTexture2D_3defb7d0d466445a95386d6845502441_R_4, _Multiply_180ff739424a4186accb3226ed998abe_Out_2);
            half _Property_13f4cc575f2542cea2938b11a825b7a6_Out_0 = _ShadeToony;
            UnityTexture2D _Property_c8f5752f4359405bbbdb833daa5ecb49_Out_0 = UnityBuildTexture2DStructNoScale(_ShadeRamp);
            half _Property_3df8d2a5beba45b9bd543d1bae33268b_Out_0 = _Curvature;
            half _Property_f21b961a69e3401bbd7673eed435785a_Out_0 = _ToonyLighting;
            Bindings_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5 _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceNormal = IN.WorldSpaceNormal;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceTangent = IN.WorldSpaceTangent;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.ObjectSpacePosition = IN.ObjectSpacePosition;
            _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
            half3 _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Color_1;
            half _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Aloha_2;
            half3 _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_ShadeColor_3;
            SG_ToonLightingTextureRamp_72cc73d224b6de64b903e0f9545d59f5((_Multiply_ed762052df704f3b992bcd126a4ce227_Out_2.xyz), _Split_8a190d5587d140a98b725b1618be5378_A_4, _Multiply_041495d9da724630a886735576fb2bd4_Out_2, _Multiply_b549bc066fe64ffbb69174bcda8c8f7a_Out_2, _Property_72cbd81e07b74b149bcacc8e4ec541ef_Out_0, (_SampleTexture2D_a995b0f4cc594165ad76673bc6ad6b1e_RGBA_0.xyz), 1, (_Multiply_97980ed117bc43fe8c3652f77084429d_Out_2.xyz), _Multiply_180ff739424a4186accb3226ed998abe_Out_2, _Property_13f4cc575f2542cea2938b11a825b7a6_Out_0, _Property_c8f5752f4359405bbbdb833daa5ecb49_Out_0, _Property_3df8d2a5beba45b9bd543d1bae33268b_Out_0, _Property_f21b961a69e3401bbd7673eed435785a_Out_0, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Color_1, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Aloha_2, _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_ShadeColor_3);
            surface.Alpha = _ToonLightingTextureRamp_3adcc2730cf747f584033092ccf7d5f7_Aloha_2;
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
            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(input.positionWS);
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