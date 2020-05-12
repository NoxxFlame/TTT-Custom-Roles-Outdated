-- Server and client both need this for scoring event logs

function ScoreInit()
    return {
        deaths = 0,
        suicides = 0,
        innos = 0,
        traitors = 0,
        monsters = 0,
        jesters = 0,
        killers = 0,
        was_traitor = false,
        was_detective = false,
        was_hypnotist = false,
        was_mercenary = false,
        was_jester = false,
        was_phantom = false,
        was_glitch = false,
        was_zombie = false,
        was_vampire = false,
        was_swapper = false,
        was_assassin = false,
        was_killer = false,
        bonus = 0 -- non-kill points to add
    };
end

local function UpdateScoreRoles(scores, id, eventinfo)
    if scores[id] == nil then
        scores[id] = ScoreInit()
        scores[id].was_traitor = eventinfo.role == ROLE_TRAITOR
        scores[id].was_detective = eventinfo.role == ROLE_DETECTIVE
        scores[id].was_hypnotist = eventinfo.role == ROLE_HYPNOTIST
        scores[id].was_mercenary = eventinfo.role == ROLE_MERCENARY
        scores[id].was_jester = eventinfo.role == ROLE_JESTER
        scores[id].was_phantom = eventinfo.role == ROLE_PHANTOM
        scores[id].was_glitch = eventinfo.role == ROLE_GLITCH
        scores[id].was_zombie = eventinfo.role == ROLE_ZOMBIE
        scores[id].was_vampire = eventinfo.role == ROLE_VAMPIRE
        scores[id].was_swapper = eventinfo.role == ROLE_SWAPPER
        scores[id].was_assassin = eventinfo.role == ROLE_ASSASSIN
        scores[id].was_killer = eventinfo.role == ROLE_KILLER
    end
end

function ScoreEvent(e, scores)
    if e.id == EVENT_KILL then
        local aid = e.att.uid
        local vid = e.vic.uid

        -- make sure a score table exists for this person
        -- he might have disconnected by now
        UpdateScoreRoles(scores, vid, e.vic)
        UpdateScoreRoles(scores, aid, e.att)

        scores[vid].deaths = scores[vid].deaths + 1

        if aid == vid then
            scores[vid].suicides = scores[vid].suicides + 1
        elseif aid ~= -1 then
            if e.vic.tr then
                scores[aid].traitors = scores[aid].traitors + 1
            elseif e.vic.mon then
                scores[aid].monsters = scores[aid].monsters + 1
            elseif e.vic.jes then
                scores[aid].jesters = scores[aid].jesters + 1
            elseif e.vic.kil then
                scores[aid].killers = scores[aid].killers + 1
            else
                scores[aid].innos = scores[aid].innos + 1
            end
        end
    elseif e.id == EVENT_BODYFOUND then
        local uid = e.uid
        -- Unknown players, traitors, and monsters don't get points for finding bodies... because they probably created them
        if scores[uid] == nil or (scores[uid].was_traitor or scores[uid].was_assassin or scores[uid].was_hypnotist or scores[uid].was_vampire or scores[uid].was_zombie or scores[uid].was_killer) then return end

        local find_bonus = scores[uid].was_detective and 3 or 1
        scores[uid].bonus = scores[uid].bonus + find_bonus
    end
end

-- events should be event log as generated by scoring.lua
-- scores should be table with UserIDs as keys
-- The method of finding these IDs differs between server and client
function ScoreEventLog(events, scores, traitors, detectives, hypnotists, mercenaries, jesters, phantoms, glitches, zombies, vampires, swappers, assassins, killers)
    for id, _ in pairs(scores) do
        scores[id] = ScoreInit()

        scores[id].was_traitor = table.HasValue(traitors, id)
        scores[id].was_detective = table.HasValue(detectives, id)
        scores[id].was_hypnotist = table.HasValue(hypnotists, id)
        scores[id].was_mercenary = table.HasValue(mercenaries, id)
        scores[id].was_jester = table.HasValue(jesters, id)
        scores[id].was_phantom = table.HasValue(phantoms, id)
        scores[id].was_glitch = table.HasValue(glitches, id)
        scores[id].was_zombie = table.HasValue(zombies, id)
        scores[id].was_vampire = table.HasValue(vampires, id)
        scores[id].was_swapper = table.HasValue(swappers, id)
        scores[id].was_assassin = table.HasValue(assassins, id)
        scores[id].was_killer = table.HasValue(killers, id)
    end

    for _, e in pairs(events) do
        ScoreEvent(e, scores)
    end

    return scores
end

