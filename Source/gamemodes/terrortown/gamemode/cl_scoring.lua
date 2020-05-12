-- Game report

include("cl_awards.lua")

local table = table
local string = string
local vgui = vgui
local pairs = pairs

CLSCORE = {}
CLSCORE.Events = {}
CLSCORE.Scores = {}
CLSCORE.TraitorIDs = {}
CLSCORE.DetectiveIDs = {}
CLSCORE.MercenaryIDs = {}
CLSCORE.HypnotistIDs = {}
CLSCORE.GlitchIDs = {}
CLSCORE.JesterIDs = {}
CLSCORE.PhantomIDs = {}
CLSCORE.ZombieIDs = {}
CLSCORE.VampireIDs = {}
CLSCORE.SwapperIDs = {}
CLSCORE.AssassinIDs = {}
CLSCORE.KillerIDs = {}
CLSCORE.Players = {}
CLSCORE.StartTime = 0
CLSCORE.Panel = nil

CLSCORE.EventDisplay = {}

local skull_icon = Material("HUD/killicons/default")

surface.CreateFont("WinHuge", {
    font = "Trebuchet24",
    size = 72,
    weight = 1000,
    shadow = true
})

surface.CreateFont("ScoreNicks", {
    font = "Trebuchet24",
    size = 32,
    weight = 100
})

-- so much text here I'm using shorter names than usual
local T = LANG.GetTranslation
local PT = LANG.GetParamTranslation
local jesterkiller = ""
local jestervictim = ""
local jesterkillerrole = -1
local hypnotised = {}
local revived = {}
local zombified = {}
local disconnected = {}
local spawnedplayers = {}
local rolechanges = {}
local customEvents = {}

function AddEvent(e)
    e["t"] = math.Round(CurTime(), 2)
    table.insert(customEvents, e)
end

local function FindTableIndex(playerTable, value)
    for k, name in pairs(playerTable) do
        if name == value then
            return k
        end
    end
    return -1
end

local function HandleRoleChange(roletable, role, targetrole, uid)
    if role == targetrole then
        if not table.HasValue(roletable, uid) then
            table.insert(roletable, uid)
        end
    else
        local roleIndex = FindTableIndex(roletable, uid)
        if roleIndex >= 0 then
            table.remove(roletable, roleIndex)
        end
    end
end

local function InsertPlayerToTable(playerTable, name)
    local tableIndex = FindTableIndex(playerTable, name)
    if tableIndex <= 0 then
        table.insert(playerTable, name)
    end
end

local function InsertRevivedPlayer(name)
    table.insert(revived, name)
end

net.Receive("TTT_JesterKiller", function(len)
    jesterkiller = net.ReadString()
    jestervictim = net.ReadString()
    jesterkillerrole = net.ReadInt(6)
    if jesterkillerrole >= 0 then
        InsertRevivedPlayer(jestervictim)
    end
end)

net.Receive("TTT_Hypnotised", function(len)
    local name = net.ReadString()
    InsertPlayerToTable(hypnotised, name)

    -- Remove any record of this player being zombified
    local zomIndex = FindTableIndex(zombified, name)
    if zomIndex > 0 then
        table.remove(zombified, zomIndex)
    end

    AddEvent({
        id = EVENT_HYPNOTISED,
        vic = name
    })
end)

net.Receive("TTT_Defibrillated", function(len)
    local name = net.ReadString()
    InsertRevivedPlayer(name)
    AddEvent({
        id = EVENT_DEFIBRILLATED,
        vic = name
    })
end)

net.Receive("TTT_Zombified", function(len)
    local name = net.ReadString()
    InsertPlayerToTable(zombified, name)

    -- Remove any record of this player being hypnotized
    local hypIndex = FindTableIndex(hypnotised, name)
    if hypIndex > 0 then
        table.remove(hypnotised, hypIndex)
    end
    AddEvent({
        id = EVENT_ZOMBIFIED,
        vic = name
    })
end)

net.Receive("TTT_PlayerDisconnected", function(len)
    local name = net.ReadString()
    table.insert(disconnected, name)
    AddEvent({
        id = EVENT_DISCONNECTED,
        vic = name
    })
end)

