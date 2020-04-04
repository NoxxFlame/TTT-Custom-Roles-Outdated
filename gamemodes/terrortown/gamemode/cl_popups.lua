-- Some popup window stuff

local GetTranslation = LANG.GetTranslation
local GetPTranslation = LANG.GetParamTranslation

-- Round start
local function GetTextForRole(role)
	local menukey = Key("+menu_context", "C")

	if role == ROLE_INNOCENT then
		return GetTranslation("info_popup_innocent")

	elseif role == ROLE_DETECTIVE then
		return GetPTranslation("info_popup_detective", { menukey = menukey })

	elseif role == ROLE_MERCENARY then
		return GetPTranslation("info_popup_mercenary", { menukey = menukey })

	elseif role == ROLE_HYPNOTIST then
		local traitors = {}
		for _, ply in pairs(player.GetAll()) do
			if ply:IsTraitor() then
				table.insert(traitors, ply)
			end
		end

		local text
		if #traitors > 0 then
			local traitorlist = ""

			for k, ply in pairs(traitors) do
				if ply ~= LocalPlayer() then
					traitorlist = traitorlist .. string.rep(" ", 42) .. ply:Nick() .. "\n"
				end
			end

			text = GetPTranslation("info_popup_hypnotist",
				{ menukey = menukey, traitorlist = traitorlist })
		else
			text = GetPTranslation("info_popup_hypnotist_alone", { menukey = menukey })
		end

		return text

	elseif role == ROLE_GLITCH then
		return GetPTranslation("info_popup_glitch", { menukey = menukey })

	elseif role == ROLE_JESTER then
		return GetPTranslation("info_popup_jester", { menukey = menukey })

	elseif role == ROLE_PHANTOM then
		return GetPTranslation("info_popup_phantom", { menukey = menukey })

	elseif role == ROLE_ZOMBIE or role == ROLE_VAMPIRE then
		local monsterlabel = "info_popup_"
		if role == ROLE_ZOMBIE then
			monsterlabel = monsterlabel .. "zombie"
		else
			monsterlabel = monsterlabel .. "vampire"
		end

		local monsters = {}
		for _, ply in pairs(player.GetAll()) do
			if ply:IsZombie() or ply:IsVampire() then
				table.insert(monsters, ply)
			end
		end

		local text
		if #monsters > 1 then
			local monsterlist = ""

			for k, ply in pairs(monsters) do
				if ply ~= LocalPlayer() then
					monsterlist = monsterlist .. string.rep(" ", 42) .. ply:Nick() .. "\n"
				end
			end

			text = GetPTranslation(monsterlabel, { menukey = menukey, monsterlist = monsterlist })
		else
			text = GetPTranslation(monsterlabel .. "_alone", { menukey = menukey })
		end

		return text

	elseif role == ROLE_SWAPPER then
		return GetPTranslation("info_popup_swapper", { menukey = menukey })

	elseif role == ROLE_ASSASSIN then
		local traitors = {}
		for _, ply in pairs(player.GetAll()) do
			if ply:IsTraitor() then
				table.insert(traitors, ply)
			end
		end
		local assassintarget = LocalPlayer():GetNWString("AssassinTarget", "")

		local text
		if #traitors > 0 then
			local traitorlist = ""

			for k, ply in pairs(traitors) do
				if ply ~= LocalPlayer() then
					traitorlist = traitorlist .. string.rep(" ", 42) .. ply:Nick() .. "\n"
				end
			end

			text = GetPTranslation("info_popup_assassin",
				{ menukey = menukey, assassintarget = assassintarget, traitorlist = traitorlist })
		else
			text = GetPTranslation("info_popup_assassin_alone", { menukey = menukey, assassintarget = assassintarget })
		end

		return text

	elseif role == ROLE_KILLER then
		return GetPTranslation("info_popup_killer", { menukey = menukey })

	elseif role == ROLE_TRAITOR then
		local traitors = {}
		local hypnotists = {}
		local assassins = {}
		local glitches = {}
		for _, ply in pairs(player.GetAll()) do
			if ply:IsTraitor() then
				table.insert(traitors, ply)
			elseif ply:IsHypnotist() then
				table.insert(traitors, ply)
				table.insert(hypnotists, ply)
			elseif ply:IsAssassin() then
				table.insert(traitors, ply)
				table.insert(assassins, ply)
			elseif ply:IsGlitch() then
				table.insert(traitors, ply)
				table.insert(glitches, ply)
			end
		end

		local text
		if #traitors > 1 then
			local traitorlabel = "info_popup_traitor"
			local traitorlist = ""

			for k, ply in pairs(traitors) do
				if ply ~= LocalPlayer() then
					traitorlist = traitorlist .. string.rep(" ", 42) .. ply:Nick() .. "\n"
				end
			end

			local hypnotistlist = ""
			if #hypnotists > 0 then
				for k, ply in pairs(hypnotists) do
					if ply ~= LocalPlayer() then
						hypnotistlist = hypnotistlist .. string.rep(" ", 42) .. ply:Nick() .. "\n"
					end
				end
				traitorlabel = traitorlabel .. "_hypnotist"
			end

			local assassinlist = ""
			if #assassins > 0 then
				for k, ply in pairs(assassins) do
					if ply ~= LocalPlayer() then
						assassinlist = assassinlist .. string.rep(" ", 42) .. ply:Nick() .. "\n"
					end
				end
				traitorlabel = traitorlabel .. "_assassin"
			end

			if #glitches > 0 then
				traitorlabel = traitorlabel .. "_glitch"
			end

			text = GetPTranslation(traitorlabel, { menukey = menukey, traitorlist = traitorlist, hypnotistlist = hypnotistlist, assassinlist = assassinlist })
		else
			text = GetPTranslation("info_popup_traitor_alone", { menukey = menukey })
		end

		return text
	end
