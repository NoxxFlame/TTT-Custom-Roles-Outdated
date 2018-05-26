AddCSLuaFile()

SWEP.HoldType = "pistol"

if CLIENT then
	SWEP.PrintName = "P228"
	SWEP.Slot = 1
	
	SWEP.Icon = "VGUI/ttt/icon_p228"
end

SWEP.Kind = WEAPON_PISTOL
SWEP.WeaponID = AMMO_PISTOL

SWEP.Base = "weapon_tttbase"
SWEP.Primary.Recoil = 1.6
SWEP.Primary.Damage = 30
SWEP.Primary.Delay = 0.4
SWEP.Primary.Cone = 0.018
SWEP.Primary.ClipSize = 20
SWEP.Primary.Automatic = true
SWEP.Primary.DefaultClip = 20
SWEP.Primary.ClipMax = 60
SWEP.Primary.Ammo = "AlyxGun"
SWEP.AutoSpawnable = true
SWEP.AmmoEnt = "item_ammo_revolver_ttt"

SWEP.ViewModel = "models/weapons/v_pist_p228.mdl"
SWEP.WorldModel = "models/weapons/w_pist_p228.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("Weapon_P228.Single")
SWEP.IronSightsPos = Vector(4.719, 0, 2.799)
SWEP.IronSightsAng = Vector(0, 0, 0)

SWEP.CanBuy = { ROLE_MERCENARY }