net.Receive("TTT_ClearRoleSwaps", function(len)
    hypnotised = {}
    revived = {}
    zombified = {}
    disconnected = {}
    spawnedplayers = {}
    rolechanges = {}
    customEvents = {}
end)

net.Receive("TTT_SpawnedPlayers", function(len)
    local name = net.ReadString()
    table.insert(spawnedplayers, name)
end)

net.Receive("TTT_RoleChanged", function(len)
    local uid = net.ReadInt(8)
    local role = net.ReadInt(8)
    rolechanges[uid] = role
end)

function CLSCORE:GetDisplay(key, event)
    local displayfns = self.EventDisplay[event.id]
    if not displayfns then return end
    local keyfn = displayfns[key]
    if not keyfn then return end

    return keyfn(event)
end

function CLSCORE:TextForEvent(e)
    return self:GetDisplay("text", e)
end

function CLSCORE:IconForEvent(e)
    return self:GetDisplay("icon", e)
end

function CLSCORE:TimeForEvent(e)
    local t = e.t - self.StartTime
    if t >= 0 then
        return util.SimpleTime(t, "%02i:%02i")
    else
        return "     "
    end
end

-- Tell CLSCORE how to display an event. See cl_scoring_events for examples.
-- Pass an empty table to keep an event from showing up.
function CLSCORE.DeclareEventDisplay(event_id, event_fns)
    -- basic input vetting, can't check returned value types because the
    -- functions may be impure
    if not tonumber(event_id) then
        Error("Event ??? display: invalid event id\n")
    end
    if (not event_fns) or type(event_fns) ~= "table" then
        Error(Format("Event %d display: no display functions found.\n", event_id))
    end
    if not event_fns.text then
        Error(Format("Event %d display: no text display function found.\n", event_id))
    end
    if not event_fns.icon then
        Error(Format("Event %d display: no icon and tooltip display function found.\n", event_id))
    end

    CLSCORE.EventDisplay[event_id] = event_fns
end

function CLSCORE:FillDList(dlst)
    local allEvents = self.Events
    table.Merge(allEvents, customEvents)
    table.SortByMember(allEvents, "t", true)

    for _, e in pairs(allEvents) do
        local etxt = self:TextForEvent(e)
        local eicon, ttip = self:IconForEvent(e)
        local etime = self:TimeForEvent(e)

        if etxt then
            if eicon then
                local mat = eicon
                eicon = vgui.Create("DImage")
                eicon:SetMaterial(mat)
                eicon:SetTooltip(ttip)
                eicon:SetKeepAspect(true)
                eicon:SizeToContents()
            end

            dlst:AddLine(etime, eicon, "  " .. etxt)
        end
    end
end

local function ValidAward(a)
    return a and a.nick and a.text and a.title and a.priority
end

local wintitle = {
    [WIN_TRAITOR] = { txt = "hilite_win_traitors", c = Color(190, 5, 5, 255) },
    [WIN_JESTER] = { txt = "hilite_win_jester", c = Color(160, 5, 230, 255) },
    [WIN_INNOCENT] = { txt = "hilite_win_innocent", c = Color(5, 190, 5, 255) },
    [WIN_KILLER] = { txt = "hilite_win_killer", c = Color(50, 0, 70, 255) },
    [WIN_MONSTER] = { txt = "hilite_win_monster", c = Color(0, 0, 0, 255) }
}

function CLSCORE:BuildEventLogPanel(dpanel)
    local margin = 10

    local w, h = dpanel:GetSize()

    local dlist = vgui.Create("DListView", dpanel)
    dlist:SetPos(0, 0)
    dlist:SetSize(w, h - margin * 2)
    dlist:SetSortable(true)
    dlist:SetMultiSelect(false)

    local timecol = dlist:AddColumn(T("col_time"))
    local iconcol = dlist:AddColumn("")
    local eventcol = dlist:AddColumn(T("col_event"))

    iconcol:SetFixedWidth(16)
    timecol:SetFixedWidth(40)

    -- If sortable is off, no background is drawn for the headers which looks
    -- terrible. So enable it, but disable the actual use of sorting.
    iconcol.Header:SetDisabled(true)
    timecol.Header:SetDisabled(true)
    eventcol.Header:SetDisabled(true)

    self:FillDList(dlist)
