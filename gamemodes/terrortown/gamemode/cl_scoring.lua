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

local function FindTableIndex(playerTable, value)
	for k, name in pairs(playerTable) do
		if name == value then
			return k
		end
	end
	return -1
end

local function InsertPlayerToTable(playerTable, name)
	local tableIndex = FindTableIndex(playerTable, name)
	if tableIndex <= 0 then
		table.insert(playerTable, name)
	end
end

local function InsertRevivedPlayer(name)
	InsertPlayerToTable(revived, name)
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
	InsertRevivedPlayer(name)

	-- Remove any record of this player being zombified
	local zomIndex = FindTableIndex(zombified, name)
	if zomIndex > 0 then
		table.remove(zombified, zomIndex)
	end
end)

net.Receive("TTT_Defibrillated", function(len)
	local name = net.ReadString()
	InsertRevivedPlayer(name)
end)

net.Receive("TTT_Zombified", function(len)
	local name = net.ReadString()
	InsertPlayerToTable(zombified, name)
	InsertRevivedPlayer(name)

	-- Remove any record of this player being hypnotized
	local hypIndex = FindTableIndex(hypnotised, name)
	if hypIndex > 0 then
		table.remove(hypnotised, hypIndex)
	end
end)

net.Receive("TTT_PlayerDisconnected", function(len)
	local name = net.ReadString()
	table.insert(disconnected, name)
end)

net.Receive("TTT_ClearRoleSwaps", function(len)
	hypnotised = {}
	revived = {}
	zombified = {}
	disconnected = {}
	spawnedplayers = {}
end)

