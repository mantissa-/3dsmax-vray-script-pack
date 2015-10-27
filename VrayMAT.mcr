-- VrayMAT 0.1 - 05/03/14
-- Developed by Midge Sinnaeve
-- www.themantissa.net
-- Licensed under GPL v2

macroScript vraymat
category:"DAZE"
toolTip:"Control Vray Materials Scenewide"
buttonText:"VrayMAT"
	(
		rollout vraymat "VrayMAT v0.1" width:270 height:395
		(
			label lbl_version "VrayMAT v0.1" pos:[190,5] width:75 height:15
			
			groupBox grp_maps "Map Settings" pos:[5,20] width:260 height:210
				
				label lbl_maptype "Map Types:" pos:[15,40] width:80 height:15
				label lbl_filter "Filter:" pos:[120,40] width:70 height:15
				label lbl_blur "Blur:" pos:[200,40] width:45 height:15
			
				checkbutton ckb_bitmap "Bitmap" pos:[15,65] width:90 height:20 checked:true
				dropdownList ddl_bitmap "" pos:[118,65] width:70 height:21 items:#("Pyramidal", "Summed Area", "None") selection:1
				spinner spn_bitmap "" pos:[200,65] width:55 height:16 range:[0.01,100,1]
				checkbutton ckb_noise "Noise" pos:[15,90] width:90 height:20 checked:true
				label lbl_nofilter1 "-----------------" pos:[120,90] width:65 height:15
				spinner spn_noise "" pos:[200,90] width:55 height:16 range:[0.01,100,1]
				checkbutton ckb_cell "Cellular" pos:[15,115] width:90 height:20 checked:true
				label lbl_nofilter2 "-----------------" pos:[120,115] width:65 height:15
				spinner spn_cell "" pos:[200,115] width:55 height:16 range:[0.01,100,1]
				checkbutton ckb_checker "Checker" pos:[15,140] width:90 height:20 checked:true
				label lbl_nofilter3 "-----------------" pos:[120,140] width:65 height:15
				spinner spn_checker "" pos:[200,140] width:55 height:16 range:[0.01,100,1]
				checkbutton ckb_smoke "Smoke" pos:[15,165] width:90 height:20 checked:true
				label lbl_nofilter4 "-----------------" pos:[120,165] width:65 height:15
				spinner spn_smoke "" pos:[200,165] width:55 height:16 range:[0.01,100,1]
				
				button btn_mapall "ALL" pos:[15,195] width:45 height:25
				button btn_mapnone "NONE" pos:[60,195] width:45 height:25
				
				checkButton ckb_mapmin "SET MIN" pos:[120,195] width:65 height:25 checked:true
				checkButton ckb_mapall "SET ALL" pos:[190,195] width:65 height:25 checked:false
			
			
			groupBox grp_mats "Materials (Vray Materials)" pos:[5,240] width:260 height:80
			
				label lbl_reflsmp "Scenewide Reflection Subdivs:" pos:[15,265] width:165 height:15
				spinner spn_reflsmp "" pos:[200,265] width:55 height:16 range:[0,1000,8] type:#integer
				label lbl_refrsmp "Scenewide Refraction Subdivs:" pos:[15,285] width:165 height:15
				spinner spn_refrsmp "" pos:[200,285] width:55 height:16 range:[0,1000,8] type:#integer
				
			
			button btn_unify "APPLY" pos:[5,325] width:260 height:35
			progressBar pb_progress "" pos:[5,365] width:260 height:5 color:(color 245 125 10)
			label lbl_progress "" pos:[8,375] width:260 height:15
			
			
			
			
			
			
			-- Interface States --
			
			on btn_mapall pressed do
			(
				ckb_bitmap.checked = true
				ckb_noise.checked = true
				ckb_cell.checked = true
				ckb_checker.checked = true
				ckb_smoke.checked = true
			)
			on btn_mapnone pressed do
			(
				ckb_bitmap.checked = false
				ckb_noise.checked = false
				ckb_cell.checked = false
				ckb_checker.checked = false
				ckb_smoke.checked = false
			)

			on ckb_mapmin changed state do
			(
				if ckb_mapmin.state == on then
				(
					ckb_mapall.state = off
				)
				else if ckb_mapmin.state == off then
				(
					ckb_mapall.state = on
				)
			)
				
			on ckb_mapall changed state do
			(
				if ckb_mapall.state == on then
				(
					ckb_mapmin.state = off
				)
				else if ckb_mapall.state == off then
				(
					ckb_mapmin.state = on
				)
			)
			
			-- Functions --
			
			fn setMaps =
			(
				
			--BITMAPS --
				
				if ckb_bitmap.checked == true then
				(
					local theBitmaps = getClassInstances bitmaptexture
					local amount = theBitmaps.count
					
					for i=1 to i=amount do
					(
						if ckb_mapmin.state == on then
						(
							if theBitmaps[i].coords.blur < spn_bitmap.value then
							(
							theBitmaps[i].coords.blur = spn_bitmap.value
							)
						)
						else if ckb_mapall.state == on then
						(
							theBitmaps[i].coords.blur = spn_bitmap.value
						)
						
						theBitmaps[i].filtering = (ddl_bitmap.selection - 1) --0 is Pyramidal, 1 is Summed Area, 2 is None
						
						pb_progress.color = (color 245 125 10)
						pb_progress.value = (100*i/amount)
						lbl_progress.text = "Processing: Bitmaps (" + (i as string) +  "/" + (amount as string) + ")"
						
					)
				)
				
				-- NOISE --
				
				if ckb_noise.checked == true then
				(
					local theNoisemaps = getClassInstances noise
					local amount = theNoisemaps.count
					
					for i=1 to i=amount do
					(
						if ckb_mapmin.state == on then
						(
							if theNoisemaps[i].coords.blur < spn_noise.value then
							(
							theNoisemaps[i].coords.blur = spn_noise.value
							)
						)
						else if ckb_mapall.state == on then
						(
							theNoisemaps[i].coords.blur = spn_noise.value
						)
						
						pb_progress.color = (color 245 125 10)
						pb_progress.value = (100*i/amount)
						lbl_progress.text = "Processing: Noise Maps (" + (i as string) +  "/" + (amount as string) + ")"
						
					)
					
				-- CELLULAR -
					
				if ckb_cell.checked == true then
				(
					local theCellmaps = getClassInstances cellular
					local amount = theCellmaps.count
					
					for i=1 to i=amount do
					(
						if ckb_mapmin.state == on then
						(
							if theCellmaps[i].coords.blur < spn_cell.value then
							(
							theCellmaps[i].coords.blur = spn_cell.value
							)
						)
						else if ckb_mapall.state == on then
						(
							theCellmaps[i].coords.blur = spn_cell.value
						)
						
						pb_progress.color = (color 245 125 10)
						pb_progress.value = (100*i/amount)
						lbl_progress.text = "Processing: Cellular Maps (" + (i as string) +  "/" + (amount as string) + ")"
						
					)
				)
				
				-- CHECKER --
				
				if ckb_checker.checked == true then
				(
					local theCheckermaps = getClassInstances checker
					local amount = theCheckermaps.count
					
					for i=1 to i=amount do
					(
						if ckb_mapmin.state == on then
						(
							if theCheckermaps[i].coords.blur < spn_checker.value then
							(
							theCheckermaps[i].coords.blur = spn_checker.value
							)
						)
						else if ckb_mapall.state == on then
						(
							theCheckermaps[i].coords.blur = spn_checker.value
						)
						
						pb_progress.color = (color 245 125 10)
						pb_progress.value = (100*i/amount)
						lbl_progress.text = "Processing: Checker Maps (" + (i as string) +  "/" + (amount as string) + ")"
						
					)
				)
				
				-- SMOKE --
				
				if ckb_smoke.checked == true then
				(
					local theSmokemaps = getClassInstances smoke
					local amount = theSmokemaps.count
					
					for i=1 to i=amount do
					(
						if ckb_mapmin.state == on then
						(
							if theSmokemaps[i].coords.blur < spn_smoke.value then
							(
							theSmokemaps[i].coords.blur = spn_smoke.value
							)
						)
						else if ckb_mapall.state == on then
						(
							theSmokemaps[i].coords.blur = spn_smoke.value
						)
						
						pb_progress.color = (color 245 125 10)
						pb_progress.value = (100*i/amount)
						lbl_progress.text = "Processing: Smoke Maps (" + (i as string) +  "/" + (amount as string) + ")"
						
					)
				)
			)			
		)

				
				
			fn setMats =
					(
						local theVM = getClassInstances VRayMtl
						local amount = theVM.count
						
						for i=1 to i=amount do
						(
							theVM[i].reflection_subdivs = spn_reflsmp.value
							theVM[i].refraction_subdivs = spn_refrsmp.value
							
							pb_progress.color = (color 245 125 10)
							pb_progress.value = (100*i/amount)
							lbl_progress.text = "Processing: Vray Materials (" + (i as string) +  "/" + (amount as string) + ")"
						)
					)

		on btn_unify pressed do
			
		(
			SetMaps()
			setMats()
			pb_progress.value = 100
			pb_progress.color = (color 10 245 10)
			lbl_progress.text = "Finished!"
		)
		
	)
		
	createDialog vraymat pos:[100,100]
)
