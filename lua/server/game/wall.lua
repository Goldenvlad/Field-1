--[[ 
This file is part of the Field project
]]

require("const")
Wall = {}
Wall.__index =  Wall

function Wall.new(position, length, spriteB, spriteM, spriteE)
    local self = {}
    setmetatable(self, Wall)
    self.position={x=position.x,y=position.y}
    self.spriteB=spriteB
    self.spriteM=spriteM
    self.spriteE=spriteE
    self.length=length
    self.w=unitWorldSize
    self.h=length
        self.type='Wall'
    decalage={unitWorldSize/2,self.length/2}

    -- print("Mur "..self.positionition[1].." "..self.position[2].." "..unitWorldSize.." "..self.length)
    self.pc = Physics.newRectangle(self.position.x,self.position.y,unitWorldSize,self.length,true,decalage)
    self.pc.fixture:setUserData(self)

    return self
end

function Wall:getPosition()
    return self.position
end

function Wall:update(dt)
end

function Wall:collideWith( object, collision )

end

function Wall:unCollideWith( object, collision )

end

function Wall:draw(x,y)

end

function Wall:send(x,y)
    return "@wall"
end