end

function CLSCORE:BuildScorePanel(dpanel)
    local margin = 10
    local w, h = dpanel:GetSize()

    local dlist = vgui.Create("DListView", dpanel)
    dlist:SetPos(0, 0)
    dlist:SetSize(w, h)
    dlist:SetSortable(true)
    dlist:SetMultiSelect(false)

    local colnames = { "", "col_player", "col_role", "col_kills1", "col_kills2", "col_kills3", "col_kills4", "col_kills5", "col_points", "col_team", "col_total" }
    for k, name in pairs(colnames) do
        if name == "" then
            -- skull icon column
            local c = dlist:AddColumn("")
            c:SetFixedWidth(18)
        else
            dlist:AddColumn(T(name))
        end
    end

    -- the type of win condition triggered is relevant for team bonus
    local wintype = WIN_NONE
    for i = #self.Events, 1, -1 do
        local e = self.Events[i]
        if e.id == EVENT_FINISH then
            wintype = e.win
            break
        end
    end

    local scores = self.Scores
    local nicks = self.Players
    local bonus = ScoreTeamBonus(scores, wintype)

    for id, s in pairs(scores) do
        if id ~= -1 then
            local was_traitor = s.was_traitor or s.was_assassin or s.was_hypnotist
            local was_monster = s.was_zombie or s.was_vampire
            local was_innocent = s.was_innocent or s.was_detective or s.was_phantom or s.was_mercenary or s.was_glitch
            local role = was_traitor and T("traitor") or (s.was_detective and T("detective") or (s.was_hypnotist and T("hypnotist") or (s.was_mercenary and T("mercenary") or (s.was_jester and T("jester") or (s.was_phantom and T("phantom") or (s.was_glitch and T("glitch") or (s.was_zombie and T("zombie") or (s.was_vampire and T("vampire") or (s.was_swapper and T("swapper") or (s.was_assassin and T("assassin") or (s.was_killer and T("killer") or T("innocent"))))))))))))

            local surv = ""
            if s.deaths > 0 then
                surv = vgui.Create("ColoredBox", dlist)
                surv:SetColor(Color(150, 50, 50))
                surv:SetBorder(false)
                surv:SetSize(18, 18)

                local skull = vgui.Create("DImage", surv)
                skull:SetMaterial(skull_icon)
                skull:SetTooltip("Dead")
                skull:SetKeepAspect(true)
                skull:SetSize(18, 18)
            end

            local points_own = KillsToPoints(s, was_traitor, was_monster, s.was_killer, was_innocent)
            local points_team = bonus.innos
            if was_traitor then
                points_team = bonus.traitors
            elseif was_monster then
                points_team = bonus.monsters
            elseif s.was_jester or s.was_swapper then
                points_team = bonus.jesters
            elseif s.was_killer then
                points_team = bonus.killers
            end
            local points_total = points_own + points_team

            local l = dlist:AddLine(surv, nicks[id], role, s.innos, s.traitors, s.monsters, s.jesters, s.killers, points_own, points_team, points_total)

            -- center align
            for _, col in pairs(l.Columns) do
                col:SetContentAlignment(5)
            end

            -- when sorting on the column showing survival, we would get an error
            -- because images can't be sorted, so instead hack in a dummy value
            local surv_col = l.Columns[1]
            if surv_col then
                surv_col.Value = type(surv_col.Value) == "Panel" and "1" or "0"
            end
        end
    end

    dlist:SortByColumn(6)
end

function CLSCORE:AddAward(y, pw, award, dpanel)
    local nick = award.nick
    local text = award.text
    local title = string.upper(award.title)

    local titlelbl = vgui.Create("DLabel", dpanel)
    titlelbl:SetText(title)
    titlelbl:SetFont("TabLarge")
    titlelbl:SizeToContents()
    local tiw, tih = titlelbl:GetSize()

    local nicklbl = vgui.Create("DLabel", dpanel)
    nicklbl:SetText(nick)
    nicklbl:SetFont("DermaDefaultBold")
    nicklbl:SizeToContents()
    local nw, nh = nicklbl:GetSize()

    local txtlbl = vgui.Create("DLabel", dpanel)
    txtlbl:SetText(text)
    txtlbl:SetFont("DermaDefault")
    txtlbl:SizeToContents()
    local tw, th = txtlbl:GetSize()

    titlelbl:SetPos((pw - tiw) / 2, y)
    y = y + tih + 2

    local fw = nw + tw + 5
    local fx = ((pw - fw) / 2)
    nicklbl:SetPos(fx, y)
    txtlbl:SetPos(fx + nw + 5, y)

    y = y + nh

    return y
