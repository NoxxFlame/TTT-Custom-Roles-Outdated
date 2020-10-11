local util = util
local surface = surface
local draw = draw

local GetPTranslation = LANG.GetParamTranslation
local GetRaw = LANG.GetRawTranslation

local key_params = { usekey = Key("+use", "USE"), walkkey = Key("+walk", "WALK") }
local ClassHint = {
    prop_ragdoll = {
        name = "corpse",
        hint = "corpse_hint",
        fmt = function(ent, txt) return GetPTranslation(txt, key_params) end
    }
};

-- Access for servers to display hints using their own HUD/UI.
function GM:GetClassHints()
    return ClassHint
end

-- Basic access for servers to add/modify hints. They override hints stored on
-- the entities themselves.
function GM:AddClassHint(cls, hint)
    ClassHint[cls] = table.Copy(hint)
end

-- "T" indicator above traitors
local indicator_mattra_noz = Material("vgui/ttt/sprite_let_tra_noz")
local indicator_matjes_noz = Material("vgui/ttt/sprite_let_jes_noz")
local indicator_mathyp_noz = Material("vgui/ttt/sprite_let_hyp_noz")
local indicator_matinn_noz = Material("vgui/ttt/sprite_let_inn_noz")
local indicator_matder_noz = Material("vgui/ttt/sprite_let_der_noz")
local indicator_matdet_noz = Material("vgui/ttt/sprite_let_det_noz")
local indicator_matgli_noz = Material("vgui/ttt/sprite_let_gli_noz")
local indicator_matpha_noz = Material("vgui/ttt/sprite_let_pha_noz")
local indicator_matmer_noz = Material("vgui/ttt/sprite_let_mer_noz")
local indicator_matzom_noz = Material("vgui/ttt/sprite_let_zom_noz")
local indicator_matvam_noz = Material("vgui/ttt/sprite_let_vam_noz")
local indicator_matswa_noz = Material("vgui/ttt/sprite_let_swa_noz")
local indicator_matass_noz = Material("vgui/ttt/sprite_let_ass_noz")
local indicator_matkil_noz = Material("vgui/ttt/sprite_let_kil_noz")
local indicator_mattra = Material("vgui/ttt/sprite_let_tra")
local indicator_matjes = Material("vgui/ttt/sprite_let_jes")
local indicator_mathyp = Material("vgui/ttt/sprite_let_hyp")
local indicator_matinn = Material("vgui/ttt/sprite_let_inn")
local indicator_matder = Material("vgui/ttt/sprite_let_der")
local indicator_matdet = Material("vgui/ttt/sprite_let_det")
local indicator_matgli = Material("vgui/ttt/sprite_let_gli")
local indicator_matpha = Material("vgui/ttt/sprite_let_pha")
local indicator_matmer = Material("vgui/ttt/sprite_let_mer")
local indicator_matzom = Material("vgui/ttt/sprite_let_zom")
local indicator_matvam = Material("vgui/ttt/sprite_let_vam")
local indicator_matswa = Material("vgui/ttt/sprite_let_swa")
local indicator_matass = Material("vgui/ttt/sprite_let_ass")
local indicator_matkil = Material("vgui/ttt/sprite_let_kil")
local indicator_mat_target = Material("vgui/ttt/sprite_let_target")

local indicator_col = Color(255, 255, 255, 130)

local propspec_outline = Material("models/props_combine/portalball001_sheet")

local function ShowTraitorIcon(ply, pos, dir)
    if ply:IsTraitor() or ply:IsGlitch() then
        render.SetMaterial(indicator_mattra_noz)
        render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
    elseif ply:IsHypnotist() then
        render.SetMaterial(indicator_mathyp_noz)
        render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
    elseif ply:IsAssassin() then
        render.SetMaterial(indicator_matass_noz)
        render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
    elseif ply:IsDetraitor() then
        render.SetMaterial(indicator_matder_noz)
        render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
    end
end

local function ShowMonsterIcon(ply, pos, dir)
    if ply:IsZombie() then
        render.SetMaterial(indicator_matzom_noz)
        render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
    elseif ply:IsVampire() then
        render.SetMaterial(indicator_matvam_noz)
        render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
    end
end

