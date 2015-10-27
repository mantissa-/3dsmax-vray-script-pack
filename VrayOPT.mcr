-- VrayOPT v1.0
-- Developed by Midge Sinnaeve
-- www.themantissa.net
-- Licensed under GPL v2

macroScript VrayOPT
	category:"DAZE"
	toolTip:"Vray Scene Optimizer (VrayOPT) "
	buttonText:"VrayOPT"
	(
		try(DestroyDialog VrayOPT ; cui.UnRegisterDialogBar VrayOPT)catch()
		rollout VrayOPT "Vray Scene Optimizer (VrayOPT)"
		(
			-- UI --
			
			button btn_version "VrayOPT 1.0" pos:[270,5] width:75 height:15 border:false
			
			button btn_add_re "Add Render Elements (Sample Rate & Passes)" pos:[5,25] width:340 height:30 toolTip:""
			
			groupBox grp_aa "Step 1: AA Sampling" pos:[5,60] width:340 height:145
				
				button btn_step_aa "Disable Scene Lights, GI & Materials" pos:[10,80] width:330 height:30 toolTip:""
				
				label lbl_dmc_min "DMC Min:" pos:[15,120] width:60 height:15	
				spinner spn_dmc_min "" pos:[80,120] width:55 height:16 range:[1,10000,1] type:#integer
				label lbl_dmc_max "DMC Max:" pos:[15,140] width:60 height:15
				spinner spn_dmc_max "" pos:[80,140] width:55 height:16 range:[1,10000,8] type:#integer
				
				label lbl_dmc_thresh "Use DMC Sampler Threshold?" pos:[170,120] width:150 height:15
				checkbox chk_dmc_thresh "" pos:[325,120] width:15 height:15 checked:true
				label lbl_color_thresh "Color Threshold:" pos:[170,140] width:100 height:15 enabled:false
				spinner spn_color_thresh "" pos:[275,140] width:60 height:16 range:[0,100,0.01] type:#float enabled:false
				
				button btn_aa_render "RENDER LOCAL" pos:[180,170] width:160 height:30
				button btn_aa_set "SET VALUES" pos:[10,170] width:160 height:30
			
			
			groupBox grp_lights "Step 2: Scene Lights" pos:[5,210] width:340 height:145
				
				button btn_step_lights "Disable GI & Materials / Enable Scene Lights" pos:[10,230] width:330 height:30
				
				label lbl_vrl_subdivs "Scenewide Shadow Subdivs (VrayLights):" pos:[15,270] width:210 height:15
				spinner spn_vrl_subdivs "" pos:[240,270] width:70 height:16 range:[0,1000,8] type:#integer
				label lbl_vrs_subdivs "Scenewide Shadow Subdivs (VraySun):" pos:[15,290] width:210 height:15
				spinner spn_vrs_subdivs "" pos:[240,290] width:70 height:16 range:[0,1000,8] type:#integer
				checkButton ckb_lock_lights "L" pos:[315,270] width:20 height:35 toolTip:"Lock Lighting Subdivs"
				
				button btn_lights_set "SET VALUES" pos:[10,320] width:160 height:30
				button btn_lights_render "RENDER LOCAL" pos:[180,320] width:160 height:30
			
			groupBox grp_gi "Step 3: Global Illumination" pos:[5,360] width:340 height:170
				
				button btn_step_gi "Disable Materials / Enable Scene Lights & GI" pos:[10,380] width:330 height:30
				
				dropDownList ddl_primary_gi "Primary Bounces:" pos:[15,415] width:155 height:40 enabled:true items:#("Irradiance map", "Photon map", "Brute force", "Light cache")
				dropDownList ddl_secondary_gi "Secondary Bounces:" pos:[180,415] width:155 height:40 items:#("None", "Photon map", "Brute force", "Light cache")
				label lbl_gi_subdivs "GI Subdivs (Only applies if Brute force is selected):" pos:[15,465] width:255 height:15 enabled:false
				spinner spn_gi_subdivs "" pos:[275,465] width:60 height:16 range:[0,5000,8] type:#integer enabled:false
				
				button btn_gi_set "SET VALUES" pos:[10,495] width:160 height:30
				button btn_gi_render "RENDER LOCAL" pos:[180,495] width:160 height:30
			
			groupBox grp_materials "Step 4: Material Subdivs" pos:[5,535] width:340 height:195
				
				button btn_step_mats "Enable Materials, Scene Lights & GI" pos:[10,555] width:330 height:30
				
				label lbl_mats_subdivs "Scenewide Material reflection && Refraction Subdivs:" pos:[15,595] width:255 height:15
				spinner spn_mats_subdivs "" pos:[275,595] width:60 height:16 range:[1,1000,8] type:#integer
				label lbl_mats_subdivs_info "(This applies to VrayMtl, VrayCarPaintMtl && VrayFlakesMtl)" pos:[15,620] width:320 height:15
				
				checkbox chk_mats_adaptive "" pos:[15,645] width:15 height:15
				label lbl_mats_adaptive "Use Adaptive Algorithm > Lower Glossines = Higher Subdivs" pos:[35,645] width:300 height:15
				label lbl_mats_adaptive_info "(The maximum amount of samples set is the chosen value)" pos:[35,665] width:300 height:15
				
				button btn_mats_set "SET VALUES" pos:[10,695] width:160 height:30
				button btn_mats_render "RENDER LOCAL" pos:[180,695] width:160 height:30
			
			-- UI States --
			
			on chk_dmc_thresh changed state do (lbl_color_thresh.enabled = not state; spn_color_thresh.enabled = not state)
			on ckb_lock_lights changed state do (lbl_vrs_subdivs.enabled = not state; spn_vrs_subdivs.enabled = not state)
			
			fn bruteForceCheck =
			(
				if ddl_primary_gi.selection == 3 then
				(
					lbl_gi_subdivs.enabled = true; spn_gi_subdivs.enabled = true
				)
				else if ddl_secondary_gi.selection == 3 then
				(
					lbl_gi_subdivs.enabled = true; spn_gi_subdivs.enabled = true
				)
				else
				(
					lbl_gi_subdivs.enabled = false; spn_gi_subdivs.enabled = false
				)
			)
			
			on ddl_primary_gi selected i do bruteForceCheck()
			on ddl_secondary_gi selected i do bruteForceCheck()
			
			-- Functions --
			
			fn addRenderElements =
			(
				if queryBox "Current Render Elements will be DELETED!\nAre you sure?" title:"Warning: Resetting Render Elements" beep: true do
				(
					relist = #(VraySampleRate, VrayRawGlobalIllumination, VrayRawLighting, VrayRawReflection, VrayRawRefraction,VrayGlobalIllumination, VrayLighting, VrayReflection, VrayRefraction, VraySpecular)
					
					re = maxOps.GetCurRenderElementMgr() -- get the current render element manager
					re.removeallrenderelements() -- remove all renderelements
					re.numrenderelements() -- get number of render elements
					
					theManager = maxOps.GetRenderElementMgr #Production
					theManager.numRenderElements()
					for n in relist do
					(
						re.addRenderElement (n elementname:(n as string))
					)
				)
			)
			
			fn stepAA =
			(
				renderSceneDialog.close()
				local vr = renderers.current
				
				vr.options_lights = false
				vr.options_defaultLights = 1
				vr.options_hiddenLights = false
				vr.options_shadows = false
				vr.options_reflectionRefraction = false
				vr.options_maps = false
				vr.options_glossyEffects = false
				vr.gi_on = false
			)
			
			fn stepLights =
			(
				renderSceneDialog.close()
				local vr = renderers.current
				
				vr.options_lights = true
				vr.options_defaultLights = 0
				vr.options_hiddenLights = true
				vr.options_shadows = true
				vr.options_reflectionRefraction = false
				vr.options_maps = false
				vr.options_glossyEffects = false
				vr.gi_on = false
			)
			
			fn stepGI =
			(
				renderSceneDialog.close()
				local vr = renderers.current
				
				vr.options_lights = true
				vr.options_defaultLights = 0
				vr.options_hiddenLights = true
				vr.options_shadows = true
				vr.options_reflectionRefraction = false
				vr.options_maps = false
				vr.options_glossyEffects = false
				vr.gi_on = true
			)
			
			fn stepMats =
			(
				renderSceneDialog.close()
				local vr = renderers.current
				
				vr.options_lights = true
				vr.options_defaultLights = 0
				vr.options_hiddenLights = true
				vr.options_shadows = true
				vr.options_reflectionRefraction = true
				vr.options_maps = true
				vr.options_glossyEffects = true
				vr.gi_on = true
			)
			
			fn setAA =
			(
				renderSceneDialog.close()
				local vr = renderers.current
				
				vr.twoLevel_baseSubdivs = spn_dmc_min.value
				vr.twoLevel_fineSubdivs = spn_dmc_max.value
				
				if chk_dmc_thresh.enabled do
				(
					vr.twoLevel_useDMCSamplerThresh = chk_dmc_thresh.enabled
					vr.twoLevel_threshold = spn_color_thresh.value
				)
				
				pushPrompt ("DMC Min subdivs: " + spn_dmc_min.value as String + "  /  DMC Max subdivs: " + spn_dmc_max.value as String)
			)
			
			fn setLights =
			(
				with undo off with redraw off
				(
					local vlights = getClassInstances VrayLight
					local l_amount = vlights.count
					local l_subdivs = spn_vrl_subdivs.value
					
					local vsuns = getClassInstances VraySun
					local s_amount = vsuns.count
					local s_subdivs = spn_vrs_subdivs.value
							
					for i = 1 to i = l_amount do
					(
						vlights[i].subdivs = l_subdivs
					)
				
					if ckb_lock_lights.state == on then
					(
						for j = 1 to j = s_amount do
						(
							vsuns[j].shadow_subdivs = l_subdivs
						)
						
						pushPrompt (i as String + " VrayLight(s) set to " + l_subdivs as String + " Subdivs  /  " + j as String + " VraySun(s) set to " + l_subdivs as String + " Subdivs")
					)
					else
					(
						for j = 1 to j = s_amount do
						(
							vsuns[j].shadow_subdivs = s_subdivs
						)
						
						pushPrompt (i as String + " VrayLight(s) set to " + l_subdivs as String + " Subdivs  /  " + j as String + " VraySun(s) set to " + s_subdivs as String + " Subdivs")
					)	
				)
			)
			
			fn setGI =
			(
				renderSceneDialog.close()
				local vr = renderers.current
				local gi_subdivs = spn_gi_subdivs.value
				
				vr.gi_primary_type = (ddl_primary_gi.selection - 1)
				vr.gi_secondary_type = (ddl_secondary_gi.selection - 1)
				
				if spn_gi_subdivs.enabled == true then
				(
					vr.dmcgi_subdivs = gi_subdivs
					
					pushPrompt ("Primary GI: " + ddl_primary_gi.selected + "  /  Secondary GI: " + ddl_secondary_gi.selected + "  /  Brute Force GI Subdivs: " + gi_subdivs as String)
				)
				else
				(
					pushPrompt ("Primary GI: " + ddl_primary_gi.selected + "  /  Secondary GI: " + ddl_secondary_gi.selected)
				)
			)
			
			fn setMats =
			(
				local vmtl = getClassInstances VRayMtl
				local vcpmtl = getClassInstances VRayCarPaintMtl
				local vfmtl = getClassInstances VRayFlakesMtl
				
				local vmtl_amount = vmtl.count
				local vcpmtl_amount = vcpmtl.count
				local vfmtl_amount = vfmtl.count
				
				local m_subdivs = spn_mats_subdivs.value
						
				for i = 1 to i = vmtl_amount do
				(
					if chk_mats_adaptive.checked == true then
					(
						if vmtl[i].reflection_glossiness <= 0.75 then vmtl[i].reflection_subdivs =  m_subdivs
						else if vmtl[i].reflection_glossiness < 1.0 then vmtl[i].reflection_subdivs = (m_subdivs * 0.8) as Integer
						else if vmtl[i].reflection_glossiness == 1.0 then vmtl[i].reflection_subdivs =  1
						
						if vmtl[i].refraction_glossiness <= 0.75 then vmtl[i].refraction_subdivs =  m_subdivs
						else if vmtl[i].refraction_glossiness < 1.0 then vmtl[i].refraction_subdivs = (m_subdivs * 0.8) as Integer
						else if vmtl[i].refraction_glossiness == 1.0 then vmtl[i].refraction_subdivs =  1
					)
					else
					(
						vmtl[i].reflection_subdivs =  m_subdivs
						vmtl[i].refraction_subdivs =  m_subdivs
					)
				)
				
				for j = 1 to j = vcpmtl_amount do
				(
					vcpmtl[j].subdivs = m_subdivs
				)
				
				for k = 1 to k = vfmtl_amount do
				(
					vfmtl[k].subdivs = m_subdivs
				)
						
				pushPrompt (i as String + " VrayMtl set to " + m_subdivs as String + " Subdivs  /  " + j as String + " VrayCarPaintMtl set to " + m_subdivs as String + " Subdivs  /  " + k as String + " VrayFlakesMtl set to " + m_subdivs as String + " Subdivs")
			)
			
			-- On Load Funtions --
			
			fn getSceneParams =
			(
				local vr = renderers.current
				spn_dmc_min.value = vr.twoLevel_baseSubdivs
				spn_dmc_max.value = vr.twoLevel_fineSubdivs
				chk_dmc_thresh.enabled = vr.twoLevel_useDMCSamplerThresh
				spn_color_thresh.value = vr.twoLevel_threshold
				
				ddl_primary_gi.selection = (vr.gi_primary_type + 1)
				ddl_secondary_gi.selection = (vr.gi_secondary_type + 1)
				
				if vr.gi_primary_type == 2 then spn_gi_subdivs.value = vr.dmcgi_subdivs
				else if vr.gi_secondary_type == 2 then spn_gi_subdivs.value = vr.dmcgi_subdivs
				
				bruteForceCheck()
			)
			
			-- Buttons --
			
			on btn_version pressed do  messageBox "Vray Scene Optimizer (VrayOPT) 1.0 - 19/02/14\n\nDev by Midge Sinnaeve\nwww.themantissa.net\nmidge@daze.tv\nFree for all use and / or modification.\nIf you modify the script, please mention my name, cheers. :)" title:"About VrayOPT" beep:false
			
			on btn_add_re pressed do addRenderElements()
			
			on btn_step_aa pressed do stepAA()
			on btn_step_lights pressed do stepLights()
			on btn_step_gi pressed do stepGI()
			on btn_step_mats pressed do stepMats()
			
			on btn_aa_set pressed do setAA()
			on btn_lights_set pressed do setLights()
			on btn_gi_set pressed do setGI()
			on btn_mats_set pressed do setMats()
			
			on btn_aa_render pressed do max quick render
			on btn_lights_render pressed do max quick render
			on btn_gi_render pressed do max quick render
			on btn_mats_render pressed do max quick render
		)
		
		if matchPattern ((renderers.current) as string) pattern:"V_Ray_Adv*" then
		(
			CreateDialog VrayOPT 350 735 50 150 style:#(#style_titlebar, #style_sysmenu, #style_toolwindow)
			cui.RegisterDialogBar VrayOPT minSize:[350, 735] maxSize:[-1,10000] style:#(#cui_floatable, #cui_dock_vert, #cui_handles)
			VrayOPT.getSceneParams()
		)
		else
		(
			messageBox "Renderer is not set to Vray Advanced" title:"Wrong Renderer"
		)
	)