end

function CLSCORE:BuildSummaryPanel(dpanel)
    local w, h = dpanel:GetSize()

    local title = wintitle[WIN_INNOCENT]
    for i = #self.Events, 1, -1 do
        local e = self.Events[i]
        if e.id == EVENT_FINISH then
            local wintype = e.win
            if wintype == WIN_TIMELIMIT then wintype = WIN_INNOCENT end
            title = wintitle[wintype]
            break
        end
    end

    local bg = vgui.Create("ColoredBox", dpanel)
    bg:SetColor(Color(97, 100, 102, 255))
    bg:SetSize(w, h)
    bg:SetPos(0, 0)

    local winlbl = vgui.Create("DLabel", dpanel)
    winlbl:SetFont("WinHuge")
    winlbl:SetText(T(title.txt))
    winlbl:SetTextColor(COLOR_WHITE)
    winlbl:SizeToContents()
    local xwin = (w - winlbl:GetWide())/2
    local ywin = 15
    winlbl:SetPos(xwin, ywin)

    bg.PaintOver = function()
        draw.RoundedBox(8, 8, ywin - 5, w - 14, winlbl:GetTall() + 10, title.c)
        draw.RoundedBox(0, 8, ywin + winlbl:GetTall() + 8, 341, 329, Color(164, 164, 164, 255))
        draw.RoundedBox(0, 357, ywin + winlbl:GetTall() + 8, 341, 329, Color(164, 164, 164, 255))
        draw.RoundedBox(0, 8, ywin + winlbl:GetTall() + 345, 690, 32, Color(164, 164, 164, 255))
        draw.RoundedBox(0, 8, ywin + winlbl:GetTall() + 385, 690, 32, Color(164, 164, 164, 255))
        for i = ywin + winlbl:GetTall() + 40, ywin + winlbl:GetTall() + 304, 33 do
            draw.RoundedBox(0, 8, i, 341, 1, Color(97, 100, 102, 255))
            draw.RoundedBox(0, 357, i, 341, 1, Color(97, 100, 102, 255))
        end
    end

    local scores = self.Scores
    local nicks = self.Players
    local symbols = false
    local countI = 0
    local countT = 0

    for id, s in pairs(scores) do
        if id ~= -1 then
            local role = s.was_traitor and "tra" or (s.was_detective and "det" or (s.was_hypnotist and "hyp" or (s.was_jester and "jes" or (s.was_swapper and "swa" or (s.was_mercenary and "mer" or (s.was_glitch and "gli" or (s.was_phantom and "pha" or (s.was_zombie and "zom" or (s.was_assassin and "ass" or (s.was_vampire and "vam" or (s.was_killer and "kil" or "inn")))))))))))

            if role == "swa" and jesterkillerrole >= 0 then
                if jesterkillerrole == 0 then
                    role = "inn"
                elseif jesterkillerrole == 1 then
                    role = "tra"
                elseif jesterkillerrole == 2 then
                    role = "det"
                elseif jesterkillerrole == 3 then
                    role = "mer"
                elseif jesterkillerrole == 4 then
                    role = "jes"
                elseif jesterkillerrole == 5 then
                    role = "pha"
                elseif jesterkillerrole == 6 then
                    role = "hyp"
                elseif jesterkillerrole == 7 then
                    role = "gli"
                elseif jesterkillerrole == 8 then
                    role = "zom"
                elseif jesterkillerrole == 9 then
                    role = "vam"
                elseif jesterkillerrole == 10 then
                    role = "swa"
                elseif jesterkillerrole == 11 then
                    role = "ass"
                elseif jesterkillerrole == 12 then
                    role = "kil"
                end
            end

            local foundPlayer = false

            for _, v in pairs(spawnedplayers) do
                if v == nicks[id] then
                    foundPlayer = true
                    break
                end
            end

            if foundPlayer then
                local dead = s.deaths or 0
                local hasDisconnected = false

                for _, v in pairs(revived) do
                    if v == nicks[id] then
                        dead = dead - 1
                    end
                end

                for _, v in pairs(disconnected) do
                    if v == nicks[id] then
                        hasDisconnected = true
                        break
                    end
                end

                if nicks[id] == jesterkiller and jesterkillerrole >= 0 then
                    role = "swa"
                end

                if ConVarExists("ttt_role_symbols") then
                    symbols = GetConVar("ttt_role_symbols"):GetBool()
                end

                local symorlet = "let"
                if symbols then
                    symorlet = "sym"
                end

                local washyped = false
                for _, v in pairs(hypnotised) do
                    if v == nicks[id] then
                        washyped = true
                    end
                end

                local waszomed = false
                for _, v in pairs(zombified) do
                    if v == nicks[id] then
                        waszomed = true
                    end
                end

                local roleIconName = "score_" .. symorlet .. "_" .. role
                if (washyped) then
                    roleIconName = roleIconName .. "_hyped"
                elseif (waszomed) then
                    roleIconName = roleIconName .. "_zomed"
                end

                local roleIcon = vgui.Create("DImage", dpanel)
                roleIcon:SetSize(32, 32)
                roleIcon:SetImage("vgui/ttt/" .. roleIconName .. ".png")

                local nicklbl = vgui.Create("DLabel", dpanel)
                nicklbl:SetFont("ScoreNicks")
                nicklbl:SetText(nicks[id])
                nicklbl:SetTextColor(COLOR_WHITE)
                nicklbl:SizeToContents()

                if role == "inn" or role == "det" or role == "mer" or role == "pha" or role == "gli" then
                    self:AddPlayerRow(dpanel, 317, 8, 96 + 33 * countI, roleIcon, nicklbl, hasDisconnected, dead)
                    countI = countI + 1
                elseif role == "tra" or role == "hyp" or role == "zom" or role == "vam" or role == "ass" then
                    self:AddPlayerRow(dpanel, 666, 357, 96 + 33 * countT, roleIcon, nicklbl, hasDisconnected, dead)
                    countT = countT + 1
                elseif role == "jes" or role == "swa" then
                    if jesterkiller ~= "" then
                        if role == "jes" then
                            nicklbl:SetText(nicks[id] .. " (Killed by " .. jesterkiller .. ")")
                            nicklbl:SizeToContents()
                        else
                            nicklbl:SetText(nicks[id] .. " (Killed " .. jestervictim .. ")")
                            nicklbl:SizeToContents()
                        end
                    end
                    self:AddPlayerRow(dpanel, 666, 8, 433, roleIcon, nicklbl, hasDisconnected, dead)
                elseif role == "kil" then
                    self:AddPlayerRow(dpanel, 666, 8, 473, roleIcon, nicklbl, hasDisconnected, dead)
                end
            end
        end
    end
