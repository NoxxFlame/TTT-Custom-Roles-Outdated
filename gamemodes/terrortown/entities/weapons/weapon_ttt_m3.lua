AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "M3"
	SWEP.Slot = 2 -- add 1 to get the slot number key
	SWEP.Icon = "VGUI/ttt/icon_m3"
	
	SWEP.ViewModelFOV = 72
	SWEP.ViewModelFlip = true
end

-- Always derive from weapon_tttbase.
SWEP.Base = "weapon_tttbase"

--- Standard GMod values

SWEP.HoldType = "shotgun"

SWEP.Primary.Delay = 0.8
SWEP.Primary.Recoil = 6
SWEP.Primary.Automatic = true
SWEP.Primary.Damage = 8
SWEP.Primary.Cone = 0.105
SWEP.Primary.Ammo = "Buckshot"
SWEP.Primary.ClipSize = 12
SWEP.Primary.ClipMax = 24
SWEP.Primary.DefaultClip = 12
SWEP.Primary.NumShots = 12
SWEP.Primary.Sound = Sound("Weapon_M3.Single")
SWEP.reloadtimer = 0

SWEP.IronSightsPos = Vector(5.719, 0, 3.4)
SWEP.IronSightsAng = Vector(0, 0, 0)

SWEP.ViewModel = "models/weapons/v_shot_m3super90.mdl"
SWEP.WorldModel = "models/weapons/w_shot_m3super90.mdl"
SWEP.UseHands = true

SWEP.CanBuy = { ROLE_MERCENARY }

-- TTT -
SWEP.Kind = WEAPON_HEAVY
SWEP.AutoSpawnable = true
SWEP.AmmoEnt = "item_box_buckshot_ttt"
SWEP.InLoadoutFor = nil
SWEP.LimitedStock = true
SWEP.AllowDrop = true
SWEP.IsSilent = false
SWEP.NoSights = false

if CLIENT then
	-- Text shown in the equip menu
	SWEP.EquipMenuData = {
		type = "Weapon",
		desc = "High powered pump-shotgun, use with caution."
	};
end

function SWEP:SetupDataTables()
	self:DTVar("Bool", 0, "reloading")
	
	return self.BaseClass.SetupDataTables(self)
end

function SWEP:Reload()
	self:SetIronsights(false)
	
	--if self.Weapon:GetNetworkedBool( "reloading", false ) then return end
	if self.dt.reloading then return end
	
	if not IsFirstTimePredicted() then return end
	
	if self.Weapon:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
		
		if self:StartReload() then
			return
		end
	end
end

function SWEP:StartReload()
	--if self.Weapon:GetNWBool( "reloading", false ) then
	if self.dt.reloading then
		return false
	end
	
	if not IsFirstTimePredicted() then return false end
	
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	
	local ply = self.Owner
	
	if not ply or ply:GetAmmoCount(self.Primary.Ammo) <= 0 then
		return false
	end
	
	local wep = self.Weapon
	
	if wep:Clip1() >= self.Primary.ClipSize then
		return false
	end
	
	wep:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
	
	self.reloadtimer = CurTime() + wep:SequenceDuration()
	
	--wep:SetNWBool("reloading", true)
	self.dt.reloading = true
	
	return true
end

function SWEP:PerformReload()
	local ply = self.Owner
	
	-- prevent normal shooting in between reloads
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	
	if not ply or ply:GetAmmoCount(self.Primary.Ammo) <= 0 then return end
	
	local wep = self.Weapon
	
	if wep:Clip1() >= self.Primary.ClipSize then return end
	
	self.Owner:RemoveAmmo(1, self.Primary.Ammo, false)
	self.Weapon:SetClip1(self.Weapon:Clip1() + 1)
	
	wep:SendWeaponAnim(ACT_VM_RELOAD)
	
	self.reloadtimer = CurTime() + wep:SequenceDuration()
end

function SWEP:FinishReload()
	self.dt.reloading = false
	self.Weapon:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
	
	self.reloadtimer = CurTime() + self.Weapon:SequenceDuration()
end

function SWEP:CanPrimaryAttack()
	if self.Weapon:Clip1() <= 0 then
		self:EmitSound("Weapon_Shotgun.Empty")
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		return false
	end
	return true
end

function SWEP:Think()
	if self.dt.reloading and IsFirstTimePredicted() then
		if self.Owner:KeyDown(IN_ATTACK) then
			self:FinishReload()
			return
		end
		
		if self.reloadtimer <= CurTime() then
			
			if self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then
				self:FinishReload()
			elseif self.Weapon:Clip1() < self.Primary.ClipSize then
				self:PerformReload()
			else
				self:FinishReload()
			end
			return
		end
	end
end

function SWEP:Deploy()
	self.dt.reloading = false
	self.reloadtimer = 0
	return self.BaseClass.Deploy(self)
end

-- The shotgun's headshot damage multiplier is based on distance. The closer it
-- is, the more damage it does. This reinforces the shotgun's role as short
-- range weapon by reducing effectiveness at mid-range, where one could score
-- lucky headshots relatively easily due to the spread.
function SWEP:GetHeadshotMultiplier(victim, dmginfo)
	local att = dmginfo:GetAttacker()
	if not IsValid(att) then return 3 end
	
	local dist = victim:GetPos():Distance(att:GetPos())
	local d = math.max(0, dist - 140)
	
	-- decay from 3.1 to 1 slowly as distance increases
	return 1 + math.max(0, (2.1 - 0.002 * (d ^ 1.25)))
end

