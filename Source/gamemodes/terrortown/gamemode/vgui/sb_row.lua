-- Scoreboard player score row, based on sandbox version

include("sb_info.lua")

local GetTranslation = LANG.GetTranslation
local GetPTranslation = LANG.GetParamTranslation

SB_ROW_HEIGHT = 24 --16

local PANEL = {}

function PANEL:Init()
    -- cannot create info card until player state is known
    self.info = nil

    self.open = false

    self.cols = {}
    self:AddColumn(GetTranslation("sb_ping"), function(ply) return ply:Ping() end)

    local beta = GetGlobalBool("ttt_karma_beta", false)

    if KARMA.IsEnabled() then
        if beta then
            self:AddColumn(GetTranslation("sb_karma"), function(ply)
                local dmgpct = math.Round(math.Clamp(-0.0000005 * ply:GetBaseKarma() ^ 2 + 0.0015 * ply:GetBaseKarma(), 0.1, 1.0) * 100)
                return dmgpct .. "%"
            end)
        else
            self:AddColumn(GetTranslation("sb_karma"), function(ply) return math.Round(ply:GetBaseKarma()) end)
        end
    end

    if DRINKS.IsEnabled() then
        self:AddColumn(GetTranslation("sb_drinks"), function(ply) return math.Round(ply:GetBaseDrinks()) end)
        self:AddColumn(GetTranslation("sb_shots"), function(ply) return math.Round(ply:GetBaseShots()) end)
    end

    -- Let hooks add their custom columns
    hook.Call("TTTScoreboardColumns", nil, self)

    for _, c in ipairs(self.cols) do
        c:SetMouseInputEnabled(false)
    end

    self.tag = vgui.Create("DLabel", self)
    self.tag:SetText("")
    self.tag:SetMouseInputEnabled(false)

    self.sresult = vgui.Create("DImage", self)
    self.sresult:SetSize(16, 16)
    self.sresult:SetMouseInputEnabled(false)

    self.avatar = vgui.Create("AvatarImage", self)
    self.avatar:SetSize(SB_ROW_HEIGHT, SB_ROW_HEIGHT)
    self.avatar:SetMouseInputEnabled(false)

    self.nick = vgui.Create("DLabel", self)
    self.nick:SetMouseInputEnabled(false)

    self.voice = vgui.Create("DImageButton", self)
    self.voice:SetSize(16, 16)

    self:SetCursor("hand")
end

function PANEL:AddColumn(label, func, width, _, _)
    local lbl = vgui.Create("DLabel", self)
    lbl.GetPlayerText = func
    lbl.IsHeading = false
    lbl.Width = width or 50 -- Retain compatibility with existing code

    table.insert(self.cols, lbl)
    return lbl
end

-- Mirror sb_main, of which it and this file both call using the
--    TTTScoreboardColumns hook, but it is useless in this file
-- Exists only so the hook wont return an error if it tries to
--    use the AddFakeColumn function of `sb_main`, which would
--    cause this file to raise a `function not found` error or others
function PANEL:AddFakeColumn() end

local namecolor = {
    default = COLOR_WHITE,
    admin = Color(220, 180, 0, 255),
    dev = Color(100, 240, 105, 255)
}

local rolecolor = {
    default = Color(0, 0, 0, 0),
    detective = Color(0, 0, 255, 30),
    traitor = Color(200, 0, 0, 30),
    innocent = Color(100, 255, 25, 30),
    glitch = Color(255, 128, 0, 30),
    mercenary = Color(255, 255, 0, 30),
    jester = Color(180, 0, 255, 30),
    hypnotist = Color(255, 100, 255, 30),
    phantom = Color(82, 226, 255, 30),
    zombie = Color(69, 97, 0, 30),
    vampire = Color(70, 70, 70, 30),
    swapper = Color(111, 0, 255, 30),
    assassin = Color(112, 50, 0, 30),
    killer = Color(60, 0, 80, 30)
}

function GM:TTTScoreboardColorForPlayer(ply)
    if not IsValid(ply) then return namecolor.default end

    if ply:SteamID() == "STEAM_0:0:1963640" then
        return namecolor.dev
    elseif ply:IsAdmin() and GetGlobalBool("ttt_highlight_admins", true) then
        return namecolor.admin
    end
    return namecolor.default
