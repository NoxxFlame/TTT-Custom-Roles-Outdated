-- Trouble in Terrorist Town

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_msgstack.lua")
AddCSLuaFile("cl_hudpickup.lua")
AddCSLuaFile("cl_keys.lua")
AddCSLuaFile("cl_wepswitch.lua")
AddCSLuaFile("cl_awards.lua")
AddCSLuaFile("cl_scoring_events.lua")
AddCSLuaFile("cl_scoring.lua")
AddCSLuaFile("cl_popups.lua")
AddCSLuaFile("cl_equip.lua")
AddCSLuaFile("equip_items_shd.lua")
AddCSLuaFile("cl_help.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_tips.lua")
AddCSLuaFile("cl_voice.lua")
AddCSLuaFile("scoring_shd.lua")
AddCSLuaFile("util.lua")
AddCSLuaFile("lang_shd.lua")
AddCSLuaFile("corpse_shd.lua")
AddCSLuaFile("player_ext_shd.lua")
AddCSLuaFile("weaponry_shd.lua")
AddCSLuaFile("cl_radio.lua")
AddCSLuaFile("cl_radar.lua")
AddCSLuaFile("cl_tbuttons.lua")
AddCSLuaFile("cl_disguise.lua")
AddCSLuaFile("cl_transfer.lua")
AddCSLuaFile("cl_search.lua")
AddCSLuaFile("cl_targetid.lua")
AddCSLuaFile("vgui/ColoredBox.lua")
AddCSLuaFile("vgui/SimpleIcon.lua")
AddCSLuaFile("vgui/ProgressBar.lua")
AddCSLuaFile("vgui/ScrollLabel.lua")
AddCSLuaFile("vgui/sb_main.lua")
AddCSLuaFile("vgui/sb_row.lua")
AddCSLuaFile("vgui/sb_team.lua")
AddCSLuaFile("vgui/sb_info.lua")

include("shared.lua")

include("karma.lua")
include("drinks.lua")
include("entity.lua")
include("scoring_shd.lua")
include("radar.lua")
include("admin.lua")
include("traitor_state.lua")
include("propspec.lua")
include("weaponry.lua")
include("gamemsg.lua")
include("ent_replace.lua")
include("scoring.lua")
include("corpse.lua")
include("player_ext_shd.lua")
include("player_ext.lua")
include("player.lua")

-- Round times
CreateConVar("ttt_roundtime_minutes", "10", FCVAR_NOTIFY)
CreateConVar("ttt_preptime_seconds", "30", FCVAR_NOTIFY)
CreateConVar("ttt_posttime_seconds", "30", FCVAR_NOTIFY)
CreateConVar("ttt_firstpreptime", "60")

-- Haste mode
local ttt_haste = CreateConVar("ttt_haste", "1", FCVAR_NOTIFY)
CreateConVar("ttt_haste_starting_minutes", "5", FCVAR_NOTIFY)
CreateConVar("ttt_haste_minutes_per_death", "0.5", FCVAR_NOTIFY)

-- Player Spawning
CreateConVar("ttt_spawn_wave_interval", "0")

CreateConVar("ttt_traitor_pct", "0.25")
CreateConVar("ttt_traitor_max", "32")

CreateConVar("ttt_detective_pct", "0.13", FCVAR_NOTIFY)
CreateConVar("ttt_detective_max", "32")
CreateConVar("ttt_detective_min_players", "8")
CreateConVar("ttt_detective_karma_min", "600")

CreateConVar("ttt_mercenary_enabled", "1")
CreateConVar("ttt_hypnotist_enabled", "1")
CreateConVar("ttt_glitch_enabled", "1")
CreateConVar("ttt_jester_enabled", "1")
CreateConVar("ttt_phantom_enabled", "1")
CreateConVar("ttt_zombie_enabled", "1")
CreateConVar("ttt_vampire_enabled", "1")
CreateConVar("ttt_swapper_enabled", "1")
CreateConVar("ttt_assassin_enabled", "1")
CreateConVar("ttt_killer_enabled", "1")

CreateConVar("ttt_zombie_chance", "0.1")
CreateConVar("ttt_hypnotist_chance", "0.2")
CreateConVar("ttt_vampire_chance", "0.2")
CreateConVar("ttt_assassin_chance", "0.2")
CreateConVar("ttt_glitch_chance", "0.25")
CreateConVar("ttt_phantom_chance", "0.25")
CreateConVar("ttt_mercenary_chance", "0.25")
CreateConVar("ttt_jester_chance", "0.25")
CreateConVar("ttt_swapper_chance", "0.25")
CreateConVar("ttt_killer_chance", "0.25")

CreateConVar("ttt_mercenary_required_innos", "2")
CreateConVar("ttt_hypnotist_required_traitors", "2")
CreateConVar("ttt_glitch_required_innos", "2")
CreateConVar("ttt_jester_required_innos", "2")
CreateConVar("ttt_phantom_required_innos", "2")
CreateConVar("ttt_zombie_required_traitors", "2")
CreateConVar("ttt_vampire_required_traitors", "2")
CreateConVar("ttt_swapper_required_innos", "2")
CreateConVar("ttt_assassin_required_traitors", "2")
CreateConVar("ttt_killer_required_innos", "3")

CreateConVar("ttt_monster_pct", "0.33")

-- Traitor credits
CreateConVar("ttt_credits_starting", "2")
CreateConVar("ttt_credits_award_pct", "0.35")
CreateConVar("ttt_credits_award_size", "1")
CreateConVar("ttt_credits_award_repeat", "1")
CreateConVar("ttt_credits_detectivekill", "1")

CreateConVar("ttt_credits_alonebonus", "1")

-- Detective credits
CreateConVar("ttt_det_credits_starting", "1")
CreateConVar("ttt_det_credits_traitorkill", "0")
CreateConVar("ttt_det_credits_traitordead", "1")

CreateConVar("ttt_mer_credits_starting", "1")
CreateConVar("ttt_kil_credits_starting", "2")

CreateConVar("ttt_detective_search_only", "1", FCVAR_REPLICATED)

-- Other
CreateConVar("ttt_shop_merc_mode", "0", FCVAR_ARCHIVE + FCVAR_REPLICATED)
CreateConVar("ttt_shop_assassin_sync", "0", FCVAR_ARCHIVE + FCVAR_REPLICATED)
CreateConVar("ttt_shop_hypnotist_sync", "0", FCVAR_ARCHIVE + FCVAR_REPLICATED)
CreateConVar("ttt_killer_max_health", "100", FCVAR_ARCHIVE)
CreateConVar("ttt_killer_knife_enabled", "1", FCVAR_ARCHIVE)
CreateConVar("ttt_killer_smoke_enabled", "1", FCVAR_ARCHIVE)
CreateConVar("ttt_killer_smoke_timer", "60", FCVAR_ARCHIVE)
CreateConVar("ttt_killer_show_target_icon", "1", FCVAR_ARCHIVE + FCVAR_REPLICATED)
CreateConVar("ttt_zombie_show_target_icon", "1", FCVAR_ARCHIVE + FCVAR_REPLICATED)
CreateConVar("ttt_vampire_show_target_icon", "1", FCVAR_ARCHIVE + FCVAR_REPLICATED)

CreateConVar("ttt_use_weapon_spawn_scripts", "1")
CreateConVar("ttt_weapon_spawn_count", "0")

CreateConVar("ttt_round_limit", "6", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED)
CreateConVar("ttt_time_limit_minutes", "75", FCVAR_NOTIFY + FCVAR_REPLICATED)

CreateConVar("ttt_idle_limit", "180", FCVAR_NOTIFY)

