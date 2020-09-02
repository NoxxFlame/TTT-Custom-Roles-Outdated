-- Traitor equipment menu
local GetTranslation = LANG.GetTranslation
local GetPTranslation = LANG.GetParamTranslation

-- create ClientConVars
local numColsVar = CreateClientConVar("ttt_bem_cols", 4, true, false, "Sets the number of columns in the Traitor/Detective menu's item list.")
local numRowsVar = CreateClientConVar("ttt_bem_rows", 5, true, false, "Sets the number of rows in the Traitor/Detective menu's item list.")
local itemSizeVar = CreateClientConVar("ttt_bem_size", 64, true, false, "Sets the item size in the Traitor/Detective menu's item list.")
local showCustomVar = CreateClientConVar("ttt_bem_marker_custom", 1, true, false, "Should custom items get a marker?")
local showFavoriteVar = CreateClientConVar("ttt_bem_marker_fav", 1, true, false, "Should favorite items get a marker?")
local showSlotVar = CreateClientConVar("ttt_bem_marker_slot", 1, true, false, "Should items get a slot-marker?")

-- get serverside ConVars
local allowChangeVar = GetConVar("ttt_bem_allow_change")
local serverColsVar = GetConVar("ttt_bem_sv_cols")
local serverRowsVar = GetConVar("ttt_bem_sv_rows")
local serverSizeVar = GetConVar("ttt_bem_sv_size")

-- add favorites DB functions
include("favorites_db.lua")

include("shared.lua")

-- Buyable weapons are loaded automatically. Buyable items are defined in
-- equip_items_shd.luaslotnumber

local BuyableWeapons = {
    [ROLE_DETECTIVE] = {},
    [ROLE_MERCENARY] = {},
    [ROLE_VAMPIRE] = {},
    [ROLE_ZOMBIE] = {},
    [ROLE_TRAITOR] = {},
    [ROLE_ASSASSIN] = {},
    [ROLE_HYPNOTIST] = {},
    [ROLE_KILLER] = {}
}

net.Receive("TTT_BuyableWeapon_Detective", function()
    for _, v in pairs(net.ReadTable()) do
        if not table.HasValue(BuyableWeapons[ROLE_DETECTIVE], v) then
            table.insert(BuyableWeapons[ROLE_DETECTIVE], v)
        end
    end
end)
net.Receive("TTT_BuyableWeapon_Mercenary", function()
    for _, v in pairs(net.ReadTable()) do
        if not table.HasValue(BuyableWeapons[ROLE_MERCENARY], v) then
            table.insert(BuyableWeapons[ROLE_MERCENARY], v)
        end
    end
end)
net.Receive("TTT_BuyableWeapon_Vampire", function()
    for _, v in pairs(net.ReadTable()) do
        if not table.HasValue(BuyableWeapons[ROLE_VAMPIRE], v) then
            table.insert(BuyableWeapons[ROLE_VAMPIRE], v)
        end
    end
end)
net.Receive("TTT_BuyableWeapon_Zombie", function()
    for _, v in pairs(net.ReadTable()) do
        if not table.HasValue(BuyableWeapons[ROLE_ZOMBIE], v) then
            table.insert(BuyableWeapons[ROLE_ZOMBIE], v)
        end
    end
end)
net.Receive("TTT_BuyableWeapon_Traitor", function()
    for _, v in pairs(net.ReadTable()) do
        if not table.HasValue(BuyableWeapons[ROLE_TRAITOR], v) then
            table.insert(BuyableWeapons[ROLE_TRAITOR], v)
        end
    end
end)
net.Receive("TTT_BuyableWeapon_Assassin", function()
    for _, v in pairs(net.ReadTable()) do
        if not table.HasValue(BuyableWeapons[ROLE_ASSASSIN], v) then
            table.insert(BuyableWeapons[ROLE_ASSASSIN], v)
        end
    end
end)
net.Receive("TTT_BuyableWeapon_Hypnotist", function()
    for _, v in pairs(net.ReadTable()) do
        if not table.HasValue(BuyableWeapons[ROLE_HYPNOTIST], v) then
            table.insert(BuyableWeapons[ROLE_HYPNOTIST], v)
        end
    end
end)
net.Receive("TTT_BuyableWeapon_Killer", function()
    for _, v in pairs(net.ReadTable()) do
        if not table.HasValue(BuyableWeapons[ROLE_KILLER], v) then
            table.insert(BuyableWeapons[ROLE_KILLER], v)
        end
    end
end)

