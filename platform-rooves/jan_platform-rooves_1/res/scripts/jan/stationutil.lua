local transf = require "transf"
local core = require "jan/core"

local stationutil = {}

---Returns the selected variant out of a maximum of maxVariants or 0 if none present.
---@param slotId integer slotId of the slot to find the module for
---@param params table params provided in updateFn()
---@return integer
function stationutil.ResolveVariant(slotId, params, maxVariants)
    local variants = (slotId ~= nil and params.modules[slotId].variant or params.variant)
    if(variants == nil) then
        return 0
    end
    return variants % maxVariants
end

---Returns the moduleId for the specified slotId or nil if not found.
---@param result table result provided in updateFn()
---@param slotId integer slotId of the slot to find the module for
---@return string
function stationutil.FindModuleForSlot(result, slotId)
    for k, v in pairs(result.dependentSlots) do
        if core.Some(v, function(x) return x == slotId end) then
            return k
        end
    end
    return nil
end

---Returns whether the module at specified coords is by lennardo97 from the mod "Station Expansion 1.5" (2081662552).
---@param result table result provided in updateFn()
---@param coords table coords provided in updateFn()
---@return boolean
function stationutil.IsLennardo97Platform(result, coords)
    local parent = result.GetModuleAt(coords[1], coords[2])
    if (parent and parent.metadata and parent.metadata.lennardo97_station) then
        return true
    end
    return false
end

---Returns the era string of the platform at the provided coordinates (e.g. "era_a").
---@param result table result provided in updateFn()
---@param coords table coords provided in updateFn()
---@return string
function stationutil.ResolveEra(result, coords)
    local parent = result.GetModuleAt(coords[1], coords[2])
    if (parent and parent.metadata and parent.metadata.platformtexture) then
        return parent.metadata.platformtexture:match("era_(%a)")
    end
    return true and parent.name:match("_era_(%a)%.module") or "a"
end

---Returns whether the platform at the provided coordinates has an underpass.
---@param result table result provided in updateFn()
---@param coords table coords provided in updateFn()
---@return boolean
function stationutil.HasUnderpass(result, coords)
    local underpasses = {
        "station/rail/modular_station/platform_passenger_stairs_era_a.module",
        "station/rail/modular_station/platform_passenger_stairs_era_b.module",
        "station/rail/modular_station/platform_passenger_stairs_era_c.module"
    }
    local parent = result.GetModuleAt(coords[1], coords[2])
    if parent and core.Some(underpasses, function(x) return x == parent.name end) then
        return true
    end
    return false
end

---Returns whether the platform has a track on the specified side.
---@param result table result provided in updateFn()
---@param coords table coords provided in updateFn()
---@param side integer left=-1, right=1
---@return boolean
function stationutil.HasTrack(result, coords, side)
    local neighbour = result.GetModuleAt(coords[1] + side, coords[2])
    return neighbour and neighbour.metadata and neighbour.metadata.track
end

---Returns whether the next adjacent platform has a roof.
---@param result table result provided in updateFn()
---@param coords table coords provided in updateFn()
---@return boolean
function stationutil.HasRoofNext(result, coords)
    local i = coords[1]
    local j = coords[2]
    if not result.GetRoofAt(i, j - 1) then
        local nextAddonModule = result.GetAddonAt(3, -3, i - 1)
        if not nextAddonModule or nextAddonModule[2] ~= j or not nextAddonModule[1].metadata.has_roof then
            return false
        end
    end
    return true
end

---Returns whether the previous adjacent platform has a roof.
---@param result table result provided in updateFn()
---@param coords table coords provided in updateFn()
---@return boolean
function stationutil.HasRoofPrevious(result, coords)
    local i = coords[1]
    local j = coords[2]
    if not result.GetRoofAt(i, j + 1) then
        local prevAddonModule = result.GetAddonAt(4, -3, i - 1)
        if not prevAddonModule or prevAddonModule[2] ~= j or not prevAddonModule[1].metadata.has_roof then
            return false
        end
    end
    return true
end

---Returns the height of the platform surface above ground.
-- This function checks the parent-module for metadata in case it is a platform by lennardo97 from the mod "Station Expansion 1.5" (2081662552). 
-- Otherwise it returns the vanilla platform height.
---@param result table result provided in updateFn()
---@param coords table coords provided in updateFn()
---@return float
function stationutil.ResolvePlatformHeight(result, coords)
    local parent = result.GetModuleAt(coords[1], coords[2])
    if parent and parent.metadata and parent.metadata.platformlevel then
        return parent.metadata.platformlevel / 100 + 0.53
    end
    return 0.8
