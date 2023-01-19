// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AxisDissolveMetallic"
{
	Properties
	{
		[HideInInspector][Foldout(Main,true,8)][Space]_EditorStart1("Editor Start", Float) = 0
		[Header(Main)][NoScaleOffset][SingleLineTexture][Space]_MainTex("Albedo", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		[NoScaleOffset][SingleLineTexture]_MetallicTexture("Metallic Texture", 2D) = "white" {}
		_MetallicValue("Metallic Value", Range( 0 , 1)) = 0
		_Glossiness("Smoothness Value", Range( 0 , 1)) = 0
		[KeywordEnum(AlbedoAlpha,MetallicAlpha)] _GlossSource("Source", Float) = 1
		[NoScaleOffset][Normal][SingleLineTexture]_BumpMap("Normal Texture", 2D) = "bump" {}
		[NoScaleOffset][SingleLineTexture]_OcclusionMap1("Occlusion Map", 2D) = "white" {}
		[Toggle]_UseEmission("UseEmission", Float) = 0
		[HideInInspector]_clipmask("clip mask", Float) = 0.5
		[NoScaleOffset][SingleLineTexture]_EmissionMap("Emission Texture", 2D) = "white" {}
		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0,0)
		[HideInInspector][Space][EndGroup()]_EditorEnd1("Editor End", Float) = 0
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
			float3 worldPos;
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform float _AdvancedInpector;
		uniform float _EditorEnd1;
		uniform float _EditorStart1;
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
		uniform sampler2D _MetallicTexture;
		uniform float _MetallicValue;
		uniform float _Glossiness;
		uniform sampler2D _OcclusionMap1;
		uniform float _clipmask;


		inline float4 TriplanarSampling16_g32( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
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


		inline float4 TriplanarSampling62_g32( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
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


		inline float4 TriplanarSampling61_g32( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
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
			float2 uv_TexCoord76_g32 = v.texcoord.xy * temp_cast_0 + temp_cast_1;
			float4 tex2DNode78_g32 = tex2Dlod( _DisplacementGuide, float4( uv_TexCoord76_g32, 0, 0.0) );
			float DissolveAmount13_g32 = _DissolveAmount;
			#ifdef _2SIDESSECONDEDGE_ON
				float staticSwitch34_g32 = ( _SecondEdgeWidth / 2.0 );
			#else
				float staticSwitch34_g32 = 0.0;
			#endif
			float3 ase_vertex3Pos = v.vertex.xyz;
			#if defined(_AXIS_X)
				float staticSwitch23_g32 = ase_vertex3Pos.x;
			#elif defined(_AXIS_Y)
				float staticSwitch23_g32 = ase_vertex3Pos.y;
			#elif defined(_AXIS_Z)
				float staticSwitch23_g32 = ase_vertex3Pos.z;
			#else
				float staticSwitch23_g32 = ase_vertex3Pos.y;
			#endif
			float2 temp_cast_2 = (_GuideTilling).xx;
			float temp_output_3_0_g32 = ( _Time.y * _GuideTillingSpeed );
			float2 temp_cast_3 = (temp_output_3_0_g32).xx;
			float2 uv_TexCoord6_g32 = v.texcoord.xy * temp_cast_2 + temp_cast_3;
			float2 temp_cast_4 = (_GuideTilling).xx;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float3 ase_vertexNormal = v.normal.xyz;
			float4 triplanar16_g32 = TriplanarSampling16_g32( _GuideTexture, ( ase_vertex3Pos + temp_output_3_0_g32 ), ase_vertexNormal, 1.0, temp_cast_4, 1.0, 0 );
			#ifdef _USETRIPLANARUVS_ON
				float staticSwitch17_g32 = triplanar16_g32.x;
			#else
				float staticSwitch17_g32 = tex2Dlod( _GuideTexture, float4( uv_TexCoord6_g32, 0, 0.0) ).r;
			#endif
			float temp_output_33_0_g32 = ( ( staticSwitch17_g32 * _GuideStrength ) + staticSwitch23_g32 );
			#ifdef _GUIDEAFFECTSEDGESBLENDING_ON
				float staticSwitch37_g32 = temp_output_33_0_g32;
			#else
				float staticSwitch37_g32 = staticSwitch23_g32;
			#endif
			float2 appendResult12_g32 = (float2(_MinValueWhenAmount0 , _MaxValueWhenAmount1));
			float2 appendResult14_g32 = (float2(_MaxValueWhenAmount1 , _MinValueWhenAmount0));
			#ifdef _INVERTDIRECTIONMINMAX_ON
				float2 staticSwitch19_g32 = appendResult14_g32;
			#else
				float2 staticSwitch19_g32 = appendResult12_g32;
			#endif
			float2 break24_g32 = staticSwitch19_g32;
			float DissolvelerpA29_g32 = break24_g32.x;
			float temp_output_1_0_g34 = DissolvelerpA29_g32;
			float DissolvelerpB31_g32 = break24_g32.y;
			float temp_output_43_0_g32 = ( ( staticSwitch37_g32 - temp_output_1_0_g34 ) / ( DissolvelerpB31_g32 - temp_output_1_0_g34 ) );
			float DissolveWithEdges32_g32 = ( DissolveAmount13_g32 + _MainEdgeWidth );
			float EdgesAlpha75_g32 = ( step( ( DissolveAmount13_g32 + staticSwitch34_g32 ) , temp_output_43_0_g32 ) - step( ( DissolveWithEdges32_g32 + staticSwitch34_g32 ) , temp_output_43_0_g32 ) );
			float lerpResult91_g32 = lerp( ( _VertexDisplacementSecondEdge * tex2DNode78_g32.r ) , ( tex2DNode78_g32.r * _VertexDisplacementMainEdge ) , EdgesAlpha75_g32);
			float temp_output_1_0_g33 = DissolvelerpA29_g32;
			float temp_output_47_0_g32 = ( ( temp_output_33_0_g32 - temp_output_1_0_g33 ) / ( DissolvelerpB31_g32 - temp_output_1_0_g33 ) );
			float temp_output_54_0_g32 = step( DissolveAmount13_g32 , temp_output_47_0_g32 );
			float smoothstepResult73_g32 = smoothstep( 0.0 , 0.06 , ( temp_output_54_0_g32 - step( ( DissolveAmount13_g32 + ( _MainEdgeWidth + _SecondEdgeWidth ) ) , temp_output_47_0_g32 ) ));
			float EdgeTexBlendAlpha83_g32 = smoothstepResult73_g32;
			float lerpResult92_g32 = lerp( 0.0 , lerpResult91_g32 , EdgeTexBlendAlpha83_g32);
			float3 VertexOffset252 = ( lerpResult92_g32 * ase_vertexNormal );
			v.vertex.xyz += VertexOffset252;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_BumpMap274 = i.uv_texcoord;
			float3 TangentNormal264 = UnpackNormal( tex2D( _BumpMap, uv_BumpMap274 ) );
			o.Normal = TangentNormal264;
			float2 uv_MainTex255 = i.uv_texcoord;
			float4 tex2DNode255 = tex2D( _MainTex, uv_MainTex255 );
			float4 AlbedoColor259 = ( tex2DNode255 * _Color );
			float4 temp_output_101_0_g32 = AlbedoColor259;
			float DissolveAmount13_g32 = _DissolveAmount;
			float2 temp_cast_0 = (_GuideTilling).xx;
			float temp_output_3_0_g32 = ( _Time.y * _GuideTillingSpeed );
			float2 temp_cast_1 = (temp_output_3_0_g32).xx;
			float2 uv_TexCoord6_g32 = i.uv_texcoord * temp_cast_0 + temp_cast_1;
			float2 temp_cast_2 = (_GuideTilling).xx;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			ase_vertexNormal = normalize( ase_vertexNormal );
			float4 triplanar16_g32 = TriplanarSampling16_g32( _GuideTexture, ( ase_vertex3Pos + temp_output_3_0_g32 ), ase_vertexNormal, 1.0, temp_cast_2, 1.0, 0 );
			#ifdef _USETRIPLANARUVS_ON
				float staticSwitch17_g32 = triplanar16_g32.x;
			#else
				float staticSwitch17_g32 = tex2D( _GuideTexture, uv_TexCoord6_g32 ).r;
			#endif
			#if defined(_AXIS_X)
				float staticSwitch23_g32 = ase_vertex3Pos.x;
			#elif defined(_AXIS_Y)
				float staticSwitch23_g32 = ase_vertex3Pos.y;
			#elif defined(_AXIS_Z)
				float staticSwitch23_g32 = ase_vertex3Pos.z;
			#else
				float staticSwitch23_g32 = ase_vertex3Pos.y;
			#endif
			float temp_output_33_0_g32 = ( ( staticSwitch17_g32 * _GuideStrength ) + staticSwitch23_g32 );
			float2 appendResult12_g32 = (float2(_MinValueWhenAmount0 , _MaxValueWhenAmount1));
			float2 appendResult14_g32 = (float2(_MaxValueWhenAmount1 , _MinValueWhenAmount0));
			#ifdef _INVERTDIRECTIONMINMAX_ON
				float2 staticSwitch19_g32 = appendResult14_g32;
			#else
				float2 staticSwitch19_g32 = appendResult12_g32;
			#endif
			float2 break24_g32 = staticSwitch19_g32;
			float DissolvelerpA29_g32 = break24_g32.x;
			float temp_output_1_0_g33 = DissolvelerpA29_g32;
			float DissolvelerpB31_g32 = break24_g32.y;
			float temp_output_47_0_g32 = ( ( temp_output_33_0_g32 - temp_output_1_0_g33 ) / ( DissolvelerpB31_g32 - temp_output_1_0_g33 ) );
			float temp_output_54_0_g32 = step( DissolveAmount13_g32 , temp_output_47_0_g32 );
			float smoothstepResult73_g32 = smoothstep( 0.0 , 0.06 , ( temp_output_54_0_g32 - step( ( DissolveAmount13_g32 + ( _MainEdgeWidth + _SecondEdgeWidth ) ) , temp_output_47_0_g32 ) ));
			float EdgeTexBlendAlpha83_g32 = smoothstepResult73_g32;
			float4 lerpResult103_g32 = lerp( temp_output_101_0_g32 , float4( 0,0,0,1 ) , EdgeTexBlendAlpha83_g32);
			float2 temp_cast_3 = (_SecondEdgePatternTilling).xx;
			float2 uv_TexCoord53_g32 = i.uv_texcoord * temp_cast_3;
			float2 temp_cast_4 = (_SecondEdgePatternTilling).xx;
			float4 triplanar62_g32 = TriplanarSampling62_g32( _SecondEdgePattern, ase_vertex3Pos, ase_vertexNormal, 1.0, temp_cast_4, 1.0, 0 );
			#ifdef _USETRIPLANARUVS_ON
				float staticSwitch71_g32 = triplanar62_g32.x;
			#else
				float staticSwitch71_g32 = tex2D( _SecondEdgePattern, uv_TexCoord53_g32 ).r;
			#endif
			float4 lerpResult79_g32 = lerp( _SecondEdgeColor1 , _SecondEdgeColor2 , staticSwitch71_g32);
			float2 temp_cast_5 = (_MainEdgePatternTilling).xx;
			float2 uv_TexCoord50_g32 = i.uv_texcoord * temp_cast_5;
			float2 temp_cast_6 = (_MainEdgePatternTilling).xx;
			float4 triplanar61_g32 = TriplanarSampling61_g32( _MainEdgePattern, ase_vertex3Pos, ase_vertexNormal, 1.0, temp_cast_6, 1.0, 0 );
			#ifdef _USETRIPLANARUVS_ON
				float staticSwitch67_g32 = triplanar61_g32.x;
			#else
				float staticSwitch67_g32 = tex2D( _MainEdgePattern, uv_TexCoord50_g32 ).r;
			#endif
			float4 lerpResult82_g32 = lerp( _MainEdgeColor1 , _MainEdgeColor2 , staticSwitch67_g32);
			#ifdef _2SIDESSECONDEDGE_ON
				float staticSwitch34_g32 = ( _SecondEdgeWidth / 2.0 );
			#else
				float staticSwitch34_g32 = 0.0;
			#endif
			#ifdef _GUIDEAFFECTSEDGESBLENDING_ON
				float staticSwitch37_g32 = temp_output_33_0_g32;
			#else
				float staticSwitch37_g32 = staticSwitch23_g32;
			#endif
			float temp_output_1_0_g34 = DissolvelerpA29_g32;
			float temp_output_43_0_g32 = ( ( staticSwitch37_g32 - temp_output_1_0_g34 ) / ( DissolvelerpB31_g32 - temp_output_1_0_g34 ) );
			float DissolveWithEdges32_g32 = ( DissolveAmount13_g32 + _MainEdgeWidth );
			float EdgesAlpha75_g32 = ( step( ( DissolveAmount13_g32 + staticSwitch34_g32 ) , temp_output_43_0_g32 ) - step( ( DissolveWithEdges32_g32 + staticSwitch34_g32 ) , temp_output_43_0_g32 ) );
			float4 lerpResult85_g32 = lerp( lerpResult79_g32 , lerpResult82_g32 , EdgesAlpha75_g32);
			float4 lerpResult89_g32 = lerp( float4( 0,0,0,0 ) , lerpResult85_g32 , EdgeTexBlendAlpha83_g32);
			float4 EmissionColor109_g32 = lerpResult89_g32;
			float4 lerpResult106_g32 = lerp( temp_output_101_0_g32 , EmissionColor109_g32 , EdgeTexBlendAlpha83_g32);
			#if defined(_EDGESAFFECT_ALBEDO)
				float4 staticSwitch99_g32 = lerpResult106_g32;
			#elif defined(_EDGESAFFECT_EMISSION)
				float4 staticSwitch99_g32 = lerpResult103_g32;
			#else
				float4 staticSwitch99_g32 = lerpResult103_g32;
			#endif
			float4 Albedo213 = staticSwitch99_g32;
			o.Albedo = Albedo213.rgb;
			float2 uv_EmissionMap270 = i.uv_texcoord;
			float4 EmissionColor272 = ( _UseEmission == 1.0 ? ( tex2D( _EmissionMap, uv_EmissionMap270 ) * _EmissionColor ) : float4( 0,0,0,0 ) );
			float4 DissolveEmission238 = EmissionColor109_g32;
			o.Emission = ( EmissionColor272 + DissolveEmission238 ).rgb;
			float2 uv_MetallicTexture267 = i.uv_texcoord;
			float4 tex2DNode267 = tex2D( _MetallicTexture, uv_MetallicTexture267 );
			float MetallicValue261 = ( tex2DNode267.r * _MetallicValue );
			o.Metallic = MetallicValue261;
			#if defined(_GLOSSSOURCE_ALBEDOALPHA)
				float staticSwitch282 = tex2DNode255.a;
			#elif defined(_GLOSSSOURCE_METALLICALPHA)
				float staticSwitch282 = tex2DNode267.a;
			#else
				float staticSwitch282 = tex2DNode267.a;
			#endif
			float SmoothnessValue283 = ( _Glossiness * staticSwitch282 );
			o.Smoothness = SmoothnessValue283;
			float2 uv_OcclusionMap1275 = i.uv_texcoord;
			float OcclusionMap277 = tex2D( _OcclusionMap1, uv_OcclusionMap1275 ).r;
			o.Occlusion = OcclusionMap277;
			o.Alpha = 1;
			float FinalAlpha96_g32 = temp_output_54_0_g32;
			float DissolveAlpha214 = FinalAlpha96_g32;
			clip( DissolveAlpha214 - _clipmask );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows vertex:vertexDataFunc 

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
200;73;1694;655;585.584;206.4005;1.083006;True;False
Node;AmplifyShaderEditor.CommentaryNode;254;-489.8708,591.688;Inherit;False;1242.73;2053.751;;25;283;282;280;279;278;277;275;274;273;272;271;270;269;268;267;265;264;263;262;261;259;258;257;256;255;Standard Metallic Inputs;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;256;-409.2598,1264.173;Inherit;False;Property;_Color;Color;2;0;Create;True;0;0;0;True;0;False;1,1,1,1;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;255;-439.8708,1072.75;Inherit;True;Property;_MainTex;Albedo;1;3;[Header];[NoScaleOffset];[SingleLineTexture];Create;False;1;Main;0;0;True;1;Space;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;257;-124.8608,1245.654;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;259;51.11617,1242.577;Inherit;False;AlbedoColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;209;-166.077,-51.38562;Inherit;False;955;416;;5;252;238;214;213;211;Dissolve Function;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;273;-325.1897,2166.84;Inherit;False;Property;_EmissionColor;Emission Color;11;1;[HDR];Create;True;0;0;0;True;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;270;-370.6808,1975.406;Inherit;True;Property;_EmissionMap;Emission Texture;10;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;278;17.35725,1979.915;Inherit;False;Property;_UseEmission;UseEmission;9;1;[Toggle];Create;True;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;263;-59.01677,2109.825;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;267;-372.1238,1521.669;Inherit;True;Property;_MetallicTexture;Metallic Texture;3;2;[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;211;-67.33564,43.44286;Inherit;False;259;AlbedoColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;282;-15.29082,1080.267;Inherit;False;Property;_GlossSource;Source;6;0;Create;False;0;0;0;True;0;False;1;1;1;True;;KeywordEnum;2;AlbedoAlpha;MetallicAlpha;Create;False;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;265;3.869215,960.5977;Inherit;False;Property;_Glossiness;Smoothness Value;5;0;Create;False;0;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;280;-173.4569,1768.125;Inherit;False;Property;_MetallicValue;Metallic Value;4;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;262;174.8942,2056.829;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;1;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;288;144.2479,85.27469;Inherit;False;AxisDissolve;13;;32;c7e8d1367c6e85c468a8796d0ba1e1a6;0;1;101;COLOR;1,1,1,1;False;4;COLOR;100;COLOR;102;FLOAT3;98;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;238;536.923,-1.38562;Inherit;False;DissolveEmission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;275;-363.4748,641.688;Inherit;True;Property;_OcclusionMap1;Occlusion Map;8;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;274;-344.9468,2385.52;Inherit;True;Property;_BumpMap;Normal Texture;7;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;False;0;0;0;True;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;268;298.4482,1011.929;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;272;362.5653,2085.802;Inherit;False;EmissionColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;279;123.8132,1653.343;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;264;-11.53679,2411.561;Inherit;False;TangentNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;258;231.8682,2325.064;Inherit;False;433.4464;170.6884;Editor;2;276;266;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;261;195.6702,1532.221;Inherit;False;MetallicValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;283;433.5612,1061.093;Inherit;False;SmoothnessValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;242;1159.134,770.9283;Inherit;False;272;EmissionColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;252;564.923,165.6144;Inherit;False;VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;251;1159.134,863.9283;Inherit;False;238;DissolveEmission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;214;561.923,248.6144;Inherit;False;DissolveAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;213;544.923,78.61438;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;277;-63.73576,677.8239;Inherit;False;OcclusionMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;240;1219.93,933.7535;Inherit;False;261;MetallicValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;271;249.9131,1319.34;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;239;1383.784,638.9327;Inherit;False;213;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;276;281.8683,2379.752;Inherit;False;Property;_EditorStart1;Editor Start;0;1;[HideInInspector];Create;True;0;0;0;True;3;Foldout(Main,true,8);;Space;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;246;1370.134,712.9283;Inherit;False;264;TangentNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;247;1429.134,805.9283;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;266;489.3142,2375.064;Inherit;False;Property;_EditorEnd1;Editor End;12;1;[HideInInspector];Create;True;0;0;0;True;2;Space;EndGroup();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;241;1704.57,1328.804;Inherit;False;Property;_AdvancedInpector;AdvancedInpector;44;1;[HideInInspector];Create;True;0;0;0;True;2;;DrawSystemProperties;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;248;1169.487,1237.828;Inherit;False;Constant;_clipmask;clip mask;9;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;253;1311.053,1302.798;Inherit;False;252;VertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;225;1242.93,1145.753;Inherit;False;214;DissolveAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;223;1222.93,1049.753;Inherit;False;277;OcclusionMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;243;1195.18,992.701;Inherit;False;283;SmoothnessValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;269;394.9132,1393.145;Inherit;False;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;284;1577.988,788.1439;Float;False;True;-1;2;;0;0;Standard;AxisDissolveMetallic;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;True;248;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;257;0;255;0
WireConnection;257;1;256;0
WireConnection;259;0;257;0
WireConnection;263;0;270;0
WireConnection;263;1;273;0
WireConnection;282;1;255;4
WireConnection;282;0;267;4
WireConnection;262;0;278;0
WireConnection;262;2;263;0
WireConnection;288;101;211;0
WireConnection;238;0;288;100
WireConnection;268;0;265;0
WireConnection;268;1;282;0
WireConnection;272;0;262;0
WireConnection;279;0;267;1
WireConnection;279;1;280;0
WireConnection;264;0;274;0
WireConnection;261;0;279;0
WireConnection;283;0;268;0
WireConnection;252;0;288;98
WireConnection;214;0;288;0
WireConnection;213;0;288;102
WireConnection;277;0;275;1
WireConnection;271;0;259;0
WireConnection;247;0;242;0
WireConnection;247;1;251;0
WireConnection;269;0;271;3
WireConnection;284;0;239;0
WireConnection;284;1;246;0
WireConnection;284;2;247;0
WireConnection;284;3;240;0
WireConnection;284;4;243;0
WireConnection;284;5;223;0
WireConnection;284;10;225;0
WireConnection;284;11;253;0
ASEEND*/
//CHKSM=00352FB64CF239BCC7B8687486441A7AC85DC21C