local Equipment = { }
function GetEquipmentForRole(role)
    local mercmode = GetGlobalInt("ttt_shop_merc_mode")

    -- Prime traitor and detective lists to make sure the sync works
    if (mercmode > 0 and role == ROLE_MERCENARY) or
        (GetGlobalBool("ttt_shop_assassin_sync") and role == ROLE_ASSASSIN) or
        (GetGlobalBool("ttt_shop_hypnotist_sync") and role == ROLE_HYPNOTIST) then
        if not Equipment[ROLE_TRAITOR] then
            GetEquipmentForRole(ROLE_TRAITOR)
        end
    end
    if mercmode > 0 and role == ROLE_MERCENARY then
        if not Equipment[ROLE_DETECTIVE] then
            GetEquipmentForRole(ROLE_DETECTIVE)
        end
    end

    -- Cache the equipment
    if not Equipment[role] then
        -- start with all the non-weapon goodies
        local tbl = table.Copy(EquipmentItems)

        -- find buyable weapons to load info from
        for _, v in pairs(weapons.GetList()) do
            if v and v.CanBuy then
                local id = WEPS.GetClass(v)
                local roletable = BuyableWeapons[role] or {}
                -- Make sure each of the buyable weapons is in the role's equipment list
                -- If this logic or the list of roles who can buy is changed, it must also be updated in weaponry.lua and cl_equip.lua
                if not table.HasValue(v.CanBuy, role) and table.HasValue(roletable, id) then
                    table.insert(v.CanBuy, role)
                end

                -- If the player is a mercenary
                if mercmode > 0 and role == ROLE_MERCENARY then
                    -- Traitor OR Detective or Detective only modes
                    if mercmode == 1 or mercmode == 3 then
                        -- and they can't already buy this weapon
                        if not table.HasValue(v.CanBuy, role) and
                            -- and detectives CAN buy this weapon, let the mercenary buy it too
                            table.HasValue(v.CanBuy, ROLE_DETECTIVE) then
                            table.insert(v.CanBuy, role)
                        end
                    end

                    -- Traitor OR Detective or Traitor only modes
                    if mercmode == 1 or mercmode == 4 then
                        -- and they can't already buy this weapon
                        if not table.HasValue(v.CanBuy, role) and
                            -- and traitors CAN buy this weapon, let the mercenary buy it too
                            table.HasValue(v.CanBuy, ROLE_TRAITOR) then
                            table.insert(v.CanBuy, role)
                        end
                    end

                    -- Traitor AND Detective
                    if mercmode == 2 then
                        -- and they can't already buy this weapon
                        if not table.HasValue(v.CanBuy, role) and
                            -- and detectives AND traitors CAN buy this weapon, let the mercenary buy it too
                            table.HasValue(v.CanBuy, ROLE_DETECTIVE) and table.HasValue(v.CanBuy, ROLE_TRAITOR) then
                            table.insert(v.CanBuy, role)
                        end
                    end
                end

                -- If the player is a non-vanilla traitor and they should have all weapons that vanilla traitors have
                if ((GetGlobalBool("ttt_shop_assassin_sync") and role == ROLE_ASSASSIN) or (GetGlobalBool("ttt_shop_hypnotist_sync") and role == ROLE_HYPNOTIST)) and
                    -- and they can't already buy this weapon
                    not table.HasValue(v.CanBuy, role) and
                    -- and vanilla traitors CAN buy this weapon, let this player buy it too
                    table.HasValue(v.CanBuy, ROLE_TRAITOR) then
                    table.insert(v.CanBuy, role)
                end

                local data = v.EquipMenuData or {}
                local base = {
                    id = id,
                    name = v.PrintName or "Unnamed",
                    limited = v.LimitedStock,
                    kind = v.Kind or WEAPON_NONE,
                    slot = (v.Slot or 0) + 1,
                    material = v.Icon or "vgui/ttt/icon_id",
                    -- the below should be specified in EquipMenuData, in which case
                    -- these values are overwritten
                    type = "Type not specified",
                    model = "models/weapons/w_bugbait.mdl",
                    desc = "No description specified."
                };

                -- Force material to nil so that model key is used when we are
                -- explicitly told to do so (ie. material is false rather than nil).
                if data.modelicon then
                    base.material = nil
                end

                table.Merge(base, data)

                -- add this buyable weapon to all relevant equipment tables
                for _, r in pairs(v.CanBuy) do
                    table.insert(tbl[r], base)
                end
            end
        end

        -- mark custom items
        for r, is in pairs(tbl) do
            for _, i in pairs(is) do
                if i and i.id then
                    i.custom = not table.HasValue(DefaultEquipment[r], i.id)
                end
            end
        end

        Equipment[role] = tbl[role]
    end

    return Equipment and Equipment[role] or {}