end

local function GetTraitorTeamColor(ply)
    if ply:IsHypnotist() then
        return rolecolor.hypnotist
    elseif ply:IsJesterTeam() then
        return rolecolor.jester
    elseif ply:IsAssassin() then
        return rolecolor.assassin
    else
        return rolecolor.traitor
    end
end

local function GetMonsterTeamColor(ply)
    if ply:IsZombie() then
        return rolecolor.zombie
    elseif ply:IsVampire() then
        return rolecolor.vampire
    end
end

function GM:TTTScoreboardRowColorForPlayer(ply)
    if not IsValid(ply) or GetRoundState() == ROUND_WAIT or GetRoundState() == ROUND_PREP then return rolecolor.default end

    if (ScoreGroup(ply) == GROUP_SEARCHED and ply.search_result) or ply == LocalPlayer() or (ply:GetNWBool('RoleRevealed', false) and LocalPlayer():IsRole(ROLE_DETECTIVE)) then
        if ply:IsTraitor() then
            return rolecolor.traitor
        elseif ply:IsDetective() then
            return rolecolor.detective
        elseif ply:IsGlitch() then
            return rolecolor.glitch
        elseif ply:IsMercenary() then
            return rolecolor.mercenary
        elseif ply:IsJester() then
            return rolecolor.jester
        elseif ply:IsHypnotist() then
            return rolecolor.hypnotist
        elseif ply:IsZombie() then
            return rolecolor.zombie
        elseif ply:IsVampire() then
            return rolecolor.vampire
        elseif ply:IsSwapper() then
            return rolecolor.swapper
        elseif ply:IsAssassin() then
            return rolecolor.assassin
        elseif ply:IsPhantom() then
            return rolecolor.phantom
        elseif ply:IsKiller() then
            return rolecolor.killer
        else
            return rolecolor.innocent
        end
    end

    if ply:IsDetective() then
        return rolecolor.detective
    end

    local client = LocalPlayer()
    if client:IsTraitorTeam() then
        if ply:IsTraitorTeam() or ply:IsGlitch() then
            return GetTraitorTeamColor(ply)
        elseif ply:IsJesterTeam() then
            return rolecolor.jester
        -- If Monsters-as-Traitors is enabled and the target is a Monster, show their colors
        elseif client:IsMonsterAlly() and ply:IsMonsterTeam() then
            return GetMonsterTeamColor(ply)
        end
    elseif client:IsMonsterTeam() then
        if ply:IsMonsterTeam() then
            return GetMonsterTeamColor(ply)
        elseif ply:IsJesterTeam() then
            return rolecolor.jester
        -- Since Zombie and Vampire were already handled above, this will only cover the traitor team and only if Monsters-as-Traitors is enabled
        elseif GetGlobalBool("ttt_monsters_are_traitors") and (ply:IsTraitorTeam() or ply:IsGlitch()) then
            return GetTraitorTeamColor(ply)
        end
    elseif client:IsKiller() then
        if ply:IsJesterTeam() then
            return rolecolor.jester
        end
    end

    return rolecolor.default
end

local function ColorForPlayer(ply)
    if IsValid(ply) then
        local c = hook.Call("TTTScoreboardColorForPlayer", GAMEMODE, ply)

        -- verify that we got a proper color
        if c and type(c) == "table" and c.r and c.b and c.g and c.a then
            return c
        else
            ErrorNoHalt("TTTScoreboardColorForPlayer hook returned something that isn't a color!\n")
        end
    end
    return namecolor.default
end

