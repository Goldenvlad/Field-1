--[[ 
This file is part of the Field project]]


require("game.camera")
require("game.animmm")
require("game.metalmanconst")
MetalMan = {}
MetalMan.__index = MetalMan

function MetalMan.new(camera,pos,powers)
	local self = {}
	setmetatable(self, MetalMan)

	-- The camera
	self.camera=camera

	-- The position initiate
	self.position={x=pos.x,y=pos.y}

	-- The physics components
	self.pc = Physics.newCharacter(self.position.x,self.position.y,unitWorldSize/2,false)
	self.pc.fixture:setUserData(self)
	self.pc.fixture:getUserData():reset()
	self.gs = self.pc.body:getGravityScale()
	self.metalWeight=MetalMTypes.Alu
	self.pc.body:setMass(self.metalWeight*unitWorldSize)


	-- Animation state
	self:setState("standing")
	self.anim = AnimMM.new('metalman/alu')
	self:loadAnimation("standing",true)
	self.goF=true
	self.animCounter=0

	-- Other states
	self.canjump=true
	self.isStatic=false
	self.strenght=MetalManFieldStr
	self.metalType=MetalTypes.Normal
	self.oldType=MetalTypes.Normal
	self.type='MetalMan'

	self.alive=true

	self.willrotate=false

	self.collisionCounter=0
	self.powers={}
	if powers~=nil then
		for k in string.gmatch(powers, "([^#]+)") do
			print(k)
			self.powers[k] = true
		end
	end
	return self
end

function MetalMan:reset()
end


function MetalMan:die(type)
	if self.alive then
		self.alive=false
		if(type=="acid") then
		else
			self:loadAnimation("mortelec",true)	
		end
	end
end


function MetalMan:jump()
	if self.canjump and not self.isStatic then
		if 	self.metalWeight==MetalMTypes.Alu then
			self.pc.body:applyLinearImpulse(0, MetalManJumpImpulse.Alu)
		else
			self.pc.body:applyLinearImpulse(0, MetalManJumpImpulse.Acier)
		end
	self:setState("startjumping")
	self:loadAnimation("startjumping",true)
	self.canjump=false
	end
end

function MetalMan:rotativeLField(pos,factor)
	local vx=self.position.x-pos.x +0.01
	local vy=self.position.y-pos.y
	local n = math.sqrt(vx*vx+vy*vy)
	local vrx = vx/n
	local vry= vy/n
	self.pc.body:applyLinearImpulse(-vry*MetaManRotFieldS.x*factor,vrx*MetaManRotFieldS.y*factor)
	self.willrotate=true
end

function MetalMan:rotativeRField(pos,factor)
	local vx=self.position.x-pos.x+0.01
	local vy=self.position.y-pos.y
	local n = math.sqrt(vx*vx+vy*vy)
	local vrx = vx/n
	local vry= vy/n
	self.pc.body:applyLinearImpulse(vry*MetaManRotFieldS.x*factor,-vrx*MetaManRotFieldS.y*factor)
	self.willrotate=true	
end

function MetalMan:attractiveField(pos,factor)
	local vx=-self.position.x+pos.x+0.01
	local vy=-self.position.y+pos.y
	local n = math.sqrt(vx*vx+vy*vy)
	local vrx = vx/n
	local vry= vy/n
	if(n>(unitWorldSize)) then 
		self.pc.body:applyLinearImpulse(vrx*MetaManAttFieldS.x*factor,vry*MetaManAttFieldS.y*factor)
	end
	self.willrotate=false	
end


function MetalMan:repulsiveField(pos,factor)
	local vx=self.position.x-pos.x
	local vy=self.position.y-pos.y
	local n = math.sqrt(vx*vx+vy*vy)
	local vrx = vx/n
	local vry = vy/(n*n)
	if(n>(unitWorldSize)) then 
		self.pc.body:applyLinearImpulse(vrx*MetaManRepFieldS.x*factor,vry*MetaManRepFieldS.y*100*factor)
	end
	self.willrotate=false
end

function MetalMan:setVelocity(x,y)
	self.pc.body:setLinearVelocity(x,y)
end

function MetalMan:initStaticField()
	self.pc.body:setLinearVelocity(0,0)
	self.isStatic=true
	self.pc.body:setGravityScale(0)
end

function MetalMan:disableField()

end


