local players = {}
local table = lib.table

CreateThread(function()
    for _, player in pairs(Ox.GetPlayers(true, { groups = Config.PoliceGroups })) do
        local inService = player.get('inService')

        if inService and table.contains(Config.PoliceGroups, inService) then
            players[player.source] = player
        end
    end
end)

RegisterNetEvent('ox:setPlayerInService', function(group)
    local player = Ox.GetPlayer(source)

    if player then
        if group and table.contains(Config.PoliceGroups, group) and player.hasGroup(Config.PoliceGroups) then
            players[source] = player
            return player.set('inService', group, true)
        end

        player.set('inService', false, true)
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

    if not player then return end

    target = Player(target)?.state

    if not target then return end

    local state = not target.isCuffed

    target:set('isCuffed', state, true)

    return state
end)

RegisterNetEvent('ox_police:setPlayerEscort', function(target, state)
    local player = players[source]

    if not player then return end

    target = Player(target)?.state

    if not target then return end

    target:set('isEscorted', state and source, true)
end)

RegisterCommand('spikes', function(source)
    local src = source
    TriggerClientEvent("spawnSpikes", src)
end)

RegisterServerEvent("deleteSpikes", function(netid)
    TriggerClientEvent("delSpikes", source, netid)
end)

AddEventHandler('ox:playerLoaded', function(source, userid, charid)
    local playerId = Ox.GetPlayer(source)
	MySQL.query('SELECT sentence FROM characters WHERE charid = @charid', {
		['@charid'] = charid,
	}, function (result)
		local remaining = result[1].sentence
        Player(source).state:set('sentence', remaining, true)
        TriggerEvent('server:beginSentence', playerId.source , remaining, true )
	end)

end)

---@param id string
---@param sentence string
---@param resume boolean
RegisterServerEvent('server:beginSentence',function(id, sentence, resume)
    if sentence == 0 then return end
    local playerId = Ox.GetPlayer(id)

	MySQL.update.await('UPDATE characters SET sentence = @sentence WHERE charid = @charid', {
		['@sentence'] = sentence,
		['@charid']   = playerId.charid,
	}, function(rowsChanged)
	end)

    TriggerClientEvent('ox_lib:notify', id, {
        title = 'Jailed',
        description = 'You have been sentenced to ' .. sentence .. ' minutes.',
        type = 'inform'
    })
    if not resume then
        exports.ox_inventory:ConfiscateInventory(id)
    end

	TriggerClientEvent('sendToJail', id, sentence)
end)

---@param target string
---@param sentence string
RegisterServerEvent('updateSentence',function(sentence, target)
    local playerId = Ox.GetPlayer(target)

	MySQL.update.await('UPDATE characters SET sentence = @sentence WHERE charid = @charid', {
		['@sentence'] = sentence,
		['@charid']   = playerId.charid,
	}, function(rowsChanged)
        Player(source).state:set('sentence', sentence, true)
	end)

	if sentence <= 0 then
		if target ~= nil then
            SetEntityCoords(target, Config.unJailCoords.x, Config.unJailCoords.y, Config.unJailCoords.z)
            SetEntityHeading( target, Config.unJailHeading)
            exports.ox_inventory:ReturnInventory(target)
            TriggerClientEvent('ox_lib:notify', target, {
                title = 'Jail',
                description = 'Your sentence has ended.',
                type = 'inform'
            })
		end
	end
end)
end)

RegisterNetEvent('gsrTest', function(target)
	local src = source
	local ply = Player(target)
	if ply.state.shot == true then
        TriggerClientEvent('ox_lib:notify', src, {type = 'success', description = 'Test comes back POSITIVE (Has Shot)'})
	else
        TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'Test comes back NEGATIVE (Has Not Shot)'})
	end
end)