end

function CLSCORE:BuildHilitePanel(dpanel)
    local w, h = dpanel:GetSize()

    local endtime = self.StartTime
    local title = wintitle[WIN_INNOCENT]
    for i=#self.Events, 1, -1 do
        local e = self.Events[i]
        if e.id == EVENT_FINISH then
           endtime = e.t
           -- when win is due to timeout, innocents win
           local wintype = e.win
           if wintype == WIN_TIMELIMIT then wintype = WIN_INNOCENT end
           title = wintitle[wintype]
           break
        end
    end

    local roundtime = endtime - self.StartTime

    local numply = table.Count(self.Players)
    local numtr = table.Count(self.TraitorIDs) + table.Count(self.HypnotistIDs) + table.Count(self.AssassinIDs)

    local bg = vgui.Create("ColoredBox", dpanel)
    bg:SetColor(Color(50, 50, 50, 255))
    bg:SetSize(w,h)
    bg:SetPos(0,0)

    local winlbl = vgui.Create("DLabel", dpanel)
    winlbl:SetFont("WinHuge")
    winlbl:SetText(T(title.txt))
    winlbl:SetTextColor(COLOR_WHITE)
    winlbl:SizeToContents()
    local xwin = (w - winlbl:GetWide())/2
    local ywin = 15
    winlbl:SetPos(xwin, ywin)

    bg.PaintOver = function()
        draw.RoundedBox(8, xwin - 15, ywin - 5, winlbl:GetWide() + 30, winlbl:GetTall() + 10, title.c)
    end

    local ysubwin = ywin + winlbl:GetTall()
    local partlbl = vgui.Create("DLabel", dpanel)

    local plytxt = PT(numtr == 1 and "hilite_players2" or "hilite_players1",
                      {numplayers = numply, numtraitors = numtr})

    partlbl:SetText(plytxt)
    partlbl:SizeToContents()
    partlbl:SetPos(xwin, ysubwin + 8)

    local timelbl = vgui.Create("DLabel", dpanel)
    timelbl:SetText(PT("hilite_duration", {time= util.SimpleTime(roundtime, "%02i:%02i")}))
    timelbl:SizeToContents()
    timelbl:SetPos(xwin + winlbl:GetWide() - timelbl:GetWide(), ysubwin + 8)

    -- Awards
    local wa = math.Round(w * 0.9)
    local ha = h - ysubwin - 40
    local xa = (w - wa) / 2
    local ya = h - ha

    local awardp = vgui.Create("DPanel", dpanel)
    awardp:SetSize(wa, ha)
    awardp:SetPos(xa, ya)
    awardp:SetPaintBackground(false)

    -- Before we pick awards, seed the rng in a way that is the same on all
    -- clients. We can do this using the round start time. To make it a bit more
    -- random, involve the round's duration too.
    math.randomseed(self.StartTime + endtime)

    -- Attempt to generate every award, then sort the succeeded ones based on
    -- priority/interestingness
    local award_choices = {}
    for k, afn in pairs(AWARDS) do
       local a = afn(self.Events, self.Scores, self.Players, self.TraitorIDs, self.DetectiveIDs)
       if ValidAward(a) then
          table.insert(award_choices, a)
       end
    end

    local max_awards = 5

    -- sort descending by priority
    table.SortByMember(award_choices, "priority")

    -- put the N most interesting awards in the menu
    for i=1,max_awards do
        local a = award_choices[i]
        if a then
            self:AddAward((i - 1) * 42, wa, a, awardp)
        end
    end
