AddCSLuaFile()

SWEP.HoldType = "crossbow"

if CLIENT then
	SWEP.PrintName = "H.U.G.E-249"
	SWEP.Slot = 2
	
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 54
	
	SWEP.Icon = "vgui/ttt/icon_m249"
	SWEP.IconLetter = "z"
end

SWEP.Base = "weapon_tttbase"

SWEP.Spawnable = true
SWEP.AutoSpawnable = true

SWEP.Kind = WEAPON_HEAVY
SWEP.CanBuy = { ROLE_MERCENARY }
SWEP.WeaponID = AMMO_M249

SWEP.Primary.Damage = 8
SWEP.Primary.Delay = 0.06
SWEP.Primary.Cone = 0.05
SWEP.Primary.ClipSize = 150
SWEP.Primary.ClipMax = 150
SWEP.Primary.DefaultClip = 150
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"
SWEP.Primary.Recoil = 1.2
SWEP.Primary.Sound = Sound("Weapon_m249.Single")
SWEP.AmmoEnt = "item_ammo_smg1_ttt"

SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_mach_m249para.mdl"
SWEP.WorldModel = "models/weapons/w_mach_m249para.mdl"

SWEP.HeadshotMultiplier = 2.2

SWEP.IronSightsPos = Vector(-5.96, -5.119, 2.349)
SWEP.IronSightsAng = Vector(0, 0, 0)
