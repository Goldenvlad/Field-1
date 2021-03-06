--[[ 
This file is a part of the Field project
]]

require("game.prelude")
require("game.storyline")
require("game.firstenter")
require("game.connecttoserver")
require("game.waitingfordistant")
require("game.levelbegin")
require("game.gameplay")

require('game.gamestates.attentetest')
require('game.gamestates.attente')
require('game.gamestates.choixtypejeu')
require('game.gamestates.arcadechoixperso')
require('game.gamestates.arcadechoixniveau')
require('game.gamestates.arcade')
require('game.gamestates.histoirechoixperso')
require('game.gamestates.histoire')

GameStateManager= {}
GameStateManager.__index = GameStateManager

function GameStateManager.new()
	local self = {}
	setmetatable(self, GameStateManager)
	self.state = {
		attente= common.instance(Attente),
		choixTypeJeu= common.instance(ChoixTypeJeu),
		arcadeChoixPerso= common.instance(ArcadeChoixPerso),
		arcadeChoixNiveau= common.instance(ArcadeChoixNiveau),
		arcade= common.instance(Arcade),
		histoireChoixPerso= common.instance(HistoireChoixPerso),
		histoire= common.instance(Histoire)
	}
	self.currentState='attente'
	return self
end


function GameStateManager:reset()
	self.state = {
		attente= common.instance(Attente),
		choixTypeJeu= common.instance(ChoixTypeJeu),
		arcadeChoixPerso= common.instance(ArcadeChoixPerso),
		arcadeChoixNiveau= common.instance(ArcadeChoixNiveau),
		arcade= common.instance(Arcade),
		histoireChoixPerso= common.instance(HistoireChoixPerso),
		histoire= common.instance(Histoire)
	}
	self.currentState='attente'
end


function GameStateManager:onMessage(msg, client)
	self.state[self.currentState]:onMessage(msg, client)
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
	self.currentState=newState
end

function GameStateManager:failed()
	self.state[self.currentState]:failed()
end

function GameStateManager:finish()
	self.state[self.currentState]:finish()
end


function GameStateManager:kickAndReset(type)
	type="SYNCRO ERROR"	
	for k,c in pairs(clients) do    
        c:send({type= "reset",pck={type=type}})
        -- c:disconnect()
    end
	self.state={}
	self:reset()
end