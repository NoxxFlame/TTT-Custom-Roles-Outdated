AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "FAMAS"
	SWEP.Slot = 2 -- add 1 to get the slot number key
	
	SWEP.ViewModelFOV = 72
	SWEP.ViewModelFlip = false
	
	SWEP.Icon = "VGUI/ttt/icon_famas"
end

-- Always derive from weapon_tttbase.
SWEP.Base = "weapon_tttbase"

--- Standard GMod values

SWEP.HoldType = "ar2"

SWEP.Primary.Delay = 0.17
SWEP.Primary.Recoil = 1.6
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Damage = 23
SWEP.Primary.Cone = 0.018
SWEP.Primary.ClipSize = 30
SWEP.Primary.ClipMax = 90
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Sound = Sound("Weapon_FAMAS.Single")

SWEP.ViewModel = "models/weapons/v_rif_famas.mdl"
SWEP.WorldModel = "models/weapons/w_rif_famas.mdl"
SWEP.UseHands = true

SWEP.IronSightsPos = Vector(6, 0, 0.95)
SWEP.IronSightsAng = Vector(2.6, 1.37, 3.5)

SWEP.CanBuy = { ROLE_MERCENARY }

--- TTT
SWEP.Kind = WEAPON_HEAVY
SWEP.AutoSpawnable = true
SWEP.AmmoEnt = "item_ammo_pistol_ttt"
SWEP.InLoadoutFor = nil
SWEP.LimitedStock = true
SWEP.AllowDrop = true
SWEP.IsSilent = false
SWEP.NoSights = true
