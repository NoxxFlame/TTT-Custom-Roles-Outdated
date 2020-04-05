--- Credit transfer tab for equipment menu
local GetTranslation = LANG.GetTranslation
function CreateTransferMenu(parent)
	local dform = vgui.Create("DForm", parent)
	dform:SetName(GetTranslation("xfer_menutitle"))
	dform:StretchToParent(0, 0, 0, 0)
	dform:SetAutoSize(false)

	if LocalPlayer():GetCredits() <= 0 then
		dform:Help(GetTranslation("xfer_no_credits"))
		return dform
	end

	local bw, bh = 100, 20
	local dsubmit = vgui.Create("DButton", dform)
	dsubmit:SetSize(bw, bh)
	dsubmit:SetDisabled(true)
	dsubmit:SetText(GetTranslation("xfer_send"))

	local selected_sid = nil

	local dpick = vgui.Create("DComboBox", dform)
	dpick.OnSelect = function(s, idx, val, data)
		if data then
			selected_sid = data
			dsubmit:SetDisabled(false)
		end
	end

	dpick:SetWide(250)

	-- fill combobox
	local r = LocalPlayer():GetRole()
	for _, p in pairs(player.GetAll()) do
		if IsValid(p) and p ~= LocalPlayer() and
			((
				-- Local player is a traitor team member
				(r == ROLE_TRAITOR or r == ROLE_HYPNOTIST or r == ROLE_ASSASSIN) and
				-- and target is a traitor team member (or a glitch)
				(p:IsActiveRole(ROLE_TRAITOR) or p:IsActiveRole(ROLE_HYPNOTIST) or p:IsActiveRole(ROLE_ASSASSIN) or p:IsActiveRole(ROLE_GLITCH))
			) or
			-- Local player is a zombie and target is a zombie
			(r == ROLE_ZOMBIE and p:IsActiveRole(ROLE_ZOMBIE))) then
			dpick:AddChoice(p:Nick(), p:SteamID())
		end
	end

	-- select first player by default
	if dpick:GetOptionText(1) then dpick:ChooseOptionID(1) end

	dsubmit.DoClick = function(s)
		if selected_sid then
			if player.GetBySteamID(selected_sid):IsActiveRole(ROLE_GLITCH) then
				RunConsoleCommand("ttt_fake_transfer_credits", selected_sid, "1")
			else
				RunConsoleCommand("ttt_transfer_credits", selected_sid, "1")
			end
		end
	end

	dsubmit.Think = function(s)
		if LocalPlayer():GetCredits() < 1 then
			s:SetDisabled(true)
		end
	end

	dform:AddItem(dpick)
	dform:AddItem(dsubmit)

	dform:Help(LANG.GetParamTranslation("xfer_help", { role = LocalPlayer():GetRoleString() }))

	return dform
end