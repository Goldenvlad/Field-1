AnimMM = {}
AnimMM.__index = AnimMM

AnimMM.ANIMS = {  -- set of animations available :
	running = {},
	startjumping = {},
	jumping = {},
	landing = {},
	standing= {},
	stoprunning={},
	returnanim={},
	load1={},
	load2={},
	mortelec={},
	mort={}
}

AnimMM.DELAY = 0.0750  -- toutes les 200ms, on fait AnimMM.next()

-- name
AnimMM.ANIMS.running.name = "running"
AnimMM.ANIMS.startjumping.name = "startjumping"
AnimMM.ANIMS.jumping.name = "jumping"
AnimMM.ANIMS.landing.name = "landing"
AnimMM.ANIMS.standing.name = "standing"
AnimMM.ANIMS.stoprunning.name = "stoprunning"
AnimMM.ANIMS.returnanim.name = "returnanim"
AnimMM.ANIMS.load1.name = "load1"
AnimMM.ANIMS.load2.name = "load2"
AnimMM.ANIMS.mortelec.name = "mortelec"
AnimMM.ANIMS.mort.name = "mort"


-- delays
AnimMM.ANIMS.running.DELAY = 0.075
AnimMM.ANIMS.startjumping.DELAY = 0.075
AnimMM.ANIMS.jumping.DELAY = 0.300
AnimMM.ANIMS.landing.DELAY = 0.075
AnimMM.ANIMS.standing.DELAY = 0.150
AnimMM.ANIMS.stoprunning.DELAY = 0.075
AnimMM.ANIMS.returnanim.DELAY = 0.2
AnimMM.ANIMS.load1.DELAY = 0.06
AnimMM.ANIMS.load2.DELAY = 0.06
AnimMM.ANIMS.mortelec.DELAY = 0.1
AnimMM.ANIMS.mort.DELAY = 1


-- number of sprites :
AnimMM.ANIMS.running.number = 9
AnimMM.ANIMS.startjumping.number = 3
AnimMM.ANIMS.jumping.number = 1
AnimMM.ANIMS.landing.number = 3
AnimMM.ANIMS.standing.number = 6
AnimMM.ANIMS.stoprunning.number = 1
AnimMM.ANIMS.returnanim.number = 1
AnimMM.ANIMS.load1.number = 10
AnimMM.ANIMS.load2.number = 10
AnimMM.ANIMS.mortelec.number = 8
AnimMM.ANIMS.mort.number = 1



-- priority :
AnimMM.ANIMS.running.priority = 10
AnimMM.ANIMS.startjumping.priority = 20
AnimMM.ANIMS.jumping.priority = 20
AnimMM.ANIMS.landing.priority = 20
AnimMM.ANIMS.standing.priority = 20
AnimMM.ANIMS.stoprunning.priority = 20
AnimMM.ANIMS.returnanim.priority = 20
AnimMM.ANIMS.load1.priority = 20
AnimMM.ANIMS.load2.priority = 20
AnimMM.ANIMS.mortelec.priority = 20
AnimMM.ANIMS.mort.priority = 1


-- automatic loopings or automatic switch :
AnimMM.ANIMS.running.loop = true
AnimMM.ANIMS.startjumping.switch = AnimMM.ANIMS.jumping
AnimMM.ANIMS.jumping.loop = true
-- AnimMM.ANIMS.landing.switch = AnimMM.ANIMS.standing
AnimMM.ANIMS.standing.loop = true
AnimMM.ANIMS.stoprunning.switch = AnimMM.ANIMS.standing
AnimMM.ANIMS.returnanim.loop = true
AnimMM.ANIMS.load1.switch = AnimMM.ANIMS.standing
AnimMM.ANIMS.load2.switch = AnimMM.ANIMS.standing
AnimMM.ANIMS.mortelec.switch = AnimMM.ANIMS.mort
AnimMM.ANIMS.mort.loop = true


-- next anim available :
AnimMM.ANIMS.running.nexts = {
	AnimMM.ANIMS.running,
	AnimMM.ANIMS.startjumping,
	AnimMM.ANIMS.landing,
	AnimMM.ANIMS.dying,
}
AnimMM.ANIMS.startjumping.nexts = {
	AnimMM.ANIMS.jumping,
	AnimMM.ANIMS.dying
}
AnimMM.ANIMS.jumping.nexts = {
	AnimMM.ANIMS.landing,
	AnimMM.ANIMS.dying
}
AnimMM.ANIMS.landing.nexts = {
	AnimMM.ANIMS.running,
	AnimMM.ANIMS.dying
}


-- PUBLIC : constructor
function AnimMM.new(folder)
	local self = {}
	setmetatable(self, AnimMM)
	self.folder=folder
	self.time = 0.0
	self.sprites = {}
	for key,val in pairs(AnimMM.ANIMS) do
		self.sprites[key] = {}
		for i=1, val.number do
			local path = 'game/anim/'..folder..'/'..key..'/'..i..'.png'
			-- print("loading image =>", path)
			self.sprites[key][i] = love.graphics.newImage(path)
		end
	end
	self.currentAnim = AnimMM.ANIMS.running
	self.currentPos = 1
	-- begin of an animation
	if self.currentAnim.beginCallback then
		self.currentAnim.beginCallback()
	end
	self:updateImg()
	return self
end

-- PUBLIC : getter for the sprite
function AnimMM:getSprite()
	return self.currentImg
end
-- PUBLIC : change animation (you can force it)
function AnimMM:syncronize(anim, pos)
	local newAnim = AnimMM.ANIMS[anim]
		self.currentAnim = newAnim
		self.currentPos = pos
		self:updateImg()
		--self.currentAnim.after = newAnim		
end

-- PUBLIC : change animation (you can force it)
function AnimMM:load(anim, force)
	local newAnim = AnimMM.ANIMS[anim]
	if force or newAnimMM.priority > self.currentAnim.priority then
		self.currentAnim = newAnim
		self.currentPos = 1
		-- begin of an animation
		if self.currentAnim.beginCallback then
			self.currentAnim.beginCallback()
		end
		self:updateImg()
	else
		self.currentAnim.after = newAnim
	end
end

-- PUBLIC : update l'anim
function AnimMM:update(seconds)
	self.time = self.time + seconds
	if self.time > self.currentAnim.DELAY then
		self:next()
		self.time = self.time - self.currentAnim.DELAY
	end
end

-- PRIVATE : go to next sprite
function AnimMM:next()
	self.currentPos = self.currentPos + 1
	if self.currentPos > self.currentAnim.number then
		-- end of an animation
		if self.currentAnim.endCallback then
			self.currentAnim.endCallback()
		end
		if self.currentAnim.after ~= nil then
			self.currentAnim = self.currentAnim.after
		elseif self.currentAnim.switch ~= nil then
			self.currentAnim = self.currentAnim.switch
		elseif self.currentAnim.loop then
			-- I don't switch
		else
			return
			print("FUCKING ANIM SWITCHING ERROR")
		end
		self.currentPos = 1
		-- begin of an animation
		if self.currentAnim.beginCallback then
			self.currentAnim.beginCallback()
		end
	end
	self:updateImg()
end

-- PRIVATE
function AnimMM:updateImg()
	self.currentImg = self.sprites[self.currentAnim.name][self.currentPos]
end

-- NETWORK
function AnimMM:getImgInfo()
	return {self.currentAnim.name,self.currentPos}
end