function MetalMan:changeMass()
	if self.alive then
		print("BING")
		if 	self.metalWeight==MetalMTypes.Alu then
				print("BONG")

			if self.powers["Acier"] then
				print("zdzdz")

				self.anim = AnimMM.new('metalman/acier')
				self:loadAnimation("standing",true)
				self:loadAnimation("load1",true)
				self.metalWeight=MetalMTypes.Acier
			end
		elseif 	self.metalWeight==MetalMTypes.Acier then
			print("BANG")
			if self.powers["Alu"] then
				print("JZBNDZ")
				self.metalWeight=MetalMTypes.Alu
				self.anim = AnimMM.new('metalman/alu')
				self:loadAnimation("load2",true)
			end
		end
		self.pc.body:setMass(self.metalWeight*unitWorldSize)
	end
end

function MetalMan:cancelStaticField()
		self.isStatic=false
		self.pc.body:setGravityScale(self.gs)
		self.pc.body:applyLinearImpulse(0, 1)
end
function MetalMan:setState( state )
	self.state = state
end

function MetalMan:switchType()
if self.alive then

	if self.metalType ==MetalTypes.Normal then
		if self.powers["Static"] then
			self.oldMetal = self.metalType
			self.metalType=MetalTypes.Static
			self.anim = AnimMM.new('metalman/static')
			if 	self.metalWeight==MetalMTypes.Alu then
				self:loadAnimation("load1",true)
			elseif 	self.metalWeight==MetalMTypes.Acier then
				self:loadAnimation("load2",true)
			end
			self.isStatic=true
		end
	elseif self.metalType ==MetalTypes.Static then
		if self.powers["Acier"] or  self.powers["Alu"] then
			self.oldMetal = self.metalType
			self.metalType=MetalTypes.Normal
			self.isStatic=false
			if 	self.metalWeight==MetalMTypes.Alu then
				self.anim = AnimMM.new('metalman/alu')
				self:loadAnimation("load1",true)
			elseif 	self.metalWeight==MetalMTypes.Acier then
				self.anim = AnimMM.new('metalman/acier')
				self:loadAnimation("load2",true)
			end
		end

	end
end
end

function MetalMan:getSpeed(  )
end

function MetalMan:collideWith( object, collision )

	if self.alive then
		if object.type=='GateInterruptor' or object.type=='Interruptor' or object.type=='TheMagnet' then
			--Ghost dude
		else
			self.collisionCounter=self.collisionCounter+1
			if self.metalWeight==MetalMTypes.Acier then
				vx,vy =self.pc.body:getLinearVelocity() 
				local kinEnergyX = math.log(0.5*self.pc.body:getMass()*self.pc.body:getMass()*self.pc.body:getMass()*math.abs(vx))
				local kinEnergyY = math.log(0.5*self.pc.body:getMass()*self.pc.body:getMass()*self.pc.body:getMass()*math.abs(vy))
				if kinEnergyX>10.9 or kinEnergyY>11 then
					gameStateManager.state["Gameplay"]:shakeOnX(2,100,0.2)
					gameStateManager.state["Gameplay"]:shakeOnY(2,100,0.2)
				end
			end
			if self.isStatic==true  then
					gameStateManager.state["Gameplay"]:shakeOnX(5,100,0.2)
					gameStateManager.state["Gameplay"]:shakeOnY(5,100,0.2)
			end

			if(object:getPosition().y>self.position.y) then
				self.canjump=true
				if self.animCounter>0 then 
					if self.anim.currentAnim.name~="running" then
						self:loadAnimation("running",true)
					end
				else
					self:setState('landing')
					self:loadAnimation("landing",true)
				end
			end	
		end
	end
end


function MetalMan:unCollideWith( object, collision )
	if self.alive then
		if object.type=='GateInterruptor' or object.type=='Interruptor' or object.type=='TheMagnet' then
			--Ghost dude
		else
			self.collisionCounter=self.collisionCounter-1
		end
	end
	if self.willrotate and self.collisionCounter==0 then
		self:loadAnimation("startjumping",true)
		self.canjump=false
	end
end

function MetalMan:still(  )
end

function MetalMan:teleport( x,y )
end

function MetalMan:left( )
end

function MetalMan:startMove(  )

	if self.alive then
		self.animCounter=self.animCounter+1
		if self.canjump and not self.isStatic then
			x,y=self.pc.body:getLinearVelocity()
			if((not self.goF and x>=0) or ( self.goF and x<=0))then
				self:loadAnimation("running",true)
			else
				self:loadAnimation("returnanim",true)
			end
		end
	end
