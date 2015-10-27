-- VrayCAM 0.3 - 05/03/14
-- Developed by Midge Sinnaeve
-- www.themantissa.net
-- Licensed under GPL v2

macroScript VrayCAM
	category:"DAZE"
	toolTip:"Create a Vray Physical Camera from the active view"
	buttonText:"VrayCAM"
(
	with undo off with redraw off
	(
	VRayPhysicalCamera whiteBalance_preset:0 pos:[0,0,0] isSelected:on
		$.targeted = off
		$.whiteBalance_preset = 1
		$.vignetting = off
		$.specify_fov = on
		$.fov = viewport.GetFOV()
		$.specify_fov = off
	)
	macros.run "Lights and Cameras" "Camera_CreateFromView"
	actionMan.executeAction 0 "40068"  -- Views: Camera View
	max vpt camera
)
