-- Please ask me if you want to use parts of this code!
-- Add Network
util.AddNetworkString("SprintSpeedset")
util.AddNetworkString("SprintGetConVars")

-- Set ConVars
local enabled = CreateConVar("ttt_sprint_enabled", "1", FCVAR_SERVER_CAN_EXECUTE, "Whether sprint is enabled")
local multiplier = CreateConVar("ttt_sprint_bonus_rel", "0.4", FCVAR_SERVER_CAN_EXECUTE, "The relative speed bonus given while sprinting. (0.1-2) Def: 0.4")
local crosshair = CreateConVar("ttt_sprint_big_crosshair", "1", FCVAR_SERVER_CAN_EXECUTE, "Makes the crosshair bigger while sprinting. Def: 1")
local regenerateI = CreateConVar("ttt_sprint_regenerate_innocent", "0.08", FCVAR_SERVER_CAN_EXECUTE, "Sets stamina regeneration for innocents. (0.01-2) Def: 0.08")
local regenerateT = CreateConVar("ttt_sprint_regenerate_traitor", "0.12", FCVAR_SERVER_CAN_EXECUTE, "Sets stamina regeneration speed for traitors. (0.01-2) Def: 0.12")
local consumption = CreateConVar("ttt_sprint_consume", "0.2", FCVAR_SERVER_CAN_EXECUTE, "Sets stamina consumption speed. (0.1-5) Def: 0.2")

-- Set the Speed
net.Receive("SprintSpeedset", function(len, ply)
    local mul = net.ReadFloat()
    if mul ~= 0 then
        ply.mult = 1 + mul
    else
        ply.mult = nil
    end
end)

-- Send Convars if requested
net.Receive("SprintGetConVars", function(len, ply)
    local table = {
        [1] = multiplier:GetFloat();
        [2] = crosshair:GetBool();
        [3] = regenerateI:GetFloat();
        [4] = regenerateT:GetFloat();
        [5] = consumption:GetFloat();
        [6] = enabled:GetBool();
    }
    net.Start("SprintGetConVars")
    net.WriteTable(table)
    net.Send(ply)
end)

-- Set Sprint Speed
hook.Add("TTTPlayerSpeedModifier", "TTTSprint4TTTPlayerSpeed", function(ply, _, _)
    return GetSprintMultiplier(ply, enabled:GetBool())
end)
