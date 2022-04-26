Shader "Custom/Silouette Behind Stuff"
{
	Properties
	{
		_SilColor("Silouette Color", Color) = (0, 0, 0, 1)
	}

	SubShader
	{
		// Silouette pass 1 (backfaces)
		Pass
		{
			Tags
            {
                "Queue" = "Transparent"
            }
			// Won't draw where it sees ref value 4
			Cull Front // draw back faces
			ZWrite OFF
			ZTest Always
			Stencil
			{
				Ref 3
				Comp Greater
				Fail keep
				Pass replace
			}
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			// Properties
			uniform float4 _SilColor;

			struct vertexInput
			{
				float4 vertex : POSITION;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;
				output.pos = UnityObjectToClipPos(input.vertex);
				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				return _SilColor;
			}

			ENDCG
		}

		// Silouette pass 2 (front faces)
		Pass
		{
			Tags
            {
                "Queue" = "Transparent"
            }
			// Won't draw where it sees ref value 4
			Cull Back // draw front faces
			ZWrite OFF
			ZTest Always
			Stencil
			{
				Ref 4 
				Comp NotEqual
				Pass keep
			}
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			// Properties
			uniform float4 _SilColor;

			struct vertexInput
			{
				float4 vertex : POSITION;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;
				output.pos = UnityObjectToClipPos(input.vertex);
				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				return _SilColor;
			}

			ENDCG
		}
	}
}