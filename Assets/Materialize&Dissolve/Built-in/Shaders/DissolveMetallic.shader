// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DissolveMetallic"
{
	Properties
	{
		[HideInInspector][Header(Main)][Foldout(Main,true,8)][Space]_EditorStart("Editor Start", Float) = 0
		[Header(Main)][NoScaleOffset][SingleLineTexture][Space]_MainTex("Albedo", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		[NoScaleOffset][SingleLineTexture]_MetallicTexture("Metallic Texture", 2D) = "white" {}
		_MetallicValue("Metallic Value", Range( 0 , 1)) = 0
		_Glossiness("Smoothness Value", Range( 0 , 1)) = 0
		[KeywordEnum(AlbedoAlpha,MetallicAlpha)] _GlossSource("Source", Float) = 1
		[NoScaleOffset][Normal][SingleLineTexture]_BumpMap("Normal Texture", 2D) = "bump" {}
		[NoScaleOffset][SingleLineTexture]_OcclusionMap1("Occlusion Map", 2D) = "white" {}
		[Toggle]_UseEmission("UseEmission", Float) = 0
		[NoScaleOffset][SingleLineTexture]_EmissionMap("Emission Texture", 2D) = "white" {}
		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0,0)
		[HideInInspector][Space][EndGroup()]_EditorEnd("Editor End", Float) = 0
		[HideInInspector][Header(Dissolve)][Space]_EditorStart("Editor Start", Float) = 0
		_DissolveAmount("Dissolve Amount", Range( 0 , 1)) = 0.3801628
		[HideInInspector]_maskclipvalue("mask clip value", Float) = 0.5
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
		#pragma multi_compile _GLOSSSOURCE_ALBEDOALPHA _GLOSSSOURCE_METALLICALPHA
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

		uniform float _EditorEnd;
		uniform float _EditorStart;
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
		uniform sampler2D _MetallicTexture;
		uniform float _MetallicValue;
		uniform float _Glossiness;
		uniform sampler2D _OcclusionMap1;
		uniform float _maskclipvalue;


		inline float4 TriplanarSampling20_g8( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
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


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_BumpMap82 = i.uv_texcoord;
			float3 TangentNormal87 = UnpackNormal( tex2D( _BumpMap, uv_BumpMap82 ) );
			o.Normal = TangentNormal87;
			float2 uv_MainTex68 = i.uv_texcoord;
			float4 tex2DNode68 = tex2D( _MainTex, uv_MainTex68 );
			float4 AlbedoColor75 = ( tex2DNode68 * _Color );
			o.Albedo = AlbedoColor75.rgb;
			float2 uv_EmissionMap65 = i.uv_texcoord;
			float4 EmissionColor80 = ( _UseEmission == 1.0 ? ( tex2D( _EmissionMap, uv_EmissionMap65 ) * _EmissionColor ) : float4( 0,0,0,0 ) );
			float2 uv_GuideTexture = i.uv_texcoord * _GuideTexture_ST.xy + _GuideTexture_ST.zw;
			float2 temp_cast_1 = (_UVTilingTriplanar).xx;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float4 triplanar20_g8 = TriplanarSampling20_g8( _GuideTexture, ase_worldPos, ase_worldNormal, 1.0, temp_cast_1, 1.0, 0 );
			#ifdef _USETRIPLANAR_ON
				float staticSwitch24_g8 = triplanar20_g8.x;
			#else
				float staticSwitch24_g8 = tex2D( _GuideTexture, uv_GuideTexture ).r;
			#endif
			float temp_output_9_0_g8 = ( staticSwitch24_g8 * _GuideAdjuster );
			float DissolveAmount11_g8 = _DissolveAmount;
			float4 lerpResult13_g8 = lerp( float4( 0,0,0,0 ) , _DissolveColor , step( temp_output_9_0_g8 , DissolveAmount11_g8 ));
			float temp_output_6_0_g8 = ( temp_output_9_0_g8 <= (0.0 + (( DissolveAmount11_g8 - _EdgeWidth ) - 0.0) * (1.0 - 0.0) / (( 1.0 - _EdgeWidth ) - 0.0)) ? 0.0 : 1.0 );
			float4 DissolveEmission105 = ( lerpResult13_g8 * temp_output_6_0_g8 );
			o.Emission = ( EmissionColor80 + DissolveEmission105 ).rgb;
			float2 uv_MetallicTexture72 = i.uv_texcoord;
			float4 tex2DNode72 = tex2D( _MetallicTexture, uv_MetallicTexture72 );
			float MetallicValue89 = ( tex2DNode72.r * _MetallicValue );
			o.Metallic = MetallicValue89;
			#if defined(_GLOSSSOURCE_ALBEDOALPHA)
				float staticSwitch76 = tex2DNode68.a;
			#elif defined(_GLOSSSOURCE_METALLICALPHA)
				float staticSwitch76 = tex2DNode72.a;
			#else
				float staticSwitch76 = tex2DNode72.a;
			#endif
			float SmoothnessValue88 = ( _Glossiness * staticSwitch76 );
			o.Smoothness = SmoothnessValue88;
			float2 uv_OcclusionMap183 = i.uv_texcoord;
			float OcclusionMap85 = tex2D( _OcclusionMap1, uv_OcclusionMap183 ).r;
			o.Occlusion = OcclusionMap85;
			o.Alpha = 1;
			float DissolveAlpha106 = temp_output_6_0_g8;
			clip( DissolveAlpha106 - _maskclipvalue );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

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
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
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
200;73;1694;655;-646.8616;4.007751;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;64;1049.135,-288.623;Inherit;False;1242.73;2053.751;;25;91;89;88;87;86;85;83;82;81;80;79;78;77;76;75;74;73;72;71;70;69;68;67;66;65;Metallic Inputs;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;66;1213.816,1286.529;Inherit;False;Property;_EmissionColor;Emission Color;11;1;[HDR];Create;True;0;0;0;True;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;65;1168.325,1095.095;Inherit;True;Property;_EmissionMap;Emission Texture;10;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;71;1556.363,1099.604;Inherit;False;Property;_UseEmission;UseEmission;9;1;[Toggle];Create;True;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;68;1131.135,56.439;Inherit;True;Property;_MainTex;Albedo;1;3;[Header];[NoScaleOffset];[SingleLineTexture];Create;False;1;Main;0;0;True;1;Space;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;72;1166.882,641.3582;Inherit;True;Property;_MetallicTexture;Metallic Texture;3;2;[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;1479.989,1229.514;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;74;1365.549,887.8141;Inherit;False;Property;_MetallicValue;Metallic Value;4;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;67;1130.746,383.8622;Inherit;False;Property;_Color;Color;2;0;Create;True;0;0;0;True;0;False;1,1,1,1;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;73;1542.875,80.28689;Inherit;False;Property;_Glossiness;Smoothness Value;5;0;Create;False;0;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;130;1568.406,-778.1167;Inherit;False;Dissolve;13;;8;8b95cf011869c504193c0700bdb62ebb;0;0;2;COLOR;15;FLOAT;0
Node;AmplifyShaderEditor.Compare;77;1713.9,1176.518;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;1;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;76;1523.715,199.9564;Inherit;False;Property;_GlossSource;Source;6;0;Create;False;0;0;0;True;0;False;1;1;1;True;;KeywordEnum;2;AlbedoAlpha;MetallicAlpha;Create;False;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;110;1518.406,-830.9395;Inherit;False;520.1606;285;;2;105;106;Dissolve Function;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;1414.145,365.3434;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;105;1799.567,-780.9395;Inherit;False;DissolveEmission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;1662.819,773.0323;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;82;1194.059,1505.209;Inherit;True;Property;_BumpMap;Normal Texture;7;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;False;0;0;0;True;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;1901.571,1205.491;Inherit;False;EmissionColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;83;1175.531,-238.6229;Inherit;True;Property;_OcclusionMap1;Occlusion Map;8;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;1837.454,131.6182;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;75;1590.122,362.2662;Inherit;False;AlbedoColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;91;1770.874,1444.753;Inherit;False;433.4464;170.6884;Editor;2;93;92;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;106;1749.042,-665.0581;Inherit;False;DissolveAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;85;1475.27,-202.487;Inherit;False;OcclusionMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;95;2862.809,-154.3629;Inherit;False;80;EmissionColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;89;1734.676,651.9097;Inherit;False;MetallicValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;2907.146,-64.85216;Inherit;False;105;DissolveEmission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;87;1527.469,1531.25;Inherit;False;TangentNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;88;1972.567,180.7825;Inherit;False;SmoothnessValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;96;2938.643,-235.5427;Inherit;False;87;TangentNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;81;1788.919,439.0294;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;86;1933.919,512.8336;Inherit;False;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;93;2028.32,1494.753;Inherit;False;Property;_EditorEnd;Editor End;12;1;[HideInInspector];Create;True;0;0;0;True;2;Space;EndGroup();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;2862.249,117.8293;Inherit;False;88;SmoothnessValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;92;1820.874,1499.441;Inherit;False;Property;_EditorStart;Editor Start;0;2;[HideInInspector];[Header];Create;True;1;Main;0;0;True;3;Foldout(Main,true,8);;Space;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;104;2860.003,212.1236;Inherit;False;85;OcclusionMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;98;3131.884,-34.54594;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;100;2910.519,33.63785;Inherit;False;89;MetallicValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;129;3337.681,453.3083;Inherit;False;Constant;_maskclipvalue;mask clip value;15;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;3016.485,297.0813;Inherit;False;106;DissolveAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;103;3127.973,-283.6022;Inherit;False;75;AlbedoColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;127;3409.806,-49.07073;Float;False;True;-1;2;;0;0;Standard;DissolveMetallic;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;False;Opaque;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;True;129;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;69;0;65;0
WireConnection;69;1;66;0
WireConnection;77;0;71;0
WireConnection;77;2;69;0
WireConnection;76;1;68;4
WireConnection;76;0;72;4
WireConnection;70;0;68;0
WireConnection;70;1;67;0
WireConnection;105;0;130;15
WireConnection;78;0;72;1
WireConnection;78;1;74;0
WireConnection;80;0;77;0
WireConnection;79;0;73;0
WireConnection;79;1;76;0
WireConnection;75;0;70;0
WireConnection;106;0;130;0
WireConnection;85;0;83;1
WireConnection;89;0;78;0
WireConnection;87;0;82;0
WireConnection;88;0;79;0
WireConnection;81;0;75;0
WireConnection;86;0;81;3
WireConnection;98;0;95;0
WireConnection;98;1;94;0
WireConnection;127;0;103;0
WireConnection;127;1;96;0
WireConnection;127;2;98;0
WireConnection;127;3;100;0
WireConnection;127;4;97;0
WireConnection;127;5;104;0
WireConnection;127;10;99;0
ASEEND*/
//CHKSM=F70B710B6526EF3F945BA8F1D44BBF111E272C94