end

---Removes platform-assets 
-- Entries in result.models are not being removed; they're beiung replaced by an empty model with same tag and transf.
---@param result table result provided in updateFn()
---@param slotId integer slotId of the module to remove assets from
---@return void
function stationutil.RemoveExistingAssets(result, slotId)
    local assetsToRemove = {
        "street/street_light_eu_a.mdl", 
        "street/street_light_us_a.mdl",
        "street/street_asset_mix/trash_standing_a.mdl",
        "station/rail/asset/era_a_double_chair.mdl", 
        "station/rail/asset/era_a_holder_wall.mdl",
        "station/rail/asset/era_a_perron_pillar.mdl", 
        "station/rail/asset/era_a_perron_number.mdl",
        "station/rail/asset/era_a_station_name.mdl", 
        "station/rail/asset/era_a_small_clock.mdl",
        "station/rail/asset/era_b_sign_nr_l.mdl",
        "station/rail/asset/era_b_sign_nr_r.mdl",
        "station/rail/asset/era_b_trashcan.mdl",
        "station/rail/asset/era_b_name_board.mdl",
        "station/rail/asset/era_b_double_chair.mdl",
        "station/rail/lennardo97_platforms/asset/sign_era_a_name.mdl",
        "station/rail/lennardo97_platforms/asset/sign_era_b_name.mdl",
        "station/rail/lennardo97_platforms/asset/sign_era_c_name.mdl",
        "station/rail/lennardo97_platforms/asset/sign_era_a_number.mdl",
        "station/rail/lennardo97_platforms/asset/sign_era_b_number.mdl",
        "station/rail/lennardo97_platforms/asset/sign_era_c_number.mdl",
    }

    local moduleId = stationutil.FindModuleForSlot(result, slotId)

    result.models = core.Map(result.models, function(x)
        if (x.tag == "__module_" .. moduleId and (core.Some(assetsToRemove, function(a)
            return a == x.id
        end))) then
            return {
                id = "empty.mdl",
                tag = x.tag,
                transf = x.transf
            }
        else
            return x
        end
    end)
end

---Adds pairs of platform-number signs with platformCallback 
---@param result table result provided in updateFn()
---@param slotId table coordinates of the module
---@param tag string
---@param offsetX float x-distance from center of platform 
---@param offsetY float y-distance from center of platform 
---@param offsetZ float z-distance from platform surface
---@return void
function stationutil.AddPlatformNumberSigns(result, coords, tag, offsetX, offsetY, offsetZ)
    local i = coords[1]
    local j = coords[2]
    local platformHeight = stationutil.ResolvePlatformHeight(result, coords)
    
    local leftTrack = stationutil.HasTrack(result, coords, -1)
    local rightTrack = stationutil.HasTrack(result, coords, 1)

    local num1 = #result.models
    result.addPlatformCallback(i, j, function(left, n, station)
        local ns = tostring(n)
        if left and leftTrack then
            result.labelText[num1 + 1] = {ns, ns}
        elseif left then
            result.labelText[num1 + 0] = {ns, ns}
        else
            result.labelText[num1 + 0] = {ns, ns}
        end
    end)

    if(leftTrack) then
        core.Add(result.models, {
            id = "station/rail/asset/era_a_perron_number.mdl",
            tag = tag,
            transf = {-1, 0, 0, 0, -0, -1, 0, 0, 0, 0, 1, 0, (5 * i) - offsetX, (40 * j) + offsetY, platformHeight + offsetZ, 1}
        })
    end
    if(rightTrack) then
        core.Add(result.models, {
            id = "station/rail/asset/era_a_perron_number.mdl",
            tag = tag,
            transf = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, (5 * i) + offsetX, (40 * j) + offsetY, platformHeight + offsetZ, 1}
        })
    end
end

---Adds station-name sign with platformCallback
---@param result table result provided in updateFn()
---@param slotId table coordinates of the module
---@param tag string
---@param offsetX float x-distance from center of platform 
---@param offsetY float y-distance from center of platform 
---@param offsetZ float z-distance from platform surface
---@return void
function stationutil.AddStationNameSign(result, coords, tag, offsetX, offsetY, offsetZ)
    local i = coords[1]
    local j = coords[2]
    local platformHeight = stationutil.ResolvePlatformHeight(result, coords)

    local era = stationutil.ResolveEra(result, coords)
    local models = {
        a = { mdl = "station/rail/asset/era_a_station_name.mdl", scale = { x = 1, y = 1, z = 1 }},
        b = { mdl = "station/rail/asset/era_b_name_board.mdl", scale = { x = 0.7, y = 1, z = 0.7 }},
        c = { mdl = "station/rail/asset/era_a_station_name.mdl", scale = { x = 1, y = 1, z = 1 }}
    }

    local num1 = #result.models
    result.addPlatformCallback(i, j, function(left, n, station)
        local stationS = tostring(station)
        result.labelText[num1 + 0] = {stationS, stationS}
    end)

    core.Add(result.models, {
        id = models[era].mdl,
        tag = tag,
        transf = transf.mul({0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 1, 0, (5 * i) + offsetX, (40 * j) + offsetY, platformHeight + offsetZ, 1}, transf.scale(models[era].scale))
    })