CreateConVar("ttt_voice_drain", "0", FCVAR_NOTIFY)
CreateConVar("ttt_voice_drain_normal", "0.2", FCVAR_NOTIFY)
CreateConVar("ttt_voice_drain_admin", "0.05", FCVAR_NOTIFY)
CreateConVar("ttt_voice_drain_recharge", "0.05", FCVAR_NOTIFY)

CreateConVar("ttt_namechange_kick", "1", FCVAR_NOTIFY)
CreateConVar("ttt_namechange_bantime", "10")

CreateConVar("ttt_karma_beta", "0", FCVAR_REPLICATED)

-- Drinking game punishments
CreateConVar("ttt_drinking_death", "drink")
CreateConVar("ttt_drinking_team_kill", "drink")
CreateConVar("ttt_drinking_suicide", "drink")
CreateConVar("ttt_drinking_jester_kill", "shot")

local ttt_detective = CreateConVar("ttt_sherlock_mode", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY)
local ttt_minply = CreateConVar("ttt_minimum_players", "2", FCVAR_ARCHIVE + FCVAR_NOTIFY)

-- debuggery
local ttt_dbgwin = CreateConVar("ttt_debug_preventwin", "0")

-- Localise stuff we use often. It's like Lua go-faster stripes.
local math = math
local table = table
local net = net
local player = player
local timer = timer
local util = util

-- Pool some network names.
util.AddNetworkString("TTT_RoundState")
util.AddNetworkString("TTT_RagdollSearch")
util.AddNetworkString("TTT_GameMsg")
util.AddNetworkString("TTT_GameMsgColor")
util.AddNetworkString("TTT_RoleChat")
util.AddNetworkString("TTT_TraitorVoiceState")
util.AddNetworkString("TTT_LastWordsMsg")
util.AddNetworkString("TTT_RadioMsg")
util.AddNetworkString("TTT_ReportStream")
util.AddNetworkString("TTT_LangMsg")
util.AddNetworkString("TTT_ServerLang")
util.AddNetworkString("TTT_Equipment")
util.AddNetworkString("TTT_Credits")
util.AddNetworkString("TTT_Bought")
util.AddNetworkString("TTT_BoughtItem")
util.AddNetworkString("TTT_InterruptChat")
util.AddNetworkString("TTT_PlayerSpawned")
util.AddNetworkString("TTT_PlayerDied")
util.AddNetworkString("TTT_CorpseCall")
util.AddNetworkString("TTT_ClearClientState")
util.AddNetworkString("TTT_PerformGesture")
util.AddNetworkString("TTT_Role")
util.AddNetworkString("TTT_RoleList")
util.AddNetworkString("TTT_ConfirmUseTButton")
util.AddNetworkString("TTT_C4Config")
util.AddNetworkString("TTT_C4DisarmResult")
util.AddNetworkString("TTT_C4Warn")
util.AddNetworkString("TTT_ShowPrints")
util.AddNetworkString("TTT_ScanResult")
util.AddNetworkString("TTT_FlareScorch")
util.AddNetworkString("TTT_Radar")
util.AddNetworkString("TTT_Spectate")
util.AddNetworkString("TTT_JesterKiller")
util.AddNetworkString("TTT_ClearRoleSwaps")
util.AddNetworkString("TTT_Birthday")
util.AddNetworkString("TTT_TeleportMark")
util.AddNetworkString("TTT_ClearTeleportMarks")
util.AddNetworkString("TTT_PlayerDisconnected")
util.AddNetworkString("TTT_SpawnedPlayers")
util.AddNetworkString("TTT_Defibrillated")
util.AddNetworkString("TTT_RoleChanged")
util.AddNetworkString("TTT_Killer_PlayerHighlightOn")
util.AddNetworkString("TTT_Zombie_PlayerHighlightOn")
util.AddNetworkString("TTT_Vampire_PlayerHighlightOn")
util.AddNetworkString("TTT_Traitor_PlayerHighlightOn")
util.AddNetworkString("TTT_PlayerHighlightOff")
util.AddNetworkString("TTT_BuyableWeapon_Detective")
util.AddNetworkString("TTT_BuyableWeapon_Mercenary")
util.AddNetworkString("TTT_BuyableWeapon_Vampire")
util.AddNetworkString("TTT_BuyableWeapon_Zombie")
util.AddNetworkString("TTT_BuyableWeapon_Traitor")
util.AddNetworkString("TTT_BuyableWeapon_Assassin")
util.AddNetworkString("TTT_BuyableWeapon_Hypnotist")
util.AddNetworkString("TTT_BuyableWeapon_Killer")

jesterkilled = 0

rolemapgo = {}

rolemapgotwo = {}

-- Round mechanics
function GM:Initialize()

    MsgN("Trouble In Terrorist Town gamemode initializing...")

    -- Force friendly fire to be enabled. If it is off, we do not get lag compensation.
    RunConsoleCommand("mp_friendlyfire", "1")

    -- Default crowbar unlocking settings, may be overridden by config entity
    GAMEMODE.crowbar_unlocks = {
        [OPEN_DOOR] = true,
        [OPEN_ROT] = true,
        [OPEN_BUT] = true,
        [OPEN_NOTOGGLE] = true
    };

    -- More map config ent defaults
    GAMEMODE.force_plymodel = ""
    GAMEMODE.propspec_allow_named = true

    GAMEMODE.MapWin = WIN_NONE
    GAMEMODE.AwardedCredits = false
    GAMEMODE.AwardedKillerCredits = false
    GAMEMODE.AwardedVampireCredits = false
    GAMEMODE.AwardedCreditsDead = 0
    GAMEMODE.AwardedKillerCreditsDead = 0
    GAMEMODE.AwardedVampireCreditsDead = 0

    GAMEMODE.round_state = ROUND_WAIT
    GAMEMODE.FirstRound = true
    GAMEMODE.RoundStartTime = 0

    GAMEMODE.DamageLog = {}
    GAMEMODE.LastRole = {}
    GAMEMODE.playermodel = GetRandomPlayerModel()
    GAMEMODE.playercolor = COLOR_WHITE

    -- Delay reading of cvars until config has definitely loaded
    GAMEMODE.cvar_init = false

    SetGlobalFloat("ttt_round_end", -1)
    SetGlobalFloat("ttt_haste_end", -1)

    -- For the paranoid
    math.randomseed(os.time())

    WaitForPlayers()

    if cvars.Number("sv_alltalk", 0) > 0 then
        ErrorNoHalt("TTT WARNING: sv_alltalk is enabled. Dead players will be able to talk to living players. TTT will now attempt to set sv_alltalk 0.\n")
        RunConsoleCommand("sv_alltalk", "0")
    end

    local cstrike = false
    for _, g in pairs(engine.GetGames()) do
        if g.folder == 'cstrike' then cstrike = true end
    end
    if not cstrike then
        ErrorNoHalt("TTT WARNING: CS:S does not appear to be mounted by GMod. Things may break in strange ways. Server admin? Check the TTT readme for help.\n")
    end
end

-- Used to do this in Initialize, but server cfg has not always run yet by that
-- point.
function GM:InitCvars()
    MsgN("TTT initializing convar settings...")

    -- Initialize game state that is synced with client
    SetGlobalInt("ttt_rounds_left", GetConVar("ttt_round_limit"):GetInt())
    GAMEMODE:SyncGlobals()
    KARMA.InitState()

    self.cvar_init = true
end

function GM:InitPostEntity()
    WEPS.ForcePrecache()
end

