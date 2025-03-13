local modulesutil = require "modulesutil"
local constructionutil = require "constructionutil"
local trainstationutil = require "modules/trainstationutil"
local transf = require "transf"
local vec3 = require "vec3"
local paramsutil = require "paramsutil"
local lsmutil = require "lennardo97_stationmoduleutil" --lennardo97_stationmoduleutil: Basis-Funktionen

local vanillaplatformheight = lsmutil.vanillaplatformheight

local lsa = {} --lennardo97_stationassetlist

--SCHILDER:
--Bahnhofsname
function lsa.stationName(textureString, platformheight, roofType)
	local models = {}
	if roofType == "a" or roofType == "b" or roofType == "c" then textureString=roofType end
	local era = lsmutil.getAssetEra(textureString)
	--if era=="dbag" then era="c" end--ÄNDERN FÜR DBAG-DESIGN!
	if roofType == "concourse_classic" then era="a" end
	if roofType == "concourse_modern" then era="c" end
	if roofType == "" then roofType = false end
	
	local offsetZ = 0
	if era=="c" then offsetZ = 2.3 end
	
	if era=="a" then
		models = {
			["station/rail/lennardo97_platforms/asset/sign_era_"..era.."_name.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				3.5000, -0.00000, platformheight+offsetZ, 1.00000 },
			},	
		}
	elseif era=="b" then
		models = {
			["station/rail/lennardo97_platforms/asset/sign_era_"..era.."_name.mdl"] = {
				{ 0.70000, 0.00000, 0.00000, 0.00000,
				0.00000, 0.70000, 0.00000, 0.00000,
				0.00000, 0.00000, 0.70000, 0.00000,
				2.5000, -0.00000, platformheight+offsetZ, 1.00000 },
			},	
		}
	elseif era=="c" and not roofType then
		models = {
			["station/rail/lennardo97_platforms/asset/sign_era_"..era.."_name.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				0.0000, -0.00000, vanillaplatformheight+offsetZ, 1.00000 },
			},
			["station/rail/asset/era_c_perron_pillar.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				0.00000, 0.00000, vanillaplatformheight-0.65, 1.00000 },
			},	
		}
	elseif era=="c" and roofType and not (roofType == "concourse_classic" or roofType == "concourse_modern") then
		models = {
			["station/rail/lennardo97_platforms/asset/sign_era_"..era.."_name.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				0.0000, -0.00000, vanillaplatformheight+offsetZ, 1.00000 },
			},	
		}
	elseif era=="c" and (roofType == "concourse_modern") then
		models = {
			["station/rail/lennardo97_platforms/asset/sign_era_"..era.."_name.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				4.5000, -0.00000, vanillaplatformheight+offsetZ, 1.00000 },
			},
			["station/rail/asset/era_c_perron_pillar.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				4.50000, 0.00000, platformheight-0.65, 1.00000 },
			},	
		}
	end
	
	return models
end

--Nummern
function lsa.stationNumber(textureString, platformheight, roofType, side, bridge)
	local rotate=1
	if side=="right" then rotate=-1 end
	local models = {}
	local offsetZ = 0
	local offsetY = 0
	local offsetX = 0
	local roofStr=""
	if roofType == "a" or roofType == "b" or roofType == "c" then textureString=roofType end
	local era = lsmutil.getAssetEra(textureString)
	if roofType == "concourse_classic" then 
		era="a"
		offsetX=2.5
	end
	if roofType == "concourse_modern" then
		era="c"
		offsetX=2.5
	end
	if bridge then offsetX=2.5 end
	if roofType == "" then roofType = false end
	if roofType=="a" or roofType=="b" or roofType=="c" then roofStr = "_roof" end
	
	if era=="a" then 
		offsetZ = 2.6 
	elseif era=="c" then 
		if roofStr=="_roof" then
			offsetY=0.45 
			offsetZ=2.3-platformheight+vanillaplatformheight
		else
			offsetY=0.45 
			offsetZ=2.3
		end
		roofStr=""
	end
	
	
	models = {
		["station/rail/lennardo97_platforms/asset/sign_era_"..era.."_number"..roofStr..".mdl"] = {
			{ 0.00000, 1*rotate, 0.00000, 0.00000,
			-1*rotate, 0.00000, 0.00000, 0.00000,
			0.00000, 0.00000, 1.00000, 0.00000,
			20.00000+offsetX, offsetY*rotate, platformheight+offsetZ, 1.00000 },
		},
	}
	
	return models