end

---Adds holder for central clock
---@param result table result provided in updateFn()
---@param slotId table coordinates of the module
---@param tag string
---@param offsetX float x-distance from center of platform 
---@param offsetY float y-distance from center of platform 
---@param offsetZ float z-distance from platform surface
---@return void
function stationutil.AddClockHolder(result, coords, tag, offsetX, offsetY, offsetZ)
    local i = coords[1]
    local j = coords[2]
    local platformHeight = stationutil.ResolvePlatformHeight(result, coords)

    core.Add(result.models, {
        id = "station/rail/asset/era_a_holder_wall.mdl",
        tag = tag,
        transf = { -0.8, 0, 0, 0, 0, -0.8, 0, 0, 0, 0, 0.8, 0, (5 * i) + offsetX, (40 * j) + offsetY, platformHeight + offsetZ, 1 },
      })

    core.Add(result.models, {
        id = "station/rail/asset/era_a_holder_wall.mdl",
        tag = tag,
        transf = { 0.8, 0, 0, 0, 0, -0.8, 0, 0, 0, 0, 0.8, 0, (5 * i) + offsetX, (40 * j) + offsetY, platformHeight + offsetZ, 1 },
      })
end

---Adds clock
---@param result table result provided in updateFn()
---@param slotId table coordinates of the module
---@param tag string
---@param offsetX float x-distance from center of platform 
---@param offsetY float y-distance from center of platform 
---@param offsetZ float z-distance from platform surface
---@return void
function stationutil.AddClock(result, coords, tag, offsetX, offsetY, offsetZ)
    local i = coords[1]
    local j = coords[2]
    local platformHeight = stationutil.ResolvePlatformHeight(result, coords)

    core.Add(result.models, {
        id = "station/rail/asset/era_a_small_clock.mdl",
        tag = tag,
        transf = {-0.8, 0, 0, 0, 0, -0.8, 0, 0, 0, 0, 0.8, 0, (5 * i) + offsetX, (40 * j) + offsetY, platformHeight + offsetZ, 1}
    })
end

---Adds a pair of clocks
---@param result table result provided in updateFn()
---@param slotId table coordinates of the module
---@param tag string
---@param offsetX float x-distance from center of platform 
---@param offsetY float y-distance from center of platform 
---@param offsetZ float z-distance from platform surface
---@return void
function stationutil.AddClocks(result, coords, tag, offsetX, offsetY, offsetZ)
    local i = coords[1]
    local j = coords[2]
    local platformHeight = stationutil.ResolvePlatformHeight(result, coords)

    if(stationutil.HasTrack(result, coords, 1)) then
        stationutil.AddClock(result, coords, tag, offsetX, offsetY, offsetZ)
    end

    if(stationutil.HasTrack(result, coords, -1)) then
        stationutil.AddClock(result, coords, tag, -offsetX, offsetY, offsetZ)
    end
end

---Adds trash can
---@param result table result provided in updateFn()
---@param slotId table coordinates of the module
---@param tag string
---@param offsetX float x-distance from center of platform 
---@param offsetY float y-distance from center of platform 
---@param offsetZ float z-distance from platform surface
---@return void
function stationutil.AddTrashCan(result, coords, tag, offsetX, offsetY, offsetZ)
    local i = coords[1]
    local j = coords[2]
    local platformHeight = stationutil.ResolvePlatformHeight(result, coords)

    local era = stationutil.ResolveEra(result, coords)
    local models = {
        a = "street/street_asset_mix/trash_standing_a.mdl",
        b = "station/rail/asset/era_b_trashcan.mdl",
        c = "street/street_asset_mix/trash_standing_a.mdl"
    }

    core.Add(result.models, {
        id = models[era],
        tag = tag,
        transf = {0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 1, 0, (5 * i) + offsetX, (40 * j) + offsetY, platformHeight + offsetZ, 1}
    })
end