function PANEL:Paint(width, height)
    if not IsValid(self.Player) then return end

    --   if ( self.Player:GetFriendStatus() == "friend" ) then
    --      color = Color( 236, 181, 113, 255 )
    --   end

    local ply = self.Player

    local c = hook.Call("TTTScoreboardRowColorForPlayer", GAMEMODE, ply)

    surface.SetDrawColor(c)
    surface.DrawRect(0, 0, width, SB_ROW_HEIGHT)

    local rolestr = ""

    if c == rolecolor.innocent then
        rolestr = "inn"
    elseif c == rolecolor.detective then
        rolestr = "det"
    elseif c == rolecolor.mercenary then
        rolestr = "mer"
    elseif c == rolecolor.glitch then
        rolestr = "gli"
    elseif c == rolecolor.phantom then
        rolestr = "pha"
    elseif c == rolecolor.traitor then
        rolestr = "tra"
    elseif c == rolecolor.hypnotist then
        rolestr = "hyp"
    elseif c == rolecolor.vampire then
        rolestr = "vam"
    elseif c == rolecolor.assassin then
        rolestr = "ass"
    elseif c == rolecolor.zombie then
        rolestr = "zom"
    elseif c == rolecolor.jester then
        rolestr = "jes"
    elseif c == rolecolor.swapper then
        rolestr = "swa"
    elseif c == rolecolor.killer then
        rolestr = "kil"
    end

    if rolestr ~= "" then
        if ConVarExists("ttt_role_symbols") then
            symbols = GetConVar("ttt_role_symbols"):GetBool()
        end

        local symorlet = "let"
        if symbols then
            symorlet = "sym"
        end

        self.sresult:SetImage("vgui/ttt/tab_" .. symorlet .. "_" .. rolestr .. ".png")
        self.sresult:SetVisible(true)
    else
        self.sresult:SetVisible(false)
    end

    if ply:Nick() == LocalPlayer():GetNWString("AssassinTarget", "") and GetRoundState() == ROUND_ACTIVE then
        surface.SetDrawColor(200, 90, 0, math.Round(math.sin(RealTime() * 8) / 2 + 0.5) * 20)
        surface.DrawRect(0, 0, width, SB_ROW_HEIGHT)
        surface.SetDrawColor(112, 50, 0, 255)
        surface.DrawOutlinedRect(SB_ROW_HEIGHT, 0, width - SB_ROW_HEIGHT, SB_ROW_HEIGHT)
        surface.DrawOutlinedRect(1 + SB_ROW_HEIGHT, 1, width - 2 - SB_ROW_HEIGHT, SB_ROW_HEIGHT - 2)
    end

    if ply == LocalPlayer() then
        surface.SetDrawColor(200, 200, 200, math.Clamp(math.sin(RealTime() * 2) * 50, 0, 100))
        surface.DrawRect(0, 0, width, SB_ROW_HEIGHT)
    end

    return true
end

function PANEL:SetPlayer(ply)
    self.Player = ply
    self.avatar:SetPlayer(ply)

    if not self.info then
        local g = ScoreGroup(ply)
        if g == GROUP_TERROR and ply ~= LocalPlayer() then
            self.info = vgui.Create("TTTScorePlayerInfoTags", self)
            self.info:SetPlayer(ply)

            self:InvalidateLayout()
        elseif g == GROUP_SEARCHED or g == GROUP_NOTFOUND then
            self.info = vgui.Create("TTTScorePlayerInfoSearch", self)
            self.info:SetPlayer(ply)
            self:InvalidateLayout()
        end
    else
        self.info:SetPlayer(ply)

        self:InvalidateLayout()
    end

    self.voice.DoClick = function()
        if IsValid(ply) and ply ~= LocalPlayer() then
            ply:SetMuted(not ply:IsMuted())
        end
    end

    self:UpdatePlayerData()
end

function PANEL:GetPlayer() return self.Player end

