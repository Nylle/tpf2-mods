local core = require "jan/core"

local stationUtil = {}

---Returns the moduleId for the specified slotId or nil if not found.
---@param result table result provided in updateFn()
---@param slotId integer slotId of the slot to find the module for
---@return string
function stationUtil.FindModuleForSlot(result, slotId)
    for k, v in pairs(result.dependentSlots) do
        if core.Some(v, function(x)
            return x == slotId
        end) then
            return k
        end
    end
    return nil
end

---Returns whether the module at specified coords is by lennardo97 from the mod "Station Expansion 1.5" (2081662552).
---@param result table result provided in updateFn()
---@param coords table coords provided in updateFn()
---@return boolean
function stationUtil.IsLennardo97Platform(result, coords)
    local parent = result.GetModuleAt(coords[1], coords[2])
    if (parent and parent.metadata and parent.metadata.lennardo97_station) then
        return true
    end
    return false
end

---Returns whether the platform at the provided coordinates has an underpass.
---@param result table result provided in updateFn()
---@param coords table coords provided in updateFn()
---@return boolean
function stationUtil.HasUnderpass(result, coords)
    local parent = result.GetModuleAt(coords[1], coords[2])
    if parent and parent.name == "station/rail/modular_station/platform_passenger_stairs_era_a.module" then
        return true
    end
    return false
end

---Returns whether the platform has a track on side.
---@param result table result provided in updateFn()
---@param coords table coords provided in updateFn()
---@param side integer left=-1, right=1
---@return boolean
function stationUtil.HasTrack(result, coords, side)
    local neighbour = result.GetModuleAt(coords[1] + side, coords[2])
    return neighbour and neighbour.metadata and neighbour.metadata.track
end

---Returns the height of the platform surface above ground.
-- This function checks the parent-module for metadata in case it is a platform by lennardo97 from the mod "Station Expansion 1.5" (2081662552). 
-- Otherwise it returns the vanilla platform height.
---@param result table result provided in updateFn()
---@param coords table coords provided in updateFn()
---@return float
function stationUtil.ResolvePlatformHeight(result, coords)
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
function stationUtil.RemoveExistingAssets(result, slotId)
    local assetsToRemove = {"street/street_light_eu_a.mdl", "street/street_asset_mix/trash_standing_a.mdl",
                            "station/rail/asset/era_a_double_chair.mdl", "station/rail/asset/era_a_holder_wall.mdl",
                            "station/rail/asset/era_a_perron_pillar.mdl", "station/rail/asset/era_a_perron_number.mdl",
                            "station/rail/asset/era_a_station_name.mdl", "station/rail/asset/era_a_small_clock.mdl",
                            "station/rail/lennardo97_platforms/asset/sign_era_a_name.mdl",
                            "station/rail/lennardo97_platforms/asset/sign_era_a_number.mdl"}

    local moduleId = stationUtil.FindModuleForSlot(result, slotId)

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
function stationUtil.AddPlatformNumberSigns(result, coords, tag, offsetX, offsetY, offsetZ)
    local i = coords[1]
    local j = coords[2]
    local platformHeight = stationUtil.ResolvePlatformHeight(result, coords)

    local leftTrack = stationUtil.HasTrack(result, coords, -1)
    local rightTrack = stationUtil.HasTrack(result, coords, 1)

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
function stationUtil.AddStationNameSign(result, coords, tag, offsetX, offsetY, offsetZ)
    local i = coords[1]
    local j = coords[2]
    local platformHeight = stationUtil.ResolvePlatformHeight(result, coords)

    local num1 = #result.models
    result.addPlatformCallback(i, j, function(left, n, station)
        local stationS = tostring(station)
        result.labelText[num1 + 0] = {stationS, stationS}
    end)

    core.Add(result.models, {
        id = "station/rail/asset/era_a_station_name.mdl",
        tag = tag,
        transf = {0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 1, 0, (5 * i) + offsetX, (40 * j) + offsetY, platformHeight + offsetZ,
                  1}
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
function stationUtil.AddClock(result, coords, tag, offsetX, offsetY, offsetZ)
    local i = coords[1]
    local j = coords[2]
    local platformHeight = stationUtil.ResolvePlatformHeight(result, coords)

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
function stationUtil.AddClocks(result, coords, tag, offsetX, offsetY, offsetZ)
    local i = coords[1]
    local j = coords[2]
    local platformHeight = stationUtil.ResolvePlatformHeight(result, coords)

    if(stationUtil.HasTrack(result, coords, 1)) then
        core.Add(result.models, {
            id = "station/rail/asset/era_a_small_clock.mdl",
            tag = tag,
            transf = {-0.8, 0, 0, 0, 0, -0.8, 0, 0, 0, 0, 0.8, 0, (5 * i) + offsetX, (40 * j) + offsetY, platformHeight + offsetZ, 1}
        })
    end

    if(stationUtil.HasTrack(result, coords, -1)) then
        core.Add(result.models, {
            id = "station/rail/asset/era_a_small_clock.mdl",
            tag = tag,
            transf = {-0.8, 0, 0, 0, 0, -0.8, 0, 0, 0, 0, 0.8, 0, (5 * i) - offsetX, (40 * j) + offsetY, platformHeight + offsetZ, 1}
        })
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
function stationUtil.AddTrashCan(result, coords, tag, offsetX, offsetY, offsetZ)
    local i = coords[1]
    local j = coords[2]
    local platformHeight = stationUtil.ResolvePlatformHeight(result, coords)

    core.Add(result.models, {
        id = "street/street_asset_mix/trash_standing_a.mdl",
        tag = tag,
        transf = {0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 1, 0, (5 * i) + offsetX, (40 * j) + offsetY, platformHeight + offsetZ,
                  1}
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
function stationUtil.AddBench(result, coords, tag, offsetX, offsetY, offsetZ)
    local i = coords[1]
    local j = coords[2]
    local platformHeight = stationUtil.ResolvePlatformHeight(result, coords)

    core.Add(result.models, {
        id = "station/rail/asset/era_a_double_chair.mdl",
        tag = tag,
        transf = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, (5 * i) + offsetX, (40 * j) + offsetY, platformHeight + offsetZ, 1}
    })
end

function stationUtil.HasRoofNext(result, coords)
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

function stationUtil.HasRoofPrevious(result, coords)
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

function stationUtil.AddButterflyRoof(result, coords, tag, offsetX, offsetY, offsetZ)
    local i = coords[1]
    local j = coords[2]
    local platformHeight = stationUtil.ResolvePlatformHeight(result, coords) - 0.53

    core.Add(result.models, {
        id = "station/rail/jan/butterfly_roof.mdl",
        tag = tag,
        transf = {1, 0, 0, 0, -0, 1, 0, 0, 0, 0, 1, 0, (5 * i) + offsetX, (40 * j) + offsetY, platformHeight + offsetZ, 1}
    })

    if not stationUtil.HasRoofNext(result, coords) then
        core.Add(result.models, {
            id = "station/rail/jan/butterfly_roof_end.mdl",
            tag = tag,
            transf = {-1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, (5 * i) + offsetX, (40 * j) + offsetY, platformHeight + offsetZ, 1}
        })
    end

    if not stationUtil.HasRoofPrevious(result, coords) then
        core.Add(result.models, {
            id = "station/rail/jan/butterfly_roof_end.mdl",
            tag = tag,
            transf = {1, 0, 0, 0, -0, 1, 0, 0, 0, 0, 1, 0, (5 * i) + offsetX, (40 * j) + offsetY, platformHeight + offsetZ, 1}
        })
    end
end

return stationUtil
