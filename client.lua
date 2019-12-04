
function translateAngle(x1, y1, ang, offset)
  x1 = x1 + math.sin(ang) * offset
  y1 = y1 + math.cos(ang) * offset
  return x1, y1
end

function dxDrawImage3D( x, y, z, width, height, material, color, rotation, ... )
    return dxDrawMaterialLine3D( x, y, z, x + width, y + height, z + tonumber( rotation or 0 ), material, height, color or 0xFFFFFFFF, ... )
end

function getVelocityPoint( startX, startY, startZ, pointX, pointY, pointZ, strength )
	local vectorX = startX-pointX
	local vectorY = startY-pointY
	local vectorZ = startZ-pointZ
	local length = ( vectorX^2 + vectorY^2 + vectorZ^2 )^0.5
	
	local propX = vectorX^2 / length^2
	local propY = vectorY^2 / length^2
	local propZ = vectorZ^2 / length^2
	
	local finalX = ( strength^2 * propX )^0.5
	local finalY = ( strength^2 * propY )^0.5
	local finalZ = ( strength^2 * propZ )^0.5
	
	if vectorX > 0 then finalX = finalX * -1 end
	if vectorY > 0 then finalY = finalY * -1 end
	if vectorZ > 0 then finalZ = finalZ * -1 end
	
	return finalX, finalY, finalZ
end

local arcBit = dxCreateTexture("arc.png")
-- tempMarker = createMarker(0, 0, 0, "corona", 4, 50, 255, 50, 150)


local arcDistance = 1500
local arcMarkerFrequency = 16
local straightDistance = 100
local arcFalloff = 0.5
local arcBitSize = 32
local arcBitOutlineSize = 8
local cooldownTime = 1500
local lastShot = getTickCount() - cooldownTime

function calculateArcFalloff(height, dist, totalDist)
	return height - math.max(0, dist-straightDistance)*((dist/totalDist)*arcFalloff)
end

function renderAimingReticle() -- TARGETING
	local veh = getPedOccupiedVehicle(localPlayer)
	if veh then
		if getElementModel(veh) == 601 or getElementModel(veh) == 432 then
			toggleControl("vehicle_fire", false)
			toggleControl("vehicle_secondary_fire", false)
			
			local x, y, z = getVehicleComponentPosition(veh, "misc_c", "world")
			local rx, ry, rz = getVehicleComponentRotation(veh, "misc_b", "world")
			
			local tx, ty = translateAngle(x, y, math.rad(-rz), arcDistance)
			local tz, _ = translateAngle(z, y, math.rad(rx), arcDistance)
			
			-- local dist = getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)
			
			for i=1,arcDistance/arcMarkerFrequency do
				local progress = i/(arcDistance/arcMarkerFrequency)
				local dx, dy, dz = interpolateBetween(x, y, z, tx, ty, tz, progress, "Linear")
				
				local dist = getDistanceBetweenPoints3D(x, y, z, dx, dy, dz)
				local dist2 = getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)
				-- local dz = dz - math.max(0, dist-straightDistance)*(progress*arcFalloff)
				local dz = calculateArcFalloff(dz, dist, dist2)
			
				-- local sx, sy = getScreenFromWorldPosition(dx, dy, dz)
				-- if sx and sy then
					-- dxDrawText("Wee", sx, sy)
				-- end
			end
			
			local mx, my, mz = interpolateBetween(x, y, z, tx, ty, tz, 0.05, "Linear")
			local mz = calculateArcFalloff(mz, getDistanceBetweenPoints3D(x, y, z, mx, my, mz), getDistanceBetweenPoints3D(x, y, z, tx, ty, tz))
			-- local mz = calculateArcFalloff(mz, )
			
			local sx, sy = getScreenFromWorldPosition(mx, my, mz+2)
			if sx and sy then
				dxDrawImage(sx-(arcBitSize/2)-(arcBitOutlineSize/2), sy-(arcBitSize/2)-(arcBitOutlineSize/2), arcBitSize+arcBitOutlineSize, arcBitSize+arcBitOutlineSize, arcBit, 0, 0, 0, tocolor(255, 255, 255, 50))
				dxDrawImage(sx-(arcBitSize/2), sy-(arcBitSize/2), arcBitSize, arcBitSize, arcBit, 0, 0, 0, tocolor(50, 255, 50, 150))
			end
			
			-- dxDrawImage3D(mx, my, mz, arcBitSize/2, arcBitSize, arcBit, tocolor(50, 255, 50, 150))
			
			-- local mx, my, mz = 
			-- setElementPosition(tempMarker, tx, ty, tz)
			
		else
			toggleControl("vehicle_fire", true)
			toggleControl("vehicle_secondary_fire", true)
		end
	end
