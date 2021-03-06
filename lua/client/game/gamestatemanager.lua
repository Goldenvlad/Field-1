--[[ 
This file is a part of the Field project
]]

require("game.prelude")
require("game.storyline")
require("game.graphicchecks")
require("game.firstenter")

require("game.cinematic.cinematic")


require("game.connecttoserver")
require("game.choixtypejeu")
require("game.choixperso")
require("game.choixniveau")
require("game.waitingfordistant")
require("game.levelbegin")
require("game.gameplay")
require("game.menu")
require("game.credits")
require("game.options")


require("game.solo.choixniveausolo")
require("game.solo.choixtypejeusolo")
require("game.solo.choixpersosolo")
require("game.solo.levelfailedsolo")
require("game.solo.levelendingsolo")



GameStateManager = {}
GameStateManager.__index = GameStateManager

function GameStateManager.new()
	local self = {}
	setmetatable(self, GameStateManager)

	-- Loader
    self.loader = require 'game/love-loader'


	-- Global States
	self.state = {}
	self.state['Prelude'] = Prelude.new()
	self.state['Storyline'] = Storyline.new()
	self.state['GraphicChecks'] = GraphicChecks.new()
	self.state['FirstEnter'] = FirstEnter.new()
	self.state['Menu'] = Menu.new()
	self.state['Credits'] = Credits.new()
	self.state['Options'] = Options.new()

	-- Jeu Réseau
	self.state['ConnectToServer'] = ConnectToServer.new()
	self.state['ChoixTypeJeu'] = ChoixTypeJeu.new()
	self.state['ChoixPerso'] = ChoixPerso.new()
	self.state['ChoixNiveau'] = ChoixNiveau.new()
	self.state['WaitingForDistant'] = WaitingForDistant.new()
	self.state['LevelBegin'] = LevelBegin.new()
	self.state['Gameplay'] = nil

	-- self.state['Cinematic'] = Cinematic.new("exemple")



	-- Jeu Solo
	self.state['ChoixTypeJeuSolo'] = ChoixTypeJeuSolo.new()	
	self.state['ChoixNiveauSolo'] = nil
	self.state['ChoixPersoSolo'] = nil
	self.state['GameplaySolo'] = nil
	self.state['LevelEndingSolo'] = nil
	self.state['LevelFailedSolo'] = nil
	-- self.state['ChoixNiveauSolo'] = ChoixNiveauSolo.new("metalman",false)
-- 
	-- Init
	self.currentState='GraphicChecks'
	self.state[self.currentState]:reset()
	return self
end

function GameStateManager:onMessage(msg)
	if self.state[self.currentState].onMessage then
		self.state[self.currentState]:onMessage(msg)
	else
		-- Problème sérieux
		assert(false)
	end
end

function GameStateManager:mousePressed(x, y, button)
	self.state[self.currentState]:mousePressed(x,y,button)
end

function GameStateManager:mouseReleased(x, y, button)
	self.state[self.currentState]:mouseReleased(x,y,button)
end

function GameStateManager:keyPressed(key, unicode)

	self.state[self.currentState]:keyPressed(key, unicode)
end

function GameStateManager:keyReleased(key, unicode)
	self.state[self.currentState]:keyReleased(key, unicode)
end

function GameStateManager:joystickPressed(joystick, button)
	self.state[self.currentState]:joystickPressed(joystick, button)
end

function GameStateManager:joystickReleased(joystick, button)
	self.state[self.currentState]:joystickReleased(joystick, button)
end

function GameStateManager:update(dt)
	self.state[self.currentState]:update(dt)
end

function GameStateManager:reset()	
	self.state[self.currentState]:reset()
end
function GameStateManager:draw()	
	self.state[self.currentState]:draw()
end
function GameStateManager:changeState(newState)
	self.currentState = newState
end
function GameStateManager:resetLoader()
	self.loader = nil
	self.loader = require 'game/love-loader'
end


function GameStateManager:resetAndChangeState(newState)
	self.state[newState]:reset()
	self.currentState=newState
end

function GameStateManager:failed()
	self.state[self.currentState]:failed()
end

function GameStateManager:finish()
	self.state[self.currentState]:finish()
end
