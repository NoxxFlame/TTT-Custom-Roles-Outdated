
-- Award/highlight generator functions take the events and the scores as
-- produced by SCORING/CLSCORING and return a table if successful, or nil if
-- not and another one should be tried.

-- some globals we'll use a lot
local table = table
local pairs = pairs

local is_dmg = function(dmg_t, bit)
                  -- deal with large-number workaround for TableToJSON by
                  -- parsing back to number here
                  return util.BitSet(tonumber(dmg_t), bit)
               end

-- so much text here I'm using shorter names than usual
local T = LANG.GetTranslation
local PT = LANG.GetParamTranslation

local function GetRoleName(s)
    return s.role == ROLE_TRAITOR and T("traitor") or (s.role == ROLE_DETECTIVE and T("detective") or (s.role == ROLE_HYPNOTIST and T("hypnotist") or (s.role == ROLE_MERCENARY and T("mercenary") or (s.role == ROLE_JESTER and T("jester") or (s.role == ROLE_PHANTOM and T("phantom") or (s.role == ROLE_GLITCH and T("glitch") or (s.role == ROLE_ZOMBIE and T("zombie") or (s.role == ROLE_VAMPIRE and T("vampire") or (s.role == ROLE_SWAPPER and T("swapper") or (s.role == ROLE_ASSASSIN and T("assassin") or (s.role == ROLE_KILLER and T("killer") or T("innocent"))))))))))))
end

-- a common pattern
local function FindHighest(tbl)
   local m_num = 0
   local m_id = nil
   for id, num in pairs(tbl) do
      if num > m_num then
         m_id = id
         m_num = num
      end
   end

   return m_id, m_num
end

local function FirstSuicide(events, scores, players, innocents, traitors, detectives, mercenaries, hypnotists, glitches, jesters, phantoms, zombies, vampires, swappers, assassins, killers)
   local fs = nil
   local fnum = 0
   for k, e in pairs(events) do
      if e.id == EVENT_KILL and e.att.sid == e.vic.sid then
         fnum = fnum + 1
         if fs == nil then
            fs = e
         end
      end
   end

   if fs then
      local award = {nick=fs.att.ni}
      if not award.nick then return nil end

      if fnum > 1 then
         award.title = T("aw_sui1_title")
         award.text =  T("aw_sui1_text")
      else
         award.title = T("aw_sui2_title")
         award.text = T("aw_sui2_text")
      end

      -- only high interest if many people died this way
      award.priority = fnum

      return award
   else
      return nil
   end
end

local function ExplosiveGrant(events, scores, players, innocents, traitors, detectives, mercenaries, hypnotists, glitches, jesters, phantoms, zombies, vampires, swappers, assassins, killers)
   local bombers = {}
   for k, e in pairs(events) do
      if e.id == EVENT_KILL and is_dmg(e.dmg.t, DMG_BLAST) then
         bombers[e.att.sid] = (bombers[e.att.sid] or 0) + 1
      end
   end

   local award = {title= T("aw_exp1_title")}

   if not table.IsEmpty(bombers) then
      for sid, num in pairs(bombers) do
         -- award goes to whoever reaches this first I guess
         if num > 2 then
            award.nick = players[sid]
            if not award.nick then return nil end -- if player disconnected or something

            award.text = PT("aw_exp1_text", {num = num})

            -- rare award, high interest
            award.priority = 10 + num

            return award
         end
      end
   end

   return nil
end

local function ExplodedSelf(events, scores, players, innocents, traitors, detectives, mercenaries, hypnotists, glitches, jesters, phantoms, zombies, vampires, swappers, assassins, killers)
   for k, e in pairs(events) do
      if e.id == EVENT_KILL and is_dmg(e.dmg.t, DMG_BLAST) and e.att.sid == e.vic.sid then
         return {title=T("aw_exp2_title"), text=T("aw_exp2_text"), nick=e.vic.ni, priority=math.random(1, 4)}
      end
   end

   return nil
end

