local evidence = {}
local equippedWeapon = {}

local function removeNode(id)
    evidence[id] = nil

    exports.ox_target:removeZone(id)
end

local function createNode(item, coords)
    local id = exports.ox_target:addSphereZone({
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

                    for k, v in pairs(evidence) do
                        if #(targetCoords - v.coords) < 2 then
                            nodes[#nodes + 1] = k
                        end
                    end

                    local items = {}

                    for i = 1, #nodes do
                        local node = evidence[nodes[i]]

                        if not items[node.item] then
                            items[node.item] = {}
                        end

                        if items[node.item][node.type] then
                            items[node.item][node.type] += 1
                        else
                            items[node.item][node.type] = 1
                        end

                        removeNode(node.id)
                    end

                    TriggerServerEvent('ox_police:collectEvidence', items)
                end
            }
        }
    })

    evidence[id] = {
        id = id,
        coords = coords,
        item = item,
        type = equippedWeapon.ammo
    }
end

AddEventHandler('ox_inventory:currentWeapon', function(weaponData)
    equippedWeapon = weaponData

    while equippedWeapon?.ammo do
		Wait(0)

        if IsPedShooting(cache.ped) then
            local impact, slugCoords = GetPedLastWeaponImpactCoord(cache.ped)

            if impact then
                Wait(100)

                createNode('slug', slugCoords)

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
