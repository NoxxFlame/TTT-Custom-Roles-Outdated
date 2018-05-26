AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "Galil"
	SWEP.Slot = 2 -- add 1 to get the slot number key
	
	SWEP.ViewModelFOV = 72
	SWEP.ViewModelFlip = false
	
	SWEP.Icon = "VGUI/ttt/icon_galil"
end

-- Always derive from weapon_tttbase.
SWEP.Base = "weapon_tttbase"

--- Standard GMod values

SWEP.HoldType = "ar2"

SWEP.Primary.Delay = 0.16
SWEP.Primary.Recoil = 1.5
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Damage = 24
SWEP.Primary.Cone = 0.018
SWEP.Primary.ClipSize = 20
SWEP.Primary.ClipMax = 60
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Sound = Sound("Weapon_Galil.Single")

SWEP.ViewModel = "models/weapons/v_rif_galil.mdl"
SWEP.WorldModel = "models/weapons/w_rif_galil.mdl"
SWEP.UseHands = true

SWEP.IronSightsPos = Vector(-5.16, 0, 2.279)
SWEP.IronSightsAng = Vector(0, 0, 0)

-- TTT --
SWEP.Kind = WEAPON_HEAVY
SWEP.AutoSpawnable = true
SWEP.AmmoEnt = "item_ammo_pistol_ttt"
SWEP.CanBuy = { ROLE_MERCENARY }
SWEP.InLoadoutFor = nil
SWEP.LimitedStock = true
SWEP.AllowDrop = true
SWEP.IsSilent = false
SWEP.NoSights = false