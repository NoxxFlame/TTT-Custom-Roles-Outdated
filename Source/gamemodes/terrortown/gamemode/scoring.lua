-- Customized scoring

local math = math
local string = string
local table = table
local pairs = pairs

SCORE = SCORE or {}
SCORE.Events = SCORE.Events or {}

-- One might wonder why all the key names in the event tables are so annoyingly
-- short. Well, the serialisation module in gmod (glon) does not do any
-- compression. At all. This means the difference between all events having a
-- "time_added" key versus a "t" key is very significant for the amount of data
-- we need to send. It's a pain, but I'm not going to code my own compression,
-- so doing it manually is the only way.

-- One decent way to reduce data sent turned out to be rounding the time floats.
-- We don't actually need to know about 10000ths of seconds after all.

function SCORE:AddEvent(entry, t_override)
	entry["t"] = math.Round(t_override or CurTime(), 2)
	table.insert(self.Events, entry)
end

local function CopyDmg(dmg)

	local wep = util.WeaponFromDamage(dmg)

	-- t = type, a = amount, g = gun, h = headshot
	local d = {}

	-- util.TableToJSON doesn't handle large integers properly
	d.t = tostring(dmg:GetDamageType())
	d.a = dmg:GetDamage()
	d.h = false

	if wep then
		local id = WepToEnum(wep)
		if id then
			d.g = id
		else
			-- we can convert each standard TTT weapon name to a preset ID, but
			-- that's not workable with custom SWEPs from people, so we'll just
			-- have to pay the byte tax there
			d.g = wep:GetClass()
		end
	else
		local infl = dmg:GetInflictor()
		if IsValid(infl) and infl.ScoreName then
			d.n = infl.ScoreName
		end
	end

	return d
end

function SCORE:HandleKill(victim, attacker, dmginfo)
	if not (IsValid(victim) and victim:IsPlayer()) then return end

	local e = {
		id = EVENT_KILL,
		att = { ni = "", sid = -1, uid = -1, tr = false, inno = false, mon = false, jes = false, kil = false },
		vic = { ni = victim:Nick(), sid = victim:SteamID(), uid = victim:UniqueID(), tr = false, inno = false, mon = false, jes = false, kil = false },
        dmg = CopyDmg(dmginfo),
        tk = false
	};

	e.dmg.h = victim.was_headshot

    e.vic.role = victim:GetRole()
    e.vic.tr = victim:GetRole() == ROLE_TRAITOR or victim:GetRole() == ROLE_HYPNOTIST or victim:GetRole() == ROLE_ASSASSIN
    e.vic.inno = victim:GetRole() == ROLE_DETECTIVE or victim:GetRole() == ROLE_INNOCENT or victim:GetRole() == ROLE_MERCENARY or victim:GetRole() == ROLE_GLITCH or victim:GetRole() == ROLE_PHANTOM
    e.vic.mon = victim:GetRole() == ROLE_ZOMBIE or victim:GetRole() == ROLE_VAMPIRE
    e.vic.jes = victim:GetRole() == ROLE_JESTER or victim:GetRole() == ROLE_SWAPPER
    e.vic.kil = victim:GetRole() == ROLE_KILLER

	if IsValid(attacker) and attacker:IsPlayer() then
		e.att.ni = attacker:Nick()
		e.att.sid = attacker:SteamID()
        e.att.uid = attacker:UniqueID()
        e.att.role = attacker:GetRole()
        e.att.tr = attacker:GetRole() == ROLE_TRAITOR or attacker:GetRole() == ROLE_HYPNOTIST or attacker:GetRole() == ROLE_ASSASSIN
        e.att.inno = attacker:GetRole() == ROLE_DETECTIVE or attacker:GetRole() == ROLE_INNOCENT or attacker:GetRole() == ROLE_MERCENARY or attacker:GetRole() == ROLE_GLITCH or attacker:GetRole() == ROLE_PHANTOM
        e.att.mon = attacker:GetRole() == ROLE_ZOMBIE or attacker:GetRole() == ROLE_VAMPIRE
        e.att.jes = attacker:GetRole() == ROLE_JESTER or attacker:GetRole() == ROLE_SWAPPER
        e.att.kil = attacker:GetRole() == ROLE_KILLER
        e.tk = (e.att.tr and e.vic.tr) or (e.att.inno and e.vic.inno) or (e.att.mon and e.vic.mon) or (e.att.jes and e.vic.jes) or (e.att.kil and e.vic.kil)

		-- If a traitor gets himself killed by another traitor's C4, it's his own
		-- damn fault for ignoring the indicator.
		if dmginfo:IsExplosionDamage() and attacker:GetTraitor() and victim:GetTraitor() then
			local infl = dmginfo:GetInflictor()
			if IsValid(infl) and infl:GetClass() == "ttt_c4" then
				e.att = table.Copy(e.vic)
			end
		end
	end

	self:AddEvent(e)