-- using this hook instead of pre/postplayerdraw because playerdraw seems to
-- happen before certain entities are drawn, which then clip over the sprite
function GM:PostDrawTranslucentRenderables()
    local symbols = false
    if ConVarExists("ttt_role_symbols") then
        symbols = GetConVar("ttt_role_symbols"):GetBool()
    end

    local hide_roles = false
    if ConVarExists("ttt_hide_role") then
        hide_roles = GetConVar("ttt_hide_role"):GetBool()
    end

    if symbols then
        indicator_mattra_noz = Material("vgui/ttt/sprite_sym_tra_noz")
        indicator_matjes_noz = Material("vgui/ttt/sprite_sym_jes_noz")
        indicator_mathyp_noz = Material("vgui/ttt/sprite_sym_hyp_noz")
        indicator_matinn_noz = Material("vgui/ttt/sprite_sym_inn_noz")
        indicator_matder_noz = Material("vgui/ttt/sprite_sym_der_noz")
        indicator_matdet_noz = Material("vgui/ttt/sprite_sym_det_noz")
        indicator_matgli_noz = Material("vgui/ttt/sprite_sym_gli_noz")
        indicator_matpha_noz = Material("vgui/ttt/sprite_sym_pha_noz")
        indicator_matmer_noz = Material("vgui/ttt/sprite_sym_mer_noz")
        indicator_matzom_noz = Material("vgui/ttt/sprite_sym_zom_noz")
        indicator_matvam_noz = Material("vgui/ttt/sprite_sym_vam_noz")
        indicator_matswa_noz = Material("vgui/ttt/sprite_sym_swa_noz")
        indicator_matass_noz = Material("vgui/ttt/sprite_sym_ass_noz")
        indicator_matkil_noz = Material("vgui/ttt/sprite_sym_kil_noz")
        indicator_mattra = Material("vgui/ttt/sprite_sym_tra")
        indicator_matjes = Material("vgui/ttt/sprite_sym_jes")
        indicator_mathyp = Material("vgui/ttt/sprite_sym_hyp")
        indicator_matinn = Material("vgui/ttt/sprite_sym_inn")
        indicator_matder = Material("vgui/ttt/sprite_sym_der")
        indicator_matdet = Material("vgui/ttt/sprite_sym_det")
        indicator_matgli = Material("vgui/ttt/sprite_sym_gli")
        indicator_matpha = Material("vgui/ttt/sprite_sym_pha")
        indicator_matmer = Material("vgui/ttt/sprite_sym_mer")
        indicator_matzom = Material("vgui/ttt/sprite_sym_zom")
        indicator_matvam = Material("vgui/ttt/sprite_sym_vam")
        indicator_matswa = Material("vgui/ttt/sprite_sym_swa")
        indicator_matass = Material("vgui/ttt/sprite_sym_ass")
        indicator_matkil = Material("vgui/ttt/sprite_sym_kil")
        indicator_mat_target = Material("vgui/ttt/sprite_sym_target")
    else
        indicator_mattra_noz = Material("vgui/ttt/sprite_let_tra_noz")
        indicator_matjes_noz = Material("vgui/ttt/sprite_let_jes_noz")
        indicator_mathyp_noz = Material("vgui/ttt/sprite_let_hyp_noz")
        indicator_matinn_noz = Material("vgui/ttt/sprite_let_inn_noz")
        indicator_matder_noz = Material("vgui/ttt/sprite_let_der_noz")
        indicator_matdet_noz = Material("vgui/ttt/sprite_let_det_noz")
        indicator_matgli_noz = Material("vgui/ttt/sprite_let_gli_noz")
        indicator_matpha_noz = Material("vgui/ttt/sprite_let_pha_noz")
        indicator_matmer_noz = Material("vgui/ttt/sprite_let_mer_noz")
        indicator_matzom_noz = Material("vgui/ttt/sprite_let_zom_noz")
        indicator_matvam_noz = Material("vgui/ttt/sprite_let_vam_noz")
        indicator_matswa_noz = Material("vgui/ttt/sprite_let_swa_noz")
        indicator_matass_noz = Material("vgui/ttt/sprite_let_ass_noz")
        indicator_matkil_noz = Material("vgui/ttt/sprite_let_kil_noz")
        indicator_mattra = Material("vgui/ttt/sprite_let_tra")
        indicator_matjes = Material("vgui/ttt/sprite_let_jes")
        indicator_mathyp = Material("vgui/ttt/sprite_let_hyp")
        indicator_matinn = Material("vgui/ttt/sprite_let_inn")
        indicator_matder = Material("vgui/ttt/sprite_let_der")
        indicator_matdet = Material("vgui/ttt/sprite_let_det")
        indicator_matgli = Material("vgui/ttt/sprite_let_gli")
        indicator_matpha = Material("vgui/ttt/sprite_let_pha")
        indicator_matmer = Material("vgui/ttt/sprite_let_mer")
        indicator_matzom = Material("vgui/ttt/sprite_let_zom")
        indicator_matvam = Material("vgui/ttt/sprite_let_vam")
        indicator_matswa = Material("vgui/ttt/sprite_let_swa")
        indicator_matass = Material("vgui/ttt/sprite_let_ass")
        indicator_matkil = Material("vgui/ttt/sprite_let_kil")
        indicator_mat_target = Material("vgui/ttt/sprite_let_target")
    end
    local client = LocalPlayer()
    local plys = player.GetAll()
    local dir = client:GetForward() * -1

    for _, v in pairs(plys) do
        -- Compatibility with the disguises and Dead Ringer
        local hidden = v:GetNWBool("disguised", false) or (v.IsFakeDead and v:IsFakeDead())
        if v:IsActive() and v ~= client and not hidden then
            local pos = v:GetPos()
            pos.z = pos.z + 74
            local revealed = v:GetNWBool('RoleRevealed', false)
            -- Only show the "KILL" target if the setting is enabled
            local showkillicon = (client:IsZombie() and GetGlobalBool("ttt_zombie_show_target_icon")) or
                (client:IsVampire() and GetGlobalBool("ttt_vampire_show_target_icon")) or
                (client:IsKiller() and GetGlobalBool("ttt_killer_show_target_icon")) or
                (client:IsAssassin() and GetGlobalBool("ttt_assassin_show_target_icon") and client:GetNWString("AssassinTarget") == v:GetName())

            -- Don't show the detective icon for the roles that have "KILL" above everyone's head
            -- Also, if show the detective icon if the target is a detratior and the client is not a traitor
            if (v:IsDetective() or (not player.IsTraitorTeam(client) and v:IsDetraitor())) and not showkillicon then
                render.SetMaterial(indicator_matdet)
                render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
            end
            if revealed and client:IsDetective() then
                if v:IsInnocent() then
                    render.SetMaterial(indicator_matinn)
                    render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
                elseif v:IsGlitch() then
                    render.SetMaterial(indicator_matgli)
                    render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
                elseif v:IsMercenary() then
                    render.SetMaterial(indicator_matmer)
                    render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
                elseif v:IsPhantom() then
                    render.SetMaterial(indicator_matpha)
                    render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
                elseif v:IsTraitor() then
                    render.SetMaterial(indicator_mattra)
                    render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
                elseif v:IsAssassin() then
                    render.SetMaterial(indicator_matass)
                    render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
                elseif v:IsHypnotist() then
                    render.SetMaterial(indicator_mathyp)
                    render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
                elseif v:IsVampire() then
                    render.SetMaterial(indicator_matvam)
                    render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
                elseif v:IsZombie() then
                    render.SetMaterial(indicator_matzom)
                    render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
                elseif v:IsJester() then
                    render.SetMaterial(indicator_matjes)
                    render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
                elseif v:IsSwapper() then
                    render.SetMaterial(indicator_matswa)
                    render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
                elseif v:IsKiller() then
                    render.SetMaterial(indicator_matkil)
                    render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
                elseif v:IsDetraitor() then
                    render.SetMaterial(indicator_matder)
                    render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
                end
            end
            if not hide_roles then
                if client:IsTraitorTeam() then
                    if v:IsTraitorTeam() or v:IsGlitch() then
                        ShowTraitorIcon(v, pos, dir)
                    elseif v:IsJesterTeam() then
                        local v_material = indicator_matjes
                        if GetGlobalBool("ttt_traitors_know_swapper") and v:IsSwapper() then
                            v_material = indicator_matswa
                        end
                        render.SetMaterial(v_material)
                        render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
                    -- If Monsters-as-Traitors is enabled and the target is a Monster, show icons
                    elseif client:IsMonsterAlly() and v:IsMonsterTeam() then
                        ShowMonsterIcon(v, pos, dir)
                    elseif showkillicon then
                        render.SetMaterial(indicator_mat_target)
                        render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
                    end
                elseif client:IsMonsterTeam() then
                    if v:IsMonsterTeam() then
                        ShowMonsterIcon(v, pos, dir)
                    elseif v:IsJesterTeam() then
                        local v_material = indicator_matjes
                        if GetGlobalBool("ttt_monsters_know_swapper") and v:IsSwapper() then
                            v_material = indicator_matswa
                        end
                        render.SetMaterial(v_material)
                        render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
                    -- Since Zombie and Vampire were already handled above, this will only cover the traitor team and only if Monsters-as-Traitors is enabled
                    elseif GetGlobalBool("ttt_monsters_are_traitors") and (v:IsTraitorTeam() or v:IsGlitch()) then
                        ShowTraitorIcon(v, pos, dir)
                    elseif showkillicon then
                        render.SetMaterial(indicator_mat_target)
                        render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
                    end
                elseif client:IsKiller() then
                    if v:IsJesterTeam() then
                        local v_material = indicator_matjes
                        if GetGlobalBool("ttt_killers_know_swapper") and v:IsSwapper() then
                            v_material = indicator_matswa
                        end
                        render.SetMaterial(v_material)
                        render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
                    elseif showkillicon then
                        render.SetMaterial(indicator_mat_target)
                        render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
                    end
                end
            end
        end
    end

    if client:Team() == TEAM_SPEC then
        cam.Start3D(client:EyePos(), client:EyeAngles())

        for _, v in pairs(plys) do
            local tgt = v:GetObserverTarget()
            if IsValid(tgt) and tgt:GetNWEntity("spec_owner", nil) == v then
                render.MaterialOverride(propspec_outline)
                render.SuppressEngineLighting(true)
                render.SetColorModulation(1, 0.5, 0)

                tgt:SetModelScale(1.05, 0)
                tgt:DrawModel()

                render.SetColorModulation(1, 1, 1)
                render.SuppressEngineLighting(false)
                render.MaterialOverride(nil)
            end
        end

        cam.End3D()
    end
