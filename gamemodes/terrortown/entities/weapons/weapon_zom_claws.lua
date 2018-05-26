AddCSLuaFile()

SWEP.HoldType = "knife"

if CLIENT then
	SWEP.PrintName = "Claws"
	SWEP.Slot = 8
	
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 54
else
	util.AddNetworkString("TTT_Zombified")
end

SWEP.Base = "weapon_tttbase"

SWEP.UseHands = true
SWEP.ViewModel = Model("models/weapons/cstrike/c_knife_t.mdl")
SWEP.WorldModel = Model("models/weapons/w_knife_t.mdl")

SWEP.Primary.Damage = 50
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Delay = 0.6
SWEP.Primary.Ammo = "none"
SWEP.AllowDrop = false

SWEP.Kind = WEAPON_ROLE
SWEP.InLoadoutFor = { ROLE_ZOMBIE }

SWEP.IsSilent = true

-- Pull out faster than standard guns
SWEP.DeploySpeed = 2
local sound_single = Sound("Weapon_Crowbar.Single")

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	
	if not IsValid(self:GetOwner()) then return end
	
	if self:GetOwner().LagCompensation then -- for some reason not always true
		self:GetOwner():LagCompensation(true)
	end
	
	local spos = self:GetOwner():GetShootPos()
	local sdest = spos + (self:GetOwner():GetAimVector() * 120)
	
	tr_main = util.TraceLine({ start = spos, endpos = sdest, filter = self:GetOwner(), mask = MASK_SHOT_HULL })
	local hitEnt = tr_main.Entity
	
	self.Weapon:EmitSound(sound_single)
	
	if IsValid(hitEnt) or tr_main.HitWorld then
		if not (CLIENT and (not IsFirstTimePredicted())) then
			local edata = EffectData()
			edata:SetStart(spos)
			edata:SetOrigin(tr_main.HitPos)
			edata:SetNormal(tr_main.Normal)
			edata:SetSurfaceProp(tr_main.SurfaceProps)
			edata:SetHitBox(tr_main.HitBox)
			edata:SetEntity(hitEnt)
			
			if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then
				util.Effect("BloodImpact", edata)
				self:GetOwner():LagCompensation(false)
				self:GetOwner():FireBullets({ Num = 1, Src = spos, Dir = self:GetOwner():GetAimVector(), Spread = Vector(0, 0, 0), Tracer = 0, Force = 1, Damage = 0 })
			else
				util.Effect("Impact", edata)
			end
		end
	end
	self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
	
	if not CLIENT then
		self:GetOwner():SetAnimation(PLAYER_ATTACK1)
		
		if hitEnt and hitEnt:IsValid() then
			if hitEnt:IsPlayer() and not hitEnt:IsZombie() then
				if hitEnt:Health() <= 50 and not hitEnt:IsJester() and not hitEnt:IsSwapper() then
					self:GetOwner():AddCredits(1)
					LANG.Msg(self:GetOwner(), "credit_zom", { num = 1 })
					hitEnt:PrintMessage(HUD_PRINTCENTER, "You will respawn as a zombie in 3 seconds.")
					hitEnt:SetPData("IsZombifying", 1)
					
					net.Start("TTT_Zombified")
					net.WriteString(hitEnt:Nick())
					net.Broadcast()
					
					timer.Simple(3, function()
						local body = hitEnt.server_ragdoll or hitEnt:GetRagdollEntity()
						hitEnt:SpawnForRound(true)
						hitEnt:SetCredits(0)
						hitEnt:SetPos(FindRespawnLocation(body:GetPos()) or body:GetPos())
						hitEnt:SetEyeAngles(Angle(0, body:GetAngles().y, 0))
						hitEnt:SetRole(ROLE_ZOMBIE)
						hitEnt:SetHealth(100)
						hitEnt:Give("weapon_zom_claws")
						hitEnt:SetPData("IsZombifying", 0)
						body:Remove()
						for k, v in pairs(player.GetAll()) do
							if v:IsActiveGlitch() then
								hitEnt:PrintMessage(HUD_PRINTTALK, "There is a Glitch.")
								hitEnt:PrintMessage(HUD_PRINTCENTER, "There is a Glitch.")
							end
						end
						SendFullStateUpdate()
					end)
				end
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
	
	if self:GetOwner().LagCompensation then
		self:GetOwner():LagCompensation(false)
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:Deploy()
	self:GetOwner():SetColor(Color(70, 100, 25, 255))
end

function SWEP:Holster(weapon)
	self:GetOwner():SetColor(Color(255, 255, 255, 255))
	return true
end

local offsets = {}

for i = 0, 360, 15 do
	table.insert(offsets, Vector(math.sin(i), math.cos(i), 0))
end

function FindRespawnLocation(pos)
	local midsize = Vector(33, 33, 74)
	local tstart = pos + Vector(0, 0, midsize.z / 2)
	
	for i = 1, #offsets do
		local o = offsets[i]
		local v = tstart + o * midsize * 1.5
		
		local t = {
			start = v,
			endpos = v,
			filter = target,
			mins = midsize / -2,
			maxs = midsize / 2
		}
		
		local tr = util.TraceHull(t)
		
		if not tr.Hit then return (v - Vector(0, 0, midsize.z / 2)) end
	end
	
	return false
end

hook.Add("TTTPlayerSpeed", "ClawsSpeed", function(ply, slowed)
	local wep = ply:GetActiveWeapon()
	if wep and IsValid(wep) and wep:GetClass() == "weapon_zom_claws" then
		if ply:HasEquipmentItem(EQUIP_SPEED) then
			return 1.5
		else
			return 1.35
		end
	end
end)

