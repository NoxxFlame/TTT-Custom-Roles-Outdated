AddCSLuaFile()

if CLIENT then
    SWEP.PrintName = "Fangs"
    SWEP.EquipMenuData = {
        type = "Weapon",
        desc = "Left click to eat bodies. Right click to fade."
    };

    SWEP.Slot = 8 -- add 1 to get the slot number key
    SWEP.ViewModelFOV = 54
    SWEP.ViewModelFlip = false
    SWEP.UseHands = true
else
    util.AddNetworkString("TTT_Vampified")
end

SWEP.InLoadoutFor = { ROLE_VAMPIRE }

SWEP.Base = "weapon_tttbase"

SWEP.HoldType = "knife"

SWEP.ViewModel = Model("models/weapons/cstrike/c_knife_t.mdl")
SWEP.WorldModel = Model("models/weapons/w_knife_t.mdl")

SWEP.Primary.Ammo = "fade"
SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = false

SWEP.Secondary.Automatic = false

SWEP.Kind = WEAPON_ROLE
SWEP.LimitedStock = false
SWEP.AllowDrop = false

SWEP.Target = nil

local STATE_ERROR = -1
local STATE_NONE = 0
local STATE_EAT = 1
local STATE_DRAIN = 2
local STATE_CONVERT = 3

local beep = Sound("npc/fast_zombie/fz_alert_close1.wav")

function SWEP:SetupDataTables()
    self:NetworkVar("Int", 0, "State")
    self:NetworkVar("Float", 0, "StartTime")
    self:NetworkVar("String", 0, "Message")
    if SERVER then
        self:Reset()
    end
end

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    self.lastTickSecond = 0
    self.fading = false

    if CLIENT then
        self:AddHUDHelp("Left click suck blood from the living and dead", "Right click to fade", false)
    end
end

function SWEP:Holster()
    self:FireError()
    return not self.fading
end

function SWEP:OnDrop()
    self:Remove()
end

local function GetPlayerFromBody(body)
    local ply = false
    if body.sid == "BOT" then
        ply = player.GetByUniqueID(body.uqid)
    else
        ply = player.GetBySteamID(body.sid)
    end

    if not IsValid(ply) then return false end

    return ply
end

function SWEP:PrimaryAttack()
    if CLIENT then return end

    local tr = self:GetTraceEntity()
    if IsValid(tr.Entity) then
        local ent = tr.Entity
        if ent:GetClass() == "prop_ragdoll" then
            local ply = GetPlayerFromBody(ent)
            if not IsValid(ply) or ply:Alive() then
                self:Error("INVALID TARGET")
                return
            end

            self:Eat(tr.Entity)
        elseif ent:IsPlayer() then
            if ent:GetJester() or ent:GetSwapper() then
                self:Error("TARGET IS A JESTER")
            elseif ent:GetZombie() or ent:GetVampire() then
                self:Error("TARGET IS AN ALLY")
            else
                self:Drain(ent)
            end
        end
    end
end

function SWEP:SecondaryAttack()
    if self:Clip1() == 100 then
        self:SetClip1(0)
    end
end

function SWEP:Eat(entity)
    self:GetOwner():EmitSound("weapons/ttt/vampireeat.wav")
    self:SetState(STATE_EAT)
    self:SetStartTime(CurTime())
    self:SetMessage("EATING BODY")

    self.TargetEntity = entity

    self:SetNextPrimaryFire(CurTime() + GetConVar("ttt_vampire_fang_timer"):GetInt())
end

function SWEP:Drain(entity)
    self:GetOwner():EmitSound("weapons/ttt/vampireeat.wav")
    self:SetState(STATE_DRAIN)
    self:SetStartTime(CurTime())
    self:SetMessage("DRAINING")

    entity:PrintMessage(HUD_PRINTCENTER, self:GetOwner():Nick() .. " is draining your blood!")
    entity:Freeze(true)
    self.TargetEntity = entity

    self:SetNextPrimaryFire(CurTime() + GetConVar("ttt_vampire_fang_timer"):GetInt())
