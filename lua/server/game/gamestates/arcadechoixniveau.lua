ArcadeChoixNiveau = {}

function ArcadeChoixNiveau:init()
end

function ArcadeChoixNiveau:update(dt) end
function ArcadeChoixNiveau:draw() end

function ArcadeChoixNiveau:onMessage(msg, client)
	if msg.type == "choixNiveau" then
		monde.level = msg.level
		for k,c in pairs(clients) do
			c:send({type= "choixNiveau", level= msg.level})
		end
		if gameStateManager.state['Gameplay']==nil then
		gameStateManager.state['Gameplay']:destroy()
	end
		gameStateManager.state['Gameplay']=Gameplay.new("maps/"..msg.level,true)
		gameStateManager:changeState("Gameplay")
	end
	-- if msg.type == "choixNiveau" then
	-- 	if not msg.confirm then
	-- 		-- TODO : checker que le niveau existe bien, toussa
	-- 		monde.niveau = msg.niveau or debug_warn("[ArcadeChoixNiveau] missing niveau")
	-- 		for k,c in pairs(clients) do
	-- 			c:send({type= "choixNiveau", niveau= msg.niveau})
	-- 		end
	-- 	else
	-- 		if monde.niveau then
	-- 			for k,c in pairs(clients) do
	-- 				c:send({type= "choixNiveauFini"})
	-- 			end
	-- 			gameStateManager:changeState("arcade")
	-- 			-- TODO : envoyer le niveau ici ?
	-- 		else
	-- 			client:send({type= "err", msg="choix du niveau pas fini"})
	-- 		end
	-- 	end
	-- else
	-- 	debug_warn("[ArcadeChoixNiveau] wrong type")
	-- end
end

ArcadeChoixNiveau = common.class("ArcadeChoixNiveau", ArcadeChoixNiveau)