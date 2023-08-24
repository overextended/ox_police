InService = player?.inService and table.contains(Config.PoliceGroups, player.inService) and player.hasGroup(Config.PoliceGroups)

RegisterCommand('duty', function()
    local wasInService = InService
    InService = not InService and player.hasGroup(Config.PoliceGroups) or false

    if not wasInService and not InService then
        lib.notify({
            description = 'Service not available',
            type = 'error'
        })
    else
        TriggerServerEvent('ox:setPlayerInService', InService)
        lib.notify({
            description = InService and 'In Service' or 'Out of Service',
            type = 'success'
        })
    end
end)

AddEventHandler('ox:playerLogout', function()
    InService = false
    LocalPlayer.state:set('isCuffed', false, true)
    LocalPlayer.state:set('isEscorted', false, true)
end)
