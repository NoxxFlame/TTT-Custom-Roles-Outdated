AddCSLuaFile()

SWEP.HoldType = "ar2"

if CLIENT then
	SWEP.PrintName = "SG550"
	
	SWEP.Slot = 2
	
	SWEP.Icon = "VGUI/ttt/icon_sg550"
end

SWEP.Base = "weapon_tttbase"
SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.Kind = WEAPON_HEAVY
SWEP.WeaponID = AMMO_RIFLE

SWEP.CanBuy = { ROLE_MERCENARY }

SWEP.Primary.Delay = 0.6
SWEP.Primary.Recoil = 4
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "357"
SWEP.Primary.Damage = 30
SWEP.Primary.Cone = 0.005
SWEP.Primary.ClipSize = 10
SWEP.Primary.ClipMax = 20 -- keep mirrored to ammo
SWEP.Primary.DefaultClip = 10

SWEP.ConeSpray = 0 -- accuracy
SWEP.ConeIncrement = 0 -- Rate of innacuracy
SWEP.ConeMax = 0 -- Maximum Innacuracy
SWEP.ConeDecrement = 0 -- Rate of accuracy

SWEP.HeadshotMultiplier = 3

SWEP.AutoSpawnable = true
SWEP.AmmoEnt = "item_ammo_357_ttt"
SWEP.ViewModel = Model("models/weapons/v_snip_sg550.mdl")
SWEP.WorldModel = Model("models/weapons/w_snip_sg550.mdl")
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("Weapon_SG550.Single")

SWEP.Secondary.Sound = Sound("Default.Zoom")

SWEP.IronSightsPos = Vector(5, -15, -2)
SWEP.IronSightsAng = Vector(2.6, 1.37, 3.5)

SWEP.AllowDrop = true

function SWEP:SetZoom(state)
	if CLIENT then
		return
	else
		if state then
			self.Owner:SetFOV(20, 0.3)
		else
			self.Owner:SetFOV(0, 0.2)
		end
	end
end

-- Add some zoom to ironsights for this gun
function SWEP:SecondaryAttack()
	if not self.IronSightsPos then return end
	if self.Weapon:GetNextSecondaryFire() > CurTime() then return end
	
	bIronsights = not self:GetIronsights()
	
	self:SetIronsights(bIronsights)
	
	if SERVER then
		self:SetZoom(bIronsights)
	else
		self:EmitSound(self.Secondary.Sound)
	end
	
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.3)
end

function SWEP:PreDrop()
	self:SetZoom(false)
	self:SetIronsights(false)
	return self.BaseClass.PreDrop(self)
end

function SWEP:Reload()
	self.Weapon:DefaultReload(ACT_VM_RELOAD);
	self:SetIronsights(false)
	self:SetZoom(false)
end

function SWEP:Holster()
	self:SetIronsights(false)
	self:SetZoom(false)
	return true
end

if CLIENT then
	local scope = surface.GetTextureID("sprites/scope")
	function SWEP:DrawHUD()
		if self:GetIronsights() then
			surface.SetDrawColor(0, 0, 0, 255)
			
			local x = ScrW() / 2.0
			local y = ScrH() / 2.0
			local scope_size = ScrH()
			
			-- crosshair
			local gap = 80
			local length = scope_size
			surface.DrawLine(x - length, y, x - gap, y)
			surface.DrawLine(x + length, y, x + gap, y)
			surface.DrawLine(x, y - length, x, y - gap)
			surface.DrawLine(x, y + length, x, y + gap)
			
			gap = 0
			length = 50
			surface.DrawLine(x - length, y, x - gap, y)
			surface.DrawLine(x + length, y, x + gap, y)
			surface.DrawLine(x, y - length, x, y - gap)
			surface.DrawLine(x, y + length, x, y + gap)
			
			-- cover edges
			local sh = scope_size / 2
			local w = (x - sh) + 2
			surface.DrawRect(0, 0, w, scope_size)
			surface.DrawRect(x + sh - 2, 0, w, scope_size)
			
			surface.SetDrawColor(255, 0, 0, 255)
			surface.DrawLine(x, y, x + 1, y + 1)
			
			-- scope
			surface.SetTexture(scope)
			surface.SetDrawColor(255, 255, 255, 255)
			
			surface.DrawTexturedRectRotated(x, y, scope_size, scope_size, 0)
		
		else
			return self.BaseClass.DrawHUD(self)
		end
	end
	
	function SWEP:AdjustMouseSensitivity()
		return (self:GetIronsights() and 0.2) or nil
	end
end
