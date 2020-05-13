AddCSLuaFile()

SWEP.HoldType = "knife"

if CLIENT then
    SWEP.PrintName = "knife_name"
    SWEP.Slot = 0

    SWEP.ViewModelFlip = false
    SWEP.ViewModelFOV = 54
    SWEP.DrawCrosshair = false

    SWEP.EquipMenuData = {type = "item_weapon", desc = "knife_desc"};

    SWEP.Icon = "vgui/ttt/icon_knife"
    SWEP.IconLetter = "j"
end

SWEP.Base                   = "weapon_tttbase"

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel             = "models/weapons/w_knife_t.mdl"

SWEP.Primary.Damage         = 65
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay          = 0.8
SWEP.Primary.Ammo           = "none"

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"
SWEP.Secondary.Delay        = 12

SWEP.Kind                    = WEAPON_MELEE
SWEP.WeaponID                = AMMO_CROWBAR

SWEP.IsSilent               = true

SWEP.AllowDelete             = true -- never removed for weapon reduction
SWEP.AllowDrop = false

-- Pull out faster than standard guns
SWEP.DeploySpeed = 2

function SWEP:PrimaryAttack()
    self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    if not IsValid(self:GetOwner()) then return end

    self:GetOwner():LagCompensation(true)

    local spos = self:GetOwner():GetShootPos()
    local sdest = spos + (self:GetOwner():GetAimVector() * 70)

    local kmins = Vector(1, 1, 1) * -10
    local kmaxs = Vector(1, 1, 1) * 10

    local tr = util.TraceHull({start=spos, endpos=sdest, filter=self:GetOwner(), mask=MASK_SHOT_HULL, mins=kmins, maxs=kmaxs})

    -- Hull might hit environment stuff that line does not hit
    if not IsValid(tr.Entity) then
        tr = util.TraceLine({start=spos, endpos=sdest, filter=self:GetOwner(), mask=MASK_SHOT_HULL})
    end

    local hitEnt = tr.Entity

    -- effects
    if IsValid(hitEnt) then
        self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)

        local edata = EffectData()
        edata:SetStart(spos)
        edata:SetOrigin(tr.HitPos)
        edata:SetNormal(tr.Normal)
        edata:SetEntity(hitEnt)

        if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then
            self:GetOwner():SetAnimation(PLAYER_ATTACK1)
            self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
            util.Effect("BloodImpact", edata)
        end
    else
        self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
    end

    if SERVER then self:GetOwner():SetAnimation(PLAYER_ATTACK1) end

    if SERVER and tr.Hit and tr.HitNonWorld and IsValid(hitEnt) then
        if hitEnt:IsPlayer() then
            -- knife damage is never karma'd, so don't need to take that into
            -- account we do want to avoid rounding error strangeness caused by
            -- other damage scaling, causing a death when we don't expect one, so
            -- when the target's health is close to kill-point we just kill
            if hitEnt:Health() < (self.Primary.Damage + 10) then
                self:StabKill(tr, spos, sdest)
            else
                local dmg = DamageInfo()
                dmg:SetDamage(self.Primary.Damage)
                dmg:SetAttacker(self:GetOwner())
                dmg:SetInflictor(self.Weapon or self)
                dmg:SetDamageForce(self:GetOwner():GetAimVector() * 5)
                dmg:SetDamagePosition(self:GetOwner():GetPos())
                dmg:SetDamageType(DMG_SLASH)

                hitEnt:DispatchTraceAttack(dmg, spos + (self:GetOwner():GetAimVector() * 3), sdest)
            end
        end
    end

    self:GetOwner():LagCompensation(false)
end

function SWEP:StabKill(tr, spos, sdest)
    local target = tr.Entity

    local dmg = DamageInfo()
    dmg:SetDamage(2000)
    dmg:SetAttacker(self:GetOwner())
    dmg:SetInflictor(self.Weapon or self)
    dmg:SetDamageForce(self:GetOwner():GetAimVector())
    dmg:SetDamagePosition(self:GetOwner():GetPos())
    dmg:SetDamageType(DMG_SLASH)

    -- now that we use a hull trace, our hitpos is guaranteed to be
    -- terrible, so try to make something of it with a separate trace and
    -- hope our effect_fn trace has more luck

    -- first a straight up line trace to see if we aimed nicely
    local retr = util.TraceLine({start=spos, endpos=sdest, filter=self:GetOwner(), mask=MASK_SHOT_HULL})

    -- if that fails, just trace to worldcenter so we have SOMETHING
    if retr.Entity ~= target then
        local center = target:LocalToWorld(target:OBBCenter())
        retr = util.TraceLine({start=spos, endpos=center, filter=self:GetOwner(), mask=MASK_SHOT_HULL})
    end

    -- create knife effect creation fn
    local bone = retr.PhysicsBone
    local pos = retr.HitPos
    local norm = tr.Normal
    local ang = Angle(-28, 0, 0) + norm:Angle()
    ang:RotateAroundAxis(ang:Right(), -90)
    pos = pos - (ang:Forward() * 7)

    local ignore = self:GetOwner()

    target.effect_fn = function(rag)
        -- we might find a better location
        local rtr = util.TraceLine({start=pos, endpos=pos + norm * 40, filter=ignore, mask=MASK_SHOT_HULL})

        if IsValid(rtr.Entity) and rtr.Entity == rag then
            bone = rtr.PhysicsBone
            pos = rtr.HitPos
            ang = Angle(-28, 0, 0) + rtr.Normal:Angle()
            ang:RotateAroundAxis(ang:Right(), -90)
            pos = pos - (ang:Forward() * 10)

        end

        local knife = ents.Create("prop_physics")
        knife:SetModel("models/weapons/w_knife_t.mdl")
        knife:SetPos(pos)
        knife:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        knife:SetAngles(ang)
        knife.CanPickup = false

        knife:Spawn()

        local phys = knife:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableCollisions(false)
        end

        constraint.Weld(rag, knife, bone, 0, 0, true)

        -- need to close over knife in order to keep a valid ref to it
        rag:CallOnRemove("ttt_knife_cleanup", function() SafeRemoveEntity(knife) end)
    end

    -- seems the spos and sdest are purely for effects/forces?
    target:DispatchTraceAttack(dmg, spos + (self:GetOwner():GetAimVector() * 3),
                               sdest)
end

function SWEP:SecondaryAttack()
    self.Weapon:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
    if not IsFirstTimePredicted() then return end
    self:SetNextPrimaryFire(CurTime() + 1)

    if CLIENT then return end

    local nade = ents.Create("tot_smokenade")
    nade.HmcdSpawned = self.HmcdSpawned
    nade:SetPos(self.Owner:GetShootPos() + self.Owner:GetAimVector() * 20)
    nade:Spawn()
    nade:Activate()
    nade:GetPhysicsObject():SetVelocity(self.Owner:GetVelocity() +
                                            self.Owner:GetAimVector() * 300)
    sound.Play("snd_jack_hmcd_match.wav", self:GetPos(), 65,
               math.random(90, 110))
    sound.Play("weapons/slam/throw.wav", self:GetPos(), 65, math.random(90, 110))
end

function SWEP:OnDrop()
    self:Remove()
end