local function FirstBlood(events, scores, players, innocents, traitors, detectives, mercenaries, hypnotists, glitches, jesters, phantoms, zombies, vampires, swappers, assassins, killers)
    for _, e in pairs(events) do
        if e.id == EVENT_KILL and e.att.sid ~= e.vic.sid and e.att.sid ~= -1 then
            local award = {nick=e.att.ni}
            if not award.nick or award.nick == "" then return nil end

            local attackerrole = GetRoleName(e.att)
            local victimrole = GetRoleName(e.vic)
            -- Non-Innocent killed Innocent
            if not e.att.inno and e.vic.inno then
                award.title = T("aw_fst1_title")
                award.text = PT("aw_fst1_text", {role=attackerrole})
            -- Non-Innocent TK
            elseif e.tk and not e.vic.inno then
                award.title = T("aw_fst2_title")
                award.text = PT("aw_fst2_text", {role=attackerrole})
            -- Innocent TK
            elseif e.tk and e.vic.inno then
                award.title = T("aw_fst3_title")
                award.text = T("aw_fst3_text")
            -- Innocent killed non-Innocent
            else
                award.title = T("aw_fst4_title")
                award.text = PT("aw_fst4_text", {role=victimrole})
            end

            -- more interesting if there were many players and therefore many kills
            award.priority = math.random(-3, math.Round(table.Count(players) / 4))

            return award
        end
    end
end

local function AllKills(events, scores, players, innocents, traitors, detectives, mercenaries, hypnotists, glitches, jesters, phantoms, zombies, vampires, swappers, assassins, killers)
    -- see if there is one killer responsible for all kills of either team

    local tr_killers = {}
    local in_killers = {}
    local mon_killers = {}
    for id, s in pairs(scores) do
        if s.innos > 0 then
            table.insert(in_killers, id)
        elseif s.traitors > 0 then
            table.insert(tr_killers, id)
        elseif s.monsters > 0 then
            table.insert(mon_killers, id)
        end
    end

    -- Someone killed all the traitors
    if #tr_killers == 1 then
        local id = tr_killers[1]
        -- Don't celebrate team killers
        if not table.HasValue(traitors, id) and not table.HasValue(hypnotists, id) and not table.HasValue(assassins, id) then
            local killer = players[id]
            if not killer then return nil end

            return {nick=killer, title=T("aw_all1_title"), text=T("aw_all1_text"), priority=math.random(0, table.Count(players))}
        end
    end

    -- Someone killed all the innocents
    if #in_killers == 1 then
        local id = in_killers[1]
        -- Don't celebrate team killers
        if not table.HasValue(innocents, id) and not table.HasValue(detectives, id) and not table.HasValue(mercenaries, id) and not table.HasValue(glitches, id) and not table.HasValue(phantoms, id) then
            local killer = players[id]
            if not killer then return nil end

            return {nick=killer, title=T("aw_all2_title"), text=T("aw_all2_text"), priority=math.random(0, table.Count(players))}
        end
    end

    -- Someone killed all the monsters
    if #mon_killers == 1 then
        local id = mon_killers[1]
        -- Don't celebrate team killers
        if not table.HasValue(zombies, id) and not table.HasValue(vampires, id) then
            local killer = players[id]
            if not killer then return nil end

            return {nick=killer, title=T("aw_all3_title"), text=T("aw_all3_text"), priority=math.random(0, table.Count(players))}
        end
    end

    return nil
end

local function NumKills_Traitor(events, scores, players, innocents, traitors, detectives, mercenaries, hypnotists, glitches, jesters, phantoms, zombies, vampires, swappers, assassins, killers)
    local trs = {}
    for id, s in pairs(scores) do
        if table.HasValue(traitors, id) then
            if s.innos > 0 or s.monsters > 0 or s.killers > 0 then
                table.insert(trs, id)
            end
        end
    end

    local choices = table.Count(trs)
    if choices > 0 then
        -- award a random killer
        local pick = math.random(1, choices)
        local sid = trs[pick]
        local nick = players[sid]
        if not nick then return nil end

        -- All non-traitor kills
        local kills = scores[sid].innos + scores[sid].monsters + scores[sid].killers
        if kills == 1 then
            return {title=T("aw_nkt1_title"), nick=nick, text=T("aw_nkt1_text"), priority=0}
        elseif kills == 2 then
            return {title=T("aw_nkt2_title"), nick=nick, text=T("aw_nkt2_text"), priority=1}
        elseif kills == 3 then
            return {title=T("aw_nkt3_title"), nick=nick, text=T("aw_nkt3_text"), priority=kills}
        elseif kills >= 4 and kills < 7 then
            return {title=T("aw_nkt4_title"), nick=nick, text=PT("aw_nkt4_text", {num = kills}), priority=kills + 2}
        elseif kills >= 7 then
            return {title=T("aw_nkt5_title"), nick=nick, text=T("aw_nkt5_text"), priority=kills + 5}
        end
    else
        return nil
    end
