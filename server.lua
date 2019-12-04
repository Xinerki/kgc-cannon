
addEvent("onTankFire", true)
addEventHandler("onTankFire", resourceRoot, function(x, y, z, distance, theTank)
	-- outputChatBox(tostring(distance))
	triggerClientEvent("onClientTankFire", resourceRoot, theTank)
	setTimer(createExplosion, math.max(50, distance/2), 1, x, y, z, 7, client)
	-- outputChatBox("fire")
end)

-- addEvent("onTankHit", true)
-- addEventHandler("onTankHit", resourceRoot, function(x, y, z)
	-- createExplosion(x, y, z, 10, client)
-- end)