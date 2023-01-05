local spawnedSpikes = {}
local spikeModel = "P_ld_stinger_s"
local stopthread = false
local ped = cache.ped
local tires = {
    {bone = "wheel_lf", index = 0},
    {bone = "wheel_rf", index = 1},
    {bone = "wheel_rr", index = 2},
    {bone = "wheel_rm", index = 3},
    {bone = "wheel_lr", index = 4},
    {bone = "wheel_lm", index = 5}
}

local function carcheck()
    while inVehicle do
        local vehicle = cache.vehicle
        local vehiclePos = GetEntityCoords(vehicle, false)
        local spikes = GetClosestObjectOfType(vehiclePos.x, vehiclePos.y, vehiclePos.z, 80.0, joaat(spikeModel), 1, 1, 1)
        local spikeCoords = GetEntityCoords(spikes, false)
        local coords = #(vehiclePos - spikeCoords)
        while DoesEntityExist(spikes) and coords < 5 do
            Wait(5)
            for a = 1, #tires do
                local tireCoords = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, tires[a].bone))
                local dist = #(tireCoords - spikeCoords)
                if dist < 1.8 then
                    if not IsVehicleTyreBurst(vehicle, tires[a].index, true) or IsVehicleTyreBurst(vehicle, tires[a].index, false) then
                        SetVehicleTyreBurst(vehicle, tires[a].index, false, 1000.0)
                    end
                end
            end
        end
        Wait(100)
    end
end

local function removeSpikes()
    for a = 1, #spawnedSpikes do
        TriggerServerEvent("deleteSpikes", spawnedSpikes[a])
    end
end

local function deleteThread(spike)
    exports.ox_target:addModel(spikeModel,{
        {
          icon = 'fa-solid fa-lock',
          label = "Pick up spike strip",
          onSelect = function(data)
            if lib.progressBar({
                duration = 1500,
                label = 'Picking up spikestrips',
                useWhileDead = false,
                canCancel = false,
                disable = {
                    car = false,
                    move = false,
                },
                anim = {
                    dict = 'amb@prop_human_bum_bin@idle_b',
                    clip = 'idle_d'
                },
            }) then
                removeSpikes()
                Spawned = false
                exports.ox_target:removeModel(spike)
            end
            spawnedSpikes = {}
          end
      },
  })
end

local function rollSpikes()
    local spawnCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.0)
    for a = 1, 2 do
        local spike = CreateObject(joaat(spikeModel), spawnCoords.x, spawnCoords.y, spawnCoords.z, 1, 1, 1)
        local netid = NetworkGetNetworkIdFromEntity(spike)
        SetNetworkIdCanMigrate(netid, false)
        SetEntityHeading(spike, GetEntityHeading(ped))
        PlaceObjectOnGroundProperly(spike)
        spawnCoords = GetOffsetFromEntityInWorldCoords(spike, 0.0, 4.0, 0.0)
        table.insert(spawnedSpikes, netid)
    end
    Spawned = true
    deleteThread(spike)
end

RegisterNetEvent("delSpikes")
AddEventHandler("delSpikes", function(netid)
    local spike = NetworkGetEntityFromNetworkId(netid)
    DeleteEntity(spike)
    DeleteEntity(spike)
end)

RegisterNetEvent("spawnSpikes")
AddEventHandler("spawnSpikes", function()
    if lib.progressBar({
        duration = 5000,
        label = 'Placing spike strips',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = false,
        },
        anim = {
            dict = 'amb@prop_human_bum_bin@idle_b',
            clip = 'idle_d'
        },
    }) then
        rollSpikes()
    end
end)

lib.onCache('vehicle', function(value)
    if value then
        -- if Spawned == true then
            inVehicle = true
            CreateThread(carcheck)
        -- end
    else
        inVehicle = false
    end
end)

