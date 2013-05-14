AnimBlocSolo = {}
AnimBlocSolo.__index = AnimBlocSolo

AnimBlocSolo.ANIMS = {  -- set of animations available :
	normal = {}
}


-- name
AnimBlocSolo.ANIMS.normal.name = "normal"
-- number of sprites :
AnimBlocSolo.ANIMS.normal.number = 4


AnimBlocSolo.ANIMS.normal.DELAY= 0.2
-- priority 
AnimBlocSolo.ANIMS.normal.priority = 10


-- automatic loopings or automatic switch :
AnimBlocSolo.ANIMS.normal.loop = true



-- PUBLIC : constructor
function AnimBlocSolo.new(folder)
	local self = {}
	setmetatable(self, AnimBlocSolo)
	self.time = 0.0
	self.sprites = {}
	for key,val in pairs(AnimBlocSolo.ANIMS) do
		self.sprites[key] = {}
		for i=1, val.number do
			local path = 'game/anim/'..folder..'/'..key..'/'..i..'.png'
			-- print("loading image =>", path)
			gameStateManager.loader.newImage(self.sprites[key],i, path)
		end
	end
	self.currentAnim = AnimBlocSolo.ANIMS.normal
	self.currentPos = 1
	-- begin of an animation
	if self.currentAnim.beginCallback then
		self.currentAnim.beginCallback()
	end
	self:updateImg()
	return self
end

-- PUBLIC : getter for the sprite
function AnimBlocSolo:getSprite()
	return self.currentImg
end

-- PUBLIC : change animation (you can force it)
function AnimBlocSolo:load(anim, force)
	local newAnim = AnimBlocSolo.ANIMS[anim]
	if force or newAnimBlocSolo.priority > self.currentAnim.priority then
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
function AnimBlocSolo:update(seconds)
	self.time = self.time + seconds
	if self.time > self.currentAnim.DELAY then
		self:next()
		self.time = self.time - self.currentAnim.DELAY
	end
end

-- PRIVATE : go to next sprite
function AnimBlocSolo:next()
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
function AnimBlocSolo:updateImg()
	self.currentImg = self.sprites[self.currentAnim.name][self.currentPos]
end

-- NETWORK
function AnimBlocSolo:getImgInfo()
	return {self.currentAnim.name,self.currentPos}
end