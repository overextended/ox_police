local GetWorldCoordFromScreenCoord = GetWorldCoordFromScreenCoord
local StartShapeTestCapsule = StartShapeTestCapsule
local GetShapeTestResult = GetShapeTestResult
local GetEntitySpeed = GetEntitySpeed
local playerState = LocalPlayer.state

local vehicleData = setmetatable({}, {
	__index = function(self, index)
		local data = Ox.GetVehicleData(index)

		if data then
			data = {
				name = data.name,
				make = data.make,
			}

			self[index] = data
			return data
		end
	end
})

local function updateTextUI()
    local coords, normal = GetWorldCoordFromScreenCoord(0.5, 0.5)
    local destination = coords + normal * 50
    local handle = StartShapeTestCapsule(coords.x, coords.y, coords.z, destination.x, destination.y, destination.z, 2.0, 2, cache.vehicle, 7)
    local _, _, _, _, entity = GetShapeTestResult(handle)

    if IsEntityAVehicle(entity) then
        local speed = math.floor(GetEntitySpeed(entity) * 2.23)
        local data = vehicleData[GetEntityArchetypeName(entity)]

        lib.showTextUI(('Speed: %s MPH  \nPlate: %s  \nMake: %s  \nModel: %s'):format(speed, GetVehicleNumberPlateText(entity), data.make, data.name))
    end
end

local active = false

RegisterCommand('alpr', function()
    if not InService or playerState.invBusy then return end

    active = not active

    while cache.vehicle and active do
        updateTextUI()
        Wait(500)
    end

    lib.hideTextUI()
end)
