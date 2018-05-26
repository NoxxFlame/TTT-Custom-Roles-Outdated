AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "P90"
	SWEP.Slot = 2
	
	SWEP.ViewModelFOV = 72
	SWEP.ViewModelFlip = true
	
	SWEP.Icon = "VGUI/ttt/icon_p90"
end

SWEP.Base = "weapon_tttbase"

SWEP.HoldType = "ar2"

SWEP.Primary.Damage = 15
SWEP.Primary.Delay = 0.065
SWEP.Primary.Cone = 0.03
SWEP.Primary.ClipSize = 45
SWEP.Primary.ClipMax = 90
SWEP.Primary.DefaultClip = 45
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"
SWEP.Primary.Recoil = 1.15
SWEP.Primary.Sound = Sound("Weapon_P90.Single")

SWEP.IronSightsPos = Vector(4.639, -2.12, 1.759)
SWEP.IronSightsAng = Vector(0, 0, 0)

SWEP.ViewModel = "models/weapons/v_smg_p90.mdl"
SWEP.WorldModel = "models/weapons/w_smg_p90.mdl"
SWEP.UseHands = true

-- TTT --

SWEP.Kind = WEAPON_HEAVY
SWEP.AutoSpawnable = true
SWEP.AmmoEnt = "item_ammo_smg1_ttt"
SWEP.CanBuy = { ROLE_MERCENARY }
SWEP.InLoadoutFor = nil
SWEP.LimitedStock = false
SWEP.AllowDrop = true
SWEP.IsSilent = false
SWEP.NoSights = false