function PANEL:UpdatePlayerData()
    if not IsValid(self.Player) then return end

    local ply = self.Player
    for i = 1, #self.cols do
        -- Set text from function, passing the label along so stuff like text
        -- color can be changed
        self.cols[i]:SetText(self.cols[i].GetPlayerText(ply, self.cols[i]))
    end

    self.nick:SetText(ply:Nick())
    if ply:Nick() == LocalPlayer():GetNWString("AssassinTarget", "") and GetRoundState() == ROUND_ACTIVE then
        self.nick:SetText(ply:Nick() .. " (TARGET)")
    elseif (LocalPlayer():GetTraitor() or LocalPlayer():GetHypnotist()) and GetRoundState() == ROUND_ACTIVE then
        for k, v in pairs(player.GetAll()) do
            if ply:Nick() == v:GetNWString("AssassinTarget", "") then
                self.nick:SetText(ply:Nick() .. " (" .. v:Nick() .. "'s Target)")
            end
        end
    end

    self.nick:SizeToContents()
    self.nick:SetTextColor(ColorForPlayer(ply))

    local ptag = ply.sb_tag
    if ScoreGroup(ply) ~= GROUP_TERROR then
        ptag = nil
    end

    self.tag:SetText(ptag and GetTranslation(ptag.txt) or "")
    self.tag:SetTextColor(ptag and ptag.color or COLOR_WHITE)

    -- cols are likely to need re-centering
    self:LayoutColumns()

    if self.info then
        self.info:UpdatePlayerData()
    end

    if self.Player ~= LocalPlayer() then
        local muted = self.Player:IsMuted()
        self.voice:SetImage(muted and "icon16/sound_mute.png" or "icon16/sound.png")
    else
        self.voice:Hide()
    end
end

function PANEL:ApplySchemeSettings()
    for k, v in pairs(self.cols) do
        v:SetFont("treb_small")
        v:SetTextColor(COLOR_WHITE)
    end

    self.nick:SetFont("treb_small")
    self.nick:SetTextColor(ColorForPlayer(self.Player))

    local ptag = self.Player and self.Player.sb_tag
    self.tag:SetTextColor(ptag and ptag.color or COLOR_WHITE)
    self.tag:SetFont("treb_small")
end

function PANEL:LayoutColumns()
    local cx = self:GetWide()
    for k, v in ipairs(self.cols) do
        v:SizeToContents()
        cx = cx - v.Width
        v:SetPos(cx - v:GetWide() / 2, (SB_ROW_HEIGHT - v:GetTall()) / 2)
    end

    self.tag:SizeToContents()
    cx = cx - 90
    self.tag:SetPos(cx - self.tag:GetWide() / 2, (SB_ROW_HEIGHT - self.tag:GetTall()) / 2)

    self.sresult:SetPos(cx - 8, (SB_ROW_HEIGHT - 16) / 2)
end

function PANEL:PerformLayout()
    self.avatar:SetPos(0, 0)
    self.avatar:SetSize(SB_ROW_HEIGHT, SB_ROW_HEIGHT)

    local fw = sboard_panel.ply_frame:GetWide()
    self:SetWide(sboard_panel.ply_frame.scroll.Enabled and fw - 16 or fw)

    if not self.open then
        self:SetSize(self:GetWide(), SB_ROW_HEIGHT)

        if self.info then self.info:SetVisible(false) end
    elseif self.info then
        self:SetSize(self:GetWide(), 100 + SB_ROW_HEIGHT)

        self.info:SetVisible(true)
        self.info:SetPos(5, SB_ROW_HEIGHT + 5)
        self.info:SetSize(self:GetWide(), 100)
        self.info:PerformLayout()

        self:SetSize(self:GetWide(), SB_ROW_HEIGHT + self.info:GetTall())
    end

    self.nick:SizeToContents()

    self.nick:SetPos(SB_ROW_HEIGHT + 10, (SB_ROW_HEIGHT - self.nick:GetTall()) / 2)

    self:LayoutColumns()

    self.voice:SetVisible(not self.open)
    self.voice:SetSize(16, 16)
    self.voice:DockMargin(4, 4, 4, 4)
    self.voice:Dock(RIGHT)
end

function PANEL:DoClick(x, y)
    self:SetOpen(not self.open)
end

function PANEL:SetOpen(o)
    if self.open then
        surface.PlaySound("ui/buttonclickrelease.wav")
    else
        surface.PlaySound("ui/buttonclick.wav")
    end

    self.open = o

    self:PerformLayout()
    self:GetParent():PerformLayout()
    sboard_panel:PerformLayout()
end

function PANEL:DoRightClick()
    local menu = DermaMenu()
    menu.Player = self:GetPlayer()

    local close = hook.Call("TTTScoreboardMenu", nil, menu)
    if close then menu:Remove() return end

    menu:Open()
end

vgui.Register("TTTScorePlayerRow", PANEL, "DButton")