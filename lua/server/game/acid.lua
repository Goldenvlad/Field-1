
require("game.animacid")
require("game.animsplash")


Acid = {}
Acid.__index = Acid
Acid.Types ={hg='hg',hm='hm',hd='hd',mg='mg',mm='mm',md='md',bg='bg',bm='bm',bd='bd'}


TimerAcid =1


function Acid.new(pos,w,h,type,netid)
	local self = {}
	setmetatable(self, Acid)

	self.netid=netid
	self.position={x=pos.x,y=pos.y}
	if type==Acid.Types.hg  or type==Acid.Types.hm or type==Acid.Types.hd then
		self.dec=20
		self.splash=AnimSplash.new('splash')
	else
		self.dec=0
	end
	self.w=w
	self.h=h-self.dec
	local decalage={self.w/2,self.h/2}
	self.pc = Physics.newZone(self.position.x,self.position.y+self.dec,self.w,self.h,decalage)
	self.pc.fixture:setUserData(self)
	self.type='Acid'
	self.acidType=type
	self.anim = AnimAcid.new('acid/'..type)
	self:loadAnimation("normal",true)
	self.isTouched=false
	self.timer=0
	self.splashpos={x=0,y=0}	
	return self
end


function Acid:loadAnimation(anim, force)
	self.anim:load(anim, force)
end


function Acid:getPosition()
	return self.position
end


function Acid:preSolve(b,coll)
end



function Acid:collideWith( object, collision )
	if object.type=='MetalMan' or object.type =='TheMagnet' then
		self.isTouched=true
		if self.acidType==Acid.Types.hg  or self.acidType==Acid.Types.hm or self.acidType==Acid.Types.hd then
			self.splash:load("kill",true)
			pos=object:getPosition()
			self.splashpos={x=pos.x,y=pos.y}
		end
		object:die("acid")
	end
end

function Acid:unCollideWith( object, collision )

end

function Acid:update(seconds)
	if self.isTouched then
		self.timer=self.timer+seconds
	end

	if self.acidType==Acid.Types.hg  or self.acidType==Acid.Types.hm or self.acidType==Acid.Types.hd then
		self.splash:update(seconds)
	end
	self.anim:update(seconds)
	x,y =self.pc.body:getPosition()
	self.position.x=x
	self.position.y=y-self.dec
	if(self.timer>=TimerArc) then
		self.isTouched=false
		gameStateManager:failed()
	end	
end

function Acid:draw(x,y)
	love.graphics.setColor(255,255,255,255)
	if self.acidType==Acid.Types.hg  or self.acidType==Acid.Types.hm or self.acidType==Acid.Types.hd then
		love.graphics.draw(self.splash:getSprite(), self.splashpos.x-x-unitWorldSize/2, self.splashpos.y+y-unitWorldSize+self.dec)
	end
	love.graphics.draw(self.anim:getSprite(), self.position.x-x, self.position.y+y)

end


function Acid:send(x,y)
	if self.acidType==Acid.Types.hg  or self.acidType==Acid.Types.hm or self.acidType==Acid.Types.hd then
		return ("@acid".."#"..self.netid.."#"..self.acidType.."#"..self.anim:getImgInfo()[1].."#"..self.anim:getImgInfo()[2].."#"..math.floor(self.position.x-x).."#"..math.floor(self.position.y+y).."#".."true".."#"..self.splash:getImgInfo()[1].."#"..self.splash:getImgInfo()[2].."#"..math.floor(self.splashpos.x-x-unitWorldSize/2).."#"..math.floor(self.splashpos.y+y-unitWorldSize+self.dec+3))
	else
		return ("@acid".."#"..self.netid.."#"..self.acidType.."#"..self.anim:getImgInfo()[1].."#"..self.anim:getImgInfo()[2].."#"..math.floor(self.position.x-x).."#"..math.floor(self.position.y+y).."#".."false")
	end
end