end

function CLSCORE:ShowPanel()
    local dpanel = vgui.Create("DFrame")
    local w, h = 750, 620
    local margin = 15
    dpanel:SetSize(w, h)
    dpanel:Center()
    dpanel:SetTitle("Round Report")
    dpanel:SetVisible(true)
    dpanel:ShowCloseButton(true)
    dpanel:SetMouseInputEnabled(true)
    dpanel:SetKeyboardInputEnabled(true)
    dpanel.OnKeyCodePressed = util.BasicKeyHandler

    function dpanel:Think()
        self:MoveToFront()
    end

    -- keep it around so we can reopen easily
    dpanel:SetDeleteOnClose(false)
    self.Panel = dpanel

    local dbut = vgui.Create("DButton", dpanel)
    local bw, bh = 100, 25
    dbut:SetSize(bw, bh)
    dbut:SetPos(w - bw - margin, h - bh - margin/2)
    dbut:SetText(T("close"))
    dbut.DoClick = function() dpanel:Close() end

    local dsave = vgui.Create("DButton", dpanel)
    dsave:SetSize(bw, bh)
    dsave:SetPos(margin, h - bh - margin/2)
    dsave:SetText(T("report_save"))
    dsave:SetTooltip(T("report_save_tip"))
    dsave:SetConsoleCommand("ttt_save_events")

    local dtabsheet = vgui.Create("DPropertySheet", dpanel)
    dtabsheet:SetPos(margin, margin + 15)
    dtabsheet:SetSize(w - margin*2, h - margin*3 - bh)
    local padding = dtabsheet:GetPadding()

    -- Summary tab
    local dtabsummary = vgui.Create("DPanel", dtabsheet)
    dtabsummary:SetPaintBackground(false)
    dtabsummary:StretchToParent(padding, padding, padding, padding)
    self:BuildSummaryPanel(dtabsummary)

    dtabsheet:AddSheet(T("report_tab_summary"), dtabsummary, "icon16/book_open.png", false, false, T("report_tab_summary_tip"))

    -- Highlight tab
    local dtabhilite = vgui.Create("DPanel", dtabsheet)
    dtabhilite:SetPaintBackground(false)
    dtabhilite:StretchToParent(padding, padding, padding, padding)
    self:BuildHilitePanel(dtabhilite)

    dtabsheet:AddSheet(T("report_tab_hilite"), dtabhilite, "icon16/star.png", false, false, T("report_tab_hilite_tip"))

    -- Event log tab
    local dtabevents = vgui.Create("DPanel", dtabsheet)
    dtabevents:StretchToParent(padding, padding, padding, padding)
    self:BuildEventLogPanel(dtabevents)

    dtabsheet:AddSheet(T("report_tab_events"), dtabevents, "icon16/application_view_detail.png", false, false, T("report_tab_events_tip"))

    -- Score tab
    local dtabscores = vgui.Create("DPanel", dtabsheet)
    dtabscores:SetPaintBackground(false)
    dtabscores:StretchToParent(padding, padding, padding, padding)
    self:BuildScorePanel(dtabscores)

    dtabsheet:AddSheet(T("report_tab_scores"), dtabscores, "icon16/user.png", false, false, T("report_tab_scores_tip"))

    dpanel:MakePopup()

    -- makepopup grabs keyboard, whereas we only need mouse
    dpanel:SetKeyboardInputEnabled(false)
