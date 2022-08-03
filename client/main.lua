InService = false

if player then
    lib.callback('ox_police:isPlayerInService', nil, function(state)
        InService = state
    end)
end

RegisterCommand('duty', function()
    if player.hasGroup(Config.PoliceGroups) then
        InService = not InService
        TriggerServerEvent('ox_police:setPlayerInService', InService)
    end
end)

local playerState = LocalPlayer.state

AddEventHandler('ox:playerLogout', function()
    playerState:set('isCuffed', false, true)
    playerState:set('isEscorted', false, true)
end)