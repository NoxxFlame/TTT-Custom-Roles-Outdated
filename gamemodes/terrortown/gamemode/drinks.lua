-- Drinking game stuff

DRINKS = {}

-- ply steamid -> drinks table for disconnected players who might reconnect
DRINKS.RememberedPlayers = {}

-- used for printing at the end of the round
DRINKS.PlayerActions = {}
DRINKS.PlayerActions["death"] = {}
DRINKS.PlayerActions["teamkill"] = {}
DRINKS.PlayerActions["suicide"] = {}
DRINKS.PlayerActions["jesterkill"] = {}
DRINKS.PlayerActions["goldengun"] = {}

-- Convars, more convenient access than GetConVar bla bla
DRINKS.cv = {}
DRINKS.cv.enabled = CreateConVar("ttt_drinking_enabled", "0", FCVAR_ARCHIVE)

local config = DRINKS.cv

function DRINKS.InitState()
	SetGlobalBool("ttt_drinking_enabled", config.enabled:GetBool())
end

function DRINKS.IsEnabled()
	return GetGlobalBool("ttt_drinking_enabled", false)
end

function DRINKS.AddDrink(ply)
	ply:SetLiveDrinks((ply:GetLiveDrinks() or 0) + 1)
end

function DRINKS.AddShot(ply)
	ply:SetLiveShots((ply:SetLiveShots() or 0) + 1)
end

function DRINKS.Rebase()
	for _, ply in pairs(player.GetAll()) do
		ply:SetBaseDrinks(ply:GetLiveDrinks())
		ply:SetBaseShots(ply:GetLiveShots())
	end
end

function DRINKS.AddPlayerAction(key, ply)
	local actionTable = DRINKS.PlayerActions[key]
	local found = false
	for _, p in pairs(actionTable) do
		if ply:Nick() == p then
			found = true
			break
		end
	end
	if not found then
		actionTable[#actionTable + 1] = ply:Nick()
	end
end

function DRINKS.ResetPlayerActions()
	DRINKS.PlayerActions["death"] = {}
	DRINKS.PlayerActions["teamkill"] = {}
	DRINKS.PlayerActions["suicide"] = {}
	DRINKS.PlayerActions["jesterkill"] = {}
	DRINKS.PlayerActions["goldengun"] = {}
end

function DRINKS.CreateDrinkMessage(convar, key, message)
	local punishment
	if convar == "drink" or convar == "shot" then
		punishment = convar
	else
		punishment = GetConVar(convar):GetString()
	end
	
	local punishedplys = DRINKS.PlayerActions[key]
	if #punishedplys > 0 and (punishment == "drink" or punishment == "shot") then
		if punishment == "drink" then
			message = " a drink for " .. message
		elseif punishment == "shot" then
			message = " a shot for " .. message
		end
		
		if #punishedplys == 1 then
			message = " takes" .. message
		else
			message = " take" .. message
		end
		
		for key, nick in pairs(punishedplys) do
			if key == 1 and #punishedplys > 1 then
				message = " and " .. nick .. message
			elseif key == #punishedplys then
				message = nick .. message
			else
				message = ", " .. nick .. message
			end
		end
		
		return message
	else
		return false
	end
end

function DRINKS.NotifyPlayers()
	local deathmessage = DRINKS.CreateDrinkMessage("ttt_drinking_death", "death", "dying at the hands of an enemy.")
	local teamkillmessage = DRINKS.CreateDrinkMessage("ttt_drinking_team_kill", "teamkill", "killing allies.")
	local suicidemessage = DRINKS.CreateDrinkMessage("ttt_drinking_suicide", "suicide", "committing suicide.")
	local jesterkillmessage = DRINKS.CreateDrinkMessage("ttt_drinking_jester_kill", "jesterkill", "killing the jester.")
	local goldengunmessage = DRINKS.CreateDrinkMessage("shot", "goldengun", "dying to the golden gun.")

	for _, ply in pairs(player.GetAll()) do
		if deathmessage then ply:PrintMessage(HUD_PRINTTALK, deathmessage) end
		if teamkillmessage then ply:PrintMessage(HUD_PRINTTALK, teamkillmessage) end
		if suicidemessage then ply:PrintMessage(HUD_PRINTTALK, suicidemessage) end
		if jesterkillmessage then ply:PrintMessage(HUD_PRINTTALK, jesterkillmessage) end
		if goldengunmessage then ply:PrintMessage(HUD_PRINTTALK, goldengunmessage) end
		
		if (ply:GetLiveDrinks() and ply:GetLiveDrinks() > ply:GetBaseDrinks()) or (ply:GetLiveShots() and ply:GetLiveShots() > ply:GetBaseShots()) then
			ply:PrintMessage(HUD_PRINTTALK, "You must take " .. ((ply:GetLiveDrinks() or 0) - (ply:GetBaseDrinks() or 0)) .. " drink(s) and " .. ((ply:GetLiveShots() or 0) - (ply:GetBaseShots() or 0)) .. " shot(s).")
			ply:PrintMessage(HUD_PRINTCENTER, "You must take " .. ((ply:GetLiveDrinks() or 0) - (ply:GetBaseDrinks() or 0)) .. " drink(s) and " .. ((ply:GetLiveShots() or 0) - (ply:GetBaseShots() or 0)) .. " shot(s).")
		end
	end
end

function DRINKS.RoundEnd()
	if DRINKS.IsEnabled() then
		DRINKS.NotifyPlayers()
		DRINKS.ResetPlayerActions()
		DRINKS.Rebase()
		DRINKS.RememberAll()
	end
end

function DRINKS.RoundBegin()
	DRINKS.InitState()
end

function DRINKS.InitPlayer(ply)
	local ds = DRINKS.Recall(ply) or { 0, 0 }
	
	ply:SetBaseDrinks(ds[1])
	ply:SetLiveDrinks(ds[1])
	ply:SetBaseShots(ds[2])
	ply:SetLiveShots(ds[2])
end

function DRINKS.Remember(ply)
	if not ply:IsFullyAuthenticated() then return end
	
	ply:SetPData("drinks_stored", ply:GetLiveDrinks())
	ply:SetPData("shots_stored", ply:GetLiveShots())
	
	-- this is purely a backup method
	DRINKS.RememberedPlayers[ply:SteamID()] = { ply:GetLiveDrinks(), ply:GetLiveShots() }
end

function DRINKS.Recall(ply)
	ply.delay_drinks_recall = not ply:IsFullyAuthenticated()
	
	if ply:IsFullyAuthenticated() then
		local d = tonumber(ply:GetPData("drinks_stored", nil))
		local s = tonumber(ply:GetPData("shots_stored", nil))
		if d and s then
			return { d, s }
		end
	end
	
	return DRINKS.RememberedPlayers[ply:SteamID()]
end

function DRINKS.LateRecallAndSet(ply)
	local d = tonumber(ply:GetPData("drinks_stored", DRINKS.RememberedPlayers[ply:SteamID()][1]))
	local s = tonumber(ply:GetPData("shots_stored", DRINKS.RememberedPlayers[ply:SteamID()][2]))
	if d and s then
		ply:SetBaseDrinks(d)
		ply:SetLiveDrinks(d)
		ply:SetBaseShots(s)
		ply:SetLiveShots(s)
	end
end

function DRINKS.RememberAll()
	for _, ply in pairs(player.GetAll()) do
		DRINKS.Remember(ply)
	end
end