end

function SCORE:HandleSpawn(ply)
	if ply:Team() == TEAM_TERROR then
		self:AddEvent({ id = EVENT_SPAWN, ni = ply:Nick(), sid = ply:SteamID(), uid = ply:UniqueID() })
	end
end

function SCORE:HandleSelection()
	local innocents = {}
	local traitors = {}
	local detectives = {}
	local mercenaries = {}
	local hypnotists = {}
	local glitches = {}
	local jesters = {}
	local phantoms = {}
	local zombies = {}
	local vampires = {}
	local swappers = {}
	local assassins = {}
	local killers = {}
	for k, ply in pairs(player.GetAll()) do
		if ply:GetTraitor() then
			table.insert(traitors, ply:UniqueID())
		elseif ply:GetDetective() then
			table.insert(detectives, ply:UniqueID())
		elseif ply:GetMercenary() then
			table.insert(mercenaries, ply:UniqueID())
		elseif ply:GetHypnotist() then
			table.insert(hypnotists, ply:UniqueID())
		elseif ply:GetGlitch() then
			table.insert(glitches, ply:UniqueID())
		elseif ply:GetJester() then
			table.insert(jesters, ply:UniqueID())
		elseif ply:GetPhantom() then
			table.insert(phantoms, ply:UniqueID())
		elseif ply:GetZombie() then
			table.insert(zombies, ply:UniqueID())
		elseif ply:GetVampire() then
			table.insert(vampires, ply:UniqueID())
		elseif ply:GetSwapper() then
			table.insert(swappers, ply:UniqueID())
		elseif ply:GetAssassin() then
			table.insert(assassins, ply:UniqueID())
		elseif ply:GetKiller() then
			table.insert(killers, ply:UniqueID())
		elseif ply:GetInnocent() then
			table.insert(innocents, ply:UniqueID())
		end
	end

	self:AddEvent({ id = EVENT_SELECTED, innocent_ids = innocents, traitor_ids = traitors, detective_ids = detectives, hypnotist_ids = hypnotists, mercenary_ids = mercenaries, jester_ids = jesters, phantom_ids = phantoms, glitch_ids = glitches, zombie_ids = zombies, vampire_ids = vampires, swapper_ids = swappers, assassin_ids = assassins, killer_ids = killers })
end

function SCORE:HandleBodyFound(finder, found)
	self:AddEvent({ id = EVENT_BODYFOUND, ni = finder:Nick(), sid = finder:SteamID(), uid = finder:UniqueID(), b = found:Nick() })
end

function SCORE:HandleC4Explosion(planter, arm_time, exp_time)
    local nick = "Someone"
    local sid = -1
    local uid = -1
	if IsValid(planter) and planter:IsPlayer() then
        nick = planter:Nick()
        sid = planter:SteamID()
        uid = planter:UniqueID()
	end

	self:AddEvent({ id = EVENT_C4PLANT, ni = nick, sid = sid, uid = uid }, arm_time)
	self:AddEvent({ id = EVENT_C4EXPLODE, ni = nick, sid = sid, uid = uid }, exp_time)
end

function SCORE:HandleC4Disarm(disarmer, owner, success)
	if disarmer == owner then return end
	if not IsValid(disarmer) then return end

	local ev = {
        id = EVENT_C4DISARM,
		ni = disarmer:Nick(),
		sid = disarmer:SteamID(),
		uid = disarmer:UniqueID(),
		s = success
	};

	if IsValid(owner) then
		ev.own = owner:Nick()
	end

	self:AddEvent(ev)
end

function SCORE:HandleCreditFound(finder, found_nick, credits)
	self:AddEvent({ id = EVENT_CREDITFOUND, ni = finder:Nick(), sid = finder:SteamID(), uid = finder:UniqueID(), b = found_nick, cr = credits })
end