end


function MetalMan:stopMove( )
	if self.alive then
		self.animCounter=self.animCounter-1
		x,y=self.pc.body:getLinearVelocity()
		self.pc.body:setLinearVelocity(x/MetalManBreakFactor,y/MetalManBreakFactor)
		if self.canjump and not self.isStatic  and self.animCounter==0 then
			self:loadAnimation("stoprunning",true)	
		end
	end
end
	
	function MetalMan:staticField(magnet)
		
	end

function MetalMan:getPosition(  )
	return self.position
end

function MetalMan:loadAnimation(anim, force)
		self.anim:load(anim, force)
end

function MetalMan:update(seconds)
	x,y =self.pc.body:getLinearVelocity()
	if x>MetalManMaxSpeed then
		self.pc.body:setLinearVelocity(MetalManMaxSpeed,y)
	end

	if x<-MetalManMaxSpeed then
		self.pc.body:setLinearVelocity(-MetalManMaxSpeed,y)
	end
	self.anim:update(seconds)
	x,y =self.pc.body:getPosition()
	self.position.x=x
	self.position.y=y
	self.camera:newPosition(x,y)

	if self.alive then
		if self.animCounter >=1 and self.anim.currentAnim.name=="standing" then
			self:loadAnimation("running",true)	
		end
		if not self.isStatic  then
			if inputManager:isKeyDown("d") then
				if self.metalWeight==MetalMTypes.Alu then
					self.pc.body:applyForce(MetalManMovingForce.Alu, 0)
				else
					self.pc.body:applyForce(MetalManMovingForce.Acier, 0)
				end
				self.goF=true

			elseif inputManager:isKeyDown("q") then 
				if self.metalWeight==MetalMTypes.Alu then
					self.pc.body:applyForce(-MetalManMovingForce.Alu, 0)
				else
					self.pc.body:applyForce(-MetalManMovingForce.Acier, 0)
				end
				self.goF=false
			end
		end
	end
	-- print "update MM"
end

function MetalMan:draw()
    	if 	self.goF then
    		love.graphics.draw(self.anim:getSprite(), windowW/2-unitWorldSize/2,windowH/2-unitWorldSize/2, 0, 1,1)
    	else
    		love.graphics.draw(self.anim:getSprite(), windowW/2+unitWorldSize/2,windowH/2-unitWorldSize/2,0 , -1,1)
    	end
end

-- Draws the character to screen
function MetalMan:secondDraw(x,y)

	-- Draws the character
	if self.goF then
	love.graphics.draw(self.anim:getSprite(), self.position.x-x-unitWorldSize/2, self.position.y+y-unitWorldSize/2, 0, 1,1)
	else
	love.graphics.draw(self.anim:getSprite(), self.position.x-x+unitWorldSize/2, self.position.y+y-unitWorldSize/2, 0, -1,1)
	end
end

-- Return the character to screen
function MetalMan:secondSend(x,y)
	if self.goF then
    	return ("@metalman".."#"..self.anim.folder.."#"..self.anim:getImgInfo()[1].."#"..self.anim:getImgInfo()[2].."#"..math.floor(self.position.x-x-unitWorldSize/2).."#"..math.floor( self.position.y+y-unitWorldSize/2).."#".."1")
	else
    	return ("@metalman".."#"..self.anim.folder.."#"..self.anim:getImgInfo()[1].."#"..self.anim:getImgInfo()[2].."#"..math.floor(self.position.x-x+unitWorldSize/2).."#"..math.floor( self.position.y+y-unitWorldSize/2).."#".."-1")
    end
end

-- Return the character to screen
function MetalMan:mainSend(x,y)
	if self.goF then
    	return ("@metalman".."#"..self.anim.folder.."#"..self.anim:getImgInfo()[1].."#"..self.anim:getImgInfo()[2].."#"..math.floor(windowW/2-unitWorldSize/2).."#"..math.floor( windowH/2-unitWorldSize/2).."#".."1")
	else
    	return ("@metalman".."#"..self.anim.folder.."#"..self.anim:getImgInfo()[1].."#"..self.anim:getImgInfo()[2].."#"..math.floor(windowW/2+unitWorldSize/2).."#"..math.floor( windowH/2-unitWorldSize/2).."#".."-1")
    end
end