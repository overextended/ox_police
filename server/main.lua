local players = {}

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
