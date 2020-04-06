include("shared.lua")

-- Define GM12 fonts for compatibility
surface.CreateFont("DefaultBold", {
	font = "Tahoma",
	size = 13,
	weight = 1000
})
surface.CreateFont("TabLarge", {
	font = "Tahoma",
	size = 13,
	weight = 700,
	shadow = true,
	antialias = false
})
surface.CreateFont("Trebuchet22", {
	font = "Trebuchet MS",
	size = 22,
	weight = 900
})

include("scoring_shd.lua")
include("corpse_shd.lua")
include("player_ext_shd.lua")
include("weaponry_shd.lua")

include("vgui/ColoredBox.lua")
include("vgui/SimpleIcon.lua")
include("vgui/ProgressBar.lua")
include("vgui/ScrollLabel.lua")

include("cl_radio.lua")
include("cl_disguise.lua")
include("cl_transfer.lua")
include("cl_targetid.lua")
include("cl_search.lua")
include("cl_radar.lua")
include("cl_tbuttons.lua")
include("cl_scoreboard.lua")
include("cl_tips.lua")
include("cl_help.lua")
include("cl_hud.lua")
include("cl_msgstack.lua")
include("cl_hudpickup.lua")
include("cl_keys.lua")
include("cl_wepswitch.lua")
include("cl_scoring.lua")
include("cl_scoring_events.lua")
include("cl_popups.lua")
include("cl_equip.lua")
include("cl_voice.lua")

CreateClientConVar("ttt_role_symbols", 0, true, false, "Shows symbols instead of letters in role icons.")
CreateClientConVar("ttt_export_player_data", 0, true, false)

function GM:Initialize()
	MsgN("TTT Client initializing...")

	GAMEMODE.round_state = ROUND_WAIT

	LANG.Init()

	self.BaseClass:Initialize()
end

function GM:InitPostEntity()
	MsgN("TTT Client post-init...")

	net.Start("TTT_Spectate")
	net.WriteBool(GetConVar("ttt_spectator_mode"):GetBool())
	net.SendToServer()

	if not game.SinglePlayer() then
		timer.Create("idlecheck", 5, 0, CheckIdle)
	end

	-- make sure player class extensions are loaded up, and then do some
	-- initialization on them
	if IsValid(LocalPlayer()) and LocalPlayer().GetTraitor then
		GAMEMODE:ClearClientState()
	end

	timer.Create("cache_ents", 1, 0, GAMEMODE.DoCacheEnts)

	RunConsoleCommand("_ttt_request_serverlang")
	RunConsoleCommand("_ttt_request_rolelist")
end

function GM:DoCacheEnts()
	RADAR:CacheEnts()
	TBHUD:CacheEnts()
end

function GM:HUDClear()
	RADAR:Clear()
	TBHUD:Clear()
end

KARMA = {}
function KARMA.IsEnabled() return GetGlobalBool("ttt_karma", false) end

DRINKS = {}
function DRINKS.IsEnabled() return GetGlobalBool("ttt_drinking_enabled", false) end

function GetRoundState() return GAMEMODE.round_state end

local function RoundStateChange(o, n)
	if n == ROUND_PREP then
		-- prep starts
		GAMEMODE:ClearClientState()
		GAMEMODE:CleanUpMap()

		-- show warning to spec mode players
		if GetConVar("ttt_spectator_mode"):GetBool() and IsValid(LocalPlayer()) then
			LANG.Msg("spec_mode_warning")
		end

		-- reset cached server language in case it has changed
		RunConsoleCommand("_ttt_request_serverlang")
	elseif n == ROUND_ACTIVE then
		-- round starts
		VOICE.CycleMuteState(MUTE_NONE)

		CLSCORE:ClearPanel()

		-- people may have died and been searched during prep
		for _, p in pairs(player.GetAll()) do
			p.search_result = nil
		end

		-- clear blood decals produced during prep
		RunConsoleCommand("r_cleardecals")

		GAMEMODE.StartingPlayers = #util.GetAlivePlayers()
	elseif n == ROUND_POST then
		RunConsoleCommand("ttt_cl_traitorpopup_close")
	end

	-- stricter checks when we're talking about hooks, because this function may
	-- be called with for example o = WAIT and n = POST, for newly connecting
	-- players, which hooking code may not expect
	if n == ROUND_PREP then
		-- can enter PREP from any phase due to ttt_roundrestart
		hook.Call("TTTPrepareRound", GAMEMODE)
	elseif (o == ROUND_PREP) and (n == ROUND_ACTIVE) then
		hook.Call("TTTBeginRound", GAMEMODE)
	elseif (o == ROUND_ACTIVE) and (n == ROUND_POST) then
		hook.Call("TTTEndRound", GAMEMODE)
	end

	-- whatever round state we get, clear out the voice flags
	for k, v in pairs(player.GetAll()) do
		v.traitor_gvoice = false
	end