---Adds bench
---@param result table result provided in updateFn()
---@param slotId table coordinates of the module
---@param tag string
---@param offsetX float x-distance from center of platform 
---@param offsetY float y-distance from center of platform 
---@param offsetZ float z-distance from platform surface
---@return void
function stationutil.AddBench(result, coords, tag, offsetX, offsetY, offsetZ)
    local i = coords[1]
    local j = coords[2]
    local platformHeight = stationutil.ResolvePlatformHeight(result, coords)

    local era = stationutil.ResolveEra(result, coords)
    local models = {
        a = { mdl = "station/rail/asset/era_a_double_chair.mdl", rot = 0 },
        b = { mdl = "station/rail/asset/era_b_double_chair.mdl", rot = 90 },
        c = { mdl = "station/rail/asset/era_a_double_chair.mdl", rot = 0 }
    }

    core.Add(result.models, {
        id = models[era].mdl,
        tag = tag,
        transf = transf.mul({1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, (5 * i) + offsetX, (40 * j) + offsetY, platformHeight + offsetZ, 1}, transf.rotZ(math.rad(models[era].rot)))
    })
end

---Adds the "Grünau" roof
---@param result table result provided in updateFn()
---@param slotId table coordinates of the module
---@param tag string
---@param offsetX float x-distance from center of platform 
---@param offsetY float y-distance from center of platform 
---@param offsetZ float z-distance from platform surface
---@param roofWidth float width of the roof
---@return void
function stationutil.AddRoofGruenau(result, coords, tag, offsetX, offsetY, offsetZ, roofWidth)
    local i = coords[1]
    local j = coords[2]
    local platformHeight = stationutil.ResolvePlatformHeight(result, coords) - 0.53

    local factor = roofWidth/5

    core.Add(result.models, {
        id = "station/rail/jan/roof_gruenau.mdl",
        tag = tag,
        transf = transf.mul({1, 0, 0, 0, -0, 1, 0, 0, 0, 0, 1, 0, (5 * i) + offsetX, (40 * j) + offsetY, platformHeight + offsetZ, 1}, transf.scale({x=factor, y=1, z=1}))
    })

    if not stationutil.HasRoofNext(result, coords) then
        core.Add(result.models, {
            id = "station/rail/jan/roof_gruenau_end.mdl",
            tag = tag,
            transf = transf.mul({-1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, (5 * i) + offsetX, (40 * j) + offsetY, platformHeight + offsetZ, 1}, transf.scale({x=factor, y=1, z=1}))
        })
    end

    if not stationutil.HasRoofPrevious(result, coords) then
        core.Add(result.models, {
            id = "station/rail/jan/roof_gruenau_end.mdl",
            tag = tag,
            transf = transf.mul({1, 0, 0, 0, -0, 1, 0, 0, 0, 0, 1, 0, (5 * i) + offsetX, (40 * j) + offsetY, platformHeight + offsetZ, 1}, transf.scale({x=factor, y=1, z=1}))
        })
    end
end

---Adds the "Schöneweide" roof
---@param result table result provided in updateFn()
---@param slotId table coordinates of the module
---@param tag string
---@param offsetX float x-distance from center of platform 
---@param offsetY float y-distance from center of platform 
---@param offsetZ float z-distance from platform surface
---@param roofWidth float width of the roof
---@return void
function stationutil.AddRoofSchoeneweide(result, coords, tag, offsetX, offsetY, offsetZ, roofWidth)
    local i = coords[1]
    local j = coords[2]
    local platformHeight = stationutil.ResolvePlatformHeight(result, coords) - 0.53

    core.Add(result.models, {
        id = "station/rail/jan/roof_schoeneweide_"..roofWidth..".mdl",
        tag = tag,
        transf = {1, 0, 0, 0, -0, 1, 0, 0, 0, 0, 1, 0, (5 * i) + offsetX, (40 * j) + offsetY, platformHeight + offsetZ, 1}
    })

    if not stationutil.HasRoofNext(result, coords) then
        core.Add(result.models, {
            id = "station/rail/jan/roof_schoeneweide_"..roofWidth.."_end.mdl",
            tag = tag,
            transf = {-1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, (5 * i) + offsetX, (40 * j) + offsetY, platformHeight + offsetZ, 1}
        })
    end

    if not stationutil.HasRoofPrevious(result, coords) then
        core.Add(result.models, {
            id = "station/rail/jan/roof_schoeneweide_"..roofWidth.."_end.mdl",
            tag = tag,
            transf = {1, 0, 0, 0, -0, 1, 0, 0, 0, 0, 1, 0, (5 * i) + offsetX, (40 * j) + offsetY, platformHeight + offsetZ, 1}
        })
    end
end

return stationutil
