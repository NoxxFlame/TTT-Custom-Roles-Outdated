-- Drinking game stuff

DRINKS = {}

-- ply steamid -> drinks table for disconnected players who might reconnect
DRINKS.RememberedPlayers = {}

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
	ply:SetLiveDrinks(ply:GetLiveDrinks + 1)
end

function DRINKS.AddShot(ply)
	ply:SetLiveShots(ply:GetLiveShots + 1)
end

function DRINKS.Rebase()
	for _, ply in pairs(player.GetAll()) do
		ply:SetBaseDrinks(ply:GetLiveDrinks())
		ply:SetBaseShots(ply:GetLiveShots())
	end
end

function DRINKS.NotifyPlayers()
	for _, ply in pairs(player.GetAll()) do
		if ply:GetLiveDrinks() > ply:GetBaseDrinks() or ply:GetLiveShots() > ply:GetBaseShots() then
			for _, p in pairs(player.GetAll()) do
				p:PrintMessage(HUD_PRINTTALK, ply:Nick() .. " takes " .. (ply:GetLiveDrinks() - ply:GetBaseDrinks()) .. " drink(s) and " .. (ply:GetLiveShots() - ply:GetBaseShots()) .. " shots.")
			end
		end
	end
end

function DRINKS.RoundEnd()
	if DRINKS.IsEnabled() then
		DRINKS.NotifyPlayers()
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