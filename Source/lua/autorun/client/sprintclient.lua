-- Request ConVars (SERVER)
local function ConVars()
    net.Start("SprintGetConVars")
    net.SendToServer()
end

-- Set default Values
local multiplier = 0.4
local crosshair = 1
local regenerateI = 0.08
local regenerateT = 0.12
local consumption = 0.3
local enabled = false
local realPercent = 100
local sprinting = false
local lastReleased = -1000
local doubleTapActivated = false
local crosshairSize = 1
local timerCon = CurTime()
local timerReg = CurTime()

-- Receive ConVars (SERVER)
net.Receive("SprintGetConVars", function()
    local table = net.ReadTable()

    multiplier = table[1]
    crosshair = table[2]
    regenerateI = table[3]
    regenerateT = table[4]
    consumption = table[5]
    enabled = table[6]
end)

-- Client ConVars
local activateKey = CreateClientConVar("ttt_sprint_activate_key", "1", true, false, "The key used to sprint. (0 = Use; 1 = Shift; 2 = Control; 3 = Custom) Def: 1")
local customActivateKey = CreateClientConVar("ttt_sprint_activate_key_custom", "32", true, false, "The custom key used to sprint if ttt_sprint_activate_key = 3. It has to be a Number. (Example: 32 = V Key) Def: 32 Key Numbers: https://wiki.garrysmod.com/page/Enums/KEY")
local doubleTapEnabled = CreateClientConVar("ttt_sprint_doubletapenabled", "0", true, false, "If double tapping forward causes the player to sprint. Def: 0")
local doubleTapTime = CreateClientConVar("ttt_sprint_doubletaptime", "0.25", true, false, "The time you have for double tapping. (0.001-1) Def: 0.25")
local crosshairDebugSize = CreateClientConVar("ttt_sprint_crosshairdebugsize", "1", true, false, "The size of the crosshair used to prevent no crosshair while not sprinting. (Disabled = 0) Def:1")

-- Requesting ConVars first time
ConVars()

-- Change the Speed
local function SpeedChange(startSprint)
    sprinting = startSprint
    net.Start("SprintSpeedset")

    local ply = LocalPlayer()
    if sprinting then
        local value = math.min(math.max(multiplier, 0.1), 2)
        net.WriteFloat(value)

        ply.mult = value + 1
    else
        net.WriteFloat(0)

        ply.mult = nil
    end

    net.SendToServer()

    if crosshair then -- Enlarge Crosshair
        if sprinting then
            local tmp = GetConVar("ttt_crosshair_size")
            crosshairSize = tmp and tmp:GetString() or 1
            RunConsoleCommand("ttt_crosshair_size", "2")
        else
            if crosshairSize == "0" then
                crosshairSize = crosshairDebugSize:GetFloat()
            end
            RunConsoleCommand("ttt_crosshair_size", crosshairSize)
        end
    end
end

-- returns the selected sprint key
function SprintKey()
    if activateKey:GetFloat() == 0 then
        return LocalPlayer():KeyDown(IN_USE)
    elseif activateKey:GetFloat() == 1 then
        return input.IsKeyDown(KEY_LSHIFT)
    elseif activateKey:GetFloat() == 2 then
        return input.IsKeyDown(KEY_LCONTROL)
    elseif activateKey:GetFloat() == 3 then
        return input.IsKeyDown(customActivateKey:GetFloat())
    end

    return false
end

-- Sprint activated (sprint if there is stamina)
local function SprintFunction()
    if realPercent > 0 then
        if not sprinting then
            SpeedChange(true)
            timerCon = CurTime()
        end

        realPercent = realPercent - (CurTime() - timerCon) * (math.min(math.max(consumption, 0.1), 5) * 250)
        timerCon = CurTime()
    else
        if sprinting then
            SpeedChange(false)
        end
    end
end

-- listen for sprinting
hook.Add("TTTPrepareRound", "TTTSprint4TTTPrepareRound", function()
    -- reset every round
    realPercent = 100
    hook.Remove("Think", "TTTSprint4Think")

    ConVars()

    -- listen for activation
    hook.Add("Think", "TTTSprint4Think", function()
        if not enabled then return end
        local client = LocalPlayer()

        if client:KeyReleased(IN_FORWARD) and doubleTapEnabled:GetBool() then
            -- Double tap
            lastReleased = CurTime()
        end

        if doubleTapEnabled:GetBool() and client:KeyDown(IN_FORWARD) and (lastReleased + math.min(math.max(doubleTapTime:GetFloat(), 0.001), 1) >= CurTime() or doubleTapActivated) then
            SprintFunction()

            doubleTapActivated = true
            timerReg = CurTime()
        elseif client:KeyDown(IN_FORWARD) and SprintKey() then
            -- forward + selected key
            SprintFunction()

            doubleTapActivated = false
            timerReg = CurTime()
        else
            if sprinting then -- not sprinting
                SpeedChange(false)
                doubleTapActivated = false
                timerReg = CurTime()
            end

            if GetRoundState() ~= ROUND_WAIT then
                if IsValid(client) and client:IsPlayer() and (client:IsTraitorTeam() or client:IsMonsterTeam() or client:IsKiller()) then
                    realPercent = realPercent + (CurTime() - timerReg) * (math.min(math.max(regenerateT, 0.01), 2) * 250)
                else
                    realPercent = realPercent + (CurTime() - timerReg) * (math.min(math.max(regenerateI, 0.01), 2) * 250)
                end
            end

            timerReg = CurTime()
            doubleTapActivated = false
        end

        if realPercent < 0 then -- prevent bugs
            realPercent = 0
            SpeedChange(false)
            doubleTapActivated = false
            timerReg = CurTime()
        elseif realPercent > 100 then
            realPercent = 100
        end
        if IsValid(client) and client:IsPlayer() then
            client:SetNWFloat("sprintMeter", realPercent)
        end
    end)
end)