end

function SWEP:FireError()
    self:SetState(STATE_NONE)

    if IsValid(self.TargetEntity) and self.TargetEntity:IsPlayer() then
        self.TargetEntity:Freeze(false)
    end

    self:SetNextPrimaryFire(CurTime() + 0.1)
end

function SWEP:DropBones()
    local pos = self.TargetEntity:GetPos()

    local skull = ents.Create("prop_physics")
    if not IsValid(skull) then return end
    skull:SetModel("models/Gibs/HGIBS.mdl")
    skull:SetPos(pos)
    skull:Spawn()
    skull:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    local ribs = ents.Create("prop_physics")
    if not IsValid(ribs) then return end
    ribs:SetModel("models/Gibs/HGIBS_rib.mdl")
    ribs:SetPos(pos + Vector(0, 0, 15))
    ribs:Spawn()
    ribs:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    local spine = ents.Create("prop_physics")
    if not IsValid(ribs) then return end
    spine:SetModel("models/Gibs/HGIBS_spine.mdl")
    spine:SetPos(pos + Vector(0, 0, 30))
    spine:Spawn()
    spine:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    local scapula = ents.Create("prop_physics")
    if not IsValid(scapula) then return end
    scapula:SetModel("models/Gibs/HGIBS_scapula.mdl")
    scapula:SetPos(pos + Vector(0, 0, 45))
    scapula:Spawn()
    scapula:SetCollisionGroup(COLLISION_GROUP_WEAPON)
end

function SWEP:Think()
    if CLIENT then return end

    if (CurTime() - self.lastTickSecond > 0.08) and (self:Clip1() <= 100) then
        self:SetClip1(self:Clip1() + math.min(1, 100 - self:Clip1()))
        self.lastTickSecond = CurTime()
    end

    if self:Clip1() < 15 and not self.fading then
        self.fading = true
        self:GetOwner():SetColor(Color(255, 255, 255, 0))
        self:GetOwner():SetMaterial("sprites/heatwave")
        self:GetOwner():EmitSound("weapons/ttt/fade.wav")
    elseif self:Clip1() >= 40 and self.fading then
        self.fading = false
        self:GetOwner():SetColor(Color(255, 255, 255, 255))
        self:GetOwner():SetMaterial("models/glass")
        self:GetOwner():EmitSound("weapons/ttt/unfade.wav")
    end

    if self:GetState() == STATE_EAT or self:GetState() == STATE_DRAIN or self:GetState() == STATE_CONVERT then
        if not IsValid(self:GetOwner()) then
            self:FireError()
            return
        end

        local tr = self:GetTraceEntity()
        if not self:GetOwner():KeyDown(IN_ATTACK) or tr.Entity ~= self.TargetEntity then
            if self:GetState() == STATE_CONVERT then
                local ply = self.TargetEntity
                ply:StripWeapon("weapon_hyp_brainwash")
                ply:StripWeapon("weapon_ttt_wtester")
                ply:SetRole(ROLE_VAMPIRE)
                ply:PrintMessage(HUD_PRINTCENTER, "You have become a Vampire! Use your fangs to suck blood or fade from view")

                net.Start("TTT_Vampified")
                net.WriteString(ply:Nick())
                net.Broadcast()

                -- Not actually an error, but it resets the things we want
                self:FireError()

                SendFullStateUpdate()
            else
                self:Error("DRAINING ABORTED")
            end
            return
        end

        if self:GetState() == STATE_EAT or self:GetState() == STATE_CONVERT then
            if CurTime() >= self:GetStartTime() + GetConVar("ttt_vampire_fang_timer"):GetInt() then
                if self:GetState() == STATE_CONVERT then
                    local attacker = self:GetOwner()
                    local dmginfo = DamageInfo()
                    dmginfo:SetDamage(10000)
                    dmginfo:SetAttacker(attacker)
                    dmginfo:SetInflictor(game.GetWorld())
                    dmginfo:SetDamageType(DMG_SLASH)
                    dmginfo:SetDamageForce(Vector(0, 0, 0))
                    dmginfo:SetDamagePosition(attacker:GetPos())
                    self.TargetEntity:TakeDamageInfo(dmginfo)

                    -- Remove the body
                    local rag = self.TargetEntity.server_ragdoll or self.TargetEntity:GetRagdollEntity()
                    if IsValid(rag) then
                        rag:Remove()
                    end
                else
                    self.TargetEntity:Remove()
                end

                self:SetState(STATE_NONE)

                local vamheal = GetConVar("ttt_vampire_fang_heal"):GetInt()
                local vamoverheal = GetConVar("ttt_vampire_fang_overheal"):GetInt()
                self:GetOwner():SetHealth(math.min(self:GetOwner():Health() + vamheal, self:GetOwner():GetMaxHealth() + vamoverheal))

                self:DropBones()
            end
        else
            if CurTime() >= self:GetStartTime() + (GetConVar("ttt_vampire_fang_timer"):GetInt() / 2) then
                self:SetState(STATE_CONVERT)
                self:SetMessage("DRAINING - RELEASE TO CONVERT")
            end
        end
    end
