AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "TMP"
	SWEP.Slot = 2 -- add 1 to get the slot number key
	
	SWEP.ViewModelFOV = 72
	SWEP.ViewModelFlip = true
	
	SWEP.Icon = "VGUI/ttt/icon_tmp"
end

-- Always derive from weapon_tttbase.
SWEP.Base = "weapon_tttbase"

--- Standard GMod values

SWEP.HoldType = "ar2"

SWEP.Primary.Damage = 10
SWEP.Primary.Delay = 0.085
SWEP.Primary.Cone = 0.03
SWEP.Primary.ClipSize = 30
SWEP.Primary.ClipMax = 60
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"
SWEP.Primary.Recoil = 1.15
SWEP.Primary.Sound = Sound("Weapon_TMP.Single")

SWEP.IronSightsPos = Vector(5.239, 0, 2.68)
SWEP.IronSightsAng = Vector(0, 0, 0)

SWEP.ViewModel = "models/weapons/v_smg_tmp.mdl"
SWEP.WorldModel = "models/weapons/w_smg_tmp.mdl"
SWEP.UseHands = true

SWEP.Kind = WEAPON_HEAVY
SWEP.AutoSpawnable = true
SWEP.AmmoEnt = "item_ammo_smg1_ttt"
SWEP.CanBuy = { ROLE_MERCENARY }
SWEP.InLoadoutFor = nil
SWEP.LimitedStock = false
SWEP.AllowDrop = true
SWEP.IsSilent = true
SWEP.NoSights = false