end

local function NumKills_Inno(events, scores, players, innocents, traitors, detectives, mercenaries, hypnotists, glitches, jesters, phantoms, zombies, vampires, swappers, assassins, killers)
    local ins = {}
    for id, s in pairs(scores) do
        if not table.HasValue(traitors, id) then
            if s.traitors > 0 or s.monsters > 0 or s.killers > 0 then
                table.insert(ins, id)
            end
        end
    end

    local choices = table.Count(ins)
    if not table.IsEmpty(ins) then
        -- award a random killer
        local pick = math.random(1, choices)
        local sid = ins[pick]
        local nick = players[sid]
        if not nick then return nil end

        -- All non-innocent kills
        local kills = scores[sid].traitors + scores[sid].monsters + scores[sid].killers
        if kills == 1 then
            return {title=T("aw_nki1_title"), nick=nick, text=T("aw_nki1_text"), priority = 0}
        elseif kills == 2 then
            return {title=T("aw_nki2_title"), nick=nick, text=T("aw_nki2_text"), priority = 1}
        elseif kills == 3 then
            return {title=T("aw_nki3_title"), nick=nick, text=T("aw_nki3_text"), priority= 5}
        elseif kills >= 4 then
            return {title=T("aw_nki4_title"), nick=nick, text=T("aw_nki4_text"), priority=kills + 10}
        end
    else
        return nil
    end
end

local function FallDeath(events, scores, players, innocents, traitors, detectives, mercenaries, hypnotists, glitches, jesters, phantoms, zombies, vampires, swappers, assassins, killers)
    for _, e in pairs(events) do
        if e.id == EVENT_KILL and is_dmg(e.dmg.t, DMG_FALL) then
            if e.att.ni ~= "" then
                return {title=T("aw_fal1_title"), nick=e.att.ni, text=T("aw_fal1_text"), priority=math.random(7, 15)}
            else
                return {title=T("aw_fal2_title"), nick=e.vic.ni, text=T("aw_fal2_text"), priority=math.random(1, 5)}
            end
        end
    end

    return nil
end

local function FallKill(events, scores, players, innocents, traitors, detectives, mercenaries, hypnotists, glitches, jesters, phantoms, zombies, vampires, swappers, assassins, killers)
    for _, e in pairs(events) do
        if e.id == EVENT_KILL and is_dmg(e.dmg.t, DMG_CRUSH) and is_dmg(e.dmg.t, DMG_PHYSGUN) then
            if e.att.ni ~= "" then
                return {title=T("aw_fal3_title"), nick=e.att.ni, text=T("aw_fal3_text"), priority=math.random(10, 15)}
            end
        end
    end
end

local function Headshots(events, scores, players, innocents, traitors, detectives, mercenaries, hypnotists, glitches, jesters, phantoms, zombies, vampires, swappers, assassins, killers)
    local hs = {}
    for _, e in pairs(events) do
        if e.id == EVENT_KILL and e.dmg.h and is_dmg(e.dmg.t, DMG_BULLET) then
            hs[e.att.sid] = (hs[e.att.sid] or 0) + 1
        end
    end

    if table.IsEmpty(hs) then return nil end

    -- find the one with the most shots
    local m_id, m_num = FindHighest(hs)

    if not m_id then return nil end

    local nick = players[m_id]
    if not nick then return nil end

    local award = {nick=nick, priority=m_num / 2}
    if m_num > 1 and m_num < 4 then
        award.title = T("aw_hed1_title")
        award.text = PT("aw_hed1_text", {num = m_num})
    elseif m_num >= 4 and m_num < 6 then
        award.title = T("aw_hed2_title")
        award.text = PT("aw_hed2_text", {num = m_num})
    elseif m_num >= 6 then
        award.title = T("aw_hed3_title")
        award.text = PT("aw_hed3_text", {num = m_num})
        award.priority = m_num + 5
    else
        return nil
    end

    return award
end