end

local function ItemIsWeapon(item) return not tonumber(item.id) end

local function CanCarryWeapon(item) return LocalPlayer():CanCarryType(item.kind) end

local color_bad = Color(244, 67, 54, 255)

-- Creates tabel of labels showing the status of ordering prerequisites
local function PreqLabels(parent, x, y)
    local tbl = {}

    tbl.credits = vgui.Create("DLabel", parent)
    --tbl.credits:SetTooltip(GetTranslation("equip_help_cost"))
    tbl.credits:SetPos(x, y)
    -- coins icon
    tbl.credits.img = vgui.Create("DImage", parent)
    tbl.credits.img:SetSize(32, 32)
    tbl.credits.img:CopyPos(tbl.credits)
    tbl.credits.img:MoveLeftOf(tbl.credits)
    tbl.credits.img:SetImage("vgui/ttt/equip/coin.png")

    -- remaining credits text
    tbl.credits.Check = function(s, sel)
        local credits = LocalPlayer():GetCredits()
        return credits > 0, " " .. credits, GetPTranslation("equip_cost", { num = credits })
    end

    tbl.owned = vgui.Create("DLabel", parent)
    --tbl.owned:SetTooltip(GetTranslation("equip_help_carry"))
    tbl.owned:CopyPos(tbl.credits)
    tbl.owned:MoveRightOf(tbl.credits, y * 3)
    -- carry icon
    tbl.owned.img = vgui.Create("DImage", parent)
    tbl.owned.img:SetSize(32, 32)
    tbl.owned.img:CopyPos(tbl.owned)
    tbl.owned.img:MoveLeftOf(tbl.owned)
    tbl.owned.img:SetImage("vgui/ttt/equip/briefcase.png")

    tbl.owned.Check = function(s, sel)
        if ItemIsWeapon(sel) and (not CanCarryWeapon(sel)) then
            return false, sel.slot, GetPTranslation("equip_carry_slot", { slot = sel.slot })
        elseif (not ItemIsWeapon(sel)) and LocalPlayer():HasEquipmentItem(sel.id) then
            return false, "X", GetTranslation("equip_carry_own")
        else
            return true, "✔", GetTranslation("equip_carry")
        end
    end

    tbl.bought = vgui.Create("DLabel", parent)
    --tbl.bought:SetTooltip(GetTranslation("equip_help_stock"))
    tbl.bought:CopyPos(tbl.owned)
    tbl.bought:MoveRightOf(tbl.owned, y * 3)
    -- stock icon
    tbl.bought.img = vgui.Create("DImage", parent)
    tbl.bought.img:SetSize(32, 32)
    tbl.bought.img:CopyPos(tbl.bought)
    tbl.bought.img:MoveLeftOf(tbl.bought)
    tbl.bought.img:SetImage("vgui/ttt/equip/package.png")

    tbl.bought.Check = function(s, sel)
        if sel.limited and LocalPlayer():HasBought(tostring(sel.id)) then
            return false, "X", GetTranslation("equip_stock_deny")
        else
            return true, "✔", GetTranslation("equip_stock_ok")
        end
    end

    for _, pnl in pairs(tbl) do
        pnl:SetFont("DermaLarge")
    end

    return function(selected)
        local allow = true
        for _, pnl in pairs(tbl) do
            local result, text, tooltip = pnl:Check(selected)
            pnl:SetTextColor(result and COLOR_WHITE or color_bad)
            pnl:SetText(text)
            pnl:SizeToContents()
            pnl:SetTooltip(tooltip)
            pnl.img:SetImageColor(result and COLOR_WHITE or color_bad)
            pnl.img:SetTooltip(tooltip)
            allow = allow and result
        end
        return allow
    end
end