end

-- Spectator labels
local function DrawPropSpecLabels(client)
    if (not client:IsSpec()) and (GetRoundState() ~= ROUND_POST) then return end

    surface.SetFont("TabLarge")

    local tgt = nil
    local scrpos = nil
    local text = nil
    local w = 0
    for _, ply in pairs(player.GetAll()) do
        if ply:IsSpec() then
            surface.SetTextColor(220, 200, 0, 120)

            tgt = ply:GetObserverTarget()

            if IsValid(tgt) and tgt:GetNWEntity("spec_owner", nil) == ply then

                scrpos = tgt:GetPos():ToScreen()
            else
                scrpos = nil
            end
        else
            local _, healthcolor = util.HealthToString(ply:Health(), ply:GetMaxHealth())
            surface.SetTextColor(UnpackColor(healthcolor))

            scrpos = ply:EyePos()
            scrpos.z = scrpos.z + 20

            scrpos = scrpos:ToScreen()
        end

        if scrpos and (not IsOffScreen(scrpos)) then
            text = ply:Nick()
            w, _ = surface.GetTextSize(text)

            surface.SetTextPos(scrpos.x - w / 2, scrpos.y)
            surface.DrawText(text)
        end
    end
end

-- Crosshair affairs

surface.CreateFont("TargetIDSmall2", {
    font = "TargetID",
    size = 16,
    weight = 1000
})

