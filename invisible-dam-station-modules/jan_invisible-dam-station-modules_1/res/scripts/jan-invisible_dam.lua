local transf = require "transf"
local vec3 = require "vec3"
local modulesutil = require "modulesutil"
local jidutil = {}

--- Determines the desired height of the module based on the selected variant.
-- If the slotId is unknown (nil), i.e. inside the getModelsFn, the variant will be determined from the params.
---@param params table params-object provided by updateFn
---@param slotId integer slotId provided by updateFn
---@return integer
function jidutil.GetHeight(params, slotId) 
	local variants = (slotId ~= nil and params.modules[slotId].variant or params.variant)
	if(variants == nil) then
		-- error-case: default
		return 10
	end
	
	local variant = variants % 3
	if variant==0 then
		return 10
	elseif variant==1 then
		return 12
	else
		return 8
	end
end

--- Counts the number of modules in the provided result-object that are left of the provided coordinates.
---@param result table result-object in which to count modules
---@param coords table coordinates of the module to start counting from
---@return integer
function jidutil.CountNeighboursLeft(result, coords)
	return jidutil.CountNeighbours(0, -1, result, coords)
end

--- Counts the number of modules in the provided result-object that are right of the provided coordinates.
---@param result table result-object in which to count modules
---@param coords table coordinates of the module to start counting from
---@return integer
function jidutil.CountNeighboursRight(result, coords)
	return jidutil.CountNeighbours(0, 1, result, coords)
end

--- Recursively counts neighbouring modules.
---@param acc integer accumulator for the result
---@param direction integer direction in which to count (-1 or +1)
---@param result table result-object in which to count modules
---@param coords table coordinates of the module to count from
---@return integer
function jidutil.CountNeighbours(acc, direction, result, coords)
	local module = result.GetModuleAt(coords[1] + (direction * (acc + 1)), coords[2])
	if module == nil then
		return acc
	else
		return jidutil.CountNeighbours(acc + 1, direction, result, coords)
	end
end

--- Returns the updateFn for use in the station-module.
---@param side string the side of the station (left|right)
---@param entrance string the type of entrance (front|centre|rear)
---@return function
function jidutil.CreateUpdateFn(side, entrance)
	return function(result, transform, tag, slotId, addModuleFn, params)
		local height = jidutil.GetHeight(params, slotId)
		local rightX = 0
		local leftX = 0

		if(side == "left") then
			rightX = 5 * (jidutil.CountNeighboursRight(result, result.GetCoord(slotId)) -1) + 2.5
			if(entrance == nil) then
				addModuleFn("station/rail/era_a/ground.mdl", transf.rotZTransl(math.rad(90), vec3.new(0,0,0)))
			elseif(entrance == "front") then
				addModuleFn("station/rail/era_a/ground_entrance_"..height.."-right.mdl", transf.rotZTransl(math.rad(90), vec3.new(0,0,0)))
			elseif(entrance == "rear") then
				addModuleFn("station/rail/era_a/ground_entrance_"..height.."-left.mdl", transf.rotZTransl(math.rad(90), vec3.new(0,0,0)))
			else
				addModuleFn("station/rail/era_a/ground_entrance_"..height..".mdl", transf.rotZTransl(math.rad(90), vec3.new(0,0,0)))
			end
		else
			leftX = 5 * (jidutil.CountNeighboursLeft(result, result.GetCoord(slotId)) -1) + 2.5
			if(entrance == nil) then
				addModuleFn("station/rail/era_a/ground.mdl", transf.rotZTransl(math.rad(270), vec3.new(0,0,0)))
			elseif(entrance == "front") then
				addModuleFn("station/rail/era_a/ground_entrance_"..height.."-left.mdl", transf.rotZTransl(math.rad(270), vec3.new(0,0,0)))
			elseif(entrance == "rear") then
				addModuleFn("station/rail/era_a/ground_entrance_"..height.."-right.mdl", transf.rotZTransl(math.rad(270), vec3.new(0,0,0)))
			else
				addModuleFn("station/rail/era_a/ground_entrance_"..height..".mdl", transf.rotZTransl(math.rad(270), vec3.new(0,0,0)))
			end
		end

		local faces = {
			{rightX, -20.0, -height, 1.0}, --A
			{rightX,  20.0, -height, 1.0}, --B
			{-leftX,  20.0, -height, 1.0}, --C
			{-leftX, -20.0, -height, 1.0}, --D
		}
		modulesutil.TransformFaces(transform, faces)
		
		table.insert(result.terrainAlignmentLists, { 
			type = "EQUAL", 
			faces = { faces },
			optional = true,
		})
		table.insert(result.groundFaces, {  
			face = faces,
			modes = {
				{ type = "FILL", key = "shared/asphalt_01.gtex.lua" },
				{ type = "STROKE_OUTER", key = "street_border.lua" },
			},
		})
	end
end

--- Returns the getModelFn for use in the station-module.
---@param side string the side of the station (left|right)
---@param entrance string the type of entrance (front|centre|rear)
---@return function
function jidutil.CreateGetModelsFn(side, entrance) 
	return function(params)
		local height = jidutil.GetHeight(params)
		local orientation = 0
		local suffix = ""

		if(side == "left") then
			orientation = 0
			if(entrance == nil) then
				suffix = ""
			elseif(entrance == "front") then
				suffix = "-a"
			elseif(entrance == "rear") then
				suffix = "-c"
			else
				suffix = "-b"
			end
		else 
			orientation = 180
			if(entrance == nil) then
				suffix = ""
			elseif(entrance == "front") then
				suffix = "-c"
			elseif(entrance == "rear") then
				suffix = "-a"
			else
				suffix = "-b"
			end
		end

		return {{ 
				id = "station/rail/era_a/invisible_dam_"..height..suffix..".mdl",
				transf = transf.rotZTransl(math.rad(orientation), vec3.new(0,0,0)),
			}}
	end
end

return jidutil