function GetTraitors()
    local trs = {}
    for _, v in ipairs(player.GetAll()) do
        if player.IsTraitorTeam(v) then table.insert(trs, v) end
    end

    return trs
end

function CountTraitors() return #GetTraitors() end

-- Role state communication

-- Send every player their role
local function SendPlayerRoles()
    for _, v in pairs(player.GetAll()) do
        net.Start("TTT_Role")
        net.WriteUInt(v:GetRole(), 4)
        net.Send(v)
    end
end

local function SendRoleListMessage(role, role_ids, ply_or_rf)
    net.Start("TTT_RoleList")
    net.WriteUInt(role, 4)

    -- list contents
    local num_ids = #role_ids
    net.WriteUInt(num_ids, 8)
    for i = 1, num_ids do
        net.WriteUInt(role_ids[i] - 1, 7)
    end

    if ply_or_rf then net.Send(ply_or_rf)
    else net.Broadcast()
    end
end

local function SendRoleList(role, ply_or_rf, pred)
    local role_ids = {}
    for _, v in pairs(player.GetAll()) do
        if v:IsRole(role) then
            if not pred or (pred and pred(v)) then
                table.insert(role_ids, v:EntIndex())
            end
        end
    end

    SendRoleListMessage(role, role_ids, ply_or_rf)
end

local function SendConfirmedRoleList(role, ply_or_rf)
    SendRoleList(role, ply_or_rf, function(p) return p:GetNWBool("body_searched") end)
end

-- Tell traitors about other traitors

function SendTraitorList(ply_or_rf) SendRoleList(ROLE_TRAITOR, ply_or_rf) end

function SendDetraitorList(ply_or_rf) SendRoleList(ROLE_DETRAITOR, ply_or_rf) end

function SendDetectiveList(ply_or_rf) SendRoleList(ROLE_DETECTIVE, ply_or_rf) end

function SendMercenaryList(ply_or_rf) SendRoleList(ROLE_MERCENARY, ply_or_rf) end

function SendHypnotistList(ply_or_rf) SendRoleList(ROLE_HYPNOTIST, ply_or_rf) end

function SendGlitchList(ply_or_rf) SendRoleList(ROLE_GLITCH, ply_or_rf) end

function SendJesterList(ply_or_rf) SendRoleList(ROLE_JESTER, ply_or_rf) end

function SendPhantomList(ply_or_rf) SendRoleList(ROLE_PHANTOM, ply_or_rf) end

function SendZombieList(ply_or_rf) SendRoleList(ROLE_ZOMBIE, ply_or_rf) end

function SendVampireList(ply_or_rf) SendRoleList(ROLE_VAMPIRE, ply_or_rf) end

function SendSwapperList(ply_or_rf) SendRoleList(ROLE_SWAPPER, ply_or_rf) end

function SendAssassinList(ply_or_rf) SendRoleList(ROLE_ASSASSIN, ply_or_rf) end

function SendKillerList(ply_or_rf) SendRoleList(ROLE_KILLER, ply_or_rf) end

function SendInnocentList(ply_or_rf) SendRoleList(ROLE_INNOCENT, ply_or_rf) end

function SendConfirmedTraitorList(ply_or_rf) SendConfirmedRoleList(ROLE_TRAITOR, ply_or_rf) end

function SendConfirmedHypnotistList(ply_or_rf) SendConfirmedRoleList(ROLE_HYPNOTIST, ply_or_rf) end

function SendConfirmedAssassinList(ply_or_rf) SendConfirmedRoleList(ROLE_ASSASSIN, ply_or_rf) end

function SendConfirmedDetraitorList(ply_or_rf) SendConfirmedRoleList(ROLE_DETRAITOR, ply_or_rf) end

function SendConfirmedZombieList(ply_or_rf) SendConfirmedRoleList(ROLE_ZOMBIE, ply_or_rf) end

function SendConfirmedVampireList(ply_or_rf) SendConfirmedRoleList(ROLE_VAMPIRE, ply_or_rf) end

