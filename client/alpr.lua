local GetWorldCoordFromScreenCoord = GetWorldCoordFromScreenCoord
local StartShapeTestCapsule = StartShapeTestCapsule
local GetShapeTestResult = GetShapeTestResult
local GetEntitySpeed = GetEntitySpeed
local playerState = LocalPlayer.state

function updateTextui(entity)
    if IsEntityAVehicle(entity) then
        local vehicle = entity
        local velocity = GetEntitySpeed(vehicle) * 2.23
        local speed = math.floor(velocity)
        local plate = GetVehicleNumberPlateText(vehicle)
        lib.showTextUI('Speed = '..speed..' MPH  \n Plate = '..plate..'')
    end
end

function radarCast()
    local coords, normal = GetWorldCoordFromScreenCoord(0.5, 0.5)
    local destination = coords + normal * 50
    local handle = StartShapeTestCapsule( coords.x, coords.y, coords.z, destination.x, destination.y, destination.z, 2.0, 2, cache.vehicle, 7 )
    local a,a,a,a, vehicle = GetShapeTestResult(handle)
    return vehicle
end

RegisterCommand('alpr', function()
    if not InService or playerState.invBusy then return end
    CreateThread(function()
        while veh do
            if Radar and InService then
                Wait(500)
                local entity = radarCast()
                updateTextui(entity)
                if veh == false then
                    lib.hideTextUI()
                    break
                end
            else
                lib.hideTextUI()
                break
            end
        end
    end)
end)

lib.onCache('vehicle', function(value)
    if value then
        veh = true
        Radar = true
    else
        Radar = false
        veh = false
        lib.hideTextUI()
    end
end)

RegisterCommand('hidealpr', function()
    Radar = false
    lib.hideTextUI()
end)


