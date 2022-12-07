local playerState = LocalPlayer.state

local function escortPlayer(ped, id)
    if not id then
        id = NetworkGetPlayerIndexFromPed(ped)
    end

    TriggerServerEvent('ox_police:setPlayerEscort', GetPlayerServerId(id), not IsEntityAttachedToEntity(ped, cache.ped))
end

RegisterCommand('escort', function()
    if not InService or playerState.invBusy then return end

    local id, ped = lib.getClosestPlayer(player.getCoords(true))
    if not id or not IsPedCuffed(ped) then return end

    escortPlayer(id, ped)
end)

local IsPedCuffed = IsPedCuffed
local IsEntityAttachedToEntity = IsEntityAttachedToEntity

exports.ox_target:addGlobalPlayer({
    {
        name = 'escort',
        icon = "fas fa-hands-bound",
        label = "Escort",
        job = Config.PoliceGroups,
        distance = 1.5,
        canInteract = function(entity)
            return InService and IsPedCuffed(entity) and not IsEntityAttachedToEntity(entity, cache.ped) and not playerState.invBusy
        end,
        onSelect = function(data)
            escortPlayer(data.entity)
        end
    },
    {
        name = 'release',
        icon = "fas fa-hands-bound",
        label = "Release",
        job = Config.PoliceGroups,
        distance = 1.5,
        canInteract = function(entity)
            return InService and IsPedCuffed(entity) and IsEntityAttachedToEntity(entity, cache.ped) and not playerState.invBusy
        end,
        onSelect = function(data)
            escortPlayer(data.entity)
        end
    },
})

local isEscorted = playerState.isEscorted

local function setEscorted(serverId)
    while isEscorted do
        local player = GetPlayerFromServerId(serverId)
        local ped = player > 0 and GetPlayerPed(player)

        if not ped then break end

        if not IsEntityAttachedToEntity(cache.ped, ped) then
            AttachEntityToEntity(cache.ped, ped, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, true, true, 2, true)
        end

        Wait(500)
    end

    Wait(0)
    playerState:set('isEscorted', false, true)
end

AddStateBagChangeHandler('isEscorted', ('player:%s'):format(cache.serverId), function(_, _, value)
    isEscorted = value

    if IsEntityAttached(cache.ped) then
        DetachEntity(cache.ped, true, false)
    end

    if value then setEscorted(value) end
end)

if isEscorted then
    CreateThread(function()
        setEscorted(isEscorted)
    end)
end
