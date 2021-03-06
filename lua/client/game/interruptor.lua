

require("game.animinter")


Interruptor = {}
Interruptor.__index = Interruptor


function Interruptor.new(pos,anim,id, timers)
	local self = {}
	setmetatable(self, Interruptor)
	self.position={x=pos.x,y=pos.y}
	self.drawed=true	
	self.type='Interruptor'
	self.anim = AnimInter.new('switch/gene')
	self.anim:syncronize(anim,id)
	self.diffuse  = love.graphics.newQuad(0, 0, 64, 64, 128, 64)

	return self
end


function Interruptor:getPosition()
	return self.position
end

function Interruptor:syncronize(pos,anim,id)
	if (self.anim.currentAnim.name~=anim) then
		self.anim:syncronize(anim,id)   
	end
	self.position.x=pos.x
	self.position.y=pos.y
	self.drawed=true
end

function Interruptor:loadAnimation(anim, force)
		self.anim:load(anim, force)
end

function Interruptor:update(seconds)
	self.anim:update(seconds)

end

function Interruptor:draw()
    	love.graphics.drawq(self.anim:getSprite(), self.diffuse,self.position.x, self.position.y)
end