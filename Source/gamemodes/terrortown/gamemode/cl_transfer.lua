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

	local selected_uid = nil

	local dpick = vgui.Create("DComboBox", dform)
	dpick.OnSelect = function(s, idx, val, data)
		if data then
			selected_uid = data
			dsubmit:SetDisabled(false)
		end
	end

	dpick:SetWide(250)

    -- fill combobox
    local ply = LocalPlayer()
	for _, p in pairs(player.GetAll()) do
		if IsValid(p) and p ~= ply and
			((
				-- Local player is a traitor team member
				ply:IsTraitorTeam() and
				-- and target is a traitor team member (or a glitch). Also include monsters if Monsters-as-Traitors is enabled
				(p:IsTraitorTeam() or p:IsActiveGlitch() or (ply:IsMonsterAlly() and p:IsMonsterTeam()))
			) or
            (
                -- Local player is a monster and target is a monster or an ally if Monsters-as-Traitors is enabled
                ply:IsMonsterTeam() and (p:IsMonsterTeam() or (GetGlobalBool("ttt_monsters_are_traitors") and (p:IsTraitorTeam() or p:IsActiveGlitch())))
            )) then
			dpick:AddChoice(p:Nick(), p:UniqueID())
		end
	end

	-- select first player by default
	if dpick:GetOptionText(1) then dpick:ChooseOptionID(1) end

	dsubmit.DoClick = function(s)
		if selected_uid then
			if player.GetByUniqueID(selected_uid):IsActiveGlitch() then
				RunConsoleCommand("ttt_fake_transfer_credits", selected_uid, "1")
			else
				RunConsoleCommand("ttt_transfer_credits", selected_uid, "1")
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