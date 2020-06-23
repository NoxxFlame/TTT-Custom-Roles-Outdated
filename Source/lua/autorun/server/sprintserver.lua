-- Please ask me if you want to use parts of this code!
-- Add Network
util.AddNetworkString("SprintSpeedset")
util.AddNetworkString("SprintGetConVars")
-- Set ConVars
local Enabled = CreateConVar("ttt_sprint_enabled", "1", FCVAR_SERVER_CAN_EXECUTE, "Whether sprint is enabled")
local Multiplier = CreateConVar("ttt_sprint_bonus_rel", "0.4", FCVAR_SERVER_CAN_EXECUTE, "The relative speed bonus given while sprinting. (0.1-2) Def: 0.4")
local Crosshair = CreateConVar("ttt_sprint_big_crosshair", "1", FCVAR_SERVER_CAN_EXECUTE, "Makes the crosshair bigger while sprinting. Def: 1")
local RegenerateI = CreateConVar("ttt_sprint_regenerate_innocent", "0.08", FCVAR_SERVER_CAN_EXECUTE, "Sets stamina regeneration for innocents. (0.01-2) Def: 0.08")
local RegenerateT = CreateConVar("ttt_sprint_regenerate_traitor", "0.12", FCVAR_SERVER_CAN_EXECUTE, "Sets stamina regeneration speed for traitors. (0.01-2) Def: 0.12")
local Consumption = CreateConVar("ttt_sprint_consume", "0.2", FCVAR_SERVER_CAN_EXECUTE, "Sets stamina consumption speed. (0.1-5) Def: 0.2")
-- Set the Speed
net.Receive("SprintSpeedset", function(len, ply)
    local mul = net.ReadFloat()
    if mul ~= 0 then
        ply.mult = 1 + mul
    else
        ply.mult = nil
    end
end)
-- Send Convats if requested
net.Receive("SprintGetConVars", function(len, ply)
    local Table = {
        [1] = Multiplier:GetFloat();
        [2] = Crosshair:GetBool();
        [3] = RegenerateI:GetFloat();
        [4] = RegenerateT:GetFloat();
        [5] = Consumption:GetFloat();
        [6] = Enabled:GetBool();
    }
    net.Start("SprintGetConVars")
    net.WriteTable(Table)
    net.Send(ply)
end)

-- Set Sprint Speed
hook.Add("TTTPlayerSpeedModifier", "TTTSprint4TTTPlayerSpeed", function(ply, _, _)
    local mult = 1
    if IsValid(ply) then
        mult = tonumber(ply:GetPData("RmdtSpeedModifier", 1))

        if Enabled:GetBool() and ply.mult then
            mult = mult * ply.mult
        end
    end

    local wep = ply:GetActiveWeapon()
    if wep and IsValid(wep) and wep:GetClass() == "genji_melee" then
        return 1.4 * mult
    elseif wep and IsValid(wep) and wep:GetClass() == "weapon_ttt_randomatknife" then
        local knifemult = 1.2
        if ConVarExists("randomat_murder_knifespeed") then
            knifemult = GetConVar("randomat_murder_knifespeed"):GetFloat()
        end
        return knifemult * mult
    elseif wep and IsValid(wep) and wep:GetClass() == "weapon_ttt_homebat" then
        return 1.25 * mult
    elseif wep and IsValid(wep) and wep:GetClass() == "weapon_vam_fangs" and wep:Clip1() < 15 then
        return 3 * mult
    elseif wep and IsValid(wep) and wep:GetClass() == "weapon_zom_claws" then
        if ply:HasEquipmentItem(EQUIP_SPEED) then
            return 1.5 * mult
        else
            return 1.35 * mult
        end
    else
        return mult
    end
end)