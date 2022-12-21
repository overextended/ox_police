local playerPed = PlayerPedId()
local playerId = cache.playerId
local bullets = {}
local timer = GetGameTimer()

function boomboompow()
	local shooThread = 500
	while murderTime do
		if IsPlayerFreeAiming(playerId) then
            shooThread = 0
			if IsPedShooting(playerPed) then
				local impact, bulletCoords = GetPedLastWeaponImpactCoord(playerPed)
				if impact then
					bulletCoords = vector3(bulletCoords.x, bulletCoords.y, bulletCoords.z)
                    Wait(100)
                    shots = exports.ox_target:addSphereZone({
                        coords = bulletCoords,
                        radius = 0.5,
                        options = {
                            {
                                name = 'evidence',
                                icon = 'fa-solid fa-gun',
                                label = 'Pick up bullets',
                                canInteract = function(entity, distance, coords, name)
                                    print(json.encode(entity))
                                    return true
                                end
                            }
                        }
                    })

                    bullets[#bullets+1] = shots
                    print(json.encode(bullets))
				end
			end
		end
		Wait(shooThread)
	end
end

AddEventHandler('ox_inventory:currentWeapon', function(data)
    if data then
        murderTime = true
        CreateThread(boomboompow)
    else
		murderTime = false
    end
end)


---@param stats string
RegisterNetEvent("casingDrop")
AddEventHandler("casingDrop", function(stats)
    local coords = stats
    local ground, impactZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, 1)
    local coords = vector3(coords.x, coords.y, (impactZ + 0.0))
    exports.ox_target:addSphereZone({
        coords = coords,
        radius = 0.5,
        options = {
            {
                name = 'evidence',
                icon = 'fa-solid fa-gun',
                label = 'Pick up casing',
                canInteract = function(entity, distance, coords, name)

                    return true
                end
            }
        }
    })
end)


RegisterCommand('clearzone', function()
    for k, v in pairs (bullets) do
        print(v)
        exports.ox_target:removeZone(tostring(v))
    end
end)
