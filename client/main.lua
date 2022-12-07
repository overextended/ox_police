local table = lib.table
InService = player?.inService and table.contains(Config.PoliceGroups, player.inService) and player.hasGroup(Config.PoliceGroups)

RegisterCommand('duty', function()
    InService = not InService and player.hasGroup(Config.PoliceGroups) or false
    TriggerServerEvent('ox:setPlayerInService', InService)
end)

AddEventHandler('ox:playerLogout', function()
    InService = false
    LocalPlayer.state:set('isCuffed', false, true)
    LocalPlayer.state:set('isEscorted', false, true)
end)