-- quick, very basic override of DPanelSelect
local PANEL = {}
local function DrawSelectedEquipment(pnl)
    surface.SetDrawColor(255, 200, 0, 255)
    surface.DrawOutlinedRect(0, 0, pnl:GetWide(), pnl:GetTall())
end

function PANEL:SelectPanel(pnl)
    if pnl then
        self.BaseClass.SelectPanel(self, pnl)
        pnl.PaintOver = DrawSelectedEquipment
    else
        self:OnActivePanelChanged(self.SelectedPanel, pnl)
        self.SelectedPanel = nil
    end
end

vgui.Register("EquipSelect", PANEL, "DPanelSelect")

local SafeTranslate = LANG.TryTranslation

local color_darkened = Color(255, 255, 255, 80)

local eqframe = nil

local function TraitorMenuPopup()
    -- calculate dimensions
    local numCols = serverColsVar:GetInt()
    local numRows = serverRowsVar:GetInt()
    local itemSize = serverSizeVar:GetInt()

    if allowChangeVar:GetBool() then
        numCols = numColsVar:GetInt()
        numRows = numRowsVar:GetInt()
        itemSize = itemSizeVar:GetInt()
    end

    -- margin
    local m = 5
    -- item list width
    local dlistw = ((itemSize + 2) * numCols) - 2 + 15
    local dlisth = ((itemSize + 2) * numRows) - 2 + 15
    -- right column width
    local diw = 270
    -- frame size
    local w = dlistw + diw + (m * 4)
    local h = dlisth + 75

    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:IsActiveSpecial() then
        return
    end

    -- Close any existing traitor menu
    if eqframe and IsValid(eqframe) then eqframe:Close() end

    local credits = ply:GetCredits()
    local can_order = credits > 0

    local dframe = vgui.Create("DFrame")
    dframe:SetSize(w, h)
    dframe:Center()
    dframe:SetTitle(GetTranslation("equip_title"))
    dframe:SetVisible(true)
    dframe:ShowCloseButton(true)
    dframe:SetMouseInputEnabled(true)
    dframe:SetDeleteOnClose(true)

    local dsheet = vgui.Create("DPropertySheet", dframe)

    -- Add a callback when switching tabs
    local oldfunc = dsheet.SetActiveTab
    dsheet.SetActiveTab = function(self, new)
        if self.m_pActiveTab ~= new and self.OnTabChanged then
            self:OnTabChanged(self.m_pActiveTab, new)
        end
        oldfunc(self, new)
    end

    dsheet:SetPos(0, 0)
    dsheet:StretchToParent(m, m + 25, m, m)
    local padding = dsheet:GetPadding()

    local dequip = vgui.Create("DPanel", dsheet)
    dequip:SetPaintBackground(false)
    dequip:StretchToParent(padding, padding, padding, padding)

    -- Determine if we already have equipment
    local owned_ids = {}
    for _, wep in pairs(ply:GetWeapons()) do
        if IsValid(wep) and wep:IsEquipment() then
            table.insert(owned_ids, wep:GetClass())
        end
    end

    -- Stick to one value for no equipment
    if #owned_ids == 0 then
        owned_ids = nil
    end

    local dsearchheight = 25
    local dsearchpadding = 5
    local dsearch = vgui.Create("DTextEntry", dequip)
    dsearch:SetPos(0, 0)
    dsearch:SetSize(dlistw, dsearchheight)
    dsearch:SetPlaceholderText("Search...")
    dsearch:SetUpdateOnType(true)
    dsearch.OnGetFocus = function() dframe:SetKeyboardInputEnabled(true) end
    dsearch.OnLoseFocus = function() dframe:SetKeyboardInputEnabled(false) end

    --- Construct icon listing
    --- icon size = 64 x 64
    local dlist = vgui.Create("EquipSelect", dequip)
    -- local dlistw = 288
    dlist:SetPos(0, dsearchheight + dsearchpadding)
    dlist:SetSize(dlistw, dlisth - dsearchheight - dsearchpadding)
    dlist:EnableVerticalScrollbar(true)
    dlist:EnableHorizontal(true)

    local bw, bh = 100, 25

    -- Whole right column
    local dih = h - bh - m * 5
    -- local diw = w - dlistw - m*6 - 2
    local dinfobg = vgui.Create("DPanel", dequip)
    dinfobg:SetPaintBackground(false)
    dinfobg:SetSize(diw - m, dih)
    dinfobg:SetPos(dlistw + m, 0)

    -- item info pane
    local dinfo = vgui.Create("ColoredBox", dinfobg)
    dinfo:SetColor(Color(90, 90, 95))
    dinfo:SetPos(0, 0)
    dinfo:StretchToParent(0, 0, m * 2, 105)

    local dfields = {}
    for _, k in pairs({ "name", "type", "desc" }) do
        dfields[k] = vgui.Create("DLabel", dinfo)
        dfields[k]:SetTooltip(GetTranslation("equip_spec_" .. k))
        dfields[k]:SetPos(m * 3, m * 2)
        dfields[k]:SetWidth(diw - m * 6)
    end

    dfields.name:SetFont("TabLarge")

    dfields.type:SetFont("DermaDefault")
    dfields.type:MoveBelow(dfields.name)

    dfields.desc:SetFont("DermaDefaultBold")
    dfields.desc:SetContentAlignment(7)
    dfields.desc:MoveBelow(dfields.type, 1)

    local dhelp = vgui.Create("DPanel", dinfobg)
    dhelp:SetPaintBackground(false)
    dhelp:SetSize(diw, 64)
    dhelp:MoveBelow(dinfo, m)

    local update_preqs = PreqLabels(dhelp, m * 7, m * 2)

    local function FillEquipmentList(itemlist)
        dlist:Clear()

        -- temp table for sorting
        local paneltablefav = {}
        local paneltable = {}
        for i = 1, 9 do
            paneltablefav[i] = {}
            paneltable[i] = {}
        end

        for k, item in pairs(itemlist) do
            local ic = nil

            -- Create icon panel
            if item.material then
                ic = vgui.Create("LayeredIcon", dlist)

                if item.custom and showCustomVar:GetBool() then
                    -- Custom marker icon
                    local marker = vgui.Create("DImage")
                    marker:SetImage("vgui/ttt/custom_marker")
                    marker.PerformLayout = function(s)
                        s:AlignBottom(2)
                        s:AlignRight(2)
                        s:SetSize(16, 16)
                    end
                    marker:SetTooltip(GetTranslation("equip_custom"))

                    ic:AddLayer(marker)

                    ic:EnableMousePassthrough(marker)
                end

                -- Favorites marker icon
                ic.favorite = false
                local favorites = GetFavorites(ply:SteamID(), ply:GetRole())
                if favorites then
                    if IsFavorite(favorites, item.id) then
                        ic.favorite = true
                        if showFavoriteVar:GetBool() then
                            local star = vgui.Create("DImage")
                            star:SetImage("icon16/star.png")
                            star.PerformLayout = function(s)
                                s:AlignTop(2)
                                s:AlignRight(2)
                                s:SetSize(12, 12)
                            end
                            star:SetTooltip("Favorite")
                            ic:AddLayer(star)
                            ic:EnableMousePassthrough(star)
                        end
                    end
                end

                -- Slot marker icon
                ic.slot = 1
                if ItemIsWeapon(item) and showSlotVar:GetBool() then
                    local slot = vgui.Create("SimpleIconLabelled")
                    slot:SetIcon("vgui/ttt/sprite_slot_cap")
                    slot:SetIconColor(ROLE_COLORS[ply:GetRole()] or COLOR_GRAY)
                    slot:SetIconSize(16)

                    slot:SetIconText(item.slot)
                    ic.slot = item.slot

                    -- Credit to @Angela on the Lonely Yogs Discord for the fix!
                    -- Clamp the item slot within the correct limits
                    if ic.slot ~= nil then
                        if ic.slot > #paneltable then
                            ic.slot = #paneltable
                        elseif ic.slot < 1 then
                            ic.slot = 1
                        end
                    end

                    slot:SetIconProperties(COLOR_WHITE,
                        "DefaultBold",
                        { opacity = 220, offset = 1 },
                        { 9, 8 })

                    ic:AddLayer(slot)
                    ic:EnableMousePassthrough(slot)
                end

                ic:SetIconSize(itemSize)
                ic:SetIcon(item.material)
            elseif item.model then
                ic = vgui.Create("SpawnIcon", dlist)
                ic:SetModel(item.model)
            else
                ErrorNoHalt("Equipment item does not have model or material specified: " .. tostring(item) .. "\n")
            end

            ic.item = item

            local tip = SafeTranslate(item.name) .. " (" .. SafeTranslate(item.type) .. ")"
            ic:SetTooltip(tip)

            -- If we cannot order this item, darken it
            local orderable = update_preqs(item)
            if ((not orderable) or
                    -- already owned
                    table.HasValue(owned_ids, item.id) or
                    (tonumber(item.id) and ply:HasEquipmentItem(tonumber(item.id))) or
                    -- already carrying a weapon for this slot
                    (ItemIsWeapon(item) and (not CanCarryWeapon(item))) or
                    -- already bought the item before
                    (item.limited and ply:HasBought(tostring(item.id)))) then
                ic:SetIconColor(color_darkened)
            end

            if ic.favorite then
                paneltablefav[ic.slot or 1][k] = ic
            else
                paneltable[ic.slot or 1][k] = ic
            end
        end

        -- add favorites first
        for i = 1, 9 do
            for _, panel in pairs(paneltablefav[i]) do
                dlist:AddPanel(panel)
            end
        end
        -- non favorites second
        for i = 1, 9 do
            for _, panel in pairs(paneltable[i]) do
                dlist:AddPanel(panel)
            end
        end

        -- select first
        dlist:SelectPanel(dlist:GetItems()[1])
    end
    dsearch.OnValueChange = function(box, value)
        local roleitems = GetEquipmentForRole(ply:GetRole())
        local filtered = {}
        for _, v in pairs(roleitems) do
            if v and v["name"] and string.find(SafeTranslate(v["name"]):lower(), value:lower()) then
                table.insert(filtered, v)
            end
        end
        FillEquipmentList(filtered)
    end

    dhelp:SizeToContents()

    local dconfirm = vgui.Create("DButton", dinfobg)
    dconfirm:SetPos(0, dih - bh * 2)
    dconfirm:SetSize(bw, bh)
    dconfirm:SetDisabled(true)
    dconfirm:SetText(GetTranslation("equip_confirm"))

    dsheet:AddSheet(GetTranslation("equip_tabtitle"), dequip, "icon16/bomb.png", false, false, "Traitor equipment menu")

    -- Item control
    if ply:HasEquipmentItem(EQUIP_RADAR) then
        local dradar = RADAR.CreateMenu(dsheet, dframe)
        dsheet:AddSheet(GetTranslation("radar_name"), dradar, "icon16/magnifier.png", false, false, "Radar control")
    end

    if ply:HasEquipmentItem(EQUIP_DISGUISE) then
        local ddisguise = DISGUISE.CreateMenu(dsheet)
        dsheet:AddSheet(GetTranslation("disg_name"), ddisguise, "icon16/user.png", false, false, "Disguise control")
    end

    -- Weapon/item control
    if IsValid(ply.radio) or ply:HasWeapon("weapon_ttt_radio") then
        local dradio = TRADIO.CreateMenu(dsheet)
        dsheet:AddSheet(GetTranslation("radio_name"), dradio, "icon16/transmit.png", false, false, "Radio control")
    end

    -- Credit transferring
    if credits > 0 and (ply:GetRole() ~= ROLE_MERCENARY or ply:GetRole() ~= ROLE_KILLER) then
        local dtransfer = CreateTransferMenu(dsheet)
        dsheet:AddSheet(GetTranslation("xfer_name"), dtransfer, "icon16/group_gear.png", false, false, "Transfer credits")
    end

    hook.Run("TTTEquipmentTabs", dsheet)

    -- couple panelselect with info
    dlist.OnActivePanelChanged = function(self, _, new)
        can_order = false
        if new and new.item then
            for k, v in pairs(new.item) do
                if dfields[k] then
                    dfields[k]:SetText(SafeTranslate(v))
                    dfields[k]:SetAutoStretchVertical(true)
                    dfields[k]:SetWrap(true)
                end
            end

            -- Trying to force everything to update to
            -- the right size is a giant pain, so just
            -- force a good size.
            dfields.desc:SetTall(70)

            can_order = update_preqs(new.item)
        else
            for _, v in pairs(dfields) do
                if v then
                    v:SetText("---")
                    v:SetAutoStretchVertical(true)
                    v:SetWrap(true)
                end
            end
        end

        dconfirm:SetDisabled(not can_order)
    end

    -- prep confirm action
    dconfirm.DoClick = function()
        local pnl = dlist.SelectedPanel
        if not pnl or not pnl.item then return end
        local choice = pnl.item
        RunConsoleCommand("ttt_order_equipment", choice.id)
        dframe:Close()
    end

    -- update some basic info, may have changed in another tab
    -- specifically the number of credits in the preq list
    dsheet.OnTabChanged = function(s, old, new)
        if not IsValid(new) then return end

        if new:GetPanel() == dequip then
            can_order = update_preqs(dlist.SelectedPanel.item)
            dconfirm:SetDisabled(not can_order)
        end
    end

    local dcancel = vgui.Create("DButton", dframe)
    dcancel:SetPos(w - 13 - bw, h - bh - 16)
    dcancel:SetSize(bw, bh)
    dcancel:SetDisabled(false)
    dcancel:SetText(GetTranslation("close"))
    dcancel.DoClick = function()
        dframe:Close()
    end

    function file.AppendLine(filename, addme)
        data = file.Read(filename)
        if (data) then
            file.Write(filename, data .. "\n" .. tostring(addme))
        else
            file.Write(filename, tostring(addme))
        end
    end

    --add as favorite button
    local dfav = vgui.Create("DButton", dinfobg)
    dfav:SetPos(0, dih - bh * 2)
    dfav:MoveRightOf(dconfirm)
    dfav:SetSize(bh, bh)
    dfav:SetDisabled(false)
    dfav:SetText("")
    dfav:SetImage("icon16/star.png")
    dfav.DoClick = function()
        local ply = LocalPlayer()
        local role = ply:GetRole()
        local guid = ply:SteamID()
        local pnl = dlist.SelectedPanel
        if not pnl or not pnl.item then return end
        local choice = pnl.item
        local weapon = choice.id
        CreateFavTable()
        if pnl.favorite then
            RemoveFavorite(guid, role, weapon)
        else
            AddFavorite(guid, role, weapon)
        end
    end

    FillEquipmentList(GetEquipmentForRole(ply:GetRole()))

    dframe:MakePopup()
    dframe:SetKeyboardInputEnabled(false)

    eqframe = dframe
