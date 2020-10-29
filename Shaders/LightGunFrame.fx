/* LightGun Frame PS, version 0.0.1
by Jacob Max Fober
*/

#include "ReShade.fxh"
#include "ReShadeUI.fxh"

  ////////////
 /// MENU ///
////////////

uniform int threshold < __UNIFORM_SLIDER_INT1
	ui_label = "Border scale (%)";
	ui_tooltip = "White borders scale in screen percentage";
	ui_min = 0; ui_max = 20;
> = 2;

  /////////////////
 /// FUNCTIONS ///
/////////////////

// Pixel-wide step function by JMF
float linearstep(float edge, float x)
{
	x -= edge;
	return clamp(x/fwidth(x), 0.0, 1.0);
}

  //////////////
 /// SHADER ///
//////////////

void LightGunBorderPS(float4 pos : SV_Position, float2 texCoord : TEXCOORD, out float3 color : SV_Target)
{
	// Panorama/portrait aspect ratio compensation
	float2 aspectRatio = float2(BUFFER_ASPECT_RATIO, 1.0/BUFFER_ASPECT_RATIO);
	aspectRatio = max(aspectRatio, 1.0);

	// Denominator for pixel linear step
	float2 pixelSize = BUFFER_PIXEL_SIZE*2.0;
	pixelSize *= aspectRatio;

	float2 border = 1.0-abs(texCoord*2.0-1.0);
	border *= aspectRatio;
	border -= threshold*0.01; // Convert percent to value

	// Perform pixel-wide step function
	border = clamp(border/pixelSize, 0.0, 1.0);

	color = lerp(
		1.0, // White border
		tex2D(ReShade::BackBuffer, texCoord).rgb, // Background
		min(border.x, border.y) // Border mask
	);
}

  //////////////
 /// OUTPUT ///
//////////////

technique LightGunFrame
<
	ui_label = "LightGun frame";
	ui_tooltip = "Experimental";
>
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = LightGunBorderPS;
	}
}