local function UsedAmmoMost(events, ammotype)
    local user = {}
    for _, e in pairs(events) do
        if e.id == EVENT_KILL and e.dmg.g == ammotype then
            user[e.att.sid] = (user[e.att.sid] or 0) + 1
        end
    end

    if table.IsEmpty(user) then return nil end

    local m_id, m_num = FindHighest(user)

    if not m_id then return nil end

    return {sid=m_id, kills=m_num}
end

local function CrowbarUser(events, scores, players, innocents, traitors, detectives, mercenaries, hypnotists, glitches, jesters, phantoms, zombies, vampires, swappers, assassins, killers)
    local most = UsedAmmoMost(events, AMMO_CROWBAR)
    if not most then return nil end

    local nick = players[most.sid]
    if not nick then return nil end

    local award = {nick=nick, priority=most.kills + math.random(0, 4)}
    local kills = most.kills
    if kills > 1 and kills < 3 then
        award.title = T("aw_cbr1_title")
        award.text = PT("aw_cbr1_text", {num = kills})
    elseif kills >= 3 then
        award.title = T("aw_cbr2_title")
        award.text = PT("aw_cbr2_text", {num = kills})
        award.priority = kills + math.random(5, 10)
    else
        return nil
    end

    return award
end

local function PistolUser(events, scores, players, innocents, traitors, detectives, mercenaries, hypnotists, glitches, jesters, phantoms, zombies, vampires, swappers, assassins, killers)
    local most = UsedAmmoMost(events, AMMO_PISTOL)
    if not most then return nil end

    local nick = players[most.sid]
    if not nick then return nil end

    local award = {nick=nick, priority=most.kills}
    local kills = most.kills
    if kills > 1 and kills < 4 then
        award.title = T("aw_pst1_title")
        award.text = PT("aw_pst1_text", {num = kills})
    elseif kills >= 4 then
        award.title = T("aw_pst2_title")
        award.text = PT("aw_pst2_text", {num = kills})
        award.priority = award.priority + math.random(0, 5)
    else
        return nil
    end

    return award
end

local function ShotgunUser(events, scores, players, innocents, traitors, detectives, mercenaries, hypnotists, glitches, jesters, phantoms, zombies, vampires, swappers, assassins, killers)
    local most = UsedAmmoMost(events, AMMO_SHOTGUN)
    if not most then return nil end

    local nick = players[most.sid]
    if not nick then return nil end

    local award = {nick=nick, priority=most.kills}
    local kills = most.kills
    if kills > 1 and kills < 4 then
        award.title = T("aw_sgn1_title")
        award.text = PT("aw_sgn1_text", {num = kills})
        award.priority = math.Round(kills / 2)
    elseif kills >= 4 then
        award.title = T("aw_sgn2_title")
        award.text = PT("aw_sgn2_text", {num = kills})
    else
        return nil
    end

    return award
end

local function RifleUser(events, scores, players, innocents, traitors, detectives, mercenaries, hypnotists, glitches, jesters, phantoms, zombies, vampires, swappers, assassins, killers)
    local most = UsedAmmoMost(events, AMMO_RIFLE)
    if not most then return nil end

    local nick = players[most.sid]
    if not nick then return nil end

    local award = {nick=nick, priority=most.kills}
    local kills = most.kills
    if kills > 1 and kills < 4 then
        award.title = T("aw_rfl1_title")
        award.text = PT("aw_rfl1_text", {num = kills})
        award.priority = math.Round(kills / 2)
    elseif kills >= 4 then
        award.title = T("aw_rfl2_title")
        award.text = PT("aw_rfl2_text", {num = kills})
    else
        return nil
    end

    return award
end

local function DeagleUser(events, scores, players, innocents, traitors, detectives, mercenaries, hypnotists, glitches, jesters, phantoms, zombies, vampires, swappers, assassins, killers)
    local most = UsedAmmoMost(events, AMMO_DEAGLE)
    if not most then return nil end

    local nick = players[most.sid]
    if not nick then return nil end

    local award = {nick=nick, priority=most.kills}
    local kills = most.kills
    if kills > 1 and kills < 4 then
        award.title = T("aw_dgl1_title")
        award.text = PT("aw_dgl1_text", {num = kills})
        award.priority = math.Round(kills / 2)
    elseif kills >= 4 then
        award.title = T("aw_dgl2_title")
        award.text = PT("aw_dgl2_text", {num = kills})
        award.priority = kills + math.random(2, 6)
    else
        return nil
    end

    return award
end