end

concommand.Add("ttt_cl_traitorpopup", TraitorMenuPopup)

local function ForceCloseTraitorMenu(ply, cmd, args)
    if IsValid(eqframe) then
        eqframe:Close()
    end
end

concommand.Add("ttt_cl_traitorpopup_close", ForceCloseTraitorMenu)

function GM:OnContextMenuOpen()
    local r = GetRoundState()
    if r == ROUND_ACTIVE and not (LocalPlayer():GetTraitor() or LocalPlayer():GetDetective() or LocalPlayer():GetMercenary() or LocalPlayer():GetZombie() or LocalPlayer():GetHypnotist() or LocalPlayer():GetVampire() or LocalPlayer():GetAssassin() or LocalPlayer():GetKiller()) then
        return
    elseif r == ROUND_POST or r == ROUND_PREP then
        CLSCORE:Toggle()
        return
    end
    if eqframe and IsValid(eqframe) then
        ForceCloseTraitorMenu()
    else
        TraitorMenuPopup()
    end
end

local function ReceiveEquipment()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    ply.equipment_items = net.ReadUInt(16)
end

net.Receive("TTT_Equipment", ReceiveEquipment)

local function ReceiveCredits()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    ply.equipment_credits = net.ReadUInt(8)
end

net.Receive("TTT_Credits", ReceiveCredits)

local r = 0
local function ReceiveBought()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    ply.bought = {}
    local num = net.ReadUInt(8)
    for i = 1, num do
        local s = net.ReadString()
        if s ~= "" then
            table.insert(ply.bought, s)
        end
    end

    -- This usermessage sometimes fails to contain the last weapon that was
    -- bought, even though resending then works perfectly. Possibly a bug in
    -- bf_read. Anyway, this hack is a workaround: we just request a new umsg.
    if num ~= #ply.bought and r < 10 then -- r is an infinite loop guard
        RunConsoleCommand("ttt_resend_bought")
        r = r + 1
    else
        r = 0
    end
end

net.Receive("TTT_Bought", ReceiveBought)

-- Player received the item he has just bought, so run clientside init
local function ReceiveBoughtItem()
    local is_item = net.ReadBit() == 1
    local id = is_item and net.ReadUInt(16) or net.ReadString()

    -- I can imagine custom equipment wanting this, so making a hook
    hook.Run("TTTBoughtItem", is_item, id)
end

net.Receive("TTT_BoughtItem", ReceiveBoughtItem)