-- Convar replication is broken in gmod, so we do this.
-- I don't like it any more than you do, dear reader.
function GM:SyncGlobals()
    SetGlobalBool("ttt_detective", ttt_detective:GetBool())
    SetGlobalBool("ttt_haste", ttt_haste:GetBool())
    SetGlobalInt("ttt_time_limit_minutes", GetConVar("ttt_time_limit_minutes"):GetInt())
    SetGlobalBool("ttt_highlight_admins", GetConVar("ttt_highlight_admins"):GetBool())
    SetGlobalBool("ttt_locational_voice", GetConVar("ttt_locational_voice"):GetBool())
    SetGlobalInt("ttt_idle_limit", GetConVar("ttt_idle_limit"):GetInt())

    SetGlobalBool("ttt_voice_drain", GetConVar("ttt_voice_drain"):GetBool())
    SetGlobalFloat("ttt_voice_drain_normal", GetConVar("ttt_voice_drain_normal"):GetFloat())
    SetGlobalFloat("ttt_voice_drain_admin", GetConVar("ttt_voice_drain_admin"):GetFloat())
    SetGlobalFloat("ttt_voice_drain_recharge", GetConVar("ttt_voice_drain_recharge"):GetFloat())

    SetGlobalBool("ttt_detective_search_only", GetConVar("ttt_detective_search_only"):GetBool())
    SetGlobalInt("ttt_shop_merc_mode", GetConVar("ttt_shop_merc_mode"):GetInt())
    SetGlobalBool("ttt_shop_assassin_sync", GetConVar("ttt_shop_assassin_sync"):GetBool())
    SetGlobalBool("ttt_shop_hypnotist_sync", GetConVar("ttt_shop_hypnotist_sync"):GetBool())

    SetGlobalBool("ttt_karma_beta", GetConVar("ttt_karma_beta"):GetBool())

    SetGlobalBool("sv_voiceenable", GetConVar("sv_voiceenable"):GetBool())

    SetGlobalBool("ttt_killer_show_target_icon", GetConVar("ttt_killer_show_target_icon"):GetBool())
    SetGlobalBool("ttt_zombie_show_target_icon", GetConVar("ttt_zombie_show_target_icon"):GetBool())
    SetGlobalBool("ttt_vampire_show_target_icon", GetConVar("ttt_vampire_show_target_icon"):GetBool())
end

function SendRoundState(state, ply)
    net.Start("TTT_RoundState")
    net.WriteUInt(state, 3)
    return ply and net.Send(ply) or net.Broadcast()
end

-- Round state is encapsulated by set/get so that it can easily be changed to
-- eg. a networked var if this proves more convenient
function SetRoundState(state)
    GAMEMODE.round_state = state

    SCORE:RoundStateChange(state)

    SendRoundState(state)
end

function GetRoundState()
    return GAMEMODE.round_state
end

local function EnoughPlayers()
    local ready = 0
    -- only count truly available players, ie. no forced specs
    for _, ply in pairs(player.GetAll()) do
        if IsValid(ply) and ply:ShouldSpawn() then
            ready = ready + 1
        end
    end
    return ready >= ttt_minply:GetInt()
end

-- Used to be in Think/Tick, now in a timer
function WaitingForPlayersChecker()
    if GetRoundState() == ROUND_WAIT then
        if EnoughPlayers() then
            timer.Create("wait2prep", 1, 1, PrepareRound)

            timer.Stop("waitingforply")
        end
    end
end

-- Start waiting for players
function WaitForPlayers()
    SetRoundState(ROUND_WAIT)

    if not timer.Start("waitingforply") then
        timer.Create("waitingforply", 2, 0, WaitingForPlayersChecker)
    end
end

-- When a player initially spawns after mapload, everything is a bit strange;
-- just making him spectator for some reason does not work right. Therefore,
-- we regularly check for these broken spectators while we wait for players
-- and immediately fix them.
function FixSpectators()
    for k, ply in pairs(player.GetAll()) do
        if ply:IsSpec() and not ply:GetRagdollSpec() and ply:GetMoveType() < MOVETYPE_NOCLIP then
            ply:Spectate(OBS_MODE_ROAMING)
        end
    end
end

-- Used to be in think, now a timer
local function WinChecker()
    hook.Add("PlayerDeath", "OnPlayerDeath", function(victim, infl, attacker)
        if victim:GetJester() and attacker:IsPlayer() and infl:GetClass() ~= env_fire and not (attacker:GetJester() or attacker:GetSwapper()) and GetRoundState() == ROUND_ACTIVE then
            net.Start("TTT_JesterKiller")
            net.WriteString(attacker:Nick())
            net.WriteString(victim:Nick())
            net.WriteInt(-1, 6)
            net.Broadcast()
            jesterkilled = 1
        end
    end)
    if GetRoundState() == ROUND_ACTIVE then
        if CurTime() > GetGlobalFloat("ttt_round_end", 0) then
            EndRound(WIN_TIMELIMIT)
        else
            local win = hook.Call("TTTCheckForWin", GAMEMODE)
            if win ~= WIN_NONE then
                EndRound(win)
            end
        end
    end
end

local function NameChangeKick()
    if not GetConVar("ttt_namechange_kick"):GetBool() then
        timer.Remove("namecheck")
        return
    end

    if GetRoundState() == ROUND_ACTIVE then
        for _, ply in pairs(player.GetHumans()) do
            if ply.spawn_nick then
                if ply.has_spawned and ply.spawn_nick ~= ply:Nick() and not hook.Call("TTTNameChangeKick", GAMEMODE, ply) then
                    local t = GetConVar("ttt_namechange_bantime"):GetInt()
                    local msg = "Changed name during a round"
                    if t > 0 then
                        ply:KickBan(t, msg)
                    else
                        ply:Kick(msg)
                    end
                end
            else
                ply.spawn_nick = ply:Nick()
            end
        end
    end
end

function StartNameChangeChecks()
    if not GetConVar("ttt_namechange_kick"):GetBool() then return end

    -- bring nicks up to date, may have been changed during prep/post
    for _, ply in pairs(player.GetAll()) do
        ply.spawn_nick = ply:Nick()
    end

    if not timer.Exists("namecheck") then
        timer.Create("namecheck", 3, 0, NameChangeKick)
    end
end

function StartWinChecks()
    if not timer.Start("winchecker") then
        timer.Create("winchecker", 1, 0, WinChecker)
    end
end

function StopWinChecks()
    timer.Stop("winchecker")
end

local function CleanUp()
    local et = ents.TTT
    -- if we are going to import entities, it's no use replacing HL2DM ones as
    -- soon as they spawn, because they'll be removed anyway
    et.SetReplaceChecking(not et.CanImportEntities(game.GetMap()))

    et.FixParentedPreCleanup()

    game.CleanUpMap()

    et.FixParentedPostCleanup()

    -- Strip players now, so that their weapons are not seen by ReplaceEntities
    for k, v in pairs(player.GetAll()) do
        if IsValid(v) then
            v:StripWeapons()
        end
    end

    -- a different kind of cleanup
    hook.Remove("PlayerSay", "ULXMeCheck")
end

local function SpawnEntities()
    local et = ents.TTT
    -- Spawn weapons from script if there is one
    local import = et.CanImportEntities(game.GetMap())

    if import then
        et.ProcessImportScript(game.GetMap())
    else
        -- Replace HL2DM/ZM ammo/weps with our own
        et.ReplaceEntities()

        -- Populate CS:S/TF2 maps with extra guns
        et.PlaceExtraWeapons()
    end

    -- Replace weapons with similar types
    if et.ReplaceWeaponsFromPools then
        et.ReplaceWeaponsFromPools()
    end

    -- Finally, get players in there
    SpawnWillingPlayers()
end

local function StopRoundTimers()
    -- remove all timers
    timer.Stop("wait2prep")
    timer.Stop("prep2begin")
    timer.Stop("end2prep")
    timer.Stop("winchecker")
end

-- Make sure we have the players to do a round, people can leave during our
-- preparations so we'll call this numerous times
local function CheckForAbort()
    if not EnoughPlayers() then
        LANG.Msg("round_minplayers")
        StopRoundTimers()

        WaitForPlayers()
        return true
    end

    return false