function SendFullStateUpdate()
    SendPlayerRoles()
    SendInnocentList()
    SendTraitorList()
    SendDetraitorList()
    SendDetectiveList()
    SendMercenaryList()
    SendHypnotistList()
    SendGlitchList()
    SendJesterList()
    SendPhantomList()
    SendZombieList()
    SendVampireList()
    SendSwapperList()
    SendAssassinList()
    SendKillerList()
    -- not useful to sync confirmed traitors here
end

function SendRoleReset(ply_or_rf)
    local plys = player.GetAll()

    net.Start("TTT_RoleList")
    net.WriteUInt(ROLE_INNOCENT, 4)

    net.WriteUInt(#plys, 8)
    for _, v in pairs(plys) do
        net.WriteUInt(v:EntIndex() - 1, 7)
    end

    if ply_or_rf then
        net.Send(ply_or_rf)
    else
        net.Broadcast()
    end
end

-- Console commands
local function request_rolelist(ply)
    -- Client requested a state update. Note that the client can only use this
    -- information after entities have been initialised (e.g. in InitPostEntity).
    if GetRoundState() ~= ROUND_WAIT then
        SendRoleReset(ply)
        SendDetectiveList(ply)
        SendMercenaryList(ply)
        SendGlitchList(ply)
        SendJesterList(ply)
        SendPhantomList(ply)
        SendSwapperList(ply)
        SendKillerList(ply)

        if GetGlobalBool("ttt_monsters_are_traitors") and ply:IsTraitorTeam() then
            SendZombieList(ply)
            SendVampireList(ply)
        else
            SendConfirmedZombieList(ply)
            SendConfirmedVampireList(ply)
        end

        if ply:IsTraitorTeam() then
            SendTraitorList(ply)
            SendHypnotistList(ply)
            SendAssassinList(ply)
            SendDetraitorList(ply)
        else
            SendConfirmedTraitorList(ply)
            SendConfirmedHypnotistList(ply)
            SendConfirmedAssassinList(ply)
            SendConfirmedDetraitorList(ply)
        end
    end
end

concommand.Add("_ttt_request_rolelist", request_rolelist)

local function force_terror(ply)
    ply:SetRoleAndBroadcast(ROLE_INNOCENT)
    ply:UnSpectate()
    ply:SetTeam(TEAM_TERROR)

    ply:StripAll()

    ply:Spawn()
    ply:PrintMessage(HUD_PRINTTALK, "You are now on the terrorist team.")

    SendFullStateUpdate()
end

concommand.Add("ttt_force_terror", force_terror, nil, nil, FCVAR_CHEAT)

local function force_innocent(ply)
    ply:SetRoleAndBroadcast(ROLE_INNOCENT)
    ply:SetMaxHealth(100)
    ply:SetHealth(100)
    if ply:HasWeapon("weapon_hyp_brainwash") then
        ply:StripWeapon("weapon_hyp_brainwash")
    end
    if ply:HasWeapon("weapon_vam_fangs") then
        ply:StripWeapon("weapon_vam_fangs")
    end
    if ply:HasWeapon("weapon_zom_claws") then
        ply:StripWeapon("weapon_zom_claws")
    end
    if ply:HasWeapon("weapon_kil_knife") then
        ply:StripWeapon("weapon_kil_knife")
    end
    ply:Give("weapon_zm_improvised")

    SendFullStateUpdate()
end

concommand.Add("ttt_force_innocent", force_innocent, nil, nil, FCVAR_CHEAT)

local function force_traitor(ply)
    ply:SetRoleAndBroadcast(ROLE_TRAITOR)
    ply:SetMaxHealth(100)
    ply:SetHealth(100)
    ply:AddCredits(GetConVarNumber("ttt_credits_starting"))
    if ply:HasWeapon("weapon_hyp_brainwash") then
        ply:StripWeapon("weapon_hyp_brainwash")
    end
    if ply:HasWeapon("weapon_vam_fangs") then
        ply:StripWeapon("weapon_vam_fangs")
    end
    if ply:HasWeapon("weapon_zom_claws") then
        ply:StripWeapon("weapon_zom_claws")
    end
    if ply:HasWeapon("weapon_kil_knife") then
        ply:StripWeapon("weapon_kil_knife")
    end
    ply:Give("weapon_zm_improvised")

    SendFullStateUpdate()
end

concommand.Add("ttt_force_traitor", force_traitor, nil, nil, FCVAR_CHEAT)

local function force_detraitor(ply)
    ply:SetRoleAndBroadcast(ROLE_DETRAITOR)
    ply:SetMaxHealth(100)
    ply:SetHealth(100)
    ply:AddCredits(GetConVarNumber("ttt_der_credits_starting"))
    if ply:HasWeapon("weapon_hyp_brainwash") then
        ply:StripWeapon("weapon_hyp_brainwash")
    end
    if ply:HasWeapon("weapon_vam_fangs") then
        ply:StripWeapon("weapon_vam_fangs")
    end
    if ply:HasWeapon("weapon_zom_claws") then
        ply:StripWeapon("weapon_zom_claws")
    end
    if ply:HasWeapon("weapon_kil_knife") then
        ply:StripWeapon("weapon_kil_knife")
    end
    ply:Give("weapon_zm_improvised")

    SendFullStateUpdate()
end

concommand.Add("ttt_force_detraitor", force_detraitor, nil, nil, FCVAR_CHEAT)

local function force_detective(ply)
    ply:SetRoleAndBroadcast(ROLE_DETECTIVE)
    ply:SetMaxHealth(100)
    ply:SetHealth(100)
    ply:AddCredits(GetConVarNumber("ttt_det_credits_starting"))
    if ply:HasWeapon("weapon_hyp_brainwash") then
        ply:StripWeapon("weapon_hyp_brainwash")
    end
    if ply:HasWeapon("weapon_vam_fangs") then
        ply:StripWeapon("weapon_vam_fangs")
    end
    if ply:HasWeapon("weapon_zom_claws") then
        ply:StripWeapon("weapon_zom_claws")
    end
    if ply:HasWeapon("weapon_kil_knife") then
        ply:StripWeapon("weapon_kil_knife")
    end
    ply:Give("weapon_zm_improvised")

    SendFullStateUpdate()
end

concommand.Add("ttt_force_detective", force_detective, nil, nil, FCVAR_CHEAT)

local function force_mercenary(ply)
    ply:SetRoleAndBroadcast(ROLE_MERCENARY)
    ply:SetMaxHealth(100)
    ply:SetHealth(100)
    ply:AddCredits(GetConVarNumber("ttt_mer_credits_starting"))
    if ply:HasWeapon("weapon_hyp_brainwash") then
        ply:StripWeapon("weapon_hyp_brainwash")
    end
    if ply:HasWeapon("weapon_vam_fangs") then
        ply:StripWeapon("weapon_vam_fangs")
    end
    if ply:HasWeapon("weapon_zom_claws") then
        ply:StripWeapon("weapon_zom_claws")
    end
    if ply:HasWeapon("weapon_kil_knife") then
        ply:StripWeapon("weapon_kil_knife")
    end
    ply:Give("weapon_zm_improvised")

    SendFullStateUpdate()
end

concommand.Add("ttt_force_mercenary", force_mercenary, nil, nil, FCVAR_CHEAT)

local function force_hypnotist(ply)
    ply:SetRoleAndBroadcast(ROLE_HYPNOTIST)
    ply:SetMaxHealth(100)
    ply:SetHealth(100)
    ply:AddCredits(GetConVarNumber("ttt_hyp_credits_starting"))
    if ply:HasWeapon("weapon_vam_fangs") then
        ply:StripWeapon("weapon_vam_fangs")
    end
    if ply:HasWeapon("weapon_zom_claws") then
        ply:StripWeapon("weapon_zom_claws")
    end
    if ply:HasWeapon("weapon_kil_knife") then
        ply:StripWeapon("weapon_kil_knife")
    end
    ply:Give("weapon_zm_improvised")
    ply:Give("weapon_hyp_brainwash")

    SendFullStateUpdate()
end

concommand.Add("ttt_force_hypnotist", force_hypnotist, nil, nil, FCVAR_CHEAT)

local function force_glitch(ply)
    ply:SetRoleAndBroadcast(ROLE_GLITCH)
    ply:SetMaxHealth(100)
    ply:SetHealth(100)
    if ply:HasWeapon("weapon_hyp_brainwash") then
        ply:StripWeapon("weapon_hyp_brainwash")
    end
    if ply:HasWeapon("weapon_vam_fangs") then
        ply:StripWeapon("weapon_vam_fangs")
    end
    if ply:HasWeapon("weapon_zom_claws") then
        ply:StripWeapon("weapon_zom_claws")
    end
    if ply:HasWeapon("weapon_kil_knife") then
        ply:StripWeapon("weapon_kil_knife")
    end
    ply:Give("weapon_zm_improvised")

    SendFullStateUpdate()
end

concommand.Add("ttt_force_glitch", force_glitch, nil, nil, FCVAR_CHEAT)

local function force_jester(ply)
    ply:SetRoleAndBroadcast(ROLE_JESTER)
    ply:SetMaxHealth(100)
    ply:SetHealth(100)
    if ply:HasWeapon("weapon_hyp_brainwash") then
        ply:StripWeapon("weapon_hyp_brainwash")
    end
    if ply:HasWeapon("weapon_vam_fangs") then
        ply:StripWeapon("weapon_vam_fangs")
    end
    if ply:HasWeapon("weapon_zom_claws") then
        ply:StripWeapon("weapon_zom_claws")
    end
    if ply:HasWeapon("weapon_kil_knife") then
        ply:StripWeapon("weapon_kil_knife")
    end
    ply:Give("weapon_zm_improvised")

    SendFullStateUpdate()
end

concommand.Add("ttt_force_jester", force_jester, nil, nil, FCVAR_CHEAT)

local function force_phantom(ply)
    ply:SetRoleAndBroadcast(ROLE_PHANTOM)
    ply:SetMaxHealth(100)
    ply:SetHealth(100)
    if ply:HasWeapon("weapon_hyp_brainwash") then
        ply:StripWeapon("weapon_hyp_brainwash")
    end
    if ply:HasWeapon("weapon_vam_fangs") then
        ply:StripWeapon("weapon_vam_fangs")
    end
    if ply:HasWeapon("weapon_zom_claws") then
        ply:StripWeapon("weapon_zom_claws")
    end
    if ply:HasWeapon("weapon_kil_knife") then
        ply:StripWeapon("weapon_kil_knife")
    end
    ply:Give("weapon_zm_improvised")

    SendFullStateUpdate()
end

concommand.Add("ttt_force_phantom", force_phantom, nil, nil, FCVAR_CHEAT)

local function force_zombie(ply)
    ply:SetRoleAndBroadcast(ROLE_ZOMBIE)
    ply:SetMaxHealth(100)
    ply:SetHealth(100)
    ply:AddCredits(GetConVarNumber("ttt_zom_credits_starting"))
    if ply:HasWeapon("weapon_hyp_brainwash") then
        ply:StripWeapon("weapon_hyp_brainwash")
    end
    if ply:HasWeapon("weapon_vam_fangs") then
        ply:StripWeapon("weapon_vam_fangs")
    end
    if ply:HasWeapon("weapon_kil_knife") then
        ply:StripWeapon("weapon_kil_knife")
    end
    ply:Give("weapon_zm_improvised")
    ply:Give("weapon_zom_claws")

    SendFullStateUpdate()
end

concommand.Add("ttt_force_zombie", force_zombie, nil, nil, FCVAR_CHEAT)

local function force_vampire(ply)
    ply:SetRoleAndBroadcast(ROLE_VAMPIRE)
    ply:SetMaxHealth(100)
    ply:SetHealth(100)
    ply:AddCredits(GetConVarNumber("ttt_vam_credits_starting"))
    if ply:HasWeapon("weapon_hyp_brainwash") then
        ply:StripWeapon("weapon_hyp_brainwash")
    end
    if ply:HasWeapon("weapon_zom_claws") then
        ply:StripWeapon("weapon_zom_claws")
    end
    if ply:HasWeapon("weapon_kil_knife") then
        ply:StripWeapon("weapon_kil_knife")
    end
    ply:Give("weapon_zm_improvised")
    ply:Give("weapon_vam_fangs")

    SendFullStateUpdate()
end

concommand.Add("ttt_force_vampire", force_vampire, nil, nil, FCVAR_CHEAT)

local function force_swapper(ply)
    ply:SetRoleAndBroadcast(ROLE_SWAPPER)
    ply:SetMaxHealth(100)
    ply:SetHealth(100)
    if ply:HasWeapon("weapon_hyp_brainwash") then
        ply:StripWeapon("weapon_hyp_brainwash")
    end
    if ply:HasWeapon("weapon_vam_fangs") then
        ply:StripWeapon("weapon_vam_fangs")
    end
    if ply:HasWeapon("weapon_zom_claws") then
        ply:StripWeapon("weapon_zom_claws")
    end
    if ply:HasWeapon("weapon_kil_knife") then
        ply:StripWeapon("weapon_kil_knife")
    end
    ply:Give("weapon_zm_improvised")

    SendFullStateUpdate()
end

concommand.Add("ttt_force_swapper", force_swapper, nil, nil, FCVAR_CHEAT)

local function force_assassin(ply)
    ply:SetRoleAndBroadcast(ROLE_ASSASSIN)
    ply:SetMaxHealth(100)
    ply:SetHealth(100)
    ply:AddCredits(GetConVarNumber("ttt_asn_credits_starting"))
    if ply:HasWeapon("weapon_hyp_brainwash") then
        ply:StripWeapon("weapon_hyp_brainwash")
    end
    if ply:HasWeapon("weapon_vam_fangs") then
        ply:StripWeapon("weapon_vam_fangs")
    end
    if ply:HasWeapon("weapon_zom_claws") then
        ply:StripWeapon("weapon_zom_claws")
    end
    if ply:HasWeapon("weapon_kil_knife") then
        ply:StripWeapon("weapon_kil_knife")
    end
    ply:Give("weapon_zm_improvised")

    SendFullStateUpdate()
end

concommand.Add("ttt_force_assassin", force_assassin, nil, nil, FCVAR_CHEAT)

local function force_killer(ply)
    ply:SetRoleAndBroadcast(ROLE_KILLER)
    ply:SetMaxHealth(GetConVar("ttt_killer_max_health"):GetInt())
    ply:SetHealth(GetConVar("ttt_killer_max_health"):GetInt())
    if ply:HasWeapon("weapon_hyp_brainwash") then
        ply:StripWeapon("weapon_hyp_brainwash")
    end
    if ply:HasWeapon("weapon_vam_fangs") then
        ply:StripWeapon("weapon_vam_fangs")
    end
    if ply:HasWeapon("weapon_zom_claws") then
        ply:StripWeapon("weapon_zom_claws")
    end
    if ply:HasWeapon("weapon_zm_improvised") then
        ply:StripWeapon("weapon_zm_improvised")
    end
    if GetConVar("ttt_killer_knife_enabled"):GetBool() then
        ply:Give("weapon_kil_knife")
    else
        ply:Give("weapon_zm_improvised")
    end

    SendFullStateUpdate()
end

concommand.Add("ttt_force_killer", force_killer, nil, nil, FCVAR_CHEAT)

local function force_spectate(ply, cmd, arg)
    if IsValid(ply) then
        if #arg == 1 and tonumber(arg[1]) == 0 then
            ply:SetForceSpec(false)
        else
            if not ply:IsSpec() then
                ply:Kill()
            end

            GAMEMODE:PlayerSpawnAsSpectator(ply)
            ply:SetTeam(TEAM_SPEC)
            ply:SetForceSpec(true)
            ply:Spawn()

            ply:SetRagdollSpec(false) -- dying will enable this, we don't want it here
        end
    end
end

concommand.Add("ttt_spectate", force_spectate)
net.Receive("TTT_Spectate", function(l, pl)
    force_spectate(pl, nil, { net.ReadBool() and 1 or 0 })
end)