local function MAC10User(events, scores, players, innocents, traitors, detectives, mercenaries, hypnotists, glitches, jesters, phantoms, zombies, vampires, swappers, assassins, killers)
    local most = UsedAmmoMost(events, AMMO_MAC10)
    if not most then return nil end

    local nick = players[most.sid]
    if not nick then return nil end

    local award = {nick=nick, priority=most.kills}
    local kills = most.kills
    if kills > 1 and kills < 4 then
        award.title = T("aw_mac1_title")
        award.text = PT("aw_mac1_text", {num = kills})
        award.priority = math.Round(kills / 2)
    elseif kills >= 4 then
        award.title = T("aw_mac2_title")
        award.text = PT("aw_mac2_text", {num = kills})
    else
        return nil
    end

    return award
end

local function SilencedPistolUser(events, scores, players, innocents, traitors, detectives, mercenaries, hypnotists, glitches, jesters, phantoms, zombies, vampires, swappers, assassins, killers)
    local most = UsedAmmoMost(events, AMMO_SIPISTOL)
    if not most then return nil end

    local nick = players[most.sid]
    if not nick then return nil end

    local award = {nick=nick, priority=most.kills}
    local kills = most.kills
    if kills > 1 and kills < 3 then
        award.title = T("aw_sip1_title")
        award.text = PT("aw_sip1_text", {num = kills})
    elseif kills >= 3 then
        award.title = T("aw_sip2_title")
        award.text = PT("aw_sip2_text", {num = kills})
    else
        return nil
    end

    return award
end

local function KnifeUser(events, scores, players, innocents, traitors, detectives, mercenaries, hypnotists, glitches, jesters, phantoms, zombies, vampires, swappers, assassins, killers)
    local most = UsedAmmoMost(events, AMMO_KNIFE)
    if not most then return nil end

    local nick = players[most.sid]
    if not nick then return nil end

    local award = {nick=nick, priority=most.kills}
    local kills = most.kills

    if kills == 1 then
        if table.HasValue(traitors, most.sid) then
            award.title = T("aw_knf1_title")
            award.text = PT("aw_knf1_text", {num = kills})
            award.priority = 0
        else
            award.title = T("aw_knf2_title")
            award.text = PT("aw_knf2_text", {num = kills})
            award.priority = 5
        end
    elseif kills > 1 and kills < 4 then
        award.title = T("aw_knf3_title")
        award.text = PT("aw_knf3_text", {num = kills})
    elseif kills >= 4 then
        award.title = T("aw_knf4_title")
        award.text = PT("aw_knf4_text", {num = kills})
    else
        return nil
    end

    return award
end

local function FlareUser(events, scores, players, innocents, traitors, detectives, mercenaries, hypnotists, glitches, jesters, phantoms, zombies, vampires, swappers, assassins, killers)
    local most = UsedAmmoMost(events, AMMO_FLARE)
    if not most then return nil end

    local nick = players[most.sid]
    if not nick then return nil end

    local award = {nick=nick, priority=most.kills}
    local kills = most.kills
    if kills > 1 and kills < 3 then
        award.title = T("aw_flg1_title")
        award.text = PT("aw_flg1_text", {num = kills})
    elseif kills >= 3 then
        award.title = T("aw_flg2_title")
        award.text = PT("aw_flg2_text", {num = kills})
    else
        return nil
    end

    return award
end

local function M249User(events, scores, players, innocents, traitors, detectives, mercenaries, hypnotists, glitches, jesters, phantoms, zombies, vampires, swappers, assassins, killers)
    local most = UsedAmmoMost(events, AMMO_M249)
    if not most then return nil end

    local nick = players[most.sid]
    if not nick then return nil end

    local award = {nick=nick, priority=most.kills}
    local kills = most.kills
    if kills > 1 and kills < 4 then
        award.title = T("aw_hug1_title")
        award.text = PT("aw_hug1_text", {num = kills})
    elseif kills >= 4 then
        award.title = T("aw_hug2_title")
        award.text = PT("aw_hug2_text", {num = kills})
    else
        return nil
    end

    return award
end

