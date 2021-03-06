--[[ 
This file is part of the Field project]]

require("game.themagnet")
require("game.metalman")
require("game.map")
require("game.camera")
require("game.magnetmanager")
require("game.generator")
require("game.metal")
require("game.maploader")
require("game.interruptor")
require("game.sound")
require("game.levelending")
require("game.levelfailed")
require("const")

Gameplay = {}
Gameplay.__index = Gameplay

function Gameplay.new(mapFile,continuous)
    local self = {}
    setmetatable(self, Gameplay)

    self.continuous=true
        -- Physics
        love.physics.setMeter( unitWorldSize) --the height of a meter our worlds will be 64px
        world = love.physics.newWorld( 0, 18*unitWorldSize, false )
        print(world:getGravity())
        world:setCallbacks(beginContact, endContact, preSolve, postSolve)
        -- Custom physics
        self.magnetmanager = MagnetManager.new()

        self.mapFile=mapFile
        --Map
        self.mapLoader = MapLoader.new(mapFile,self.magnetmanager)
        -- self.mapLoader = MapLoader.new("maps.level1",self.magnetmanager)

        -- Camera Metal Man
        self.cameraMM =Camera.new(0,0)
        -- Camera The Magnet
        self.cameraTM =Camera.new(0,0)

        
    -- Player loading
        self.metalMan = MetalMan.new(self.cameraMM,self.mapLoader.metalManPos,self.mapLoader.metalManPowers)
        self.theMagnet = TheMagnet.new(self.cameraTM,self.mapLoader.theMagnetPos,self.mapLoader.theMagnetPowers)
        self.magnetmanager:addGenerator(self.theMagnet)
        self.magnetmanager:addMetal(self.metalMan)

        -- Temp var
        self.drawWho=1
        self.shouldEnd=false
        self.maxTime = 0.016 -- 50 ms
        self.lastTime = 42
        self.levelFinished=false
        return self
    end

    function Gameplay:destroy()
        self.shouldEnd=false
        world:setCallbacks(nil, function() collectgarbage() end)
        world:destroy()
        world=nil
        world = love.physics.newWorld( 0, 18*unitWorldSize, false )
        print(world:getGravity())
        world:setCallbacks(beginContact, endContact, preSolve, postSolve)
    end  

    function Gameplay:reset()
        self.shouldEnd=false
        world:setCallbacks(nil, function() collectgarbage() end)
        world:destroy()
        world=nil
        world = love.physics.newWorld( 0, 18*unitWorldSize, false )
        print(world:getGravity())
        world:setCallbacks(beginContact, endContact, preSolve, postSolve)
        -- Custom physics
        self.magnetmanager= nil
        self.magnetmanager = MagnetManager.new()

        print("LOADING FILE =", self.mapFile)
        self.mapLoader = MapLoader.new(self.mapFile, self.magnetmanager)

        -- Camera Metal Man
        self.cameraMM =Camera.new(0,0)
        -- Camera The Magnet
        self.cameraTM =Camera.new(0,0)

        
        --Characters
        self.metalMan = MetalMan.new(self.cameraMM,self.mapLoader.metalManPos, self.mapLoader.metalManPowers)
        self.theMagnet = TheMagnet.new(self.cameraTM,self.mapLoader.theMagnetPos, self.mapLoader.theMagnetPowers)
        self.magnetmanager:addGenerator(self.theMagnet)
        self.magnetmanager:addMetal(self.metalMan)

        -- Temp var
        self.drawWho=1
    end

    function Gameplay:failed()
        self.shouldEnd=true
    end

    function Gameplay:finish()
        self.levelFinished=true
    end

    function Gameplay:mousePressed(x, y, button)
    end
    

    function Gameplay:mousePressed(x, y, button)
    end
    
    function Gameplay:mouseReleased(x, y, button)
    end
    
    
    function Gameplay:keyPressed(key, unicode)
        if key=="z" then
            self.metalMan:jump()     
        end
        if key=="up" then
            self.theMagnet:jump()
        end 

        if key =="i" then
            self.theMagnet:enableStaticField()
        end

        if key =="o" then
            self.theMagnet:enableAttractiveField()
        end
        if key =="p" then
            self.theMagnet:enableRepulsiveField()
        end

        if key =="k" then
            self.theMagnet:enableRotativeLField()
        end
        if key =="l" then
            self.theMagnet:enableRotativeRField()
        end

        if key =="e" then
            self.mapLoader:handleTry('MetalMan')
        end
        if key =="f" then
            self.mapLoader:handleTry('TheMagnet')
        end

        if key =="y" then
            self.drawWho= (self.drawWho+1)%2
        end

        if not self.metalMan.isStatic then
            print("Server recieved changemass")
            if key =="b" then
                self.metalMan:changeMass()
            end
        end
        if key =="d" then
            self.metalMan:startMove()
        end

        if key =="q" then
            self.metalMan:startMove()
        end


        if key =="left" then
            self.theMagnet:startMove()
        end

        if key =="right" then
            self.theMagnet:startMove()
        end

        if key=="n" then
            self.metalMan:switchType()
            self.magnetmanager:changeMetalType(self.metalMan,self.metalMan.oldMetal,self.metalMan.metalType)
        end

        if key=="c" then
            self.levelFinished=true
        end
    end

    function Gameplay:sendTheWorld()
        for k,c in pairs(clients) do    
            local packet={}
            if c.perso=="metalman" then
                packet.camera=self.cameraMM:toSend()
                packet.map=self.mapLoader:toSend(self.cameraMM:getPos())
                packet.metalman=self.metalMan:mainSend(self.cameraMM:getPos())
                packet.themagnet=self.theMagnet:secondSend(self.cameraMM:getPos().x-windowW/2,windowH/2-self.cameraMM:getPos().y)
            elseif c.perso=="themagnet" then
                packet.camera=self.cameraTM:toSend()
                packet.map=self.mapLoader:toSend(self.cameraTM:getPos())
                packet.themagnet=self.theMagnet:mainSend(self.cameraTM:getPos())
                packet.metalman=self.metalMan:secondSend(self.cameraTM:getPos().x-windowW/2,windowH/2-self.cameraTM:getPos().y)
            end
        -- Envoyer ici packet (seld.Send(packet))
        -- print("Envoi de :", table2.tostring(packet))

            c:send({type= "gameplaypacket", pk= packet})
        end
    end


    function Gameplay:keyReleased(key, unicode)
        if key =="i" then
            self.theMagnet:disableStaticField()
        end

        if key =="o" or key =="p" or key =="k"or key =="l"then
            self.theMagnet:disableField()
        end
        if key =="d" then
            self.metalMan:stopMove()
        end

        if key =="q" then
            self.metalMan:stopMove()
        end

        if key =="left" then
            self.theMagnet:stopMove()
        end

        if key =="right" then
            self.theMagnet:stopMove()
        end

    end
    
    
    function Gameplay:update(dt)
        -- print("DELTA TIME IS ==", dt)
        self.lastTime = self.lastTime + dt
        if self.lastTime > self.maxTime then
            self:sendTheWorld()
            self.lastTime = 0
        end

        if(self.levelFinished) then
			inputManager:clearInputs()
            gameStateManager.state['LevelEnding']=LevelEnding.new(self.mapLoader.levelends[1].next,self.continuous)
            gameStateManager:changeState('LevelEnding')
            packet={
            levelfinish=true,
            continuous=self.continuous,
            next=self.mapLoader.levelends[1].next
        }
        for k,c in pairs(clients) do
            c:send({type= "gameplaypacket", pk= packet})
        end            return
        end

        if(self.shouldEnd) then
            inputManager:clearInputs()
            gameStateManager.state['LevelFailed']=LevelFailed.new()
            gameStateManager:changeState('LevelFailed')
            packet={
            levelfailed=true
        }           
        for k,c in pairs(clients) do
            c:send({type= "gameplaypacket", pk= packet})
        end
        return
        end        
        world:update(dt) 
        self.magnetmanager:update(dt)   

        -- Other stuff
        self.cameraMM:update(dt)
        self.cameraTM:update(dt)
        self.theMagnet:update(dt)
        self.metalMan:update(dt)
        self.mapLoader:update(dt)
    end
    
    function Gameplay:draw()
        if self.drawWho==1 then
            self.mapLoader:draw(self.cameraMM:getPos())
            self.theMagnet:secondDraw(self.cameraMM:getPos().x-windowW/2,windowH/2-self.cameraMM:getPos().y)
            self.metalMan:draw()
            self.mapLoader:firstPlanDraw(self.cameraMM:getPos())

        else
            self.mapLoader:draw(self.cameraTM:getPos())
            self.metalMan:secondDraw(self.cameraTM:getPos().x-windowW/2,windowH/2-self.cameraTM:getPos().y)
            self.theMagnet:draw() 
            self.mapLoader:firstPlanDraw(self.cameraTM:getPos())

        end
    end
    
    
    function beginContact(a, b, coll)
        local x,y = coll:getNormal()
        b:getUserData():collideWith(a:getUserData(), coll)
        a:getUserData():collideWith(b:getUserData(), coll)

    end
    
    function endContact(a, b, coll)
    local x,y = coll:getNormal()
    b:getUserData():unCollideWith(a:getUserData(), coll)
    a:getUserData():unCollideWith(b:getUserData(), coll)
    collectgarbage()
end

function preSolve(a, b, coll)
    local o1 = a:getUserData()
    local o2 = b:getUserData()

    if o1.preSolve then
    	o1:preSolve(o2, coll)
    end

    if o2.preSolve then
    	o2:preSolve(o1, coll)
    end
end

function Gameplay:postSolve(a, b, coll)
-- we won't do anything with this function
end

function Gameplay:shakeOnX(dx,speed,duration)
    self.cameraMM:shakeOnX(dx,speed,duration)
    self.cameraTM:shakeOnX(dx,speed,duration)
end

function Gameplay:shakeOnY(dy,speed,duration)
    self.cameraMM:shakeOnY(dy,speed,duration)
    self.cameraTM:shakeOnY(dy,speed,duration)
end