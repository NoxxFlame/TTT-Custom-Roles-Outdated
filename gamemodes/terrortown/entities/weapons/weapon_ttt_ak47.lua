AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "AK47"
	SWEP.Slot = 2 -- add 1 to get the slot number key
	
	SWEP.ViewModelFOV = 72
	SWEP.ViewModelFlip = true
	
	SWEP.Icon = "VGUI/ttt/icon_ak47"
end

-- Always derive from weapon_tttbase.
SWEP.Base = "weapon_tttbase"

--- Standard GMod values

SWEP.HoldType = "ar2"

SWEP.Primary.Delay = 0.15
SWEP.Primary.Recoil = 2
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Damage = 22
SWEP.Primary.Cone = 0.018
SWEP.Primary.ClipSize = 30
SWEP.Primary.ClipMax = 60
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Sound = Sound("Weapon_AK47.Single")

SWEP.IronSightsPos = Vector(6.05, -5, 2.4)
SWEP.IronSightsAng = Vector(2.2, -0.1, 0)

SWEP.ViewModel = "models/weapons/v_rif_ak47.mdl"
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"
SWEP.UseHands = true

SWEP.CanBuy = { ROLE_MERCENARY }

--- TTT config values

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_HEAVY

-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2, then this gun can
-- be spawned as a random weapon. Of course this AK is special equipment so it won't,
-- but for the sake of example this is explicitly set to false anyway.
SWEP.AutoSpawnable = true

-- The AmmoEnt is the ammo entity that can be picked up when carrying this gun.
SWEP.AmmoEnt = "item_ammo_pistol_ttt"

-- InLoadoutFor is a table of ROLE_* entries that specifies which roles should
-- receive this weapon as soon as the round starts. In this case, none.
SWEP.InLoadoutFor = nil

-- If LimitedStock is true, you can only buy one per round.
SWEP.LimitedStock = true

-- If AllowDrop is false, players can't manually drop the gun with Q
SWEP.AllowDrop = true

-- If IsSilent is true, victims will not scream upon death.
SWEP.IsSilent = false

-- If NoSights is true, the weapon won't have ironsights
SWEP.NoSights = false

-- Equipment menu information is only needed on the client
if CLIENT then
	-- Text shown in the equip menu
	SWEP.EquipMenuData = {
		type = "Weapon",
		desc = "High powered assault rifle."
	};
end