end

--BASIS-ASSETS
function lsa.basics(textureString, platformheight, roofType, special)
	local models = {}
	local offsetX = 0
	local offsetZ = 0
	local offsetY = 0
	if roofType == "a" or roofType == "b" or roofType == "c" then textureString=roofType end
	local era = lsmutil.getAssetEra(textureString)
	if roofType == "concourse_classic" then 
		era="a" 
		offsetX = 2.5
	end
	if roofType == "concourse_modern" then
		era="c"
		offsetX = 2.5
	end
	if special=="bridge" then offsetX = 2.5 end
	if roofType == "" then roofType = false end
	
	if era=="a" and not roofType then
		models = {
			["station/rail/asset/era_a_perron_pillar.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				20.00000+offsetX, 0.00000, platformheight, 1.00000 },
			},
			["street/street_light_eu_a.mdl"]={
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				10.00000, 0.00000, platformheight, 1.00000 },
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				30.00000, 0.00000, platformheight, 1.00000 },
			},
		}
	elseif era=="a" and (roofType=="concourse_classic") then
		models = {
			["station/rail/asset/era_a_perron_pillar.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				20.00000+offsetX, 0.00000, platformheight, 1.00000 },
			},
		}
	elseif era=="b" and not roofType then
		models = {
			["street/street_light_us_a.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 10.00000, 0.00000, platformheight, 1.00000 },
				{ 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 30.00000, 0.00000, platformheight, 1.00000 },
			},		
		}
	elseif era=="c" and (not roofType) then
		models = {
			["asset/lamp_new.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 10.00000, 0.00000, platformheight-2, 1.00000 },
				{ 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 30.00000, 0.00000, platformheight-2, 1.00000 },
				{ -1.00000, 0.00000, 0.00000, 0.00000, 0.00000, -1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 10.00000, 0.00000, platformheight-2, 1.00000 },
				{ -1.00000, 0.00000, 0.00000, 0.00000, 0.00000, -1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 30.00000, 0.00000, platformheight-2, 1.00000 },
			},					
			["station/rail/asset/era_c_perron_pillar.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				20.00000+offsetX, 0.00000, platformheight-0.65, 1.00000 },
			},
		}
	elseif era=="c" and (roofType=="concourse_modern") then
		models = {					
			["station/rail/asset/era_c_perron_pillar.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				20.00000+offsetX, 0.00000, platformheight-0.65, 1.00000 },
			},
		}
	end
	
	if special then --Über/Unterführung
		models = {}
		if era=="a"then
			models = {
				["station/rail/asset/era_a_perron_pillar.mdl"] = {
					{ 1.00000, 0.00000, 0.00000, 0.00000,
					0.00000, 1.00000, 0.00000, 0.00000,
					0.00000, 0.00000, 1.00000, 0.00000,
					20.00000+offsetX, 0.00000, platformheight, 1.00000 },
				},
			}
		elseif era=="c"then
			models = {
				["station/rail/asset/era_c_perron_pillar.mdl"] = {
					{ 1.00000, 0.00000, 0.00000, 0.00000,
					0.00000, 1.00000, 0.00000, 0.00000,
					0.00000, 0.00000, 1.00000, 0.00000,
					20.00000+offsetX, 0.00000, platformheight-0.65, 1.00000 },
				},
			}
		end
	end
	
	return models
end

