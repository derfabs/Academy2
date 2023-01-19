// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DissolveSpecular"
{
	Properties
	{
		[HideInInspector][Header(Main)][Foldout(Main,true,8)][Space]_Float2("Float 2", Float) = 0
		[NoScaleOffset][SingleLineTexture]_MainTex("Albedo", 2D) = "white" {}
		[HideInInspector]_Cutoff1("Alpha Clip Threshold", Range( 0 , 1)) = 0
		_Color("Color", Color) = (1,1,1,1)
		[NoScaleOffset][SingleLineTexture]_SpecGlossMap("Specular Texture", 2D) = "white" {}
		_SpecColor1("Specular Value", Color) = (0.6226415,0.6226415,0.6226415,0)
		_Glossiness1("Smoothness Value", Range( 0 , 1)) = 0
		[KeywordEnum(AlbedoAlpha,SpecularAlpha)] _GlossSource1("Source", Float) = 1
		[NoScaleOffset][Normal][SingleLineTexture]_BumpMap("Normal Texture", 2D) = "bump" {}
		[NoScaleOffset][SingleLineTexture]_OcclusionMap("Occlusion Map", 2D) = "white" {}
		[Toggle]_UseEmission("UseEmission", Float) = 0
		[NoScaleOffset][SingleLineTexture]_EmissionMap("Emission Texture", 2D) = "white" {}
		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0,0)
		[HideInInspector][Space][EndGroup()]_Float1("Float 1", Float) = 0
		[HideInInspector][Header(Dissolve)][Space]_EditorStart("Editor Start", Float) = 0
		[HideInInspector]_maskclipvalue("mask clip value", Float) = 0.5
		_DissolveAmount("Dissolve Amount", Range( 0 , 1)) = 0.3801628
		[HDR]_DissolveColor("Dissolve Color", Color) = (1,0,0,0)
		_EdgeWidth("Edge Width", Range( 0 , 0.1)) = 0
		_GuideAdjuster("Guide Adjuster", Range( 1 , 2)) = 1
		_GuideTexture("Guide Texture", 2D) = "white" {}
		[Toggle(_USETRIPLANAR_ON)] _UseTriplanar("UseTriplanar", Float) = 0
		_UVTilingTriplanar("UV Tiling Triplanar", Range( 0 , 1)) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _USETRIPLANAR_ON
		#pragma multi_compile _GLOSSSOURCE1_ALBEDOALPHA _GLOSSSOURCE1_SPECULARALPHA
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform float _EditorStart;
		uniform float _Float1;
		uniform float _Float2;
		uniform float _Cutoff1;
		uniform sampler2D _BumpMap;
		uniform sampler2D _MainTex;
		uniform float4 _Color;
		uniform float _UseEmission;
		uniform sampler2D _EmissionMap;
		uniform float4 _EmissionColor;
		uniform float4 _DissolveColor;
		uniform sampler2D _GuideTexture;
		uniform float4 _GuideTexture_ST;
		uniform float _UVTilingTriplanar;
		uniform float _GuideAdjuster;
		uniform float _DissolveAmount;
		uniform float _EdgeWidth;
		uniform sampler2D _SpecGlossMap;
		uniform float4 _SpecColor1;
		uniform float _Glossiness1;
		uniform sampler2D _OcclusionMap;
		uniform float _maskclipvalue;


		inline float4 TriplanarSampling20_g3( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
			yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
			zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float2 uv_BumpMap169 = i.uv_texcoord;
			float3 TangentNormal174 = UnpackNormal( tex2D( _BumpMap, uv_BumpMap169 ) );
			o.Normal = TangentNormal174;
			float2 uv_MainTex153 = i.uv_texcoord;
			float4 tex2DNode153 = tex2D( _MainTex, uv_MainTex153 );
			float4 AlbedoColor158 = ( tex2DNode153 * _Color );
			o.Albedo = AlbedoColor158.rgb;
			float2 uv_EmissionMap150 = i.uv_texcoord;
			float4 EmissionColor164 = ( _UseEmission == 1.0 ? ( tex2D( _EmissionMap, uv_EmissionMap150 ) * _EmissionColor ) : float4( 0,0,0,0 ) );
			float2 uv_GuideTexture = i.uv_texcoord * _GuideTexture_ST.xy + _GuideTexture_ST.zw;
			float2 temp_cast_1 = (_UVTilingTriplanar).xx;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float4 triplanar20_g3 = TriplanarSampling20_g3( _GuideTexture, ase_worldPos, ase_worldNormal, 1.0, temp_cast_1, 1.0, 0 );
			#ifdef _USETRIPLANAR_ON
				float staticSwitch24_g3 = triplanar20_g3.x;
			#else
				float staticSwitch24_g3 = tex2D( _GuideTexture, uv_GuideTexture ).r;
			#endif
			float temp_output_9_0_g3 = ( staticSwitch24_g3 * _GuideAdjuster );
			float DissolveAmount11_g3 = _DissolveAmount;
			float4 lerpResult13_g3 = lerp( float4( 0,0,0,0 ) , _DissolveColor , step( temp_output_9_0_g3 , DissolveAmount11_g3 ));
			float temp_output_6_0_g3 = ( temp_output_9_0_g3 <= (0.0 + (( DissolveAmount11_g3 - _EdgeWidth ) - 0.0) * (1.0 - 0.0) / (( 1.0 - _EdgeWidth ) - 0.0)) ? 0.0 : 1.0 );
			float4 DissolveEmission129 = ( lerpResult13_g3 * temp_output_6_0_g3 );
			o.Emission = ( EmissionColor164 + DissolveEmission129 ).rgb;
			float2 uv_SpecGlossMap156 = i.uv_texcoord;
			float4 tex2DNode156 = tex2D( _SpecGlossMap, uv_SpecGlossMap156 );
			float4 SpecularColor171 = ( tex2DNode156.r * _SpecColor1 );
			o.Specular = SpecularColor171.rgb;
			#if defined(_GLOSSSOURCE1_ALBEDOALPHA)
				float staticSwitch160 = tex2DNode153.a;
			#elif defined(_GLOSSSOURCE1_SPECULARALPHA)
				float staticSwitch160 = tex2DNode156.a;
			#else
				float staticSwitch160 = tex2DNode156.a;
			#endif
			float SmoothnessValue176 = ( _Glossiness1 * staticSwitch160 );
			o.Smoothness = SmoothnessValue176;
			float2 uv_OcclusionMap166 = i.uv_texcoord;
			float OcclusionMap170 = tex2D( _OcclusionMap, uv_OcclusionMap166 ).r;
			o.Occlusion = OcclusionMap170;
			o.Alpha = 1;
			float DissolveAlpha125 = temp_output_6_0_g3;
			clip( DissolveAlpha125 - _maskclipvalue );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardSpecular keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandardSpecular o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandardSpecular, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=18935
200;73;1694;655;-2940.497;981.8713;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;149;1623.593,-1127.853;Inherit;False;1242.73;2053.751;;27;176;175;174;173;172;171;170;169;168;167;166;165;164;163;162;161;160;159;158;157;156;155;154;153;152;151;150;Standard Inputs;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;151;1788.274,447.2978;Inherit;False;Property;_EmissionColor;Emission Color;12;1;[HDR];Create;True;0;0;0;True;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;150;1742.784,255.8645;Inherit;True;Property;_EmissionMap;Emission Texture;11;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;155;2054.447,390.2829;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;157;2132.962,259.4436;Inherit;False;Property;_UseEmission;UseEmission;10;1;[Toggle];Create;True;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;153;1673.594,-646.7911;Inherit;True;Property;_MainTex;Albedo;1;2;[NoScaleOffset];[SingleLineTexture];Create;False;1;PBR Settings;0;0;True;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;156;1751.905,-239.5345;Inherit;True;Property;_SpecGlossMap;Specular Texture;4;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;103;2067.964,-1574.71;Inherit;False;520.1606;285;;2;129;125;Dissolve Function;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;161;2117.333,-758.9429;Inherit;False;Property;_Glossiness1;Smoothness Value;6;0;Create;False;0;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;152;1704.205,-455.3677;Inherit;False;Property;_Color;Color;3;0;Create;True;0;0;0;True;0;False;1,1,1,1;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Compare;162;2288.358,337.2875;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;1;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;183;2117.964,-1521.887;Inherit;False;Dissolve;14;;3;8b95cf011869c504193c0700bdb62ebb;0;0;2;COLOR;15;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;159;1783.144,-33.7209;Inherit;False;Property;_SpecColor1;Specular Value;5;0;Create;False;0;0;0;True;0;False;0.6226415,0.6226415,0.6226415,0;0.6226415,0.6226415,0.6226415,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;160;2098.173,-639.2737;Inherit;False;Property;_GlossSource1;Source;7;0;Create;False;0;0;0;True;0;False;1;1;1;True;;KeywordEnum;2;AlbedoAlpha;SpecularAlpha;Create;False;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;164;2476.029,366.2604;Inherit;False;EmissionColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;169;1768.518,665.9787;Inherit;True;Property;_BumpMap;Normal Texture;8;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;False;0;0;0;True;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;166;1749.989,-1077.853;Inherit;True;Property;_OcclusionMap;Occlusion Map;9;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;168;2411.913,-707.6118;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;154;1988.603,-473.8865;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;129;2349.125,-1524.71;Inherit;False;DissolveEmission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;165;2165.627,-149.1454;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;139;3456.704,-808.6229;Inherit;False;129;DissolveEmission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;134;3412.367,-898.1337;Inherit;False;164;EmissionColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;125;2298.6,-1408.829;Inherit;False;DissolveAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;170;2049.729,-1041.717;Inherit;False;OcclusionMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;171;2339.39,-142.3975;Inherit;False;SpecularColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;158;2164.58,-476.9636;Inherit;False;AlbedoColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;172;2345.333,605.522;Inherit;False;433.4464;170.6884;Editor;2;178;177;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;174;2101.927,692.0197;Inherit;False;TangentNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;176;2547.026,-658.4475;Inherit;False;SmoothnessValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;173;2014.997,-847.485;Inherit;False;AlphaClipThreshold;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;141;3411.807,-625.9415;Inherit;False;176;SmoothnessValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;142;3461.466,-710.1329;Inherit;False;171;SpecularColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;145;3689.531,-1037.373;Inherit;False;158;AlbedoColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;167;2363.377,-400.2003;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;177;2602.779,655.522;Inherit;False;Property;_Float1;Float 1;13;1;[HideInInspector];Create;True;0;0;0;True;2;Space;EndGroup();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;144;3440.394,-534.9083;Inherit;False;170;OcclusionMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;178;2395.333,660.2099;Inherit;False;Property;_Float2;Float 2;0;2;[HideInInspector];[Header];Create;True;1;Main;0;0;True;3;Foldout(Main,true,8);;Space;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;175;2508.378,-326.396;Inherit;False;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;163;1716.795,-839.525;Inherit;False;Property;_Cutoff1;Alpha Clip Threshold;2;1;[HideInInspector];Create;False;0;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;132;3530.725,-380.0328;Inherit;False;125;DissolveAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;147;3699.442,-863.3167;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;148;3488.201,-979.3135;Inherit;False;174;TangentNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;184;3698.497,-456.8713;Inherit;False;Constant;_maskclipvalue;mask clip value;15;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;182;3869.533,-825.4035;Float;False;True;-1;2;;0;0;StandardSpecular;DissolveSpecular;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;True;184;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;155;0;150;0
WireConnection;155;1;151;0
WireConnection;162;0;157;0
WireConnection;162;2;155;0
WireConnection;160;1;153;4
WireConnection;160;0;156;4
WireConnection;164;0;162;0
WireConnection;168;0;161;0
WireConnection;168;1;160;0
WireConnection;154;0;153;0
WireConnection;154;1;152;0
WireConnection;129;0;183;15
WireConnection;165;0;156;1
WireConnection;165;1;159;0
WireConnection;125;0;183;0
WireConnection;170;0;166;1
WireConnection;171;0;165;0
WireConnection;158;0;154;0
WireConnection;174;0;169;0
WireConnection;176;0;168;0
WireConnection;173;0;163;0
WireConnection;167;0;158;0
WireConnection;175;0;167;3
WireConnection;147;0;134;0
WireConnection;147;1;139;0
WireConnection;182;0;145;0
WireConnection;182;1;148;0
WireConnection;182;2;147;0
WireConnection;182;3;142;0
WireConnection;182;4;141;0
WireConnection;182;5;144;0
WireConnection;182;10;132;0
ASEEND*/
//CHKSM=913A24A965EA0759D4016B57FD08DEECD112D68A