local function M16User(events, scores, players, innocents, traitors, detectives, mercenaries, hypnotists, glitches, jesters, phantoms, zombies, vampires, swappers, assassins, killers)
    local most = UsedAmmoMost(events, AMMO_M16)
    if not most then return nil end

    local nick = players[most.sid]
    if not nick then return nil end

    local award = {nick=nick, priority=most.kills}
    local kills = most.kills
    if kills > 1 and kills < 4 then
        award.title = T("aw_msx1_title")
        award.text = PT("aw_msx1_text", {num = kills})
    elseif kills >= 4 then
        award.title = T("aw_msx2_title")
        award.text = PT("aw_msx2_text", {num = kills})
    else
        return nil
    end

    return award
end

local function TeamKiller(events, scores, players, innocents, traitors, detectives, mercenaries, hypnotists, glitches, jesters, phantoms, zombies, vampires, swappers, assassins, killers)
    local num_traitors = table.Count(traitors) + table.Count(hypnotists) + table.Count(assassins)
    local num_inno = table.Count(innocents) + table.Count(detectives) + table.Count(mercenaries) + table.Count(glitches) + table.Count(phantoms)
    local num_mon = table.Count(zombies) + table.Count(vampires)

    -- find biggest tker
    local tker = nil
    local pct = 0
    for id, s in pairs(scores) do
        local kills = s.innos
        local team = num_inno - 1
        if table.HasValue(traitors, id) or table.HasValue(hypnotists, id) or table.HasValue(assassins, id) then
            kills = s.traitors
            team = num_traitors - 1
        elseif table.HasValue(zombies, id) or table.HasValue(vampires, id) then
            kills = s.monsters
            team = num_mon - 1
        -- Essentially ignore killers because they can't have a team
        elseif table.HasValue(killers, id) then
            kills = 0
            team = 0
        end

        if kills > 0 and (kills / team) > pct then
            pct = kills / team
            tker = id
        end
    end

    -- no tks
    if pct == 0 or tker == nil then return nil end

    local nick = players[tker]
    if not nick then return nil end

    local was_traitor = table.HasValue(traitors, tker) or table.HasValue(hypnotists, tker) or table.HasValue(assassins, tker)
    local was_monster = table.HasValue(zombies, tker) or table.HasValue(vampires, tker)
    local kills = (was_traitor and scores[tker].traitors > 0 and scores[tker].traitors) or (was_monster and scores[tker].monsters > 0 and scores[tker].monsters) or (scores[tker].innos > 0 and scores[tker].innos) or 0
    local award = {nick=nick, priority=kills}
    if kills == 1 then
        award.title = T("aw_tkl1_title")
        award.text =  T("aw_tkl1_text")
        award.priority = 0
    elseif kills == 2 then
        award.title = T("aw_tkl2_title")
        award.text =  T("aw_tkl2_text")
    elseif kills == 3 then
        award.title = T("aw_tkl3_title")
        award.text =  T("aw_tkl3_text")
    elseif pct >= 1.0 then
        award.title = T("aw_tkl4_title")
        award.text =  T("aw_tkl4_text")
        award.priority = kills + math.random(3, 6)
    elseif pct >= 0.75 and not was_traitor and not was_monster then
        award.title = T("aw_tkl5_title")
        award.text =  T("aw_tkl5_text")
        award.priority = kills + 10
    elseif pct > 0.5 then
        award.title = T("aw_tkl6_title")
        award.text =  T("aw_tkl6_text")
        award.priority = kills + math.random(2, 7)
    elseif pct >= 0.25 then
        award.title = T("aw_tkl7_title")
        award.text =  T("aw_tkl7_text")
    else
        return nil
    end
    return award
end

local function Burner(events, scores, players, innocents, traitors, detectives, mercenaries, hypnotists, glitches, jesters, phantoms, zombies, vampires, swappers, assassins, killers)
    local brn = {}
    for _, e in pairs(events) do
        if e.id == EVENT_KILL and is_dmg(e.dmg.t, DMG_BURN) then
            brn[e.att.sid] = (brn[e.att.sid] or 0) + 1
        end
    end

    if table.IsEmpty(brn) then return nil end

    -- find the one with the most burnings
    local m_id, m_num = FindHighest(brn)

    if not m_id then return nil end

    local nick = players[m_id]
    if not nick then return nil end

    local award = {nick=nick, priority=m_num * 2}
    if m_num > 1 and m_num < 4 then
        award.title = T("aw_brn1_title")
        award.text =  T("aw_brn1_text")
    elseif m_num >= 4 and m_num < 7 then
        award.title = T("aw_brn2_title")
        award.text =  T("aw_brn2_text")
    elseif m_num >= 7 then
        award.title = T("aw_brn3_title")
        award.text =  T("aw_brn3_text")
        award.priority = m_num + math.random(0, 4)
    else
        return nil
    end

    return award