local minimalist = CreateConVar("ttt_minimal_targetid", "0", FCVAR_ARCHIVE)

local magnifier_mat = Material("icon16/magnifier.png")
local ring_tex = surface.GetTextureID("effects/select_ring")

local rag_color = Color(200, 200, 200, 255)

local GetLang = LANG.GetUnsafeLanguageTable

local MAX_TRACE_LENGTH = math.sqrt(3) * 2 * 16384

function GM:HUDDrawTargetID()
    local client = LocalPlayer()

    local L = GetLang()

    if hook.Call("HUDShouldDraw", GAMEMODE, "TTTPropSpec") then
        DrawPropSpecLabels(client)
    end

    local startpos = client:EyePos()
    local endpos = client:GetAimVector()
    endpos:Mul(MAX_TRACE_LENGTH)
    endpos:Add(startpos)

    local trace = util.TraceLine({
        start = startpos,
        endpos = endpos,
        mask = MASK_SHOT,
        filter = client:GetObserverMode() == OBS_MODE_IN_EYE and { client, client:GetObserverTarget() } or client
    })
    local ent = trace.Entity
    if (not IsValid(ent)) or ent.NoTarget then return end

    -- some bools for caching what kind of ent we are looking at
    local target_innocent = false
    local target_detective = false
    local target_glitch = false
    local target_mercenary = false
    local target_phantom = false
    local target_traitor = false
    local target_assassin = false
    local target_hypnotist = false
    local target_vampire = false
    local target_zombie = false
    local target_jester = false
    local target_swapper = false
    local target_killer = false
    local target_detraitor = false
    local target_fellow_traitor = false
    local target_fellow_zombie = false
    local target_current_target = false
    local target_corpse = false

    local text = nil
    local color = COLOR_WHITE

    -- if a vehicle, we identify the driver instead
    if IsValid(ent:GetNWEntity("ttt_driver", nil)) then
        ent = ent:GetNWEntity("ttt_driver", nil)

        if ent == client then return end
    end

    local cls = ent:GetClass()
    local minimal = minimalist:GetBool()
    local hint = (not minimal) and (ent.TargetIDHint or ClassHint[cls])

    local hide_roles = false
    if ConVarExists("ttt_hide_role") then
        hide_roles = GetConVar("ttt_hide_role"):GetBool()
    end

    if ent:IsPlayer() and ent:Alive() then
        text = ent:Nick()
        client.last_id = ent
        if ent:GetNWBool("disguised", false) or (ent:GetActiveWeapon():IsValid() and ent:GetActiveWeapon():GetClass() == "weapon_ttt_cloak") then
            client.last_id = nil

            if client:IsTraitorTeam() or client:IsSpec() then
                text = ent:Nick() .. L.target_disg
            else
                return
            end
        end

        -- in minimalist targetID, colour nick with health level
        if minimal then
            _, color = util.HealthToString(ent:Health(), ent:GetMaxHealth())
        end
        local revealed = ent:GetNWBool('RoleRevealed', false)
        if GetRoundState() == ROUND_ACTIVE and client:IsDetective() and revealed then
            target_innocent = ent:IsInnocent()
            target_glitch = ent:IsGlitch()
            target_mercenary = ent:IsMercenary()
            target_phantom = ent:IsPhantom()
            target_traitor = ent:IsTraitor()
            target_assassin = ent:IsAssassin()
            target_hypnotist = ent:IsHypnotist()
            target_vampire = ent:IsVampire()
            target_zombie = ent:IsZombie()
            target_jester = ent:IsJester()
            target_swapper = ent:IsSwapper()
            target_killer = ent:IsKiller()
            target_detraitor = ent:IsDetraitor()
        end
        if not hide_roles and GetRoundState() == ROUND_ACTIVE then
            if client:IsTraitorTeam() then
                target_glitch = ent:IsGlitch()
                if client:IsTraitor() then
                    target_fellow_traitor = ent:IsTraitor() or target_glitch
                else
                    target_traitor = ent:IsTraitor() or target_glitch
                end
                target_hypnotist = ent:IsHypnotist()
                target_assassin = ent:IsAssassin()
                target_detraitor = ent:IsDetraitor()
                if GetGlobalBool("ttt_traitors_know_swapper") then
                    target_jester = ent:IsJester()
                    target_swapper = ent:IsSwapper()
                else
                    target_jester = ent:IsJesterTeam()
                end

                -- Show monster icons if Monsters-as-Traitors is enabled
                if client:IsMonsterAlly() and ent:IsMonsterTeam() then
                    target_vampire = ent:IsVampire()
                    target_zombie = ent:IsZombie()
                end
            elseif client:IsMonsterTeam() then
                if client:IsZombie() then
                    target_fellow_zombie = ent:IsZombie()
                else
                    target_zombie = ent:IsZombie()
                end
                target_vampire = ent:IsVampire()
                if GetGlobalBool("ttt_monsters_know_swapper") then
                    target_jester = ent:IsJester()
                    target_swapper = ent:IsSwapper()
                else
                    target_jester = ent:IsJesterTeam()
                end

                -- Show traitor icons if Monsters-as-Traitors is enabled
                if GetGlobalBool("ttt_monsters_are_traitors") then
                    target_glitch = ent:IsGlitch()
                    target_traitor = ent:IsTraitor() or target_glitch
                    target_hypnotist = ent:IsHypnotist()
                    target_assassin = ent:IsAssassin()
                    target_detraitor = ent:IsDetraitor()
                end
            elseif client:IsAssassin() then
                target_current_target = (ent:Nick() == client:GetNWString("AssassinTarget", ""))
            elseif client:IsKiller() then
                if GetGlobalBool("ttt_killers_know_swapper") then
                    target_jester = ent:IsJester()
                    target_swapper = ent:IsSwapper()
                else
                    target_jester = ent:IsJesterTeam()
                end
            end

            target_detective = ent:IsDetective() or ent:IsDetraitor()
        end
    elseif cls == "prop_ragdoll" then
        -- only show this if the ragdoll has a nick, else it could be a mattress
        if CORPSE.GetPlayerNick(ent, false) == false then return end

        target_corpse = true

        if CORPSE.GetFound(ent, false) or not DetectiveMode() then
            text = CORPSE.GetPlayerNick(ent, "A Terrorist")
        else
            text = L.target_unid
            color = COLOR_YELLOW
        end
    elseif not hint then
        -- Not something to ID and not something to hint about
        return
    end

    local x_orig = ScrW() / 2.0
    local x = x_orig
    local y = ScrH() / 2.0

    local w, h = 0, 0 -- text width/height, reused several times

    if target_innocent or target_detective or target_glitch or target_mercenary or target_phantom or target_traitor or target_assassin or target_hypnotist or target_vampire or target_zombie or target_jester or target_swapper or target_killer or target_fellow_traitor or target_fellow_zombie or target_detraitor then
        surface.SetTexture(ring_tex)

        if target_innocent then
            surface.SetDrawColor(0, 255, 0, 200)
        elseif target_detraitor then
            surface.SetDrawColor(112, 27, 140, 200)
        elseif target_detective then
            surface.SetDrawColor(0, 0, 255, 200)
        elseif target_glitch and client:IsDetective() then
            surface.SetDrawColor(245, 106, 0, 200)
        elseif target_mercenary then
            surface.SetDrawColor(245, 200, 0, 200)
        elseif target_phantom then
            surface.SetDrawColor(82, 226, 255, 200)
        elseif target_traitor or target_fellow_traitor then
            surface.SetDrawColor(255, 0, 0, 200)
        elseif target_assassin then
            surface.SetDrawColor(112, 50, 0, 200)
        elseif target_hypnotist then
            surface.SetDrawColor(255, 80, 235, 200)
        elseif target_vampire then
            surface.SetDrawColor(45, 45, 45, 200)
        elseif target_zombie or target_fellow_zombie then
            surface.SetDrawColor(69, 97, 0, 200)
        elseif target_jester then
            surface.SetDrawColor(180, 23, 253, 200)
        elseif target_swapper then
            surface.SetDrawColor(180, 23, 253, 200)
        elseif target_killer then
            surface.SetDrawColor(50, 0, 70, 200)
        end
        surface.DrawTexturedRect(x - 32, y - 32, 64, 64)
    end

    y = y + 30
    local font = "TargetID"
    surface.SetFont(font)

    -- Draw main title, ie. nickname
    if text then
        w, h = surface.GetTextSize(text)

        x = x - w / 2

        draw.SimpleText(text, font, x + 1, y + 1, COLOR_BLACK)
        draw.SimpleText(text, font, x, y, color)

        -- for ragdolls searched by detectives, add icon
        if ent.search_result and client:IsDetective() then
            -- if I am detective and I know a search result for this corpse, then I
            -- have searched it or another detective has
            surface.SetMaterial(magnifier_mat)
            surface.SetDrawColor(200, 200, 255, 255)
            surface.DrawTexturedRect(x + w + 5, y, 16, 16)
        end

        y = y + h + 4
    end

    -- Minimalist target ID only draws a health-coloured nickname, no hints, no
    -- karma, no tag
    if minimal then return end

    -- Draw subtitle: health or type
    local clr = rag_color
    if ent:IsPlayer() then
        text, clr = util.HealthToString(ent:Health(), ent:GetMaxHealth())

        -- HealthToString returns a string id, need to look it up
        text = L[text]
    elseif hint then
        text = GetRaw(hint.name) or hint.name
    else
        return
    end
    font = "TargetIDSmall2"

    surface.SetFont(font)
    w, h = surface.GetTextSize(text)
    x = x_orig - w / 2

    draw.SimpleText(text, font, x + 1, y + 1, COLOR_BLACK)
    draw.SimpleText(text, font, x, y, clr)

    font = "TargetIDSmall"
    surface.SetFont(font)

    -- Draw second subtitle: karma
    if ent:IsPlayer() and KARMA.IsEnabled() then
        text, clr = util.KarmaToString(ent:GetBaseKarma())

        text = L[text]

        w, h = surface.GetTextSize(text)
        y = y + h + 5
        x = x_orig - w / 2

        draw.SimpleText(text, font, x + 1, y + 1, COLOR_BLACK)
        draw.SimpleText(text, font, x, y, clr)
    end

    -- Draw key hint
    if hint and hint.hint then
        if not hint.fmt then
            text = GetRaw(hint.hint) or hint.hint
        else
            text = hint.fmt(ent, hint.hint)
        end

        w, h = surface.GetTextSize(text)
        x = x_orig - w / 2
        y = y + h + 5
        draw.SimpleText(text, font, x + 1, y + 1, COLOR_BLACK)
        draw.SimpleText(text, font, x, y, COLOR_LGRAY)
    end

    text = nil
    if target_current_target then
        text = L.target_current_target
        clr = Color(112, 50, 0, 200)
    elseif target_innocent then
        text = L.target_innocent
        clr = Color(0, 255, 0, 200)
    elseif target_detraitor then
        text = L.target_detraitor
        clr = Color(112, 27, 140, 200)
    elseif target_detective then
        text = L.target_detective
        clr = Color(0, 0, 255, 200)
    elseif target_glitch and client:IsDetective() then
        text = L.target_glitch
        clr = Color(245, 106, 0, 200)
    elseif target_mercenary then
        text = L.target_mercenary
        clr = Color(245, 200, 0, 200)
    elseif target_phantom then
        text = L.target_phantom
        clr = Color(82, 226, 255, 200)
    elseif target_traitor then
        text = L.target_traitor
		clr = Color(255, 0, 0, 200)
	elseif target_assassin then
		text = L.target_assassin
		clr = Color(112, 50, 0, 200)
	elseif target_hypnotist then
		text = L.target_hypnotist
		clr = Color(255, 80, 235, 200)
	elseif target_vampire then
		text = L.target_vampire
		clr = Color(45, 45, 45, 200)
	elseif target_zombie then
		text = L.target_zombie
		clr = Color(69, 97, 0, 200)
	elseif target_jester then
		text = L.target_jester
		clr = Color(180, 23, 253, 200)
	elseif target_swapper then
		text = L.target_swapper
		clr = Color(180, 23, 253, 200)
	elseif target_killer then
		text = L.target_killer
		clr = Color(50, 0, 70, 200)
	elseif ent.sb_tag and ent.sb_tag.txt ~= nil then
		text = L[ent.sb_tag.txt]
		clr = ent.sb_tag.color
	elseif target_fellow_traitor then
		text = L.target_fellow_traitor
		clr = Color(255, 0, 0, 200)
	elseif target_fellow_zombie then
		text = L.target_fellow_zombie
		clr = Color(69, 97, 0, 200)
	elseif target_corpse and player.HasBuyMenu(client, true) and CORPSE.GetCredits(ent, 0) > 0 then
		text = L.target_credits
		clr = COLOR_YELLOW
	end

	if text then
		w, h = surface.GetTextSize(text)
		x = x_orig - w / 2
		y = y + h + 5

		draw.SimpleText(text, font, x + 1, y + 1, COLOR_BLACK)
		draw.SimpleText(text, font, x, y, clr)
	end
end