end

function CLSCORE:AddPlayerRow(dpanel, statusX, roleX, y, roleIcon, nicklbl, hasDisconnected, dead)
    roleIcon:SetPos(roleX, y)
    nicklbl:SetPos(roleX + 38, y - 2)
    if hasDisconnected then
        local disconIcon = vgui.Create("DImage", dpanel)
        disconIcon:SetSize(32, 32)
        disconIcon:SetPos(statusX, y)
        disconIcon:SetImage("vgui/ttt/score_disconicon.png")
    elseif dead > 0 then
        local skullIcon = vgui.Create("DImage", dpanel)
        skullIcon:SetSize(32, 32)
        skullIcon:SetPos(statusX, y)
        skullIcon:SetImage("vgui/ttt/score_skullicon.png")
    end
end

function CLSCORE:ClearPanel()

    if self.Panel then
        -- move the mouse off any tooltips and then remove the panel next tick

        -- we need this hack as opposed to just calling Remove because gmod does
        -- not offer a means of killing the tooltip, and doesn't clean it up
        -- properly on Remove
        input.SetCursorPos(ScrW() / 2, ScrH() / 2)
        local pnl = self.Panel
        timer.Simple(0, function() pnl:Remove() end)
    end
end

function CLSCORE:SaveLog()
    if self.Events and #self.Events <= 0 then
        chat.AddText(COLOR_WHITE, T("report_save_error"))
        return
    end

    local logdir = "ttt/logs"
    if not file.IsDir(logdir, "DATA") then
        file.CreateDir(logdir)
    end

    local logname = logdir .. "/ttt_events_" .. os.time() .. ".txt"
    local log = "Trouble in Terrorist Town - Round Events Log\n" .. string.rep("-", 50) .. "\n"

    log = log .. string.format("%s | %-25s | %s\n", " TIME", "TYPE", "WHAT HAPPENED") .. string.rep("-", 50) .. "\n"

    for _, e in pairs(self.Events) do
        local etxt = self:TextForEvent(e)
        local etime = self:TimeForEvent(e)
        local _, etype = self:IconForEvent(e)
        if etxt then
            log = log .. string.format("%s | %-25s | %s\n", etime, etype, etxt)
        end
    end

    file.Write(logname, log)

    chat.AddText(COLOR_WHITE, T("report_save_result"), COLOR_GREEN, " /garrysmod/data/" .. logname)
end

function CLSCORE:Reset()
    self.Events = {}
    self.Scores = {}
    self.Players = {}
    self.RoundStarted = 0

    self:ClearPanel()
end