function SCORE:ApplyEventLogScores(wintype)
	local scores = {}
	local innocents = {}
	local traitors = {}
	local detectives = {}
	local mercenaries = {}
	local hypnotists = {}
	local glitches = {}
	local jesters = {}
	local phantoms = {}
	local zombies = {}
	local vampires = {}
	local swappers = {}
	local assassins = {}
	local killers = {}
	for _, ply in pairs(player.GetAll()) do
		scores[ply:UniqueID()] = {}

		if ply:GetTraitor() then
			table.insert(traitors, ply:UniqueID())
		elseif ply:GetDetective() then
			table.insert(detectives, ply:UniqueID())
		elseif ply:GetMercenary() then
			table.insert(mercenaries, ply:UniqueID())
		elseif ply:GetHypnotist() then
			table.insert(hypnotists, ply:UniqueID())
		elseif ply:GetGlitch() then
			table.insert(glitches, ply:UniqueID())
		elseif ply:GetJester() then
			table.insert(jesters, ply:UniqueID())
		elseif ply:GetPhantom() then
			table.insert(phantoms, ply:UniqueID())
		elseif ply:GetZombie() then
			table.insert(zombies, ply:UniqueID())
		elseif ply:GetVampire() then
			table.insert(vampires, ply:UniqueID())
		elseif ply:GetSwapper() then
			table.insert(swappers, ply:UniqueID())
		elseif ply:GetAssassin() then
			table.insert(assassins, ply:UniqueID())
		elseif ply:GetKiller() then
			table.insert(killers, ply:UniqueID())
		elseif ply:GetInnocent() then
			table.insert(innocents, ply:UniqueID())
		end
	end

	-- individual scores, and count those left alive
	local scored_log = ScoreEventLog(self.Events, scores, innocents, traitors, detectives, hypnotists, mercenaries, jesters, phantoms, glitches, zombies, vampires, swappers, assassins, killers)
	local ply = nil
    for uid, s in pairs(scored_log) do
		ply = Player(uid)
		if IsValid(ply) and ply:ShouldScore() then
			ply:AddFrags(KillsToPoints(s, ply:GetTraitor()))
		end
	end

	-- team scores
	local bonus = ScoreTeamBonus(scored_log, wintype)

	for uid, _ in pairs(scored_log) do
		ply = Player(uid)
        if IsValid(ply) and ply:ShouldScore() then
            local points_team = bonus.innos
            if ply:GetTraitor() or ply:GetAssassin() or ply:GetHypnotist() then
                points_team = bonus.traitors
            elseif ply:GetVampire() or ply:GetZombie() then
                points_team = bonus.monsters
            elseif ply:GetJester() or ply:GetSwapper() then
                points_team = bonus.jesters
            elseif ply:GetKiller() then
                points_team = bonus.killers
            end

			ply:AddFrags(points_team)
		end
	end

	-- count deaths
	for _, e in pairs(self.Events) do
		if e.id == EVENT_KILL then
            local victim = Player(e.vic.uid)
			if IsValid(victim) and victim:ShouldScore() then
				victim:AddDeaths(1)
			end
		end
	end
end

function SCORE:RoundStateChange(newstate)
	self:AddEvent({ id = EVENT_GAME, state = newstate })
end

function SCORE:RoundComplete(wintype)
	self:AddEvent({ id = EVENT_FINISH, win = wintype })
end

function SCORE:Reset()
	self.Events = {}
end

local function SortEvents(events)
	-- sort events on time
	table.sort(events, function(a, b)
		if not b or not a then return false end
		return a.t and b.t and a.t < b.t
	end)
	return events
end

local function EncodeForStream(events)
	events = SortEvents(events)

	-- may want to filter out data later
	-- just serialize for now

	local result = util.TableToJSON(events)
	if not result then
		ErrorNoHalt("Round report event encoding failed!\n")
		return false
	else
		return result
	end
end

function SCORE:StreamToClients()
	local s = EncodeForStream(self.Events)
	if not s then
		return -- error occurred
	end

	-- divide into happy lil bits.
	-- this was necessary with user messages, now it's
	-- a just-in-case thing if a round somehow manages to be > 64K
	local cut = {}
	local max = 65500
	while #s ~= 0 do
		local bit = string.sub(s, 1, max - 1)
		table.insert(cut, bit)

		s = string.sub(s, max, -1)
	end

	local parts = #cut
	for k, bit in pairs(cut) do
		net.Start("TTT_ReportStream")
		net.WriteBit((k ~= parts)) -- continuation bit, 1 if there's more coming
		net.WriteString(bit)
		net.Broadcast()
	end
end