--UNTERFÜHRUNG
function lsa.underpass(textureString, platformheight, roofType)
	local models = {}
	if roofType == "a" or roofType == "b" or roofType == "c" then textureString=roofType end
	local era = lsmutil.getAssetEra(textureString)
	if roofType == "concourse_classic" then era="a" end
	if roofType == "concourse_modern" then era="c" end
	if roofType == "" then roofType = false end
	local offsetZ = 0
	if era=="c" then offsetZ=2.3 end
	
	if (era=="a") and not roofType then
		models = {
			["station/rail/asset/era_a_small_clock.mdl"] = {
				{ -0.00000, 0.80000, 0.00000, 0.00000,
				-0.80000, -0.00000, -0.00000, 0.00000,
				0.00000, -0.00000, 0.80000, 0.00000,
				20.00000, 0, platformheight+3.4, 1.00000 },
			},
		}
	elseif era=="b" and not roofType then
		local offsetY=2
		models = {
			["station/rail/asset/era_a_small_clock.mdl"] = {
				{ -0.00000, 0.80000, 0.00000, 0.00000,
				-0.80000, -0.00000, -0.00000, 0.00000,
				0.00000, -0.00000, 0.80000, 0.00000,
				10.00000, -0.98800+offsetY, 2.368+platformheight, 1.00000 },
				{ -0.00000, -0.80000, 0.00000, 0.00000,
				0.80000, -0.00000, -0.00000, 0.00000,
				0.00000, -0.00000, 0.80000, 0.00000,
				30.00000, 0.98800-offsetY, 2.368+platformheight, 1.00000 },
			},
			["station/rail/asset/era_a_holder_wall.mdl"] = {
				{ -0.00000, 0.80000, 0.00000, 0.00000,
				-0.80000, -0.00000, -0.00000, 0.00000,
				0.00000, -0.00000, 0.80000, 0.00000,
				10.00000, -1.98000+offsetY, 2.72+platformheight, 1.00000 },
				{ -0.00000, -0.80000, 0.00000, 0.00000,
				0.80000, -0.00000, -0.00000, 0.00000,
				0.00000, -0.00000, 0.80000, 0.00000,
				30.00000, 1.98000-offsetY, 2.72+platformheight, 1.00000 },
			},
		}
	elseif (era=="a" or era=="b") and roofType then
		local offsetY=2
		local deltaY=0
		if roofType == "concourse_classic" or roofType == "concourse_modern" then
			deltaY=0.2
		end
		
		models = {
			["station/rail/asset/era_a_small_clock.mdl"] = {
				{ -0.00000, 0.80000, 0.00000, 0.00000,
				-0.80000, -0.00000, -0.00000, 0.00000,
				0.00000, -0.00000, 0.80000, 0.00000,
				10.00000, -0.98800+offsetY+deltaY, 2.368+platformheight, 1.00000 },
				{ -0.00000, -0.80000, 0.00000, 0.00000,
				0.80000, -0.00000, -0.00000, 0.00000,
				0.00000, -0.00000, 0.80000, 0.00000,
				30.00000, 0.98800-offsetY-deltaY, 2.368+platformheight, 1.00000 },
			},
			["station/rail/asset/era_a_holder_wall.mdl"] = {
				{ -0.00000, 0.80000, 0.00000, 0.00000,
				-0.80000, -0.00000, -0.00000, 0.00000,
				0.00000, -0.00000, 0.80000, 0.00000,
				10.00000, -1.98000+offsetY+deltaY, 2.72+platformheight, 1.00000 },
				{ -0.00000, -0.80000, 0.00000, 0.00000,
				0.80000, -0.00000, -0.00000, 0.00000,
				0.00000, -0.00000, 0.80000, 0.00000,
				30.00000, 1.98000-offsetY-deltaY, 2.72+platformheight, 1.00000 },
			},
			["station/rail/asset/era_a_perron_pillar.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				10.00000, deltaY, platformheight, 1.00000 },
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				30.00000, -deltaY, platformheight, 1.00000 },
			},
		}
	elseif era=="c" then
		local deltaZ = 0
		if roofType then deltaZ = vanillaplatformheight-platformheight+0.5 end
		models = {
			["station/rail/asset/era_c_perron_holder.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 10.00000, 0.00000, platformheight+offsetZ+deltaZ, 1.00000 },
				{ 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 30.00000, 0.00000, platformheight+offsetZ+deltaZ, 1.00000 },
			},
			["station/rail/asset/era_c_perron_pillar.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 10.00000, 0.00000, platformheight-0.65, 1.00000 },
				{ 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 30.00000, 0.00000, platformheight-0.65, 1.00000 },
			},
			["station/rail/asset/era_c_small_clock.mdl"] = {
				{ 0.00000, 1.00000, 0.00000, 0.00000, -1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 29.76500, -1.16000, platformheight+offsetZ+deltaZ, 1.00000 },
				{ 0.00000, 1.00000, 0.00000, 0.00000, -1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 29.76500, 1.16000, platformheight+offsetZ+deltaZ, 1.00000 },
				{ 0.00000, 1.00000, 0.00000, 0.00000, -1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 9.76500, -1.16000, platformheight+offsetZ+deltaZ, 1.00000 },
				{ 0.00000, 1.00000, 0.00000, 0.00000, -1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 9.76500, 1.16000, platformheight+offsetZ+deltaZ, 1.00000 },
			},
			["station/rail/asset/era_c_trashcan.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 5.00000, 0.00000, platformheight, 1.00000 },
				{ 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 35.00000, 0.00000, platformheight, 1.00000 },
			},
		}
	end
	
	return models