function ScoreTeamBonus(scores, wintype)
    local alive = { traitors = 0, innos = 0, monsters = 0, jesters = 0, killers = 0 }
    local dead = { traitors = 0, innos = 0, monsters = 0, jesters = 0, killers = 0 }

    for _, sc in pairs(scores) do
        local state = (sc.deaths == 0) and alive or dead
        if sc.was_traitor or sc.was_hypnotist or sc.was_assassin then
            state.traitors = state.traitors + 1
        elseif sc.was_zombie or sc.was_vampire then
            state.monsters = state.monsters + 1
        elseif sc.was_jester or sc.was_swapper then
            state.jesters = state.jesters + 1
        elseif sc.was_killer then
            state.killers = state.killers + 1
        else
            state.innos = state.innos + 1
        end
    end

    local bonus = {}
    bonus.traitors = (alive.traitors * 1) + math.ceil(dead.innos * 0.5)
    bonus.monsters = (alive.monsters * 1) + math.ceil(dead.innos * 0.5)
    bonus.killers = (alive.killers * 1) + math.ceil(dead.innos * 0.5)
    bonus.jesters = dead.jesters * 1
    bonus.innos = alive.innos * 1

    -- running down the clock must never be beneficial for traitors monsters or killers
    if wintype == WIN_TIMELIMIT then
        bonus.traitors = math.floor(alive.innos * -0.5) + math.ceil(dead.innos * 0.5)
        bonus.monsters = math.floor(alive.innos * -0.5) + math.ceil(dead.innos * 0.5)
        bonus.killers = math.floor(alive.innos * -0.5) + math.ceil(dead.innos * 0.5)
    end

    return bonus
end

-- Scores were initially calculated as points immediately, but not anymore, so
-- we can convert them using this fn
function KillsToPoints(score, was_traitor, was_monster, was_killer, was_innocent)
    return ((score.suicides * -1)
            + score.bonus
            + (score.traitors * (was_traitor and -16 or 5))
            + (score.monsters * (was_monster and -16 or 5))
            + (score.jesters * -10)
            + (score.killers * (was_killer and -16 or 5))
            + (score.innos * (was_innocent and -8 or 1))
            + (score.deaths == 0 and 1 or 0)) --effectively 2 due to team bonus
    --for your own survival
end

-- Weapon AMMO_ enum stuff, used only in score.lua/cl_score.lua these days

-- Not actually ammo identifiers anymore, but still weapon identifiers. Used
-- only in round report (score.lua) to save bandwidth because we can't use
-- pooled strings there. Custom SWEPs are sent as classname string and don't
-- need to bother with these.
AMMO_DEAGLE = 2
AMMO_PISTOL = 3
AMMO_MAC10 = 4
AMMO_RIFLE = 5
AMMO_SHOTGUN = 7
-- Following are custom, intentionally out of ammo enum range
AMMO_CROWBAR = 50
AMMO_SIPISTOL = 51
AMMO_C4 = 52
AMMO_FLARE = 53
AMMO_KNIFE = 54
AMMO_M249 = 55
AMMO_M16 = 56
AMMO_DISCOMB = 57
AMMO_POLTER = 58
AMMO_TELEPORT = 59
AMMO_RADIO = 60
AMMO_DEFUSER = 61
AMMO_WTESTER = 62
AMMO_BEACON = 63
AMMO_HEALTHSTATION = 64
AMMO_MOLOTOV = 65
AMMO_SMOKE = 66
AMMO_BINOCULARS = 67
AMMO_PUSH = 68
AMMO_STUN = 69
AMMO_CSE = 70
AMMO_DECOY = 71
AMMO_GLOCK = 72

local WeaponNames = nil
function GetWeaponClassNames()
    if not WeaponNames then
        local tbl = {}
        for k, v in pairs(weapons.GetList()) do
            if v and v.WeaponID then
                tbl[v.WeaponID] = WEPS.GetClass(v)
            end
        end

        for k, v in pairs(scripted_ents.GetList()) do
            local id = v and (v.WeaponID or (v.t and v.t.WeaponID))
            if id then
                tbl[id] = WEPS.GetClass(v)
            end
        end

        WeaponNames = tbl
    end

    return WeaponNames
end

-- reverse lookup from enum to SWEP table
function EnumToSWEP(ammo)
    local e2w = GetWeaponClassNames() or {}
    if e2w[ammo] then
        return util.WeaponForClass(e2w[ammo])
    else
        return nil
    end
end

function EnumToSWEPKey(ammo, key)
    local swep = EnumToSWEP(ammo)
    return swep and swep[key]
end

-- something the client can display
-- This used to be done with a big table of AMMO_ ids to names, now we just use
-- the weapon PrintNames. This means it is no longer usable from the server (not
-- used there anyway), and means capitalization is slightly less pretty.
function EnumToWep(ammo)
    return EnumToSWEPKey(ammo, "PrintName")
end

-- something cheap to send over the network
function WepToEnum(wep)
    if not IsValid(wep) then return end

    return wep.WeaponID
end
