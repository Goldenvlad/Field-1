--[[ 
This file is part of the Field project
]]

require("game.gamestatemanager")

package.path = "./lubeboth/?.lua;" .. package.path
require("lubeboth.class")
require("lubeboth.lube")
require("lubeboth.TSerial")
require("lubeboth.client")
require("game.musicmanager")
cron = require("lubeboth.cron")
table2 = require("lubeboth.table2")

gameStateManager = nil

-- Game paused quoi...@Florent si ça gere le focus tu l'apelle focus.
gameFocus = true

musicM = MusicManager.new()
musicM:play()


-- "low level" events :

function rcvCallback(data)
    serveur:gotData(data, onConnect)
end

-- "high level" events :

function onMessage(msg)
	if gameStateManager.currentState=='Gameplay' then
		if msg.type == "gameplaypacket" then
			gameStateManager.state['Gameplay']:handlePacket(msg.pk)
		end
	elseif msg.type == "listmaps" then
		-- print("MAPS =", table2.tostring(msg))
		monde.availableMaps = msg.maps
	else
		gameStateManager:onMessage(msg)
	end
end

function discoveryCallback(data, id)
    ip_addr = id:sub(0, id:find(':')-1)
    -- print("Got data :", data, "From :", ip_addr)
    if data == "hi" then
    	gameStateManager:onMessage({type="discovery", ip=ip_addr})
    end
end

function love.load()
	love.graphics.setIcon( love.graphics.newImage("icons/256x256.png" ))
	-- lube :
	discoveryListener = lube.udpServer()
	discoveryListener:listen(3411)
	discoveryListener.callbacks.recv = discoveryCallback
	-- /lube
	monde = {}
	gameStateManager = GameStateManager.new()
	love.audio.setDistanceModel("exponent")
	--love.audio.setOrientation(0,0,1, 0,1,0)
	love.audio.setPosition(love.graphics.getWidth()/2, love.graphics.getHeight()/2,0)
end

function love.update(dt)
	-- lube :
	if conn ~= nil then
		conn:update(dt)
	end

	-- Music managing
	musicM:update(dt)

	
	-- cron.update(dt)
	
	-- /lube

	gameStateManager:update(dt)
	
end	

function love.mousepressed(x, y, button)
	gameStateManager:mousePressed(x, y, button)
end

function love.mousereleased(x, y, button)
	gameStateManager:mouseReleased(x, y, button)
end

function love.keypressed(key, unicode)
	gameStateManager:keyPressed(key, unicode)
end

function love.keyreleased(key, unicode)
	gameStateManager:keyReleased(key, unicode)
end

function love.joystickpressed(joystick, button)
	if gameFocus then

		gameStateManager:joystickPressed(joystick, button)
	end
end

function love.joystickreleased(joystick, button)
	if gameFocus then
		gameStateManager:joystickReleased(joystick, button)
	end
end

function love.draw()
	gameStateManager:draw()
end

function love.focus(b)
	gameFocus = b
end