end

function lsa.waitingArea(textureString, platformheight, roofType) --für Era A/B/C mit Wartebereich-Modul
	local janRoof = false
	if(roofType == "jan") then 
		janRoof = true 
		roofType = ""
	end

	local era = lsmutil.getAssetEra(textureString)
	local models = {}
	local offsetZ = 0
	if era=="c" then offsetZ=2.3 end
	platformheight=0
	if roofType=="" then roofType = false end
	
	if (era=="a") and not roofType then
		local clockId = "station/rail/asset/era_a_small_clock.mdl"
		if(janRoof) then clockId = "empty.mdl" end

		models = {
			[clockId] = {
				{ -0.00000, 0.80000, 0.00000, 0.00000,
				-0.80000, -0.00000, -0.00000, 0.00000,
				0.00000, -0.00000, 0.80000, 0.00000,
				20.00000, 0, platformheight+3.4, 1.00000 },
			},
			["station/rail/asset/era_a_double_chair.mdl"] = {
				{ 0.00000, 1.00000, 0.00000, 0.00000,
				-1.00000, .00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				8.00000, 0.00000, platformheight, 1.00000 },
				
				{ 0.00000, 1.00000, 0.00000, 0.00000,
				-1.00000, .00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				13.00000, 0.00000, platformheight, 1.00000 },
				
				{ 0.00000, 1.00000, 0.00000, 0.00000,
				-1.00000, .00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				27.00000, 0.00000, platformheight, 1.00000 },
				
				{ 0.00000, 1.00000, 0.00000, 0.00000,
				-1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				32.00000, 0.00000, platformheight, 1.00000 },
			},
			["station/rail/asset/era_a_trashcan.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				11.00000, 0.00000, platformheight, 1.00000 },
				
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				29.00000, 0.00000, platformheight, 1.00000 },
			},
		}
	elseif (era=="a") and roofType then 
		local offsetY = 2
		models = {
			["station/rail/asset/era_a_small_clock.mdl"] = {
				{ -0.00000, 0.80000, 0.00000, 0.00000,
				-0.80000, -0.00000, -0.00000, 0.00000,
				0.00000, -0.00000, 0.80000, 0.00000,
				10.00000, -0.98800+offsetY, 2.368+platformheight, 1.00000 },
				{ -0.00000, -0.80000, 0.00000, 0.00000,
				0.80000, -0.00000, -0.00000, 0.00000,
				0.00000, -0.00000, 0.80000, 0.00000,
				30.00000, 0.98800-offsetY, 2.368+platformheight, 1.00000 },
			},
			["station/rail/asset/era_a_holder_wall.mdl"] = {
				{ -0.00000, 0.80000, 0.00000, 0.00000,
				-0.80000, -0.00000, -0.00000, 0.00000,
				0.00000, -0.00000, 0.80000, 0.00000,
				10.00000, -1.98000+offsetY, 2.72+platformheight, 1.00000 },
				{ -0.00000, -0.80000, 0.00000, 0.00000,
				0.80000, -0.00000, -0.00000, 0.00000,
				0.00000, -0.00000, 0.80000, 0.00000,
				30.00000, 1.98000-offsetY, 2.72+platformheight, 1.00000 },
			},
			["station/rail/asset/era_a_perron_pillar.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				10.00000, 0.00000, platformheight, 1.00000 },
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				30.00000, 0.00000, platformheight, 1.00000 },
			},
			["station/rail/asset/era_a_double_chair.mdl"] = {
				{ 0.00000, 1.00000, 0.00000, 0.00000,
				-1.00000, .00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				8.00000, 0.00000, platformheight, 1.00000 },
				
				{ 0.00000, 1.00000, 0.00000, 0.00000,
				-1.00000, .00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				13.00000, 0.00000, platformheight, 1.00000 },
				
				{ 0.00000, 1.00000, 0.00000, 0.00000,
				-1.00000, .00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				27.00000, 0.00000, platformheight, 1.00000 },
				
				{ 0.00000, 1.00000, 0.00000, 0.00000,
				-1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				32.00000, 0.00000, platformheight, 1.00000 },
			},
			["station/rail/asset/era_a_trashcan.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				11.00000, 0.00000, platformheight, 1.00000 },
				
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				29.00000, 0.00000, platformheight, 1.00000 },
			},
		}
	elseif era=="b" and not roofType then 
		models = {
			["station/rail/asset/era_a_small_clock.mdl"] = {
				{ -0.00000, 0.80000, 0.00000, 0.00000,
				-0.80000, -0.00000, -0.00000, 0.00000,
				0.00000, -0.00000, 0.80000, 0.00000,
				20.00000, 0, platformheight+3.4, 1.00000 },
			},
			["station/rail/asset/era_b_double_chair.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				7.00000, 0.00000, platformheight, 1.00000 },
				
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				14.00000, 0.00000, platformheight, 1.00000 },
				
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				26.00000, 0.00000, platformheight, 1.00000 },
				
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				33.00000, 0.00000, platformheight, 1.00000 },
			},
			["station/rail/asset/era_b_trashcan.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				11.00000, 0.00000, platformheight, 1.00000 },
				
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				29.00000, 0.00000, platformheight, 1.00000 },
			},
		}
	elseif (era=="b") and roofType then 
		local offsetY = 2
		models = {
			["station/rail/asset/era_a_small_clock.mdl"] = {
				{ -0.00000, 0.80000, 0.00000, 0.00000,
				-0.80000, -0.00000, -0.00000, 0.00000,
				0.00000, -0.00000, 0.80000, 0.00000,
				10.00000, -0.98800+offsetY, 2.368+platformheight, 1.00000 },
				{ -0.00000, -0.80000, 0.00000, 0.00000,
				0.80000, -0.00000, -0.00000, 0.00000,
				0.00000, -0.00000, 0.80000, 0.00000,
				30.00000, 0.98800-offsetY, 2.368+platformheight, 1.00000 },
			},
			["station/rail/asset/era_a_holder_wall.mdl"] = {
				{ -0.00000, 0.80000, 0.00000, 0.00000,
				-0.80000, -0.00000, -0.00000, 0.00000,
				0.00000, -0.00000, 0.80000, 0.00000,
				10.00000, -1.98000+offsetY, 2.72+platformheight, 1.00000 },
				{ -0.00000, -0.80000, 0.00000, 0.00000,
				0.80000, -0.00000, -0.00000, 0.00000,
				0.00000, -0.00000, 0.80000, 0.00000,
				30.00000, 1.98000-offsetY, 2.72+platformheight, 1.00000 },
			},
			["station/rail/asset/era_a_perron_pillar.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				10.00000, 0.00000, platformheight, 1.00000 },
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				30.00000, 0.00000, platformheight, 1.00000 },
			},
			["station/rail/asset/era_b_double_chair.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				7.00000, 0.00000, platformheight, 1.00000 },
				
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				14.00000, 0.00000, platformheight, 1.00000 },
				
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				26.00000, 0.00000, platformheight, 1.00000 },
				
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				33.00000, 0.00000, platformheight, 1.00000 },
			},
			["station/rail/asset/era_b_trashcan.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				11.00000, 0.00000, platformheight, 1.00000 },
				
				{ 1.00000, 0.00000, 0.00000, 0.00000,
				0.00000, 1.00000, 0.00000, 0.00000,
				0.00000, 0.00000, 1.00000, 0.00000,
				29.00000, 0.00000, platformheight, 1.00000 },
			},
		}
	elseif era=="c" then
		local deltaZ = 0
		if roofType then deltaZ = vanillaplatformheight-platformheight-0.85 end
		models = {
			["station/rail/asset/era_c_double_chair.mdl"] = {
				{ 0.00000, 1.00000, 0.00000, 0.00000, -1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 7.00000, 0.00000, platformheight, 1.00000 },
				{ 0.00000, 1.00000, 0.00000, 0.00000, -1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 12.00000, 0.00000, platformheight, 1.00000 },
				{ 0.00000, 1.00000, 0.00000, 0.00000, -1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 15.00000, 0.00000, platformheight, 1.00000 },
				{ 0.00000, 1.00000, 0.00000, 0.00000, -1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 25.00000, 0.00000, platformheight, 1.00000 },
				{ 0.00000, 1.00000, 0.00000, 0.00000, -1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 28.00000, 0.00000, platformheight, 1.00000 },
				{ 0.00000, 1.00000, 0.00000, 0.00000, -1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 33.00000, 0.00000, platformheight, 1.00000 },
			},
			["station/rail/asset/era_c_perron_holder.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 10.00000, 0.00000, platformheight+offsetZ+deltaZ, 1.00000 },
				{ 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 30.00000, 0.00000, platformheight+offsetZ+deltaZ, 1.00000 },
			},
			["station/rail/asset/era_c_perron_pillar.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 10.00000, 0.00000, platformheight-0.65, 1.00000 },
				{ 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 30.00000, 0.00000, platformheight-0.65, 1.00000 },
			},
			["station/rail/asset/era_c_small_clock.mdl"] = {
				{ 0.00000, 1.00000, 0.00000, 0.00000, -1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 29.76500, -1.16000, platformheight+offsetZ+deltaZ, 1.00000 },
				{ 0.00000, 1.00000, 0.00000, 0.00000, -1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 29.76500, 1.16000, platformheight+offsetZ+deltaZ, 1.00000 },
				{ 0.00000, 1.00000, 0.00000, 0.00000, -1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 9.76500, -1.16000, platformheight+offsetZ+deltaZ, 1.00000 },
				{ 0.00000, 1.00000, 0.00000, 0.00000, -1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 9.76500, 1.16000, platformheight+offsetZ+deltaZ, 1.00000 },
			},
			["station/rail/asset/era_c_trashcan.mdl"] = {
				{ 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 5.30000, 0.00000, platformheight, 1.00000 },
				{ 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 16.50000, 0.00000, platformheight, 1.00000 },
				{ 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 23.50000, 0.00000, platformheight, 1.00000 },
				{ 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1.00000, 0.00000, 34.70000, 0.00000, platformheight, 1.00000 },
			},
		}
	end
	
	return models
end

return lsa