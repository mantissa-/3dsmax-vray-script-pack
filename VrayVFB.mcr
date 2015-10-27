-- VrayVFB 0.1c - 08/10/13
-- Developed by Midge Sinnaeve
-- www.themantissa.net
-- Licensed under GPL v2

macroScript VrayVFB
	category:"DAZE"
	toolTip:"Open Vray Frame Buffer"
	buttonText:"VrayVFB"
(
	vr = renderers.current
	vr.showLastVFB()
)