net.Receive("TTT_SpawnedPlayers", function(len)
	local name = net.ReadString()
	table.insert(spawnedplayers, name)
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

	for k, e in pairs(self.Events) do

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

	local colnames = { "", "col_player", "col_role", "col_kills1", "col_kills2", "col_points", "col_team", "col_total" }
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
			local was_traitor = s.was_traitor
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

			local points_own = KillsToPoints(s, was_traitor)
			local points_team = (was_traitor and bonus.traitors or bonus.innos)
			local points_total = points_own + points_team

			local l = dlist:AddLine(surv, nicks[id], role, s.innos, s.traitors, points_own, points_team, points_total)

			-- center align
			for k, col in pairs(l.Columns) do
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

-- double check that we have no nils
local function ValidAward(a)
	return a and a.nick and a.text and a.title and a.priority
end

local wintitle = {
	[WIN_TRAITOR] = { txt = "hilite_win_traitors", c = Color(190, 5, 5, 255) },
	[WIN_JESTER] = { txt = "hilite_win_jester", c = Color(160, 5, 230, 255) },
	[WIN_INNOCENT] = { txt = "hilite_win_innocent", c = Color(5, 190, 5, 255) },
	[WIN_KILLER] = { txt = "hilite_win_killer", c = Color(50, 0, 70, 255) },
	[WIN_MONSTER] = { txt = "hilite_win_killer", c = Color(0, 0, 0, 255) }
}

function CLSCORE:ShowPanel()
	local margin = 15

	local dpanel = vgui.Create("DFrame")
	local w, h = 700, 502
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

	local bg = vgui.Create("ColoredBox", dpanel)
	bg:SetColor(Color(97, 100, 102, 255))
	bg:SetSize(w - 4, h - 26)
	bg:SetPos(2, 24)

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

	local winlbl = vgui.Create("DLabel", dpanel)
	winlbl:SetFont("WinHuge")
	winlbl:SetText(T(title.txt))
	winlbl:SetTextColor(COLOR_WHITE)
	winlbl:SizeToContents()
	local xwin = (w - winlbl:GetWide()) / 2
	local ywin = 37
	winlbl:SetPos(xwin, ywin)

	bg.PaintOver = function()
		draw.RoundedBox(8, 8, 8, 680, winlbl:GetTall() + 10, title.c)
		draw.RoundedBox(0, 8, ywin - 19 + winlbl:GetTall() + 8, 336, 329, Color(164, 164, 164, 255))
		draw.RoundedBox(0, 352, ywin - 19 + winlbl:GetTall() + 8, 336, 329, Color(164, 164, 164, 255))
		draw.RoundedBox(0, 8, ywin - 19 + winlbl:GetTall() + 345, 680, 32, Color(164, 164, 164, 255))
		for i = ywin - 19 + winlbl:GetTall() + 40, ywin - 19 + winlbl:GetTall() + 304, 33 do
			draw.RoundedBox(0, 8, i, 336, 1, Color(97, 100, 102, 255))
			draw.RoundedBox(0, 352, i, 336, 1, Color(97, 100, 102, 255))
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

			for k, v in pairs(spawnedplayers) do
				if v == nicks[id] then
					foundPlayer = true
					break
				end
			end

			if foundPlayer then
				local dead = s.deaths
				local hasDisconnected = false

				for k, v in pairs(revived) do
					if v == nicks[id] then
						dead = dead - 1
					end
				end

				for k, v in pairs(disconnected) do
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

				for k, v in pairs(hypnotised) do
					if v == nicks[id] then
						role = role .. "_hyped"
					end
				end

				for k, v in pairs(zombified) do
					if v == nicks[id] then
						role = role .. "_zomed"
					end
				end

				local roleIcon = vgui.Create("DImage", dpanel)
				roleIcon:SetSize(32, 32)
				roleIcon:SetImage("vgui/ttt/score_" .. symorlet .. "_" .. role .. ".png")

				local nicklbl = vgui.Create("DLabel", dpanel)
				nicklbl:SetFont("ScoreNicks")
				nicklbl:SetText(nicks[id])
				nicklbl:SetTextColor(COLOR_WHITE)
				nicklbl:SizeToContents()

				if role == "inn" or role == "det" or role == "mer" or role == "pha" or role == "gli" then
					roleIcon:SetPos(10, 123 + 33 * countI)
					nicklbl:SetPos(48, 121 + 33 * countI)
					if hasDisconnected then
						disconIcon = vgui.Create("DImage", dpanel)
						disconIcon:SetSize(32, 32)
						disconIcon:SetPos(314, 123 + 33 * countI)
						disconIcon:SetImage("vgui/ttt/score_disconicon.png")
					elseif dead > 0 then
						skullIcon = vgui.Create("DImage", dpanel)
						skullIcon:SetSize(32, 32)
						skullIcon:SetPos(314, 123 + 33 * countI)
						skullIcon:SetImage("vgui/ttt/score_skullicon.png")
					end
					countI = countI + 1
				elseif role == "tra" or role == "hyp" or role == "zom" or role == "vam" or role == "ass" or string.sub(role, 5) == "hyped" or string.sub(role, 5) == "zomed" then
					roleIcon:SetPos(354, 123 + 33 * countT)
					nicklbl:SetPos(392, 121 + 33 * countT)
					if hasDisconnected then
						disconIcon = vgui.Create("DImage", dpanel)
						disconIcon:SetSize(32, 32)
						disconIcon:SetPos(658, 123 + 33 * countT)
						disconIcon:SetImage("vgui/ttt/score_disconicon.png")
					elseif dead > 0 then
						skullIcon = vgui.Create("DImage", dpanel)
						skullIcon:SetSize(32, 32)
						skullIcon:SetPos(658, 123 + 33 * countT)
						skullIcon:SetImage("vgui/ttt/score_skullicon.png")
					end
					countT = countT + 1
				elseif role == "jes" or role == "swa" or role == "kil" then
					roleIcon:SetPos(10, 460)
					nicklbl:SetPos(48, 458)
					if jesterkiller ~= "" then
						if role == "jes" then
							nicklbl:SetText(nicks[id] .. " (Killed by " .. jesterkiller .. ")")
							nicklbl:SizeToContents()
						else
							nicklbl:SetText(nicks[id] .. " (Killed " .. jestervictim .. ")")
							nicklbl:SizeToContents()
						end
					end
					if hasDisconnected then
						disconIcon = vgui.Create("DImage", dpanel)
						disconIcon:SetSize(32, 32)
						disconIcon:SetPos(658, 460)
						disconIcon:SetImage("vgui/ttt/score_disconicon.png")
					elseif dead > 0 then
						skullIcon = vgui.Create("DImage", dpanel)
						skullIcon:SetSize(32, 32)
						skullIcon:SetPos(658, 460)
						skullIcon:SetImage("vgui/ttt/score_skullicon.png")
					end
				end
			end
		end
	end

	dpanel:MakePopup()

	-- makepopup grabs keyboard, whereas we only need mouse
	dpanel:SetKeyboardInputEnabled(false)
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
	--self.StoredEvents = nil
	self.TraitorIDs = {}
	self.DetectiveIDs = {}
	self.MercenaryIDs = {}
	self.HypnotistIDs = {}
	self.GlitchIDs = {}
	self.JesterIDs = {}
	self.PhantomIDs = {}
	self.ZombieIDs = {}
	self.VampireIDs = {}
	self.SwapperIDs = {}
	self.AssassinIDs = {}
	self.KillerIDs = {}
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
	for k, e in pairs(events) do
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
	for k, e in pairs(events) do
		if e.id == EVENT_SPAWN then
			scores[e.sid] = ScoreInit()
			nicks[e.sid] = e.ni
		end
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
