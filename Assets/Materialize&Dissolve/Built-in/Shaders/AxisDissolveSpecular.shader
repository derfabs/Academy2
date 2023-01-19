// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AxisDissolveSpecular"
{
	Properties
	{
		[HideInInspector][Foldout(Main,true,8)][Space]_Float2("Float 2", Float) = 0
		[Header(Main)][NoScaleOffset][SingleLineTexture][Space]_MainTex("Albedo", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		[NoScaleOffset][SingleLineTexture]_SpecGlossMap("Specular Texture", 2D) = "white" {}
		_SpecColor1("Specular Value", Color) = (0.6226415,0.6226415,0.6226415,0)
		_Glossiness1("Smoothness Value", Range( 0 , 1)) = 0
		[KeywordEnum(AlbedoAlpha,SpecularAlpha)] _GlossSource1("Source", Float) = 1
		[NoScaleOffset][Normal][SingleLineTexture]_BumpMap("Normal Texture", 2D) = "bump" {}
		[NoScaleOffset][SingleLineTexture]_OcclusionMap("Occlusion Map", 2D) = "white" {}
		[HideInInspector]_cliptest("clip test", Float) = 0.5
		[Toggle]_UseEmission("UseEmission", Float) = 0
		[NoScaleOffset][SingleLineTexture]_EmissionMap("Emission Texture", 2D) = "white" {}
		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0,0)
		[HideInInspector][Space][EndGroup()]_Float1("Float 1", Float) = 0
		[Header(Main Dissolve Settings)][Space]_DissolveAmount("Dissolve Amount", Range( 0 , 1)) = 1
		_MinValueWhenAmount0("Min Value (When Amount = 0)", Float) = 0
		_MaxValueWhenAmount1("Max Value (When Amount = 1)", Float) = 3
		[KeywordEnum(X,Y,Z)] _Axis("Axis", Float) = 1
		[KeywordEnum(Albedo,Emission)] _EdgesAffect("EdgesAffect", Float) = 1
		[Toggle(_INVERTDIRECTIONMINMAX_ON)] _InvertDirectionMinMax("Invert Direction (Min & Max)", Float) = 0
		[Toggle(_USETRIPLANARUVS_ON)] _UseTriplanarUvs("Use Triplanar Uvs", Float) = 0
		[Header(Dissolve Guide)][NoScaleOffset][Space]_GuideTexture("Guide Texture", 2D) = "white" {}
		_GuideTilling("Guide Tilling", Float) = 1
		_GuideTillingSpeed("Guide Tilling Speed", Range( -0.4 , 0.4)) = 0.005
		_GuideStrength("Guide Strength", Range( 0 , 10)) = 0
		[Toggle(_GUIDEAFFECTSEDGESBLENDING_ON)] _GuideAffectsEdgesBlending("Guide Affects Edges Blending", Float) = 0
		[Header(Vertex Displacement)][Space]_VertexDisplacementMainEdge("Vertex Displacement Main Edge ", Range( 0 , 2)) = 0
		_VertexDisplacementSecondEdge("Vertex Displacement Second Edge", Range( 0 , 2)) = 0
		[NoScaleOffset]_DisplacementGuide(" Displacement Guide", 2D) = "white" {}
		_DisplacementGuideTillingSpeed("Displacement Guide Tilling Speed", Range( 0 , 0.2)) = 0.005
		_DisplacementGuideTilling("Displacement Guide Tilling", Float) = 1
		[Header(Main Edge)][Space]_MainEdgeWidth("Main Edge Width", Range( 0 , 0.5)) = 0.01308131
		[NoScaleOffset]_MainEdgePattern("Main Edge Pattern", 2D) = "black" {}
		_MainEdgePatternTilling("Main Edge Pattern Tilling", Float) = 1
		[HDR]_MainEdgeColor1("Main Edge Color 1", Color) = (0,0.171536,1,1)
		[HDR]_MainEdgeColor2("Main Edge Color 2", Color) = (1,0,0.5446758,1)
		[Header(Second Edge)][Space]_SecondEdgeWidth("Second Edge Width", Range( 0 , 0.5)) = 0.02225761
		[NoScaleOffset]_SecondEdgePattern("Second Edge Pattern", 2D) = "black" {}
		_SecondEdgePatternTilling("Second Edge Pattern Tilling", Float) = 1
		[HDR]_SecondEdgeColor1("Second Edge Color 1", Color) = (0,0.171536,1,1)
		[HDR]_SecondEdgeColor2("Second Edge Color 2", Color) = (1,0,0.5446758,1)
		[Toggle(_2SIDESSECONDEDGE_ON)] _2SidesSecondEdge("2 Sides Second Edge", Float) = 1
		[HideInInspector][DrawSystemProperties]_AdvancedInpector("AdvancedInpector", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_local __ _2SIDESSECONDEDGE_ON
		#pragma multi_compile_local __ _GUIDEAFFECTSEDGESBLENDING_ON
		#pragma multi_compile_local _AXIS_X _AXIS_Y _AXIS_Z
		#pragma multi_compile_local __ _USETRIPLANARUVS_ON
		#pragma shader_feature_local _INVERTDIRECTIONMINMAX_ON
		#pragma shader_feature_local _EDGESAFFECT_ALBEDO _EDGESAFFECT_EMISSION
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
			float3 worldPos;
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform float _Float2;
		uniform float _AdvancedInpector;
		uniform float _Float1;
		uniform float _VertexDisplacementSecondEdge;
		uniform sampler2D _DisplacementGuide;
		uniform float _DisplacementGuideTilling;
		uniform float _DisplacementGuideTillingSpeed;
		uniform float _VertexDisplacementMainEdge;
		uniform float _DissolveAmount;
		uniform float _SecondEdgeWidth;
		uniform sampler2D _GuideTexture;
		uniform float _GuideTilling;
		uniform float _GuideTillingSpeed;
		uniform float _GuideStrength;
		uniform float _MinValueWhenAmount0;
		uniform float _MaxValueWhenAmount1;
		uniform float _MainEdgeWidth;
		uniform sampler2D _BumpMap;
		uniform sampler2D _MainTex;
		uniform float4 _Color;
		uniform float4 _SecondEdgeColor1;
		uniform float4 _SecondEdgeColor2;
		uniform sampler2D _SecondEdgePattern;
		uniform float _SecondEdgePatternTilling;
		uniform float4 _MainEdgeColor1;
		uniform float4 _MainEdgeColor2;
		uniform sampler2D _MainEdgePattern;
		uniform float _MainEdgePatternTilling;
		uniform float _UseEmission;
		uniform sampler2D _EmissionMap;
		uniform float4 _EmissionColor;
		uniform sampler2D _SpecGlossMap;
		uniform float4 _SpecColor1;
		uniform float _Glossiness1;
		uniform sampler2D _OcclusionMap;
		uniform float _cliptest;


		inline float4 TriplanarSampling16_g20( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.zy * float2(  nsign.x, 1.0 ), 0, 0) );
			yNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.xz * float2(  nsign.y, 1.0 ), 0, 0) );
			zNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.xy * float2( -nsign.z, 1.0 ), 0, 0) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


		inline float4 TriplanarSampling62_g20( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
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


		inline float4 TriplanarSampling61_g20( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
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


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float2 temp_cast_0 = (_DisplacementGuideTilling).xx;
			float2 temp_cast_1 = (( _Time.y * _DisplacementGuideTillingSpeed )).xx;
			float2 uv_TexCoord76_g20 = v.texcoord.xy * temp_cast_0 + temp_cast_1;
			float4 tex2DNode78_g20 = tex2Dlod( _DisplacementGuide, float4( uv_TexCoord76_g20, 0, 0.0) );
			float DissolveAmount13_g20 = _DissolveAmount;
			#ifdef _2SIDESSECONDEDGE_ON
				float staticSwitch34_g20 = ( _SecondEdgeWidth / 2.0 );
			#else
				float staticSwitch34_g20 = 0.0;
			#endif
			float3 ase_vertex3Pos = v.vertex.xyz;
			#if defined(_AXIS_X)
				float staticSwitch23_g20 = ase_vertex3Pos.x;
			#elif defined(_AXIS_Y)
				float staticSwitch23_g20 = ase_vertex3Pos.y;
			#elif defined(_AXIS_Z)
				float staticSwitch23_g20 = ase_vertex3Pos.z;
			#else
				float staticSwitch23_g20 = ase_vertex3Pos.y;
			#endif
			float2 temp_cast_2 = (_GuideTilling).xx;
			float temp_output_3_0_g20 = ( _Time.y * _GuideTillingSpeed );
			float2 temp_cast_3 = (temp_output_3_0_g20).xx;
			float2 uv_TexCoord6_g20 = v.texcoord.xy * temp_cast_2 + temp_cast_3;
			float2 temp_cast_4 = (_GuideTilling).xx;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float3 ase_vertexNormal = v.normal.xyz;
			float4 triplanar16_g20 = TriplanarSampling16_g20( _GuideTexture, ( ase_vertex3Pos + temp_output_3_0_g20 ), ase_vertexNormal, 1.0, temp_cast_4, 1.0, 0 );
			#ifdef _USETRIPLANARUVS_ON
				float staticSwitch17_g20 = triplanar16_g20.x;
			#else
				float staticSwitch17_g20 = tex2Dlod( _GuideTexture, float4( uv_TexCoord6_g20, 0, 0.0) ).r;
			#endif
			float temp_output_33_0_g20 = ( ( staticSwitch17_g20 * _GuideStrength ) + staticSwitch23_g20 );
			#ifdef _GUIDEAFFECTSEDGESBLENDING_ON
				float staticSwitch37_g20 = temp_output_33_0_g20;
			#else
				float staticSwitch37_g20 = staticSwitch23_g20;
			#endif
			float2 appendResult12_g20 = (float2(_MinValueWhenAmount0 , _MaxValueWhenAmount1));
			float2 appendResult14_g20 = (float2(_MaxValueWhenAmount1 , _MinValueWhenAmount0));
			#ifdef _INVERTDIRECTIONMINMAX_ON
				float2 staticSwitch19_g20 = appendResult14_g20;
			#else
				float2 staticSwitch19_g20 = appendResult12_g20;
			#endif
			float2 break24_g20 = staticSwitch19_g20;
			float DissolvelerpA29_g20 = break24_g20.x;
			float temp_output_1_0_g22 = DissolvelerpA29_g20;
			float DissolvelerpB31_g20 = break24_g20.y;
			float temp_output_43_0_g20 = ( ( staticSwitch37_g20 - temp_output_1_0_g22 ) / ( DissolvelerpB31_g20 - temp_output_1_0_g22 ) );
			float DissolveWithEdges32_g20 = ( DissolveAmount13_g20 + _MainEdgeWidth );
			float EdgesAlpha75_g20 = ( step( ( DissolveAmount13_g20 + staticSwitch34_g20 ) , temp_output_43_0_g20 ) - step( ( DissolveWithEdges32_g20 + staticSwitch34_g20 ) , temp_output_43_0_g20 ) );
			float lerpResult91_g20 = lerp( ( _VertexDisplacementSecondEdge * tex2DNode78_g20.r ) , ( tex2DNode78_g20.r * _VertexDisplacementMainEdge ) , EdgesAlpha75_g20);
			float temp_output_1_0_g21 = DissolvelerpA29_g20;
			float temp_output_47_0_g20 = ( ( temp_output_33_0_g20 - temp_output_1_0_g21 ) / ( DissolvelerpB31_g20 - temp_output_1_0_g21 ) );
			float temp_output_54_0_g20 = step( DissolveAmount13_g20 , temp_output_47_0_g20 );
			float smoothstepResult73_g20 = smoothstep( 0.0 , 0.06 , ( temp_output_54_0_g20 - step( ( DissolveAmount13_g20 + ( _MainEdgeWidth + _SecondEdgeWidth ) ) , temp_output_47_0_g20 ) ));
			float EdgeTexBlendAlpha83_g20 = smoothstepResult73_g20;
			float lerpResult92_g20 = lerp( 0.0 , lerpResult91_g20 , EdgeTexBlendAlpha83_g20);
			float3 VertexOffset245 = ( lerpResult92_g20 * ase_vertexNormal );
			v.vertex.xyz += VertexOffset245;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float2 uv_BumpMap220 = i.uv_texcoord;
			float3 TangentNormal217 = UnpackNormal( tex2D( _BumpMap, uv_BumpMap220 ) );
			o.Normal = TangentNormal217;
			float2 uv_MainTex211 = i.uv_texcoord;
			float4 tex2DNode211 = tex2D( _MainTex, uv_MainTex211 );
			float4 AlbedoColor215 = ( tex2DNode211 * _Color );
			float4 temp_output_101_0_g20 = AlbedoColor215;
			float DissolveAmount13_g20 = _DissolveAmount;
			float2 temp_cast_0 = (_GuideTilling).xx;
			float temp_output_3_0_g20 = ( _Time.y * _GuideTillingSpeed );
			float2 temp_cast_1 = (temp_output_3_0_g20).xx;
			float2 uv_TexCoord6_g20 = i.uv_texcoord * temp_cast_0 + temp_cast_1;
			float2 temp_cast_2 = (_GuideTilling).xx;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			ase_vertexNormal = normalize( ase_vertexNormal );
			float4 triplanar16_g20 = TriplanarSampling16_g20( _GuideTexture, ( ase_vertex3Pos + temp_output_3_0_g20 ), ase_vertexNormal, 1.0, temp_cast_2, 1.0, 0 );
			#ifdef _USETRIPLANARUVS_ON
				float staticSwitch17_g20 = triplanar16_g20.x;
			#else
				float staticSwitch17_g20 = tex2D( _GuideTexture, uv_TexCoord6_g20 ).r;
			#endif
			#if defined(_AXIS_X)
				float staticSwitch23_g20 = ase_vertex3Pos.x;
			#elif defined(_AXIS_Y)
				float staticSwitch23_g20 = ase_vertex3Pos.y;
			#elif defined(_AXIS_Z)
				float staticSwitch23_g20 = ase_vertex3Pos.z;
			#else
				float staticSwitch23_g20 = ase_vertex3Pos.y;
			#endif
			float temp_output_33_0_g20 = ( ( staticSwitch17_g20 * _GuideStrength ) + staticSwitch23_g20 );
			float2 appendResult12_g20 = (float2(_MinValueWhenAmount0 , _MaxValueWhenAmount1));
			float2 appendResult14_g20 = (float2(_MaxValueWhenAmount1 , _MinValueWhenAmount0));
			#ifdef _INVERTDIRECTIONMINMAX_ON
				float2 staticSwitch19_g20 = appendResult14_g20;
			#else
				float2 staticSwitch19_g20 = appendResult12_g20;
			#endif
			float2 break24_g20 = staticSwitch19_g20;
			float DissolvelerpA29_g20 = break24_g20.x;
			float temp_output_1_0_g21 = DissolvelerpA29_g20;
			float DissolvelerpB31_g20 = break24_g20.y;
			float temp_output_47_0_g20 = ( ( temp_output_33_0_g20 - temp_output_1_0_g21 ) / ( DissolvelerpB31_g20 - temp_output_1_0_g21 ) );
			float temp_output_54_0_g20 = step( DissolveAmount13_g20 , temp_output_47_0_g20 );
			float smoothstepResult73_g20 = smoothstep( 0.0 , 0.06 , ( temp_output_54_0_g20 - step( ( DissolveAmount13_g20 + ( _MainEdgeWidth + _SecondEdgeWidth ) ) , temp_output_47_0_g20 ) ));
			float EdgeTexBlendAlpha83_g20 = smoothstepResult73_g20;
			float4 lerpResult103_g20 = lerp( temp_output_101_0_g20 , float4( 0,0,0,1 ) , EdgeTexBlendAlpha83_g20);
			float2 temp_cast_3 = (_SecondEdgePatternTilling).xx;
			float2 uv_TexCoord53_g20 = i.uv_texcoord * temp_cast_3;
			float2 temp_cast_4 = (_SecondEdgePatternTilling).xx;
			float4 triplanar62_g20 = TriplanarSampling62_g20( _SecondEdgePattern, ase_vertex3Pos, ase_vertexNormal, 1.0, temp_cast_4, 1.0, 0 );
			#ifdef _USETRIPLANARUVS_ON
				float staticSwitch71_g20 = triplanar62_g20.x;
			#else
				float staticSwitch71_g20 = tex2D( _SecondEdgePattern, uv_TexCoord53_g20 ).r;
			#endif
			float4 lerpResult79_g20 = lerp( _SecondEdgeColor1 , _SecondEdgeColor2 , staticSwitch71_g20);
			float2 temp_cast_5 = (_MainEdgePatternTilling).xx;
			float2 uv_TexCoord50_g20 = i.uv_texcoord * temp_cast_5;
			float2 temp_cast_6 = (_MainEdgePatternTilling).xx;
			float4 triplanar61_g20 = TriplanarSampling61_g20( _MainEdgePattern, ase_vertex3Pos, ase_vertexNormal, 1.0, temp_cast_6, 1.0, 0 );
			#ifdef _USETRIPLANARUVS_ON
				float staticSwitch67_g20 = triplanar61_g20.x;
			#else
				float staticSwitch67_g20 = tex2D( _MainEdgePattern, uv_TexCoord50_g20 ).r;
			#endif
			float4 lerpResult82_g20 = lerp( _MainEdgeColor1 , _MainEdgeColor2 , staticSwitch67_g20);
			#ifdef _2SIDESSECONDEDGE_ON
				float staticSwitch34_g20 = ( _SecondEdgeWidth / 2.0 );
			#else
				float staticSwitch34_g20 = 0.0;
			#endif
			#ifdef _GUIDEAFFECTSEDGESBLENDING_ON
				float staticSwitch37_g20 = temp_output_33_0_g20;
			#else
				float staticSwitch37_g20 = staticSwitch23_g20;
			#endif
			float temp_output_1_0_g22 = DissolvelerpA29_g20;
			float temp_output_43_0_g20 = ( ( staticSwitch37_g20 - temp_output_1_0_g22 ) / ( DissolvelerpB31_g20 - temp_output_1_0_g22 ) );
			float DissolveWithEdges32_g20 = ( DissolveAmount13_g20 + _MainEdgeWidth );
			float EdgesAlpha75_g20 = ( step( ( DissolveAmount13_g20 + staticSwitch34_g20 ) , temp_output_43_0_g20 ) - step( ( DissolveWithEdges32_g20 + staticSwitch34_g20 ) , temp_output_43_0_g20 ) );
			float4 lerpResult85_g20 = lerp( lerpResult79_g20 , lerpResult82_g20 , EdgesAlpha75_g20);
			float4 lerpResult89_g20 = lerp( float4( 0,0,0,0 ) , lerpResult85_g20 , EdgeTexBlendAlpha83_g20);
			float4 EmissionColor109_g20 = lerpResult89_g20;
			float4 lerpResult106_g20 = lerp( temp_output_101_0_g20 , EmissionColor109_g20 , EdgeTexBlendAlpha83_g20);
			#if defined(_EDGESAFFECT_ALBEDO)
				float4 staticSwitch99_g20 = lerpResult106_g20;
			#elif defined(_EDGESAFFECT_EMISSION)
				float4 staticSwitch99_g20 = lerpResult103_g20;
			#else
				float4 staticSwitch99_g20 = lerpResult103_g20;
			#endif
			float4 Albedo243 = staticSwitch99_g20;
			o.Albedo = Albedo243.rgb;
			float2 uv_EmissionMap226 = i.uv_texcoord;
			float4 EmissionColor233 = ( _UseEmission == 1.0 ? ( tex2D( _EmissionMap, uv_EmissionMap226 ) * _EmissionColor ) : float4( 0,0,0,0 ) );
			float4 DissolveEmission244 = EmissionColor109_g20;
			o.Emission = ( EmissionColor233 + DissolveEmission244 ).rgb;
			float2 uv_SpecGlossMap227 = i.uv_texcoord;
			float4 tex2DNode227 = tex2D( _SpecGlossMap, uv_SpecGlossMap227 );
			float4 SpecularColor219 = ( tex2DNode227.r * _SpecColor1 );
			o.Specular = SpecularColor219.rgb;
			#if defined(_GLOSSSOURCE1_ALBEDOALPHA)
				float staticSwitch229 = tex2DNode211.a;
			#elif defined(_GLOSSSOURCE1_SPECULARALPHA)
				float staticSwitch229 = tex2DNode227.a;
			#else
				float staticSwitch229 = tex2DNode227.a;
			#endif
			float SmoothnessValue224 = ( _Glossiness1 * staticSwitch229 );
			o.Smoothness = SmoothnessValue224;
			float2 uv_OcclusionMap238 = i.uv_texcoord;
			float OcclusionMap218 = tex2D( _OcclusionMap, uv_OcclusionMap238 ).r;
			o.Occlusion = OcclusionMap218;
			o.Alpha = 1;
			float FinalAlpha96_g20 = temp_output_54_0_g20;
			float DissolveAlpha246 = FinalAlpha96_g20;
			clip( DissolveAlpha246 - _cliptest );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardSpecular keepalpha fullforwardshadows vertex:vertexDataFunc 

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
				vertexDataFunc( v, customInputData );
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
200;73;1694;655;-1846.638;-322.9759;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;210;1078.458,209.8322;Inherit;False;1242.73;2053.751;;25;239;238;237;236;235;234;233;232;231;230;229;228;227;226;224;221;220;219;218;217;215;214;213;212;211;Standard Inputs;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;212;1159.07,882.3176;Inherit;False;Property;_Color;Color;2;0;Create;True;0;0;0;True;0;False;1,1,1,1;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;211;1128.459,690.894;Inherit;True;Property;_MainTex;Albedo;1;3;[Header];[NoScaleOffset];[SingleLineTexture];Create;False;1;Main;0;0;True;1;Space;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;213;1443.468,863.7988;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;236;1243.139,1784.983;Inherit;False;Property;_EmissionColor;Emission Color;11;1;[HDR];Create;True;0;0;0;True;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;226;1197.649,1593.55;Inherit;True;Property;_EmissionMap;Emission Texture;10;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;257;1153.915,-347.8067;Inherit;False;955;416;;6;242;256;243;246;244;245;Dissolve Function;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;215;1619.445,860.7216;Inherit;False;AlbedoColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;242;1203.915,-186.8067;Inherit;False;215;AlbedoColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;221;1587.827,1597.129;Inherit;False;Property;_UseEmission;UseEmission;9;1;[Toggle];Create;True;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;228;1509.312,1727.968;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;227;1206.77,1098.151;Inherit;True;Property;_SpecGlossMap;Specular Texture;3;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;230;1238.009,1303.964;Inherit;False;Property;_SpecColor1;Specular Value;4;0;Create;False;0;0;0;True;0;False;0.6226415,0.6226415,0.6226415,0;0.6226415,0.6226415,0.6226415,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;237;1572.198,578.7423;Inherit;False;Property;_Glossiness1;Smoothness Value;5;0;Create;False;0;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;231;1743.223,1674.973;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;1;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;256;1464.24,-211.1464;Inherit;False;AxisDissolve;13;;20;c7e8d1367c6e85c468a8796d0ba1e1a6;0;1;101;COLOR;1,1,1,1;False;4;COLOR;100;COLOR;102;FLOAT3;98;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;229;1553.038,698.4114;Inherit;False;Property;_GlossSource1;Source;6;0;Create;False;0;0;0;True;0;False;1;1;1;True;;KeywordEnum;2;AlbedoAlpha;SpecularAlpha;Create;False;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;244;1856.915,-297.8067;Inherit;False;DissolveEmission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;220;1223.383,2003.664;Inherit;True;Property;_BumpMap;Normal Texture;7;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;False;0;0;0;True;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;238;1204.854,259.8322;Inherit;True;Property;_OcclusionMap;Occlusion Map;8;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;233;1930.894,1703.946;Inherit;False;EmissionColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;239;1866.778,630.0734;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;234;1620.492,1188.54;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;214;1800.198,1943.207;Inherit;False;433.4464;170.6884;Editor;2;225;223;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;219;1794.255,1195.288;Inherit;False;SpecularColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;218;1504.594,295.9682;Inherit;False;OcclusionMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;243;1864.915,-223.8067;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;245;1884.915,-130.8067;Inherit;False;VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;224;2001.891,679.2376;Inherit;False;SmoothnessValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;249;2479.126,474.5072;Inherit;False;233;EmissionColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;246;1881.915,-47.80669;Inherit;False;DissolveAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;217;1556.792,2029.705;Inherit;False;TangentNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;251;2479.126,567.5072;Inherit;False;244;DissolveEmission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;258;2700.799,913.928;Inherit;False;245;VertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;248;2690.126,416.5072;Inherit;False;217;TangentNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;225;1850.198,1997.895;Inherit;False;Property;_Float2;Float 2;0;1;[HideInInspector];Create;True;0;0;0;True;3;Foldout(Main,true,8);;Space;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;232;1818.242,937.4849;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;255;2561.922,849.3324;Inherit;False;246;DissolveAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;253;2544.922,765.3324;Inherit;False;218;OcclusionMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;254;2498.922,641.3324;Inherit;False;219;SpecularColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;252;2517.172,708.2799;Inherit;False;224;SmoothnessValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;247;2722.126,337.5072;Inherit;False;243;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;240;3104.19,874.4133;Inherit;False;Property;_AdvancedInpector;AdvancedInpector;44;1;[HideInInspector];Create;True;0;0;0;True;2;;DrawSystemProperties;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;223;2057.644,1993.207;Inherit;False;Property;_Float1;Float 1;12;1;[HideInInspector];Create;True;0;0;0;True;2;Space;EndGroup();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;235;1963.243,1011.289;Inherit;False;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;2720.716,989.276;Inherit;False;Constant;_cliptest;clip test;9;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;250;2749.126,509.5072;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;259;2907.176,510.324;Float;False;True;-1;2;;0;0;StandardSpecular;AxisDissolveSpecular;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;False;Opaque;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;True;29;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;213;0;211;0
WireConnection;213;1;212;0
WireConnection;215;0;213;0
WireConnection;228;0;226;0
WireConnection;228;1;236;0
WireConnection;231;0;221;0
WireConnection;231;2;228;0
WireConnection;256;101;242;0
WireConnection;229;1;211;4
WireConnection;229;0;227;4
WireConnection;244;0;256;100
WireConnection;233;0;231;0
WireConnection;239;0;237;0
WireConnection;239;1;229;0
WireConnection;234;0;227;1
WireConnection;234;1;230;0
WireConnection;219;0;234;0
WireConnection;218;0;238;1
WireConnection;243;0;256;102
WireConnection;245;0;256;98
WireConnection;224;0;239;0
WireConnection;246;0;256;0
WireConnection;217;0;220;0
WireConnection;232;0;215;0
WireConnection;235;0;232;3
WireConnection;250;0;249;0
WireConnection;250;1;251;0
WireConnection;259;0;247;0
WireConnection;259;1;248;0
WireConnection;259;2;250;0
WireConnection;259;3;254;0
WireConnection;259;4;252;0
WireConnection;259;5;253;0
WireConnection;259;10;255;0
WireConnection;259;11;258;0
ASEEND*/
//CHKSM=FACC6CD953F37E96700D11D874F00E0948CB551A