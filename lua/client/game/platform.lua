--[[ 
This file is part of the Field project
]]

require("const")

require("game.physics")
Platform = {}
Platform.__index =  Platform

function Platform.new(position, length, spriteB, spriteM, spriteE)
    local self = {}
    setmetatable(self, Platform)
    self.position={x=position.x,y=position.y}
    self.spriteB=spriteB
    self.spriteM=spriteM
    self.spriteE=spriteE
    self.length=length
    self.w=length
    self.h=unitWorldSize
    self.type='Platform'
    decalage={self.length/2,unitWorldSize/4}

    -- print("Sol "..self.position[1].." "..self.position[2].." "..unitWorldSize.." "..self.length)
    self.pc = Physics.newRectangle(self.position.x,self.position.y,self.length,unitWorldSize/2,true,decalage)
    self.pc.fixture:setUserData(self)
    return self
end


function Platform:getPosition()
    return self.position
end
function Platform:update(dt)
end

function Platform:collideWith( object, collision )

end

function Platform:unCollideWith( object, collision )

end
function Platform:draw(x,y)
end

function Platform:send(x,y)
    return "@platform".."#"
end