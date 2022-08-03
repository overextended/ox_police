local playerState = LocalPlayer.state

local function escortPlayer(id, ped)
    TriggerServerEvent('ox_police:setPlayerEscort', GetPlayerServerId(id), not IsEntityAttachedToEntity(ped, cache.ped))
end

RegisterCommand('escort', function()
    if not InService or playerState.invBusy then return end

    local id, ped = lib.getClosestPlayer(player.getCoords(true))
    if not id or not IsPedCuffed(ped) then return end

    escortPlayer(id, ped)
end)

exports.qtarget:Player({
    options = {
        {
            icon = "fas fa-hands-bound",
            label = "Escort",
            job = Config.PoliceGroups,
            canInteract = function(entity)
                return InService and IsPedCuffed(entity) and not playerState.invBusy
            end,
            action = function(entity)
                escortPlayer(NetworkGetPlayerIndexFromPed(entity), entity)
            end
        },
    },
    distance = 2.0
})

local isEscorted = playerState.isEscorted

local function whileEscorted(serverId)
    while isEscorted do
        local player = GetPlayerFromServerId(serverId)
        local ped = player > 0 and GetPlayerPed(player)

        if not ped then
            playerState.isEscorted = false
            return
        end

        if not IsEntityAttachedToEntity(cache.ped, ped) then
            AttachEntityToEntity(cache.ped, ped, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2,
                true)
        end

        Wait(500)
    end
end

AddStateBagChangeHandler('isEscorted', ('player:%s'):format(cache.serverId), function(_, _, value)
    if IsEntityAttached(cache.ped) then
        DetachEntity(cache.ped, true, false)
    end

    if value then
        CreateThread(function()
            whileEscorted(value)
        end)
    end

    isEscorted = value
end)

playerState.isEscorted = isEscorted