end

function GM:TTTDelayRoundStartForVote()
    -- Can be used for custom voting systems
    --return true, 30
    return false
end

function PrepareRound()
    for _, v in pairs(player.GetAll()) do
        v:SetNWBool("HauntedSmoke", false)
        v:SetNWBool("KillerSmoke", false)
        v:SetNWBool("PlayerHighlightOn", false)
        v:SetNWBool("RoleRevealed", false)
    end

    jesterkilled = 0
    -- Check playercount
    if CheckForAbort() then return end

    local delay_round, delay_length = hook.Call("TTTDelayRoundStartForVote", GAMEMODE)

    if delay_round then
        delay_length = delay_length or 30

        LANG.Msg("round_voting", { num = delay_length })

        timer.Create("delayedprep", delay_length, 1, PrepareRound)
        return
    end

    -- Cleanup
    CleanUp()

    GAMEMODE.MapWin = WIN_NONE
    GAMEMODE.AwardedCredits = false
    GAMEMODE.AwardedKillerCredits = false
    GAMEMODE.AwardedVampireCredits = false
    GAMEMODE.AwardedCreditsDead = 0
    GAMEMODE.AwardedKillerCreditsDead = 0
    GAMEMODE.AwardedVampireCreditsDead = 0

    SCORE:Reset()

    -- Update damage scaling
    KARMA.RoundBegin()

    DRINKS.RoundBegin()

    -- New look. Random if no forced model set.
    GAMEMODE.playermodel = GAMEMODE.force_plymodel == "" and GetRandomPlayerModel() or GAMEMODE.force_plymodel
    GAMEMODE.playercolor = hook.Call("TTTPlayerColor", GAMEMODE, GAMEMODE.playermodel)

    if CheckForAbort() then return end
    -- Schedule round start
    local ptime = GetConVar("ttt_preptime_seconds"):GetFloat()
    if GAMEMODE.FirstRound then
        ptime = GetConVar("ttt_firstpreptime"):GetFloat()
        GAMEMODE.FirstRound = false
    end

    -- Piggyback on "round end" time global var to show end of phase timer
    SetRoundEnd(CurTime() + ptime)

    timer.Create("prep2begin", ptime, 1, BeginRound)
    -- Mute for a second around traitor selection, to counter a dumb exploit
    -- related to traitor's mics cutting off for a second when they're selected.
    timer.Create("selectmute", ptime - 1, 1, function() MuteForRestart(true) end)

    LANG.Msg("round_begintime", { num = ptime - 1.5 })
    SetRoundState(ROUND_PREP)

    -- Delay spawning until next frame to avoid ent overload
    timer.Simple(0.01, SpawnEntities)
    -- Undo the roundrestart mute, though they will once again be muted for the
    -- selectmute timer.
    timer.Create("restartmute", 1, 1, function() MuteForRestart(false) end)

    net.Start("TTT_ClearClientState") net.Broadcast()
    net.Start("TTT_ClearTeleportMarks") net.Broadcast()

    -- In case client's cleanup fails, make client set all players to innocent role
    timer.Simple(1, SendRoleReset)
    -- Tell hooks and map we started prep
    hook.Call("TTTPrepareRound")

    ents.TTT.TriggerRoundStateOutputs(ROUND_PREP)
end

function SetRoundEnd(endtime)
    SetGlobalFloat("ttt_round_end", endtime)
end

function IncRoundEnd(incr)
    SetRoundEnd(GetGlobalFloat("ttt_round_end", 0) + incr)
end

function TellTraitorsAboutTraitors()
    local traitornicks = {}
    local glitchnick = {}
    local jesternick = {}
    local killernick = {}
    for k, v in pairs(player.GetAll()) do
        if v:IsTraitor() or v:IsHypnotist() or v:IsAssassin() then
            table.insert(traitornicks, v:Nick())
        elseif v:IsGlitch() then
            table.insert(traitornicks, v:Nick())
            table.insert(glitchnick, v:Nick())
        elseif v:IsJester() or v:IsSwapper() then
            table.insert(jesternick, v:Nick())
        elseif v:IsKiller() then
            table.insert(killernick, v:Nick())
        end
    end

    -- This is ugly as hell, but it's kinda nice to filter out the names of the
    -- traitors themselves in the messages to them
    for k, v in pairs(player.GetAll()) do
        if v:IsTraitor() or v:IsHypnotist() or v:IsAssassin() then
            if not table.IsEmpty(glitchnick) then
                v:PrintMessage(HUD_PRINTTALK, "There is a Glitch.")
                v:PrintMessage(HUD_PRINTCENTER, "There is a Glitch.")
            end
            if not table.IsEmpty(killernick) then
                v:PrintMessage(HUD_PRINTTALK, "There is a Killer.")
                if not table.IsEmpty(glitchnick) then
                    timer.Simple(2, function()
                        v:PrintMessage(HUD_PRINTCENTER, "There is a Killer.")
                    end)
                else
                    v:PrintMessage(HUD_PRINTCENTER, "There is a Killer.")
                end
            end
            if #traitornicks < 2 then
                LANG.Msg(v, "round_traitors_one")
                return
            else
                local names = ""
                for i, name in pairs(traitornicks) do
                    if name ~= v:Nick() then
                        names = names .. name .. ", "
                    end
                end
                names = string.sub(names, 1, -3)
                LANG.Msg(v, "round_traitors_more", { names = names })
            end
        end
    end
end

function SpawnWillingPlayers(dead_only)
    local plys = player.GetAll()
    local wave_delay = GetConVar("ttt_spawn_wave_interval"):GetFloat()

    -- simple method, should make this a case of the other method once that has
    -- been tested.
    if wave_delay <= 0 or dead_only then
        for k, ply in pairs(player.GetAll()) do
            if IsValid(ply) then
                ply:SpawnForRound(dead_only, true)
            end
        end
    else
        -- wave method
        local num_spawns = #GetSpawnEnts()

        local to_spawn = {}
        for _, ply in RandomPairs(plys) do
            if IsValid(ply) and ply:ShouldSpawn() then
                table.insert(to_spawn, ply)
                GAMEMODE:PlayerSpawnAsSpectator(ply)
            end
        end

        local sfn = function()
            local c = 0
            -- fill the available spawnpoints with players that need
            -- spawning
            while c < num_spawns and #to_spawn > 0 do
                for k, ply in pairs(to_spawn) do
                    if IsValid(ply) and ply:SpawnForRound() then
                        -- a spawn ent is now occupied
                        c = c + 1
                    end
                    -- Few possible cases:
                    -- 1) player has now been spawned
                    -- 2) player should remain spectator after all
                    -- 3) player has disconnected
                    -- In all cases we don't need to spawn them again.
                    table.remove(to_spawn, k)

                    -- all spawn ents are occupied, so the rest will have
                    -- to wait for next wave
                    if c >= num_spawns then
                        break
                    end
                end
            end

            MsgN("Spawned " .. c .. " players in spawn wave.")

            if #to_spawn == 0 then
                timer.Remove("spawnwave")
                MsgN("Spawn waves ending, all players spawned.")
            end
        end

        MsgN("Spawn waves starting.")
        timer.Create("spawnwave", wave_delay, 0, sfn)

        -- already run one wave, which may stop the timer if everyone is spawned
        -- in one go
        sfn()
    end
end

local function InitRoundEndTime()
    -- Init round values
    local endtime = CurTime() + (GetConVar("ttt_roundtime_minutes"):GetInt() * 60)
    if HasteMode() then
        endtime = CurTime() + (GetConVar("ttt_haste_starting_minutes"):GetInt() * 60)
        -- this is a "fake" time shown to innocents, showing the end time if no
        -- one would have been killed, it has no gameplay effect
        SetGlobalFloat("ttt_haste_end", endtime)
    end

    SetRoundEnd(endtime)
