local players = {}
local vehicles = {}

for _, v in pairs(Ox.GetPlayers(true, { inService = 'police' })) do
    players[v.source] = v
end

RegisterNetEvent('ox_police:setPlayerInService', function(state)
    local player = Ox.GetPlayer(source)

    if player.hasGroup(Config.PoliceGroups) then
        player.set('inService', state and 'police' or false)

        if state then
            players[source] = player
            return
        end
    end

    players[source] = nil
end)

AddEventHandler('ox:playerLogout', function(source)
    players[source] = nil
end)

lib.callback.register('ox_police:isPlayerInService', function(source, target)
    return players[target or source]
end)

lib.callback.register('ox_police:setPlayerCuffs', function(source, target)
    local player = players[source]

    if not player then
        return print('player is not in service')
    end

    target = Player(target)?.state

    if not target then
        return print('invalid target')
    end

    local state = not target.isCuffed
    target:set('isCuffed', state, true)

    return state
end)

RegisterNetEvent('ox_police:setPlayerEscort', function(target, state)
    local player = players[source]

    if not player then
        return print('player is not in service')
    end

    target = Player(target)?.state

    if not target then
        return print('invalid target')
    end

    target:set('isEscorted', state and source, true)
end)

lib.callback.register('ox_police:spawnVehicle', function(source, model, mock)

    -- perform checks to prevent exploits and abuse
    local player = players[source]
    local isClose = false
    local isPolice = player.hasGroup(Config.PoliceGroups)

    if not isPolice then
        return print('player is not a policeman')
    end

    for i=1, #Config.SpawnerCoords do
        local spawnerCoords = Config.SpawnerCoords[i].coords
        local distance = #(spawnerCoords - player.getCoords(true))
        if distance <= 5.0 then
            isClose = true
            break
        end
    end

    if not isClose then
        return print('player is too far away')
    end

    if not player then
        return print('player is not in service')
    end

    if type(mock) ~= "table" then
        return print('invalid mock, possible cheater')
    end

    if not mock then
        return print('missing mock, possible cheater')
    end
    -- end of tests
    
    -- spawn the vehicle and set the player as driver
    -- add the vehicle to the list of vehicles, including player identifier and vehicle plate
    local vehicle = Ox.CreateVehicle({
        model = model,
        owner = player.charid,
    }, player.getCoords(), GetEntityHeading(player.ped))

    Wait(100) -- Is the wait really needed here?
    warpPedIntoVehicle(player.ped, vehicle, -1)
    Wait(100) -- Is the wait really needed here?

    local plate = GetVehicleNumberPlateText(vehicle)
    vehicles[player.charid] = {
        vehicle = vehicle,
        plate = plate,
    }

    -- set it so we can perform quick checks to see the owner
    local plate, currentOwner = plate, true
    player.set(plate, currentOwner)

end)