end

concommand.Add("ttt_print_playercount", function() print(GAMEMODE.StartingPlayers) end)

--- optional sound cues on round start and end
CreateConVar("ttt_cl_soundcues", "0", FCVAR_ARCHIVE)

local cues = {
	Sound("ttt/thump01e.mp3"),
	Sound("ttt/thump02e.mp3")
};
local function PlaySoundCue()
	if GetConVar("ttt_cl_soundcues"):GetBool() then
		surface.PlaySound(table.Random(cues))
	end
end

GM.TTTBeginRound = PlaySoundCue
GM.TTTEndRound = PlaySoundCue

local confetti = Material("confetti.png")
net.Receive("TTT_Birthday", function()
	local ent = net.ReadEntity()
	ent:EmitSound("birthday.wav")
	local pos = ent:GetPos() + Vector(0, 0, ent:OBBMaxs().z)
	if ent.GetShootPos then
		pos = ent:GetShootPos()
	end

	local velMax = 200
	local gravMax = 50
	local gravity = Vector(math.random(-gravMax, gravMax), math.random(-gravMax, gravMax), math.random(-gravMax, 0))

	--Handles particles
	local emitter = ParticleEmitter(pos, true)
	for I = 1, 150 do
		local p = emitter:Add(confetti, pos)
		p:SetStartSize(math.random(6, 10))
		p:SetEndSize(0)
		p:SetAngles(Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
		p:SetAngleVelocity(Angle(math.random(5, 50), math.random(5, 50), math.random(5, 50)))
		p:SetVelocity(Vector(math.random(-velMax, velMax), math.random(-velMax, velMax), math.random(-velMax, velMax)))
		p:SetColor(255, 255, 255)
		p:SetDieTime(math.random(4, 7))
		p:SetGravity(gravity)
		p:SetAirResistance(125)
	end
end)

--- usermessages
local function ReceiveRole()
	local client = LocalPlayer()
	local role = net.ReadUInt(4)

	-- after a mapswitch, server might have sent us this before we are even done
	-- loading our code
	if not client.SetRole then return end

	client:SetRole(role)

	Msg("You are: ")
	if client:IsTraitor() then MsgN("TRAITOR")
	elseif client:IsDetective() then MsgN("DETECTIVE")
	elseif client:IsMercenary() then MsgN("MERCENARY")
	elseif client:IsHypnotist() then MsgN("HYPNOTIST")
	elseif client:IsGlitch() then MsgN("GLITCH")
	elseif client:IsJester() then MsgN("JESTER")
	elseif client:IsPhantom() then MsgN("PHANTOM")
	elseif client:IsZombie() then MsgN("ZOMBIE")
	elseif client:IsVampire() then MsgN("VAMPIRE")
	elseif client:IsSwapper() then MsgN("SWAPPER")
	elseif client:IsAssassin() then MsgN("ASSASSIN")
	elseif client:IsKiller() then MsgN("KILLER")
	else MsgN("INNOCENT")
	end
end

net.Receive("TTT_Role", ReceiveRole)

local function ReceiveRoleList()
	local role = net.ReadUInt(4)
	local num_ids = net.ReadUInt(8)

	for i = 1, num_ids do
		local eidx = net.ReadUInt(7) + 1 -- we - 1 worldspawn=0
		local ply = player.GetByID(eidx)
		if IsValid(ply) and ply.SetRole then
			ply:SetRole(role)

			if ply:IsTraitor() or ply:IsHypnotist() or ply:IsVampire() or ply:IsAssassin() or ply:IsZombie() then
				ply.traitor_gvoice = false -- assume traitorchat by default
			end
		end
	end
end

net.Receive("TTT_RoleList", ReceiveRoleList)

-- Round state comm
local function ReceiveRoundState()
	local o = GetRoundState()
	GAMEMODE.round_state = net.ReadUInt(3)

	if o ~= GAMEMODE.round_state then
		RoundStateChange(o, GAMEMODE.round_state)
	end

	MsgN("Round state: " .. GAMEMODE.round_state)
end

net.Receive("TTT_RoundState", ReceiveRoundState)

-- Cleanup at start of new round
function GM:ClearClientState()
	GAMEMODE:HUDClear()

	local client = LocalPlayer()
	if not client.SetRole then return end -- code not loaded yet

	client:SetRole(ROLE_INNOCENT)

	client.equipment_items = EQUIP_NONE
	client.equipment_credits = 0
	client.bought = {}
	client.last_id = nil
	client.radio = nil
	client.called_corpses = {}

	VOICE.InitBattery()

	for _, p in pairs(player.GetAll()) do
		if IsValid(p) then
			p.sb_tag = nil
			p:SetRole(ROLE_INNOCENT)
			p.search_result = nil
		end
	end

	VOICE.CycleMuteState(MUTE_NONE)
	RunConsoleCommand("ttt_mute_team_check", "0")

	if GAMEMODE.ForcedMouse then
		gui.EnableScreenClicker(false)
	end
end

net.Receive("TTT_ClearClientState", GM.ClearClientState)

function GM:CleanUpMap()
	-- Ragdolls sometimes stay around on clients. Deleting them can create issues
	-- so all we can do is try to hide them.
	for _, ent in pairs(ents.FindByClass("prop_ragdoll")) do
		if IsValid(ent) and CORPSE.GetPlayerNick(ent, "") ~= "" then
			ent:SetNoDraw(true)
			ent:SetSolid(SOLID_NONE)
			ent:SetColor(Color(0, 0, 0, 0))

			-- Horrible hack to make targetid ignore this ent, because we can't
			-- modify the collision group clientside.
			ent.NoTarget = true
		end
	end

	-- This cleans up decals since GMod v100
	game.CleanUpMap()
end

-- server tells us to call this when our LocalPlayer has spawned
local function PlayerSpawn()
	local as_spec = net.ReadBit() == 1
	if as_spec then
		TIPS.Show()
	else
		TIPS.Hide()
	end
end

net.Receive("TTT_PlayerSpawned", PlayerSpawn)

local function PlayerDeath()
	TIPS.Show()
end

net.Receive("TTT_PlayerDied", PlayerDeath)

function GM:ShouldDrawLocalPlayer(ply) return false end

local view = { origin = vector_origin, angles = angle_zero, fov = 0 }
function GM:CalcView(ply, origin, angles, fov)
	view.origin = origin
	view.angles = angles
	view.fov = fov

	-- first person ragdolling
	if ply:Team() == TEAM_SPEC and ply:GetObserverMode() == OBS_MODE_IN_EYE then
		local tgt = ply:GetObserverTarget()
		if IsValid(tgt) and (not tgt:IsPlayer()) then
			-- assume if we are in_eye and not speccing a player, we spec a ragdoll
			local eyes = tgt:LookupAttachment("eyes") or 0
			eyes = tgt:GetAttachment(eyes)
			if eyes then
				view.origin = eyes.Pos
				view.angles = eyes.Ang
			end
		end
	end

	local wep = ply:GetActiveWeapon()
	if IsValid(wep) then
		local func = wep.CalcView
		if func then
			view.origin, view.angles, view.fov = func(wep, ply, origin * 1, angles * 1, fov)
		end
	end

	return view
end

function GM:AddDeathNotice() end

function GM:DrawDeathNotice() end

function GM:Think()
	for _, v in pairs(player.GetAll()) do
		if v:Alive() and (v:GetNWBool("HauntedSmoke") or v:GetNWBool("KillerSmoke")) then
			if not v.SmokeEmitter then v.SmokeEmitter = ParticleEmitter(v:GetPos()) end
			if not v.SmokeNextPart then v.SmokeNextPart = CurTime() end
			local pos = v:GetPos() + Vector(0, 0, 30)
			local client = LocalPlayer()
			if v.SmokeNextPart < CurTime() then
				if client:GetPos():Distance(pos) > 1000 then return end
				v.SmokeEmitter:SetPos(pos)
				v.SmokeNextPart = CurTime() + math.Rand(0.003, 0.01)
				local vec = Vector(math.Rand(-8, 8), math.Rand(-8, 8), math.Rand(10, 55))
				local pos = v:LocalToWorld(vec)
				local particle = v.SmokeEmitter:Add("particle/snow.vmt", pos)
				particle:SetVelocity(Vector(0, 0, 4) + VectorRand() * 3)
				particle:SetDieTime(math.Rand(0.5, 2))
				particle:SetStartAlpha(math.random(150, 220))
				particle:SetEndAlpha(0)
				local size = math.random(4, 7)
				particle:SetStartSize(size)
				particle:SetEndSize(size + 1)
				particle:SetRoll(0)
				particle:SetRollDelta(0)
				particle:SetColor(0, 0, 0)
			end
		else
			if v.SmokeEmitter then
				v.SmokeEmitter:Finish()
				v.SmokeEmitter = nil
			end
		end
	end

	if GetConVar("ttt_export_player_data"):GetBool() then
		local client = LocalPlayer()

		local state = GetRoundState() == 3 and "1" or "0"
		local role = tostring(client:GetRole())
		local alive = client:IsActive() and "1" or "0"
		local health = tostring(client:Health())

		local data = state .. "," .. role .. "," .. alive .. "," .. health
		file.Write("playerdata/data.txt", data)
	end
end

function GM:Tick()
	local client = LocalPlayer()
	if IsValid(client) then
		if client:Alive() and client:Team() ~= TEAM_SPEC then
			WSWITCH:Think()
			RADIO:StoreTarget()
		end

		VOICE.Tick()
	end
end

-- Simple client-based idle checking
local idle = { ang = nil, pos = nil, mx = 0, my = 0, t = 0 }
function CheckIdle()
	local client = LocalPlayer()
	if not IsValid(client) then return end

	if not idle.ang or not idle.pos then
		-- init things
		idle.ang = client:GetAngles()
		idle.pos = client:GetPos()
		idle.mx = gui.MouseX()
		idle.my = gui.MouseY()
		idle.t = CurTime()

		return
	end

	if GetRoundState() == ROUND_ACTIVE and client:IsTerror() and client:Alive() then
		local idle_limit = GetGlobalInt("ttt_idle_limit", 300) or 300
		if idle_limit <= 0 then idle_limit = 300 end -- networking sucks sometimes

		if client:GetAngles() ~= idle.ang then
			-- Normal players will move their viewing angles all the time
			idle.ang = client:GetAngles()
			idle.t = CurTime()
		elseif gui.MouseX() ~= idle.mx or gui.MouseY() ~= idle.my then
			-- Players in eg. the Help will move their mouse occasionally
			idle.mx = gui.MouseX()
			idle.my = gui.MouseY()
			idle.t = CurTime()
		elseif client:GetPos():Distance(idle.pos) > 10 then
			-- Even if players don't move their mouse, they might still walk
			idle.pos = client:GetPos()
			idle.t = CurTime()
		elseif CurTime() > (idle.t + idle_limit) then
			RunConsoleCommand("say", "(AUTOMATED MESSAGE) I have been moved to the Spectator team because I was idle/AFK.")

			timer.Simple(0.3, function()
				RunConsoleCommand("ttt_spectator_mode", 1)
				net.Start("TTT_Spectate")
				net.WriteBool(true)
				net.SendToServer()
				RunConsoleCommand("ttt_cl_idlepopup")
			end)
		elseif CurTime() > (idle.t + (idle_limit / 2)) then
			-- will repeat
			LANG.Msg("idle_warning")
		end
	end
end

function GM:OnEntityCreated(ent)
	-- Make ragdolls look like the player that has died
	if ent:IsRagdoll() then
		local ply = CORPSE.GetPlayer(ent)

		if IsValid(ply) then
			-- Only copy any decals if this ragdoll was recently created
			if ent:GetCreationTime() > CurTime() - 1 then
				ent:SnatchModelInstance(ply)
			end

			-- Copy the color for the PlayerColor matproxy
			local playerColor = ply:GetPlayerColor()
			ent.GetPlayerColor = function()
				return playerColor
			end
		end
	end

	return self.BaseClass.OnEntityCreated(self, ent)
end

local showHighlights = false

net.Receive("TTT_Killer_PlayerHighlightOn", function(len, ply)
	hook.Add("PreDrawHalos", "AddPlayerHighlights", function()
		showHighlights = true
		OnPlayerHightlightEnabled(ROLE_KILLER)
	end)
end)
net.Receive("TTT_Zombie_PlayerHighlightOn", function(len, ply)
	hook.Add("PreDrawHalos", "AddPlayerHighlights", function()
		showHighlights = true
		OnPlayerHightlightEnabled(ROLE_ZOMBIE, ROLE_VAMPIRE)
	end)
end)
net.Receive("TTT_Vampire_PlayerHighlightOn", function(len, ply)
	hook.Add("PreDrawHalos", "AddPlayerHighlights", function()
		showHighlights = true
		OnPlayerHightlightEnabled(ROLE_VAMPIRE, ROLE_ZOMBIE)
	end)
end)
net.Receive("TTT_PlayerHighlightOff", function(len, ply)
	showHighlights = false
	hook.Remove("PreDrawHalos", "AddPlayerHighlights")
end)

function OnPlayerHightlightEnabled(role, alliedRole)
	local client = LocalPlayer()
	if not IsValid(client) then return end
	if client:GetRole() == role then
		local enemies = {}
		local friends = {}
		local jesters = {}
		if GetRoundState() == ROUND_ACTIVE then
			for k, v in pairs(player.GetAll()) do
				local isJester = v:GetRole() == ROLE_JESTER or v:GetRole() == ROLE_SWAPPER
				local isFriend = v:GetRole() == role or (alliedRole and v:GetRole() == alliedRole)
				if v:Alive() and isJester then
					table.insert(jesters, v)
				elseif v:Alive() and isFriend then
					table.insert(friends, v)
				elseif v:Alive() then
					table.insert(enemies, v)
				end
			end

			if showHighlights then
				halo.Add(enemies, Color(255, 0, 0), 1, 1, 1, true, true)
				halo.Add(friends, Color(0, 255, 0), 1, 1, 1, true, true)
				halo.Add(jesters, Color(255, 85, 100), 1, 1, 1, true, true)
			end
		end
	end
end