end

local function Coroner(events, scores, players, innocents, traitors, detectives, mercenaries, hypnotists, glitches, jesters, phantoms, zombies, vampires, swappers, assassins, killers)
    local finders = {}
    for _, e in pairs(events) do
        if e.id == EVENT_BODYFOUND then
            finders[e.sid] = (finders[e.sid] or 0) + 1
        end
    end

    if table.IsEmpty(finders) then return end

    local m_id, m_num = FindHighest(finders)

    if not m_id then return nil end

    local nick = players[m_id]
    if not nick then return nil end

    local award = {nick=nick, priority=m_num}
    if m_num > 2 and m_num < 6 then
        award.title =  T("aw_fnd1_title")
        award.text =  PT("aw_fnd1_text", {num = m_num})
    elseif m_num >= 6 and m_num < 10 then
        award.title = T("aw_fnd2_title")
        award.text = PT("aw_fnd2_text", {num = m_num})
    elseif m_num >= 10 then
        award.title = T("aw_fnd3_title")
        award.text = PT("aw_fnd3_text", {num = m_num})
        award.priority = m_num + math.random(0, 4)
    else
        return nil
    end

    return award
end

local function CreditFound(events, scores, players, innocents, traitors, detectives, mercenaries, hypnotists, glitches, jesters, phantoms, zombies, vampires, swappers, assassins, killers)
    local finders = {}
    for _, e in pairs(events) do
        if e.id == EVENT_CREDITFOUND then
            finders[e.sid] = (finders[e.sid] or 0) + e.cr
        end
    end

    if table.IsEmpty(finders) then return end

    local m_id, m_num = FindHighest(finders)

    if not m_id then return nil end

    local nick = players[m_id]
    if not nick then return nil end

    local award = {nick=nick}
    if m_num > 2 then
        award.title = T("aw_crd1_title")
        award.text = PT("aw_crd1_text", {num = m_num})
        award.priority = m_num + math.random(0, m_num)
    else
        return nil
    end

    return award
end

local function TimeOfDeath(events, scores, players, innocents, traitors, detectives, mercenaries, hypnotists, glitches, jesters, phantoms, zombies, vampires, swappers, assassins, killers)
    local near = 10
    local time_near_start = CLSCORE.StartTime + near
    local time_near_end   = nil

    local traitor_win = nil
    local innocent_win = nil
    local monster_win = nil

    local e = nil
    for i=#events, 1, -1 do
        e = events[i]

        if e.id == EVENT_FINISH then
            time_near_end = e.t - near
            traitor_win = (e.win == WIN_TRAITOR)
            innocent_win = (e.win == WIN_INNOCENT)
            monster_win = (e.win == WIN_MONSTER)
        elseif e.id == EVENT_KILL and e.vic then
            -- If this happened near the end and the winning team matches the victim's team
            if time_near_end and e.t > time_near_end and ((e.vic.tr and traitor_win) or (e.vic.inno and innocent_win) or (e.vic.mon and monster_win)) then
                return {
                    nick  = e.vic.ni,
                    title = T("aw_tod1_title"),
                    text  = T("aw_tod1_text"),
                    priority = (e.t - time_near_end) * 2
                };
            -- If this happened near the start
            elseif e.t < time_near_start then
                return {
                    nick  = e.vic.ni,
                    title = T("aw_tod2_title"),
                    text  = T("aw_tod2_text"),
                    priority = (time_near_start - e.t) * 2
                };
            end
        end
    end
end


-- New award functions must be added to this to be used by CLSCORE.
-- Note that AWARDS is global. You can just go: table.insert(AWARDS, myawardfn) in your SWEPs.
AWARDS = { FirstSuicide, ExplosiveGrant, ExplodedSelf, FirstBlood, AllKills, NumKills_Traitor, NumKills_Inno, FallDeath, Headshots, PistolUser, ShotgunUser, RifleUser, DeagleUser, MAC10User, CrowbarUser, TeamKiller, Burner, SilencedPistolUser, KnifeUser, FlareUser, Coroner, M249User, M16User, CreditFound, FallKill, TimeOfDeath }
