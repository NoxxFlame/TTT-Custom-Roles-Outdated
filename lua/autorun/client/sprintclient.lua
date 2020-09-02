-- Request ConVars (SERVER)
local function ConVars()
	net.Start("SprintGetConVars")
	net.SendToServer()
end

-- Set default Values
local Multiplier = 0.4
local Crosshair = 1
local RegenerateI = 0.08
local RegenerateT = 0.12
local Consumption = 0.3
local realProzent = 100
local sprinting = false
local lastReleased = -1000
local DoubleTapActivated = false
local CrosshairSize = 1
local TimerCon = CurTime()
local TimerReg = CurTime()
local surface = surface
local ply = LocalPlayer()

-- Receive ConVars (SERVER)
net.Receive("SprintGetConVars", function()
	local Table = net.ReadTable()
	
	Multiplier = Table[1]
	Crosshair = Table[2]
	RegenerateI = Table[3]
	RegenerateT = Table[4]
	Consumption = Table[5]
end)

-- Client ConVars
local ActivateKey = CreateClientConVar("ttt_sprint_activate_key", "1", true, false, "The key used to sprint. (0 = Use; 1 = Shift; 2 = Control; 3 = Custom) Def:1")
local CustomActivateKey = CreateClientConVar("ttt_sprint_activate_key_custom", "32", true, false, "The custom key used to sprint if ttt_sprint_activate_key = 3. It has to be a Number. (Example: 32 = V Key) Def: 32 Key Numbers: https://wiki.garrysmod.com/page/Enums/KEY")
local DoubleTapEnabled = CreateClientConVar("ttt_sprint_doubletapenabled", "0", true, false, "If double tapping forward causes the player to sprint. Def:1")
local DoubleTapTime = CreateClientConVar("ttt_sprint_doubletaptime", "0.25", true, false, "The time you have for double tapping. (0.001-1) Def:0.25")
local CrosshairDebugSize = CreateClientConVar("ttt_sprint_crosshairdebugsize", "1", true, false, "The size of the crosshair used to prevent no crosshair while not sprinting. (Disabled = 0) Def:1")

-- Requesting ConVars first time
ConVars()

-- Change the Speed
local function SpeedChange(Bool)
	net.Start("SprintSpeedset")
	
	if Bool then
		net.WriteFloat(math.min(math.max(Multiplier, 0.1), 2))
		
		ply.mult = 1 + math.min(math.max(Multiplier, 0.1), 2)
	else
		net.WriteFloat(0)
		
		ply.mult = nil
	end
	
	net.SendToServer()
	
	if Crosshair then -- Enlarge Crosshair
		if Bool then
			local tmp = GetConVar("ttt_crosshair_size")
			
			CrosshairSize = tmp and tmp:GetString() or 1
			
			RunConsoleCommand("ttt_crosshair_size", "2")
		else
			if CrosshairSize == "0" then
				CrosshairSize = CrosshairDebugSize:GetFloat()
			end
			
			RunConsoleCommand("ttt_crosshair_size", CrosshairSize)
		end
	end
end

-- returns the selected sprint key
function SprintKey()
	if ActivateKey:GetFloat() == 0 then
		return LocalPlayer():KeyDown(IN_USE)
	elseif ActivateKey:GetFloat() == 1 then
		return input.IsKeyDown(KEY_LSHIFT)
	elseif ActivateKey:GetFloat() == 2 then
		return input.IsKeyDown(KEY_LCONTROL)
	elseif ActivateKey:GetFloat() == 3 then
		return input.IsKeyDown(CustomActivateKey:GetFloat())
	end
	
	return false
end

-- Sprint activated (sprint if there is stamina)
local function SprintFunction()
	if realProzent > 0 then
		if not sprinting then
			SpeedChange(true)
			
			sprinting = true
			TimerCon = CurTime()
		end
		
		realProzent = realProzent - (CurTime() - TimerCon) * (math.min(math.max(Consumption, 0.1), 5) * 250)
		TimerCon = CurTime()
	else
		if sprinting then
			SpeedChange(false)
			
			sprinting = false
		end
	end
end

-- listen for sprinting
hook.Add("TTTPrepareRound", "TTTSprint4TTTPrepareRound", function()
	-- reset every round
	realProzent = 100
	
	ConVars()
	
	-- listen for activation
	hook.Add("Think", "TTTSprint4Think", function()
		local client = LocalPlayer()
		
		if client:KeyReleased(IN_FORWARD) and DoubleTapEnabled:GetBool() then
			-- Double tap
			lastReleased = CurTime()
		end
		
		if DoubleTapEnabled:GetBool() and client:KeyDown(IN_FORWARD) and (lastReleased + math.min(math.max(DoubleTapTime:GetFloat(), 0.001), 1) >= CurTime() or DoubleTapActivated) then
			SprintFunction()
			
			DoubleTapActivated = true
			TimerReg = CurTime()
		elseif client:KeyDown(IN_FORWARD) and SprintKey() then
			-- forward + selected key
			SprintFunction()
			
			DoubleTapActivated = false
			TimerReg = CurTime()
		else
			if sprinting then -- not sprinting
				SpeedChange(false)
				sprinting = false
				DoubleTapActivated = false
				TimerReg = CurTime()
			end
			
			if GetRoundState() ~= ROUND_WAIT then
				if IsValid(client) and client:IsPlayer() and client:GetTraitor() or client:GetAssassin() or client:GetHypnotist() or client:GetVampire() or client:GetZombie() or client:GetDetraitor() or client:GetKiller() then
					realProzent = realProzent + (CurTime() - TimerReg) * (math.min(math.max(RegenerateT, 0.01), 2) * 250)
				else
					realProzent = realProzent + (CurTime() - TimerReg) * (math.min(math.max(RegenerateI, 0.01), 2) * 250)
				end
			end
			
			TimerReg = CurTime()
			DoubleTapActivated = false
		end
		
		if realProzent < 0 then -- prevent bugs
			realProzent = 0
			SpeedChange(false)
			sprinting = false
			DoubleTapActivated = false
			TimerReg = CurTime()
		elseif realProzent > 100 then
			realProzent = 100
		end
		if IsValid(client) and client:IsPlayer() then
			client:SetNWFloat("sprintMeter", realProzent)
		end
	end)
end)

-- Set Sprint Speed
hook.Add("TTTPlayerSpeedModifier", "TTTSprint4TTTPlayerSpeed", function(ply, _, _)
	if multi then
		local wep = ply:GetActiveWeapon()
		local multi = Multiplier + 1
		if wep and IsValid(wep) and wep:GetClass() == "genji_melee" then
			return 1.4 * multi
		elseif wep and IsValid(wep) and wep:GetClass() == "weapon_ttt_homebat" then
			return 1.25 * multi
		elseif wep and IsValid(wep) and wep:GetClass() == "weapon_vam_fangs" and wep:Clip1() < 13 then
			return 3 * multi
		elseif wep and IsValid(wep) and wep:GetClass() == "weapon_zom_claws" then
			if ply:HasEquipmentItem(EQUIP_SPEED) then
				return 1.5 * multi
			else
				return 1.35 * multi
			end
		else
			return multi
		end
	else
		return 1
	end
end)
