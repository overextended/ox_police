local createdEvidence = {}

CreateThread(function()
    while true do
        Wait(1000)

        if next(createdEvidence) then
            TriggerServerEvent('ox_police:distributeEvidence', createdEvidence)

            table.wipe(createdEvidence)
        end
    end
end)

local equippedWeapon = {}
local glm = require 'glm'

local function createNode(item, coords)
    coords = vec3(glm.snap(coords.x, 0.0625), glm.snap(coords.y, 0.0625), glm.snap(coords.z, 0.0625))

    local entry = {
        [item] = {
            [equippedWeapon.ammo] = 1
        }
    }

    if createdEvidence[coords] then
        lib.table.merge(createdEvidence[coords], entry)
    else
        createdEvidence[coords] = entry
    end
end

AddEventHandler('ox_inventory:currentWeapon', function(weaponData)
    equippedWeapon = weaponData

    while equippedWeapon?.ammo do
		Wait(0)

        if IsPedShooting(cache.ped) then
            local hit, entityHit, endCoords = lib.raycast.cam(tonumber('000111111', 2), 7)

            if hit then
                if GetEntityType(entityHit) == 0 then
                    createNode('slug', endCoords)
                end

                Wait(100)

                local pedCoords = GetEntityCoords(cache.ped)
                local direction = math.rad(math.random(360))
                local magnitude = math.random(100) / 20

                local coords = vec3(pedCoords.x + math.sin(direction) * magnitude, pedCoords.y + math.cos(direction) * magnitude, pedCoords.z)

                local success, impactZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, 1)

                if success then
                    createNode('case', vector3(coords.x, coords.y, impactZ))
                end
            end
		end
	end
end)

local evidence = {}

local function removeNode(coords)
    if evidence[coords] then
        exports.ox_target:removeZone(evidence[coords])

        evidence[coords] = nil
    end
end

RegisterNetEvent('ox_police:updateEvidence', function(addEvidence, clearEvidence)
    for coords in pairs(addEvidence) do
        if not evidence[coords] then
            evidence[coords] = exports.ox_target:addSphereZone({
                coords = coords,
                radius = 0.5,
                drawSprite = true,
                options = {
                    {
                        name = 'evidence',
                        icon = 'fa-solid fa-gun',
                        label = 'Collect evidence',
                        onSelect = function(data)
                            local nodes = {}
                            local targetCoords = data.coords

                            for k in pairs(evidence) do
                                if #(targetCoords - k) < 2 then
                                    removeNode(k)
                                    nodes[#nodes + 1] = k
                                end
                            end

                            TriggerServerEvent('ox_police:collectEvidence', nodes)
                        end
                    }
                }
            })
        end
    end

    for coords in pairs(clearEvidence) do
        removeNode(coords)
    end
end)
