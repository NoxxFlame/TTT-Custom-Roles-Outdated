AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "MP5"
	SWEP.Slot = 2 -- add 1 to get the slot number key
	
	SWEP.ViewModelFOV = 72
	SWEP.ViewModelFlip = true
	
	SWEP.Icon = "VGUI/ttt/icon_mp5"
end

-- Always derive from weapon_tttbase.
SWEP.Base = "weapon_tttbase"

--- Standard GMod values

SWEP.HoldType = "ar2"

SWEP.Primary.Delay = 0.093
SWEP.Primary.Recoil = 1.2
SWEP.Primary.Automatic = true
SWEP.Primary.Damage = 11
SWEP.Primary.Cone = 0.03
SWEP.Primary.Ammo = "smg1"
SWEP.Primary.ClipSize = 30
SWEP.Primary.ClipMax = 60
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Sound = Sound("Weapon_MP5Navy.Single")

SWEP.IronSightsPos = Vector(4.84, 0.36, 1.84)
SWEP.IronSightsAng = Vector(1.1, 0.3, 0)

SWEP.ViewModel = "models/weapons/v_smg_mp5.mdl"
SWEP.WorldModel = "models/weapons/w_smg_mp5.mdl"
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