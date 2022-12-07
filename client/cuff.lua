local playerState = LocalPlayer.state
local Wait = Wait
local TaskPlayAnim = TaskPlayAnim

local function cuffPlayer(ped)
    local playerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped))
    local state = lib.callback.await('ox_police:setPlayerCuffs', 200, playerId)

    if state == nil then return end

    playerState.invBusy = true

    FreezeEntityPosition(cache.ped, true)
    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
    AttachEntityToEntity(cache.ped, ped, 11816, -0.07, -0.58, 0.0, 0.0, 0.0, 0.0, false, false , false, true, 2, true)

    local dict = state and 'mp_arrest_paired' or 'mp_arresting'

    if state then
        lib.requestAnimDict(dict)
        TaskPlayAnim(cache.ped, dict, 'cop_p2_back_right', 8.0, -8.0, 3750, 2, 0.0, false, false, false)
        Wait(3750)
    else
        lib.requestAnimDict(dict)
        TaskPlayAnim(cache.ped, dict, 'a_uncuff', 8.0, -8, 5500, 0, 0, false, false, false)
        Wait(5500)
    end

    DetachEntity(cache.ped, true, false)
    FreezeEntityPosition(cache.ped, false)
    RemoveAnimDict(dict)

    playerState.invBusy = false
end

local IsPedCuffed = IsPedCuffed
local IsEntityAttached = IsEntityAttached

RegisterCommand('cuff', function()
    if not InService or playerState.invBusy then return end

    local id, ped = lib.getClosestPlayer(player.getCoords(true))
    if not id then return end

    cuffPlayer(ped)
end)

exports.ox_target:addGlobalPlayer({
    {
        name = 'cuff',
        icon = 'fas fa-handcuffs',
        label = 'Handcuff',
        groups = Config.PoliceGroups,
        distance = 1.5,
        canInteract = function(entity)
            return InService and not IsPedCuffed(entity) and not playerState.invBusy
        end,
        onSelect = function(data)
            cuffPlayer(data.entity)
        end
    },
    {
        name = 'uncuff',
        icon = 'fas fa-handcuffs',
        label = 'Remove handcuffs',
        groups = Config.PoliceGroups,
        distance = 1.5,
        canInteract = function(entity)
            return InService and IsPedCuffed(entity) and not IsEntityAttached(entity) and not playerState.invBusy
        end,
        onSelect = function(data)
            cuffPlayer(data.entity)
        end
    },
})

local isCuffed = playerState.isCuffed
local IsEntityPlayingAnim = IsEntityPlayingAnim
local DisablePlayerFiring = DisablePlayerFiring
local DisableControlAction = DisableControlAction

local function whileCuffed()
    local dict = 'mp_arresting'

    while isCuffed do
        if not IsEntityPlayingAnim(cache.ped, dict, 'idle', 3) then
            lib.requestAnimDict(dict)
            TaskPlayAnim(cache.ped, dict, 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
        end

        DisablePlayerFiring(cache.playerId, true)
        DisableControlAction(0, 140, true)
        Wait(0)
    end

    ClearPedTasks(cache.ped)
    RemoveAnimDict(dict)
end

AddStateBagChangeHandler('isCuffed', ('player:%s'):format(cache.serverId), function(_, _, value)
    local ped = cache.ped

    SetEnableHandcuffs(ped, value)
    SetEnableBoundAnkles(ped, value)

    if player then
        if isCuffed ~= value then
            SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
            FreezeEntityPosition(ped, true)

            if value then
                playerState.invBusy = value

                lib.requestAnimDict('mp_arrest_paired')
                TaskPlayAnim(ped, 'mp_arrest_paired', 'crook_p2_back_right', 8.0, -8, 3750, 2, 0, false, false, false)
                Wait(3750)
                RemoveAnimDict('mp_arrest_paired')
            else
                lib.requestAnimDict('mp_arresting')
                TaskPlayAnim(ped, 'mp_arresting', 'b_uncuff', 8.0, -8, 5500, 0, 0, false, false, false)
                Wait(5500)

                playerState.invBusy = value
            end

            FreezeEntityPosition(ped, false)
            isCuffed = value
        end
    end

    isCuffed = value

    if value then
        CreateThread(whileCuffed)
    end
end)

playerState.isCuffed = isCuffed
