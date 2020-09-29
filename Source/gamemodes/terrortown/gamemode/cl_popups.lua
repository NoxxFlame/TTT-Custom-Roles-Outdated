-- Some popup window stuff

local GetTranslation = LANG.GetTranslation
local GetPTranslation = LANG.GetParamTranslation

-- Round start
local function GetTextForLocalPlayer()
    local menukey = Key("+menu_context", "C")

    local client = LocalPlayer()
    if client:IsInnocent() then
        return GetTranslation("info_popup_innocent")

    elseif client:IsDetective() then
        return GetPTranslation("info_popup_detective", { menukey = menukey })

    elseif client:IsMercenary() then
        return GetPTranslation("info_popup_mercenary", { menukey = menukey })

    elseif client:IsGlitch() then
        return GetPTranslation("info_popup_glitch", { menukey = menukey })

    elseif client:IsJester() then
        return GetPTranslation("info_popup_jester", { menukey = menukey })

    elseif client:IsPhantom() then
        return GetPTranslation("info_popup_phantom", { menukey = menukey })

    elseif client:IsMonsterTeam() then
        local monsterlabel = "info_popup_"
        if client:IsZombie() then
            monsterlabel = monsterlabel .. "zombie"
        else
            monsterlabel = monsterlabel .. "vampire"
        end

        local allies = {}
        local glitches = {}
        for _, ply in pairs(player.GetAll()) do
            if ply:IsMonsterTeam() or ply:IsMonsterAlly() then
                table.insert(allies, ply)
            elseif GetGlobalBool("ttt_monsters_are_traitors") and ply:IsGlitch() then
                table.insert(allies, ply)
                table.insert(glitches, ply)
            end
        end

        local text
        if #allies > 1 then
            local allylist = ""
            for _, ply in pairs(allies) do
                if ply ~= client then
                    allylist = allylist .. string.rep(" ", 42) .. ply:Nick() .. "\n"
                end
            end

            if #glitches > 0 then
                monsterlabel = monsterlabel .. "_glitch"
            end

            text = GetPTranslation(monsterlabel, { menukey = menukey, allylist = allylist })
        else
            text = GetPTranslation(monsterlabel .. "_alone", { menukey = menukey })
        end

        return text

    elseif client:IsSwapper() then
        return GetPTranslation("info_popup_swapper", { menukey = menukey })

    elseif client:IsKiller() then
        return GetPTranslation("info_popup_killer", { menukey = menukey })

    elseif client:IsTraitorTeam() then
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
            elseif ply:IsMonsterTeam() and client:IsMonsterAlly() then
                table.insert(traitors, ply)
            end
        end

        local assassintarget = nil
        if client:IsAssassin() then
            assassintarget = string.rep(" ", 42) .. client:GetNWString("AssassinTarget", "")
        end

        local type = (client:IsHypnotist() and "hypnotist") or (client:IsAssassin() and "assassin") or "traitor"
        local text
        if #traitors > 1 then
            local traitorlabel = "info_popup_" .. type
            local traitorlist = ""

            for _, ply in pairs(traitors) do
                if ply ~= client then
                    traitorlist = traitorlist .. string.rep(" ", 42) .. ply:Nick() .. "\n"
                end
            end

            local hypnotistlist = ""
            if #hypnotists > 0 and not client:IsHypnotist() then
                for _, ply in pairs(hypnotists) do
                    if ply ~= client then
                        hypnotistlist = hypnotistlist .. string.rep(" ", 42) .. ply:Nick() .. "\n"
                    end
                end
                traitorlabel = traitorlabel .. "_hypnotist"
            end

            local assassinlist = ""
            if #assassins > 0 and not client:IsAssassin() then
                for _, ply in pairs(assassins) do
                    if ply ~= client then
                        assassinlist = assassinlist .. string.rep(" ", 42) .. ply:Nick() .. "\n"
                    end
                end
                traitorlabel = traitorlabel .. "_assassin"
            end

            if #glitches > 0 then
                traitorlabel = traitorlabel .. "_glitch"
            end

            text = GetPTranslation(traitorlabel, { menukey = menukey, traitorlist = traitorlist, hypnotistlist = hypnotistlist, assassinlist = assassinlist, assassintarget = assassintarget })
        else
            text = GetPTranslation("info_popup_" .. type .. "_alone", { menukey = menukey, assassintarget = assassintarget })
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

    local text = GetTextForLocalPlayer()

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