-- Set Sprint Speed
hook.Add("TTTPlayerSpeedModifier", "TTTSprint4TTTPlayerSpeed", function(ply, _, _)
    return GetSprintMultiplier(ply, enabled)
end)

-- Add configuration tab
hook.Add("TTTSettingsTabs", "TTTSprint4TTTSettingsTabs", function(dtabs)
    if not enabled then return end

    local settingsPanel = vgui.Create("DPanelList", dtabs)
    settingsPanel:StretchToParent(0, 0, dtabs:GetPadding() * 2, 0)
    settingsPanel:EnableVerticalScrollbar(true)
    settingsPanel:SetPadding(10)
    settingsPanel:SetSpacing(10)

    dtabs:AddSheet("Sprint", settingsPanel, "icon16/arrow_up.png", false, false, "The sprint settings")

    local addonList = vgui.Create("DIconLayout", settingsPanel)
    addonList:SetSpaceX(5)
    addonList:SetSpaceY(5)
    addonList:Dock(FILL)
    addonList:DockMargin(5, 5, 5, 5)
    addonList:DockPadding(10, 10, 10, 10)

    -- General Settings
    local generalSettings = vgui.Create("DForm")
    generalSettings:SetSpacing(10)
    generalSettings:SetName("General settings")
    generalSettings:SetWide(settingsPanel:GetWide() - 30)

    settingsPanel:AddItem(generalSettings)

    generalSettings:NumSlider("Crosshair debug size (0 = off)", "ttt_sprint_crosshairdebugsize", 0, 3, 1)

    -- Controls (Activation Method)
    local sprintTab = vgui.Create("DForm")
    sprintTab:SetSpacing(10)
    sprintTab:SetName("Controls")
    sprintTab:SetWide(settingsPanel:GetWide() - 30)
    settingsPanel:AddItem(sprintTab)

    local settingsText = vgui.Create("DLabel", generalSettings)
    settingsText:SetText("Activation method:")
    settingsText:SetColor(Color(0, 0, 0))
    sprintTab:AddItem(settingsText)

    -- Selection
    local keyBox = vgui.Create("DComboBox")

    local keySelected
    local function Selection()
        if activateKey:GetFloat() == 0 then
            keySelected = "Use Key"
        elseif activateKey:GetFloat() == 1 then
            keySelected = "Shift Key"
        elseif activateKey:GetFloat() == 2 then
            keySelected = "Control Key"
        elseif activateKey:GetFloat() == 3 then
            keySelected = "Custom Key"
        elseif activateKey:GetFloat() == 4 then
            keySelected = "Double tap"
        else
            keySelected = " "
        end
    end

    -- Extra Options/Information
    local function KeySettingExtra()
        if keySelected == "Custom Key" then
            sprintTab:TextEntry("Key Number:", "ttt_sprint_activate_key_custom")

            local link = vgui.Create("DLabelURL")
            link:SetText("Key Numbers: https://wiki.garrysmod.com/page/Enums/KEY")
            link:SetURL("https://wiki.garrysmod.com/page/Enums/KEY")

            sprintTab:AddItem(link)
        elseif keySelected == "Double tap" then
            sprintTab:NumSlider("Double tap time", "ttt_sprint_doubletaptime", 0.001, 1, 2)
        end
    end

    -- functions to refresh more easy
    local function ComboBox()
        sprintTab:AddItem(settingsText)

        keyBox:Clear()
        keyBox:SetValue(keySelected)
        keyBox:AddChoice("Use Key")
        keyBox:AddChoice("Shift Key")
        keyBox:AddChoice("Control Key")
        keyBox:AddChoice("Custom Key")
        keyBox:AddChoice("Double tap")

        sprintTab:AddItem(keyBox)
    end

    function keyBox:OnSelect(index, value, data)
        if value == "Use Key" then
            RunConsoleCommand("ttt_sprint_activate_key", "0")
        elseif value == "Shift Key" then
            RunConsoleCommand("ttt_sprint_activate_key", "1")
        elseif value == "Control Key" then
            RunConsoleCommand("ttt_sprint_activate_key", "2")
        elseif value == "Custom Key" then
            RunConsoleCommand("ttt_sprint_activate_key", "3")
        elseif value == "Double tap" then
            RunConsoleCommand("ttt_sprint_activate_key", "4")
        end

        sprintTab:Clear()

        keySelected = value

        ComboBox()
        KeySettingExtra()
    end

    Selection()
    ComboBox()
    KeySettingExtra()
end)