end

function fireTankLocal()
	if getTickCount() > lastShot + cooldownTime then
		if getPedOccupiedVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
			local veh = getPedOccupiedVehicle(localPlayer)
			if getElementModel(veh) == 601 or getElementModel(veh) == 432 then
				local x, y, z = getVehicleComponentPosition(veh, "misc_c", "world")
				local rx, ry, rz = getVehicleComponentRotation(veh, "misc_b", "world")
				
				local tx, ty = translateAngle(x, y, math.rad(-rz), arcDistance)
				local tz, _ = translateAngle(z, y, math.rad(rx), arcDistance)
				
				fxAddTankFire(x, y, z, tx-x, ty-y, tz-z)
				
				local ox, oy, oz = getElementVelocity(veh)
				local sx, sy, sz = interpolateBetween(x, y, z, tx, ty, tz, 0.02, "Linear")
				local vx, vy, vz = getVelocityPoint(tx, ty, tz, sx, sy, sz, 0.1)
				setElementAngularVelocity(veh, -vy/5, vx/5, 0)
				setElementVelocity(veh, ox+vx, oy+vy, oz+(vz*2))
				
				-- for i=1,arcDistance do
				counter = 0
				repeat
					counter = counter + 1
					local i = counter
					local progress = i/arcDistance
					local progress2 = (i+1)/arcDistance
					local dx, dy, dz = interpolateBetween(x, y, z, tx, ty, tz, progress, "Linear")
					local dx2, dy2, dz2 = interpolateBetween(x, y, z, tx, ty, tz, progress2, "Linear")
					
					local totalDist = getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)
					local dist = getDistanceBetweenPoints3D(x, y, z, dx, dy, dz)
					
					local dz = calculateArcFalloff(dz, dist, totalDist)
					local dz2 = calculateArcFalloff(dz2, dist, totalDist)
					
					hit, hitX, hitY, hitZ = processLineOfSight(dx, dy, dz, dx2, dy2, dz2, true, true, true, true, false, true, true, true, veh, false, true)
					-- dxDrawText(i, getScreenFromWorldPosition(dx, dy, dz))
					
				until hit == true or counter == arcDistance
				-- end
				if hit == true then
					triggerServerEvent("onTankFire", resourceRoot, hitX, hitY, hitZ, counter, veh)
				else
					triggerServerEvent("onTankFire", resourceRoot, tx, ty, tz, counter, veh)
				end
				
				triggerServerEvent("onRequestMuzzle", localPlayer, x, y, z, x, y, z)
				
				-- outputChatBox(tostring(hit))
				
				lastShot = getTickCount()
			end
		end
	end
end

addEvent("onClientTankFire", true)
addEventHandler("onClientTankFire", resourceRoot, function(tank)
	local x, y, z = getElementPosition(tank)
	local sound = playSound3D("Cannon-"..math.random(1,3)..".wav", x, y, z)
	setSoundMaxDistance(sound, 300)
	setSoundVolume(sound, 0.6)
	-- outputChatBox('fire')
end)

addEventHandler("onClientRender", root, renderAimingReticle)
bindKey("vehicle_fire", "down", fireTankLocal)
bindKey("vehicle_secondary_fire", "down", fireTankLocal)