end

local startshowtime = CreateConVar("ttt_startpopup_duration", "17", FCVAR_ARCHIVE)
-- shows info about goal and fellow traitors (if any)
local function RoundStartPopup()
	-- based on Derma_Message

	if startshowtime:GetInt() <= 0 then return end

	if not LocalPlayer() then return end

	local dframe = vgui.Create("Panel")
	dframe:SetDrawOnTop(true)
	dframe:SetMouseInputEnabled(false)
	dframe:SetKeyboardInputEnabled(false)

	local color = Color(0, 0, 0, 200)
	dframe.Paint = function(s)
		draw.RoundedBox(8, 0, 0, s:GetWide(), s:GetTall(), color)
	end

	local text = GetTextForRole(LocalPlayer():GetRole())

	local dtext = vgui.Create("DLabel", dframe)
	dtext:SetFont("TabLarge")
	dtext:SetText(text)
	dtext:SizeToContents()
	dtext:SetContentAlignment(5)
	dtext:SetTextColor(color_white)

	local w, h = dtext:GetSize()
	local m = 10

	dtext:SetPos(m, m)

	dframe:SetSize(w + m * 2, h + m * 2)
	dframe:Center()

	dframe:AlignBottom(10)

	timer.Simple(startshowtime:GetInt(), function() dframe:Remove() end)
end

concommand.Add("ttt_cl_startpopup", RoundStartPopup)

--- Idle message
local function IdlePopup()
	local w, h = 300, 180

	local dframe = vgui.Create("DFrame")
	dframe:SetSize(w, h)
	dframe:Center()
	dframe:SetTitle(GetTranslation("idle_popup_title"))
	dframe:SetVisible(true)
	dframe:SetMouseInputEnabled(true)

	local inner = vgui.Create("DPanel", dframe)
	inner:StretchToParent(5, 25, 5, 45)

	local idle_limit = GetGlobalInt("ttt_idle_limit", 300) or 300

	local text = vgui.Create("DLabel", inner)
	text:SetWrap(true)
	text:SetText(GetPTranslation("idle_popup", { num = idle_limit, helpkey = Key("gm_showhelp", "F1") }))
	text:SetDark(true)
	text:StretchToParent(10, 5, 10, 5)

	local bw, bh = 75, 25
	local cancel = vgui.Create("DButton", dframe)
	cancel:SetPos(10, h - 40)
	cancel:SetSize(bw, bh)
	cancel:SetText(GetTranslation("idle_popup_close"))
	cancel.DoClick = function() dframe:Close() end

	local disable = vgui.Create("DButton", dframe)
	disable:SetPos(w - 185, h - 40)
	disable:SetSize(175, bh)
	disable:SetText(GetTranslation("idle_popup_off"))
	disable.DoClick = function()
		RunConsoleCommand("ttt_spectator_mode", "0")
		dframe:Close()
	end

	dframe:MakePopup()
end

concommand.Add("ttt_cl_idlepopup", IdlePopup)