end

if CLIENT then
    function SWEP:DrawHUD()
        local x = ScrW() / 2.0
        local y = ScrH() / 2.0

        y = y + (y / 3)

        local w, h = 255, 20

        if self:GetState() == STATE_EAT or self:GetState() == STATE_DRAIN or self:GetState() == STATE_CONVERT then
            local progress = math.TimeFraction(self:GetStartTime(), self:GetStartTime() + GetConVar("ttt_vampire_fang_timer"):GetInt(), CurTime())

            if progress < 0 then return end

            progress = math.Clamp(progress, 0, 1)

            surface.SetDrawColor(0, 255, 0, 155)

            surface.DrawOutlinedRect(x - w / 2, y - h, w, h)

            surface.DrawRect(x - w / 2, y - h, w * progress, h)

            surface.SetFont("TabLarge")
            surface.SetTextColor(255, 255, 255, 180)
            surface.SetTextPos((x - w / 2) + 3, y - h - 15)
            surface.DrawText(self:GetMessage())
        elseif self:GetState() == STATE_ERROR then
            surface.SetDrawColor(200 + math.sin(CurTime() * 32) * 50, 0, 0, 155)

            surface.DrawOutlinedRect(x - w / 2, y - h, w, h)

            surface.DrawRect(x - w / 2, y - h, w, h)

            surface.SetFont("TabLarge")
            surface.SetTextColor(255, 255, 255, 180)
            surface.SetTextPos((x - w / 2) + 3, y - h - 15)
            surface.DrawText(self:GetMessage())
        end
    end
else
    function SWEP:Reset()
        self:SetState(STATE_NONE)
        self:SetStartTime(-1)
        self:SetMessage('')
        self:SetNextPrimaryFire(CurTime() + 0.1)
        self.TargetEntity = nil
    end

    function SWEP:Error(msg)
        self:SetState(STATE_ERROR)
        self:SetStartTime(CurTime())
        self:SetMessage(msg)

        self:GetOwner():EmitSound(beep, 60, 50, 1)

        if IsValid(self.TargetEntity) and self.TargetEntity:IsPlayer() then
            self.TargetEntity:Freeze(false)
        end
        self.TargetEntity = nil

        timer.Simple(0.75, function()
            if IsValid(self) then self:Reset() end
        end)
    end

    function SWEP:GetTraceEntity()
        local spos = self:GetOwner():GetShootPos()
        local sdest = spos + (self:GetOwner():GetAimVector() * 70)
        local kmins = Vector(1,1,1) * -10
        local kmaxs = Vector(1,1,1) * 10

        return util.TraceHull({start=spos, endpos=sdest, filter=self:GetOwner(), mask=MASK_SHOT_HULL, mins=kmins, maxs=kmaxs})
    end
end