﻿Shader "Unlit/ScreenSpaceMatrixEffect"
{
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv     : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv     : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			uint      _screen_width;
			uint      _screen_height;

			sampler2D _white_noise;
			sampler2D _font_texture;
			// -----------------------------------

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv     = v.uv;

				return o;
			}

			//---------------------------------------------------------
			
			float text(float2 coord)
			{
				float2 uv    = fmod(coord.xy, 16.) * 0.0625;
				float2 block = floor(coord.xy/16.);
				       uv    = uv * 0.8 + .1;
			    float  rand  = tex2D(_white_noise, block.xy/float2(512.,512.));
				
				       rand = floor(rand*16.);
				       uv   += float2(rand, rand);

					   uv   *= 0.0625;
					   uv.x  = -uv.x;
			    return tex2D(_font_texture, uv).r;
			}
			//---------------------------------------------------------

			float3 rain(float2 fragCoord)
			{
				fragCoord.x -= fmod(fragCoord.x, 16.);

				float offset = sin(fragCoord.x*15.);
				float speed  = cos(fragCoord.x*3.)*.3 + .7;

				float y = frac(fragCoord.y / _screen_height + _Time.y * speed + offset);
				return float3(.1, 1., .35) / (y*20.);
			}

			//---------------------------------------------------------

			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_font_texture, i.uv);
			       col.xyz = text(i.uv * float2(_screen_width, _screen_height)*0.6)*rain(i.uv * float2(_screen_width, _screen_height)*0.6);
				return col;
			}
			ENDCG
		}
	}
}