end

function BeginRound()
    GAMEMODE:SyncGlobals()

    if CheckForAbort() then return end

    ReadRoleEquipment()
    InitRoundEndTime()

    if CheckForAbort() then return end

    -- Respawn dumb people who died during prep
    SpawnWillingPlayers(true)

    -- Remove their ragdolls
    ents.TTT.RemoveRagdolls(true)

    if CheckForAbort() then return end
    -- Select traitors & co. This is where things really start so we can't abort
    -- anymore.
    SelectRoles()
    LANG.Msg("round_selected")
    SendFullStateUpdate()

    -- Edge case where a player joins just as the round starts and is picked as
    -- traitor, but for whatever reason does not get the traitor state msg. So
    -- re-send after a second just to make sure everyone is getting it.
    timer.Simple(1, SendFullStateUpdate)
    timer.Simple(10, SendFullStateUpdate)
    SCORE:HandleSelection() -- log traitors and detectives

    for _, v in pairs(player.GetAll()) do
        v:SetPData("IsZombifying", 0)
        v:SetNWString("AssassinTarget", "")
        if v:GetRole() == ROLE_ASSASSIN then
            local enemies = {}
            local detectives = {}
            for _, p in pairs(player.GetAll()) do
                if p:Alive() and not p:IsSpec() then
                    if p:GetRole() == ROLE_INNOCENT or p:GetRole() == ROLE_PHANTOM or p:GetRole() == ROLE_MERCENARY or p:GetRole() == ROLE_KILLER or p:GetRole() == ROLE_VAMPIRE or p:GetRole() == ROLE_ZOMBIE then
                        table.insert(enemies, p:Nick())
                    elseif p:GetRole() == ROLE_DETECTIVE then
                        table.insert(detectives, p:Nick())
                    end
                end
            end
            if #enemies > 0 then
                v:SetNWString("AssassinTarget", enemies[math.random(#enemies)])
            elseif #detectives > 0 then
                v:SetNWString("AssassinTarget", detectives[math.random(#detectives)])
            end

            if #enemies + #detectives >= 1 then
                local targetCount
                if #enemies + #detectives > 1 then
                    targetCount = "first"
                elseif #enemies + #detectives == 1 then
                    targetCount = "final"
                end
                local targetMessage = "Your " .. targetCount .. " target is " .. v:GetNWString("AssassinTarget", "")
                v:PrintMessage(HUD_PRINTCENTER, targetMessage)
                v:PrintMessage(HUD_PRINTTALK, targetMessage)
            end
        elseif v:GetRole() == ROLE_HYPNOTIST then
            v:Give("weapon_hyp_brainwash")
        -- Ensure the Killer has their knife if it's enabled
        elseif v:GetRole() == ROLE_KILLER and GetConVar("ttt_killer_knife_enabled"):GetBool() then
            v:StripWeapon("weapon_zm_improvised")
            v:Give("weapon_kil_knife")
        end
    end

    net.Start("TTT_JesterKiller")
    net.WriteString("")
    net.WriteString("")
    net.WriteInt(-1, 6)
    net.Broadcast()

    net.Start("TTT_ClearRoleSwaps")
    net.Broadcast()

    for k, v in pairs(player.GetAll()) do
        if v:Alive() and v:IsTerror() then
            net.Start("TTT_SpawnedPlayers")
            net.WriteString(v:Nick())
            net.Broadcast()
        end
    end

    -- Give the StateUpdate messages ample time to arrive
    timer.Simple(1.5, TellTraitorsAboutTraitors)
    timer.Simple(2.5, ShowRoundStartPopup)

    timer.Create("zombieHealthRegen", 0.66, 0, function()
        for k, v in pairs(player.GetAll()) do
            if v:Alive() and not v:IsSpec() and v:HasEquipmentItem(EQUIP_REGEN) then
                local hp = v:Health()
                if hp < 100 then
                    v:SetHealth(hp + 1)
                end
            end
        end
    end)

    -- Start the win condition check timer
    StartWinChecks()
    StartNameChangeChecks()
    timer.Create("selectmute", 1, 1, function() MuteForRestart(false) end)
    GAMEMODE.DamageLog = {}
    GAMEMODE.RoundStartTime = CurTime()

    -- Sound start alarm
    SetRoundState(ROUND_ACTIVE)
    LANG.Msg("round_started")
    ServerLog("Round proper has begun...\n")

    GAMEMODE:UpdatePlayerLoadouts() -- needs to happen when round_active

    hook.Call("TTTBeginRound")

    ents.TTT.TriggerRoundStateOutputs(ROUND_BEGIN)
end

function PrintResultMessage(type)
    ServerLog("Round ended.\n")
    if type == WIN_TIMELIMIT then
        LANG.Msg("win_time")
        ServerLog("Result: Timelimit reached, innocent win.\n")
    elseif type == WIN_TRAITOR then
        LANG.Msg("win_traitor")
        ServerLog("Result: Traitors win.\n")
    elseif type == WIN_INNOCENT then
        LANG.Msg("win_innocent")
        ServerLog("Result: Innocents win.\n")
    elseif type == WIN_JESTER then
        LANG.Msg("win_jester")
        ServerLog("Result: Jester wins.\n")
    elseif type == WIN_KILLER then
        LANG.Msg("killer")
        ServerLog("Result: Killer wins.\n")
    elseif type == WIN_MONSTER then
        LANG.Msg("monster")
        ServerLog("Result: Monsters win.\n")
    else
        ServerLog("Result: Unknown victory condition!\n")
    end
end

function CheckForMapSwitch()
    -- Check for mapswitch
    local rounds_left = math.max(0, GetGlobalInt("ttt_rounds_left", 6) - 1)
    SetGlobalInt("ttt_rounds_left", rounds_left)

    local time_left = math.max(0, (GetConVar("ttt_time_limit_minutes"):GetInt() * 60) - CurTime())
    local switchmap = false
    local nextmap = string.upper(game.GetMapNext())

    if rounds_left <= 0 then
        LANG.Msg("limit_round", { mapname = nextmap })
        switchmap = true
    elseif time_left <= 0 then
        LANG.Msg("limit_time", { mapname = nextmap })
        switchmap = true
    end

    if switchmap then
        timer.Stop("end2prep")
        timer.Simple(15, game.LoadNextMap)
    else
        LANG.Msg("limit_left", {
            num = rounds_left,
            time = math.ceil(time_left / 60),
            mapname = nextmap
        })
    end
end

function LogScore(type)

    local playerStats = {}
    if file.Exists("stats/playerStats.txt", "DATA") then
        playerStats = util.JSONToTable(file.Read("stats/playerStats.txt", "DATA"))
    end

    local roleStats = {}
    if file.Exists("stats/roleStats.txt", "DATA") then
        roleStats = util.JSONToTable(file.Read("stats/roleStats.txt", "DATA"))
    end

    local roundRoles = { false, false, false, false, false, false, false, false, false, false, false, false }
    local roleNames = { "Innocent", "Traitor", "Detective", "Mercenary", "Jester", "Phantom", "Hypnotist", "Glitch", "Zombie", "Vampire", "Swapper", "Assassin", "Killer" }

    for k, v in pairs(player.GetAll()) do
        local didWin = ((type == WIN_INNOCENT or type == WIN_TIMELIMIT) and (v:GetRole() == ROLE_INNOCENT or v:GetRole() == ROLE_DETECTIVE or v:GetRole() == ROLE_GLITCH or v:GetRole() == ROLE_MERCENARY or v:GetRole() == ROLE_PHANTOM)) or (type == WIN_TRAITOR and (v:GetRole() == ROLE_TRAITOR or v:GetRole() == ROLE_ASSASSIN or v:GetRole() == ROLE_HYPNOTIST)) or (type == WIN_MONSTER and (v:GetRole() == ROLE_VAMPIRE or v:GetRole() == ROLE_ZOMBIE)) or (type == WIN_JESTER and (v:GetRole() == ROLE_JESTER or v:GetRole() == ROLE_SWAPPER))

        if not playerStats[v:Nick()] then
            playerStats[v:Nick()] = { 0, 0 } -- Wins, Rounds
        end
        playerStats[v:Nick()][2] = playerStats[v:Nick()][2] + 1

        if didWin then
            playerStats[v:Nick()][1] = playerStats[v:Nick()][1] + 1
        end

        if not roundRoles[v:GetRole() + 1] then
            if not roleStats[roleNames[v:GetRole() + 1]] then
                roleStats[roleNames[v:GetRole() + 1]] = { 0, 0 } -- Wins, Rounds
            end
            roleStats[roleNames[v:GetRole() + 1]][2] = roleStats[roleNames[v:GetRole() + 1]][2] + 1

            if didWin then
                roleStats[roleNames[v:GetRole() + 1]][1] = roleStats[roleNames[v:GetRole() + 1]][1] + 1
            end

            roundRoles[v:GetRole()] = true
        end
    end

    file.Write("stats/playerStats.txt", util.TableToJSON(playerStats))
    file.Write("stats/roleStats.txt", util.TableToJSON(roleStats))
end

function EndRound(type)

    -- LogScore(type)

    PrintResultMessage(type)

    -- first handle round end
    SetRoundState(ROUND_POST)

    local ptime = math.max(5, GetConVar("ttt_posttime_seconds"):GetInt())
    LANG.Msg("win_showreport", { num = ptime })
    timer.Create("end2prep", ptime, 1, PrepareRound)

    -- Piggyback on "round end" time global var to show end of phase timer
    SetRoundEnd(CurTime() + ptime)

    timer.Create("restartmute", ptime - 1, 1, function() MuteForRestart(true) end)

    -- Stop checking for wins
    StopWinChecks()

    -- We may need to start a timer for a mapswitch, or start a vote
    CheckForMapSwitch()

    KARMA.RoundEnd()

    DRINKS.RoundEnd()

    -- now handle potentially error prone scoring stuff

    -- register an end of round event
    SCORE:RoundComplete(type)

    -- update player scores
    SCORE:ApplyEventLogScores(type)

    -- send the clients the round log, players will be shown the report
    SCORE:StreamToClients()

    -- server plugins might want to start a map vote here or something
    -- these hooks are not used by TTT internally
    hook.Call("TTTEndRound", GAMEMODE, type)

    ents.TTT.TriggerRoundStateOutputs(ROUND_POST, type)
end

function GM:MapTriggeredEnd(wintype)
    self.MapWin = wintype
end

-- The most basic win check is whether both sides have one dude alive
function GM:TTTCheckForWin()
    if ttt_dbgwin:GetBool() then return WIN_NONE end

    if GAMEMODE.MapWin == WIN_TRAITOR or GAMEMODE.MapWin == WIN_INNOCENT then
        local mw = GAMEMODE.MapWin
        GAMEMODE.MapWin = WIN_NONE
        return mw
    end

    local traitor_alive = false
    local innocent_alive = false
    local jester_alive = false
    local killer_alive = false
    local monster_alive = false
    for k, v in pairs(player.GetAll()) do
        if (v:Alive() and v:IsTerror()) or v:GetPData("IsZombifying", 0) == 1 then
            if v:GetTraitor() or v:GetHypnotist() or v:GetAssassin() then
                traitor_alive = true
            elseif v:GetJester() or v:GetSwapper() then
                jester_alive = true
            elseif v:GetKiller() then
                killer_alive = true
            elseif v:GetZombie() or v:GetVampire() or v:GetPData("IsZombifying", 0) == 1 then
                monster_alive = true
            else
                innocent_alive = true
            end
        end

        if traitor_alive and innocent_alive and jester_alive then
            return WIN_NONE --early out
        end
    end

    if traitor_alive and not innocent_alive and not killer_alive and jester_alive and not monster_alive then
        return WIN_TRAITOR
    elseif traitor_alive and not innocent_alive and not killer_alive and not jester_alive and jesterkilled == 0 and not monster_alive then
        return WIN_TRAITOR
    elseif not traitor_alive and innocent_alive and not killer_alive and jester_alive and not monster_alive then
        return WIN_INNOCENT
    elseif not traitor_alive and innocent_alive and not killer_alive and not jester_alive and jesterkilled == 0 and not monster_alive then
        return WIN_INNOCENT
    elseif not innocent_alive and not killer_alive and jester_alive and not monster_alive then
        -- ultimately if no one is alive, traitors win
        return WIN_TRAITOR
    elseif not innocent_alive and not killer_alive and not jester_alive and jesterkilled == 0 and not monster_alive then
        return WIN_TRAITOR
    elseif not traitor_alive and not innocent_alive and killer_alive and not monster_alive then
        return WIN_KILLER
    elseif not jester_alive and jesterkilled == 1 then
        return WIN_JESTER
    elseif not traitor_alive and not innocent_alive and not killer_alive and jester_alive and monster_alive then
        return WIN_MONSTER
    elseif not traitor_alive and not innocent_alive and not killer_alive and not jester_alive and jesterkilled == 0 and monster_alive then
        return WIN_MONSTER
    end
    return WIN_NONE
end

local function GetTraitorCount(ply_count)
    -- get number of traitors: pct of players rounded up
    local traitor_count = math.ceil(ply_count * GetConVar("ttt_traitor_pct"):GetFloat())
    -- make sure the traitor count is within the range [1, max]
    return math.Clamp(traitor_count, 1, GetConVar("ttt_traitor_max"):GetInt())
end

local function GetMonsterCount(ply_count)
    -- get number of monsters: pct of players rounded up
    return math.ceil(ply_count * GetConVar("ttt_monster_pct"):GetFloat())
end

local function GetDetectiveCount(ply_count)
    if ply_count < GetConVar("ttt_detective_min_players"):GetInt() then return 0 end

    -- get number of detectives: pct of players rounded up
    local det_count = math.ceil(ply_count * GetConVar("ttt_detective_pct"):GetFloat())
    -- make sure the detective count is within the range [1, max]
    return math.Clamp(det_count, 1, GetConVar("ttt_detective_max"):GetInt())
end

local function WasRole(prev_roles, ply, ...)
    for i = 1, select("#", ...) do
        local v = select(i, ...)
        if table.HasValue(prev_roles[v], ply) then
            return true
        end
    end

    return false
end

local function GetRandomPlayer(choicelist)
    if #choicelist == 0 then
        return nil, nil
    end
    local pick = math.random(1, #choicelist)
    return choicelist[pick], pick
end

function SelectRoles()
    local choices = {}
    local prev_roles = {
        [ROLE_INNOCENT] = {},
        [ROLE_TRAITOR] = {},
        [ROLE_DETECTIVE] = {},
        [ROLE_MERCENARY] = {},
        [ROLE_HYPNOTIST] = {},
        [ROLE_GLITCH] = {},
        [ROLE_JESTER] = {},
        [ROLE_PHANTOM] = {},
        [ROLE_ZOMBIE] = {},
        [ROLE_VAMPIRE] = {},
        [ROLE_SWAPPER] = {},
        [ROLE_ASSASSIN] = {},
        [ROLE_KILLER] = {}
    };

    if not GAMEMODE.LastRole then GAMEMODE.LastRole = {} end

    for _, v in pairs(player.GetAll()) do
        -- everyone on the spec team is in specmode
        if IsValid(v) and (not v:IsSpec()) then
            -- save previous role and sign up as possible traitor/detective
            local r = GAMEMODE.LastRole[v:SteamID()] or v:GetRole() or ROLE_INNOCENT

            table.insert(prev_roles[r], v)
            table.insert(choices, v)
        end

        v:SetRole(ROLE_INNOCENT)
    end

    -- determine how many of each role we want
    local choice_count = #choices
    local traitor_count = GetTraitorCount(choice_count)
    local monster_count = GetMonsterCount(choice_count)
    local det_count = GetDetectiveCount(choice_count)

    local zombie_chance = GetConVar("ttt_zombie_chance"):GetFloat()
    local vampire_chance = GetConVar("ttt_vampire_chance"):GetFloat()
    local hypnotist_chance = GetConVar("ttt_hypnotist_chance"):GetFloat()
    local assassin_chance = GetConVar("ttt_assassin_chance"):GetFloat()
    local jester_chance = GetConVar("ttt_jester_chance"):GetFloat()
    local swapper_chance = GetConVar("ttt_swapper_chance"):GetFloat()
    local killer_chance = GetConVar("ttt_killer_chance"):GetFloat()
    local glitch_chance = GetConVar("ttt_glitch_chance"):GetFloat()
    local phantom_chance = GetConVar("ttt_phantom_chance"):GetFloat()
    local mercenary_chance = GetConVar("ttt_mercenary_chance"):GetFloat()

    if choice_count == 0 then return end

    local choices_copy = table.Copy(choices)
    local prev_roles_copy = table.Copy(prev_roles)

    hook.Call("TTTSelectRoles", GAMEMODE, choices_copy, prev_roles_copy)

    -- first select traitors
    local ts = 0
    -- Count the "Traitor" role by itself since the Glitch can be identified via the special roles unless there are 2 vanilla traitors
    local vanilla_ts = 0
    local ds = 0
    local ms = 0
    local hasMonster = false
    local hasSpecial = false
    local hasJester = false
    local hasMercenary = false
    local hasPhantom = false
    local hasGlitch = false
    local hasKiller = false

    print("-----CHECKING EXTERNALLY CHOSEN ROLES-----")
    for _, v in pairs(player.GetAll()) do
        if IsValid(v) and (not v:IsSpec()) then
            local index = 0
            for i, j in pairs(choices) do
                if v == j then
                    index = i
                end
            end
            local role = v:GetRole()
            if role ~= ROLE_INNOCENT then
                table.remove(choices, index)
                if role == ROLE_TRAITOR then
                    ts = ts + 1
                    vanilla_ts = vanilla_ts + 1
                    print(v:Nick() .. " (" .. v:SteamID() .. ") - Traitor")
                elseif role == ROLE_ZOMBIE then
                    ms = ms + 1
                    print(v:Nick() .. " (" .. v:SteamID() .. ") - Zombie")
                    v:SetZombiePrime(true)
                    hasMonster = true
                elseif role == ROLE_HYPNOTIST then
                    ts = ts + 1
                    hasSpecial = true
                    print(v:Nick() .. " (" .. v:SteamID() .. ") - Hypnotist")
                elseif role == ROLE_VAMPIRE then
                    ms = ms + 1
                    hasMonster = true
                    print(v:Nick() .. " (" .. v:SteamID() .. ") - Vampire")
                elseif role == ROLE_ASSASSIN then
                    ts = ts + 1
                    hasSpecial = true
                    print(v:Nick() .. " (" .. v:SteamID() .. ") - Assassin")
                elseif role == ROLE_JESTER then
                    hasJester = true
                    print(v:Nick() .. " (" .. v:SteamID() .. ") - Jester")
                elseif role == ROLE_SWAPPER then
                    hasJester = true
                    print(v:Nick() .. " (" .. v:SteamID() .. ") - Swapper")
                elseif role == ROLE_KILLER then
                    hasKiller = true
                    print(v:Nick() .. " (" .. v:SteamID() .. ") - Killer")
                elseif role == ROLE_DETECTIVE then
                    ds = ds + 1
                    print(v:Nick() .. " (" .. v:SteamID() .. ") - Detective")
                elseif role == ROLE_MERCENARY then
                    hasMercenary = true
                    print(v:Nick() .. " (" .. v:SteamID() .. ") - Mercenary")
                elseif role == ROLE_PHANTOM then
                    hasPhantom = true
                    print(v:Nick() .. " (" .. v:SteamID() .. ") - Phantom")
                elseif role == ROLE_GLITCH then
                    hasGlitch = true
                    print(v:Nick() .. " (" .. v:SteamID() .. ") - Glitch")
                end
            end
        end
    end

    print("-----RANDOMLY PICKING REMAINING ROLES-----")
    while ts < traitor_count and #choices > 0 do
        -- select random index in choices table
        local pply, pick = GetRandomPlayer(choices)

        -- make this guy traitor if he was not one last time, or if he makes
        -- a roll
        if IsValid(pply) and (not WasRole(prev_roles, pply, ROLE_TRAITOR, ROLE_ASSASSIN, ROLE_HYPNOTIST) or math.random(1, 3) == 2) then
            if ts >= GetConVar("ttt_hypnotist_required_traitors"):GetInt() and GetConVar("ttt_hypnotist_enabled"):GetInt() == 1 and math.random() <= hypnotist_chance and not hasSpecial then
                print(pply:Nick() .. " (" .. pply:SteamID() .. ") - Hypnotist")
                pply:SetRole(ROLE_HYPNOTIST)
                hasSpecial = true
            elseif ts >= GetConVar("ttt_assassin_required_traitors"):GetInt() and GetConVar("ttt_assassin_enabled"):GetInt() == 1 and math.random() <= assassin_chance and not hasSpecial then
                print(pply:Nick() .. " (" .. pply:SteamID() .. ") - Assassin")
                pply:SetRole(ROLE_ASSASSIN)
                hasSpecial = true
            else
                print(pply:Nick() .. " (" .. pply:SteamID() .. ") - Traitor")
                pply:SetRole(ROLE_TRAITOR)
                vanilla_ts = vanilla_ts + 1
            end
            table.remove(choices, pick)
            ts = ts + 1
        end
    end

    while ms < monster_count and #choices > 0 do
        -- select random index in choices table
        local pply, pick = GetRandomPlayer(choices)

        -- make this guy monster if he was not one last time, or if he makes
        -- a roll
        if IsValid(pply) and (not WasRole(prev_roles, pply, ROLE_ZOMBIE, ROLE_VAMPIRE) or math.random(1, 3) == 2) then
            if ts >= GetConVar("ttt_zombie_required_traitors"):GetInt() and GetConVar("ttt_zombie_enabled"):GetInt() == 1 and math.random() <= zombie_chance and not hasMonster then
                print(pply:Nick() .. " (" .. pply:SteamID() .. ") - Zombie")
                pply:SetRole(ROLE_ZOMBIE)
                pply:SetZombiePrime(true)
                table.remove(choices, pick)
                hasMonster = true
            elseif ts >= GetConVar("ttt_vampire_required_traitors"):GetInt() and GetConVar("ttt_vampire_enabled"):GetInt() == 1 and math.random() <= vampire_chance and not hasMonster then
                print(pply:Nick() .. " (" .. pply:SteamID() .. ") - Vampire")
                pply:SetRole(ROLE_VAMPIRE)
                table.remove(choices, pick)
                hasMonster = true
            end
            -- Count the attempts so we don't stay in this loop forever
            ms = ms + 1
        end
    end

    -- now select detectives, explicitly choosing from players who did not get
    -- traitor, so becoming detective does not mean you lost a chance to be
    -- traitor
    local min_karma = GetConVarNumber("ttt_detective_karma_min") or 0
    while ds < det_count and #choices > 0 do
        -- sometimes we need all remaining choices to be detective to fill the
        -- roles up, this happens more often with a lot of detective-deniers
        if #choices <= (det_count - ds) then
            for k, pply in pairs(choices) do
                if IsValid(pply) then
                    print(pply:Nick() .. " (" .. pply:SteamID() .. ") - Detective")
                    pply:SetRole(ROLE_DETECTIVE)
                    table.remove(choices, k)
                    ds = ds + 1
                end
            end

            break -- out of while
        end

        -- select random index in choices table
        local pply, pick = GetRandomPlayer(choices)

        -- we are less likely to be a detective unless we were innocent last round
        if (IsValid(pply) and pply:GetBaseKarma() > min_karma and (WasRole(prev_roles, pply, ROLE_INNOCENT, ROLE_GLITCH, ROLE_PHANTOM, ROLE_MERCENARY) or math.random(1, 3) == 2)) then
            -- if a player has specified he does not want to be detective, we skip
            -- him here (he might still get it if we don't have enough
            -- alternatives)
            if not pply:GetAvoidDetective() or math.random(1, 2) == 2 then
                print(pply:Nick() .. " (" .. pply:SteamID() .. ") - Detective")
                pply:SetRole(ROLE_DETECTIVE)
                table.remove(choices, pick)
                ds = ds + 1
            end
        end
    end

    -- select random index in choices table
    local pply, pick = GetRandomPlayer(choices)

    -- make this guy jester if he was not one last time, or if he makes
    -- a roll
    if IsValid(pply) and (not WasRole(prev_roles, pply, ROLE_JESTER, ROLE_SWAPPER) or math.random(1, 3) == 2) then
        if GetConVar("ttt_jester_enabled"):GetInt() == 1 and #choices >= GetConVar("ttt_jester_required_innos"):GetInt() and math.random() <= jester_chance and not hasJester then
            if IsValid(pply) then
                print(pply:Nick() .. " (" .. pply:SteamID() .. ") - Jester")
                pply:SetRole(ROLE_JESTER)
                table.remove(choices, pick)
                hasJester = true
            end
        elseif GetConVar("ttt_swapper_enabled"):GetInt() == 1 and #choices >= GetConVar("ttt_swapper_required_innos"):GetInt() and math.random() <= swapper_chance and not hasJester then
            if IsValid(pply) then
                print(pply:Nick() .. " (" .. pply:SteamID() .. ") - Swapper")
                pply:SetRole(ROLE_SWAPPER)
                table.remove(choices, pick)
                hasJester = true
            end
        end
    end

    -- select random index in choices table
    pply, pick = GetRandomPlayer(choices)
    -- make this guy killer if he was not one last time, or if he makes
    -- a roll
    if IsValid(pply) and (not WasRole(prev_roles, pply, ROLE_KILLER) or math.random(1, 3) == 2) then
        if GetConVar("ttt_killer_enabled"):GetInt() == 1 and #choices >= GetConVar("ttt_killer_required_innos"):GetInt() and math.random() <= killer_chance and not hasKiller then
            if IsValid(pply) then
                print(pply:Nick() .. " (" .. pply:SteamID() .. ") - Killer")
                pply:SetRole(ROLE_KILLER)
                pply:SetMaxHealth(GetConVar("ttt_killer_max_health"):GetInt())
                pply:SetHealth(GetConVar("ttt_killer_max_health"):GetInt())
                table.remove(choices, pick)
                hasKiller = true
            end
        end
    end

    -- select random index in choices table
    pply, pick = GetRandomPlayer(choices)
    if IsValid(pply) and (not WasRole(prev_roles, pply, ROLE_MERCENARY) or math.random(1, 3) == 2) then
        if GetConVar("ttt_mercenary_enabled"):GetInt() == 1 and #choices >= GetConVar("ttt_mercenary_required_innos"):GetInt() and math.random() <= mercenary_chance and not hasMercenary then
            if IsValid(pply) then
                print(pply:Nick() .. " (" .. pply:SteamID() .. ") - Mercenary")
                pply:SetRole(ROLE_MERCENARY)
                table.remove(choices, pick)
                hasMercenary = true
            end
        end
    end

    -- select random index in choices table
    pply, pick = GetRandomPlayer(choices)
    if IsValid(pply) and (not WasRole(prev_roles, pply, ROLE_PHANTOM) or math.random(1, 3) == 2) then
        if GetConVar("ttt_phantom_enabled"):GetInt() == 1 and #choices >= GetConVar("ttt_phantom_required_innos"):GetInt() and math.random() <= phantom_chance and not hasPhantom then
            if IsValid(pply) then
                print(pply:Nick() .. " (" .. pply:SteamID() .. ") - Phantom")
                pply:SetRole(ROLE_PHANTOM)
                table.remove(choices, pick)
                hasPhantom = true
            end
        end
    end

    -- select random index in choices table
    pply, pick = GetRandomPlayer(choices)
    if IsValid(pply) and (not WasRole(prev_roles, pply, ROLE_GLITCH) or math.random(1, 3) == 2) then
        -- Only spawn a glitch if we have multiple vanilla Traitors since otherwise the role doesn't do anything
        if GetConVar("ttt_glitch_enabled"):GetInt() == 1 and #choices >= GetConVar("ttt_glitch_required_innos"):GetInt() and math.random() <= glitch_chance and not hasGlitch and vanilla_ts > 1 then
            if IsValid(pply) then
                print(pply:Nick() .. " (" .. pply:SteamID() .. ") - Glitch")
                pply:SetRole(ROLE_GLITCH)
                table.remove(choices, pick)
                hasGlitch = true
            end
        end
    end

    -- Anyone left is innocent
    for _, v in pairs(choices) do
        if v:GetRole() ~= ROLE_DETECTIVE then
            print(v:Nick() .. " (" .. v:SteamID() .. ") - Innocent")
        end
    end
    print("------------DONE PICKING ROLES------------")

    GAMEMODE.LastRole = {}

    for _, ply in pairs(player.GetAll()) do
        -- initialize credit count for everyone based on their role
        ply:SetDefaultCredits()

        -- store a steamid -> role map
        GAMEMODE.LastRole[ply:SteamID()] = ply:GetRole()
    end
end

local function ForceRoundRestart(ply, command, args)
    -- ply is nil on dedicated server console
    if (not IsValid(ply)) or ply:IsAdmin() or ply:IsSuperAdmin() or cvars.Bool("sv_cheats", 0) then
        LANG.Msg("round_restart")

        StopRoundTimers()

        -- do prep
        PrepareRound()
    else
        ply:PrintMessage(HUD_PRINTCONSOLE, "You must be a GMod Admin or SuperAdmin on the server to use this command, or sv_cheats must be enabled.")
    end
end

concommand.Add("ttt_roundrestart", ForceRoundRestart)

-- If this logic or the list of roles who can buy is changed, it must also be updated in weaponry.lua and cl_equip.lua
function ReadRoleEquipment()
    local rolenames = { "Detective", "Mercenary", "Vampire", "Zombie", "Traitor", "Assassin", "Hypnotist", "Killer" }
    for _, role in pairs(rolenames) do
        local rolefiles, _ = file.Find("roleweapons/" .. role:lower() .. "/*.txt", "DATA")
        local roleweapons = { }
        for _, v in pairs(rolefiles) do
            local lastdotpos = v:find("%.")
            local weaponname = v:sub(0, lastdotpos - 1)
            table.insert(roleweapons, weaponname)
        end

        net.Start("TTT_BuyableWeapon_" .. role)
        net.WriteTable(roleweapons)
        net.Broadcast()
    end
end