function CLSCORE:Init(events)
    -- Get start time and traitors
    local starttime = nil
    local traitors = nil
    local detectives = nil
    local mercenary = nil
    local hypnotist = nil
    local glitch = nil
    local jester = nil
    local phantom = nil
    local zombie = nil
    local vampire = nil
    local swapper = nil
    local assassin = nil
    local killer = nil
    for _, e in pairs(events) do
        if e.id == EVENT_GAME and e.state == ROUND_ACTIVE then
            starttime = e.t
        elseif e.id == EVENT_SELECTED then
            traitors = e.traitor_ids
            detectives = e.detective_ids
            mercenary = e.mercenary_ids
            hypnotist = e.hypnotist_ids
            glitch = e.glitch_ids
            jester = e.jester_ids
            phantom = e.phantom_ids
            zombie = e.zombie_ids
            vampire = e.vampire_ids
            swapper = e.swapper_ids
            assassin = e.assassin_ids
            killer = e.killer_ids
        end

        if starttime and traitors then
            break
        end
    end

    -- Get scores and players
    local scores = {}
    local nicks = {}
    for _, e in pairs(events) do
        if e.id == EVENT_SPAWN then
            scores[e.uid] = ScoreInit()
            nicks[e.uid] = e.ni
        end
    end

    -- If a player swapped roles during the round, remove them from the other table
    for uid, role in pairs(rolechanges) do
        HandleRoleChange(traitors, role, ROLE_TRAITOR, uid)
        HandleRoleChange(detectives, role, ROLE_DETECTIVE, uid)
        HandleRoleChange(mercenary, role, ROLE_MERCENARY, uid)
        HandleRoleChange(hypnotist, role, ROLE_HYPNOTIST, uid)
        HandleRoleChange(glitch, role, ROLE_GLITCH, uid)
        HandleRoleChange(jester, role, ROLE_JESTER, uid)
        HandleRoleChange(phantom, role, ROLE_PHANTOM, uid)
        HandleRoleChange(zombie, role, ROLE_ZOMBIE, uid)
        HandleRoleChange(vampire, role, ROLE_VAMPIRE, uid)
        HandleRoleChange(swapper, role, ROLE_SWAPPER, uid)
        HandleRoleChange(assassin, role, ROLE_ASSASSIN, uid)
        HandleRoleChange(killer, role, ROLE_KILLER, uid)
    end

    scores = ScoreEventLog(events, scores, traitors, detectives, hypnotist, mercenary, jester, phantom, glitch, zombie, vampire, swapper, assassin, killer)

    self.Players = nicks
    self.Scores = scores
    self.TraitorIDs = traitors
    self.DetectiveIDs = detectives
    self.MercenaryIDs = mercenary
    self.HypnotistIDs = hypnotist
    self.GlitchIDs = glitch
    self.JesterIDs = jester
    self.PhantomIDs = phantom
    self.ZombieIDs = zombie
    self.VampireIDs = vampire
    self.SwapperIDs = swapper
    self.AssassinIDs = assassin
    self.KillerIDs = killer
    self.StartTime = starttime
    self.Events = events
end

function CLSCORE:ReportEvents(events)
    self:Reset()

    self:Init(events)
    self:ShowPanel()
end

function CLSCORE:Reopen()
    if self.Panel and self.Panel:IsValid() and not self.Panel:IsVisible() then
        self.Panel:SetVisible(true)
    end
end

local buff = ""
local function ReceiveReportStream(len)
    local cont = net.ReadBit() == 1

    buff = buff .. net.ReadString()

    if cont then
        return
    else
        -- do stuff with buffer contents

        local json_events = buff -- util.Decompress(buff)
        if not json_events then
            ErrorNoHalt("Round report decompression failed!\n")
        else
            -- convert the json string back to a table
            local events = util.JSONToTable(json_events)

            if istable(events) then
                CLSCORE:ReportEvents(events)
            else
                ErrorNoHalt("Round report event decoding failed!\n")
            end
        end

        -- flush
        buff = ""
    end
end

net.Receive("TTT_ReportStream", ReceiveReportStream)

local function SaveLog(ply, cmd, args)
    CLSCORE:SaveLog()
end

concommand.Add("ttt_save_events", SaveLog)
