-- // code by slim#0001
-- // help with raycast viktorelmer#9834
-- // Русские которые пишут на ESX, пожалуйста, не используйте мой код, вы говноеды!

local isCursorShowing = false
local uiHasFocus = false


local function DrawText3Ds(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
  
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end

local function RotationToDirection(rotation)
	local adjustedRotation = 
	{ 
		x = (math.pi / 180) * rotation.x, 
		y = (math.pi / 180) * rotation.y, 
		z = (math.pi / 180) * rotation.z 
	}
	local direction = 
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		z = math.sin(adjustedRotation.x)
	}
	return direction
end


local function RayCastGamePlayCamera(distance,flag)
	local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination = 
	{ 
		x = cameraCoord.x + direction.x * distance, 
		y = cameraCoord.y + direction.y * distance, 
		z = cameraCoord.z + direction.z * distance 
    }
    if not flag then
        flag = -1

        --[[
            Flags:  
            1: Intersect with map  
            2: Intersect with vehicles (used to be mission entities?) (includes train)  
            4: Intersect with peds? (same as 8)  
            8: Intersect with peds? (same as 4)  
            16: Intersect with objects  
            32: Water?  
            64: Unknown 
            128: Unknown  
            256: Intersect with vegetation (plants, coral. trees not included)  
            NOTE: Raycasts that intersect with mission_entites (flag = 2) has limited range and will not register for far away entites. The range seems to be about 30 metres.  
        ]]

    end
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, flag, -1, 1))
	return b, c, e, destination
end


Citizen.CreateThread(function()
	while (true) do
		Citizen.Wait(0)
		-- Displays the Cursor
		if(isCursorShowing) then
			ShowCursorThisFrame() -- show cursor
		end
		-- UI Focus
		if(uiHasFocus) then
			DisableControlAction(0, 1, uiHasFocus)		-- Mouse Look, Left/Right
			DisableControlAction(0, 2, uiHasFocus)		-- Mouse Look, Up/Down
			DisableControlAction(0, 142, uiHasFocus)	-- Right Click
		else
			EnableControlAction(0, 1, not uiHasFocus)	-- Mouse Look, Left/Right
			EnableControlAction(0, 2, not uiHasFocus)	-- Mouse Look, Up/Down
			EnableControlAction(0, 142, not uiHasFocus)	-- Right Click
        end
        if IsControlPressed(0,58) then -- / G
            uiHasFocus = true
            isCursorShowing = true
        else
            uiHasFocus = false
            isCursorShowing = false
        end
	end
end)

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(5)
        local hit, coords, entity = RayCastGamePlayCamera(10.0,-1)
        local gp = GetPlayerPed(-1)
        if hit and (IsEntityAVehicle(entity)) then
            local position = GetEntityCoords(gp) 
            local entitypos = GetEntityCoords(entity)
            if IsEntityAVehicle(entity) and GetDistanceBetweenCoords(position.x, position.y, position.z, entitypos.x, entitypos.y, entitypos.z, true) < 4 then -- Get Player, and check distance with ped
                if not IsPedInAnyVehicle(gp) then
                    DrawText3Ds(entitypos.x, entitypos.y, entitypos.z, "Vehicle: [~g~G~s~]")            
                    if IsControlJustPressed(1, 68) and uiHasFocus and isCursorShowing then -- RIGHT BUTTON
                        --tvRP.notify("~g~This a ped :)")
                        print("THIS IS A VEHICLE")
                    end
				end
            end
        elseif hit and (IsEntityAPed(entity)) and gp ~= entity then
            local position = GetEntityCoords(gp) 
            local entitypos = GetEntityCoords(entity)
            hit, coords, entity = RayCastGamePlayCamera(10.0,4)
            if IsEntityAPed(entity) and GetDistanceBetweenCoords(position.x, position.y, position.z, entitypos.x, entitypos.y, entitypos.z, true) < 5 then -- Get Player, and check distance with ped
                if not IsPedInAnyVehicle(gp) then
                    DrawText3Ds(entitypos.x, entitypos.y, entitypos.z, "Ped: [~g~G~s~]") 
                    if IsControlJustPressed(1, 68) and uiHasFocus and isCursorShowing then -- RIGHT BUTTON
                        --tvRP.notify("~g~This a ped :)")
                        print("THIS IS A PED")
                    end
                end
            end
		end
	end
end)
