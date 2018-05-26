CreateConVar("ttt_rp_railgun_sound", 1, { FCVAR_SERVER_CAN_EXECUTE }, "Makes the Railgun emit a sound to indicate its current charge level")
if SERVER then
	AddCSLuaFile()
end

SWEP.HoldType = "ar2"

if CLIENT then
	SWEP.PrintName = "Railgun"
	SWEP.Slot = 2
	SWEP.Icon = "vgui/ttt/icon_rgun"
end

SWEP.Base = "weapon_tttbase"
SWEP.Spawnable = true
SWEP.CanBuy = { ROLE_MERCENARY }

SWEP.Kind = WEAPON_HEAVY

SWEP.Primary.Delay = 2.5
SWEP.Primary.Recoil = 7
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "357"
SWEP.Primary.Damage = 20
SWEP.Primary.Cone = 0.005
SWEP.Primary.ClipSize = 8
SWEP.Primary.ClipMax = 20 -- keep mirrored to ammo
SWEP.Primary.DefaultClip = 8

SWEP.HeadshotMultiplier = 4

SWEP.AutoSpawnable = true
SWEP.AmmoEnt = "item_ammo_357_ttt"

SWEP.UseHands = false
SWEP.ViewModelFlip = true
SWEP.ViewModelFOV = 70
SWEP.ViewModel = "models/weapons/v_aw50_awp.mdl"
SWEP.WorldModel = "models/weapons/w_acc_int_aw50.mdl"

SWEP.Primary.Sound = "weapons/aw50/barret50-1.wav"
SWEP.Primary.Special1 = "weapons/aw50/bfg_firebegin.wav"
SWEP.Primary.Special2 = Sound("Buttons.snd3")

SWEP.Secondary.Sound = Sound("Default.Zoom")

SWEP.IronSightsPos = Vector(3.68, -15, 1.08)
SWEP.IronSightsAng = Vector(0, 0, 0)

function SWEP:ShootBullet(dmg, recoil, numbul, cone)
	
	self:SendWeaponAnim(self.PrimaryAnim)
	
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	if not IsFirstTimePredicted() then return end
	
	local sights = self:GetIronsights()
	
	numbul = numbul or 1
	cone = cone or 0.01
	
	local bullet = {}
	bullet.Num = numbul
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = self.Owner:GetAimVector()
	bullet.Spread = Vector(cone, cone, 0)
	bullet.Tracer = 1
	bullet.TracerName = "ToolTracer"
	bullet.Force = 10
	bullet.Damage = dmg
	
	self.Owner:FireBullets(bullet)
	
	-- Owner can die after firebullets
	if (not IsValid(self.Owner)) or (not self.Owner:Alive()) or self.Owner:IsNPC() then return end
	
	if ((game.SinglePlayer() and SERVER) or
			((not game.SinglePlayer()) and CLIENT and IsFirstTimePredicted())) then
		
		-- reduce recoil if ironsighting
		recoil = sights and (recoil * 0.6) or recoil
		
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil
		self.Owner:SetEyeAngles(eyeang)
	end
end

function SWEP:PrimaryAttack(worldsnd)
	if (self:Clip1() == 0) then return end
	self.InAttack = true
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	
	if SERVER then
		self.ChargeSound = CreateSound(self.Owner, self.Primary.Special1)
		self.ChargeSound:SetSoundLevel(90)
		self.ChargeSound:Play()
	end
	
	self.mode1 = CurTime()
	if (self:Clip1() > 1) then
		self.mode2 = CurTime() + 0.6
	end
	if (self:Clip1() > 2) then
		self.mode3 = CurTime() + 1.2
	end
	if (self:Clip1() > 3) then
		self.mode4 = CurTime() + 1.8
	end
	self.overcharge = CurTime() + 2.4
end

function SWEP:Think()
	if self.mode1 and CurTime() > self.mode1 then
		self.mode1 = nil
		if not self.Owner:KeyDown(IN_ATTACK) then return end
		self.mode = "single"
		if (ConVarExists("ttt_rp_railgun_sound")) then
			if GetConVar("ttt_rp_railgun_sound"):GetBool() then self:EmitSound(self.Primary.Special2, self.Primary.SoundLevel) end
		end
	end
	
	if self.mode2 and CurTime() > self.mode2 then
		self.mode2 = nil
		if not self.Owner:KeyDown(IN_ATTACK) then return end
		self.mode = "2"
		if (ConVarExists("ttt_rp_railgun_sound")) then
			if GetConVar("ttt_rp_railgun_sound"):GetBool() then self:EmitSound(self.Primary.Special2, self.Primary.SoundLevel) end
		end
	end
	
	if self.mode3 and CurTime() > self.mode3 then
		self.mode3 = nil
		if not self.Owner:KeyDown(IN_ATTACK) then return end
		self.mode = "3"
		if (ConVarExists("ttt_rp_railgun_sound")) then
			if GetConVar("ttt_rp_railgun_sound"):GetBool() then self:EmitSound(self.Primary.Special2, self.Primary.SoundLevel) end
		end
	end
	
	if self.mode4 and CurTime() > self.mode4 then
		self.mode4 = nil
		if not self.Owner:KeyDown(IN_ATTACK) then return end
		self.mode = "4"
		if (ConVarExists("ttt_rp_railgun_sound")) then
			if GetConVar("ttt_rp_railgun_sound"):GetBool() then self:EmitSound(self.Primary.Special2, self.Primary.SoundLevel) end
		end
	end
	
	if self.overcharge and CurTime() > self.overcharge then
		self.overcharge = nil
		if not self.Owner:KeyDown(IN_ATTACK) then return end
		self:Explode()
	end
	
	if not self.InAttack or self.Owner:KeyDown(IN_ATTACK) then return end
	self.InAttack = nil
	self:BfgFire(true)
	self.mode = "single"
	
	self.mode1 = nil
	self.mode2 = nil
	self.mode3 = nil
	self.mode4 = nil
	self.overcharge = nil
end

function SWEP:Explode()
	if not self.Owner:KeyDown(IN_ATTACK) or not self.InAttack then return end
	self:EmitSound("weapons/aw50/bfg_explode" .. math.random(1, 4) .. ".wav", 100, 100)
	self.InAttack = nil
	self:TakePrimaryAmmo(self.Primary.ClipSize)
	self.mode = "single"
	if SERVER then
		self.Owner:Kill()
	end
end

function SWEP:BfgFire(worldsnd)
	
	self:SetNextSecondaryFire(CurTime() + 0.5)
	self:SetNextPrimaryFire(CurTime() + 0.5)
	
	if not worldsnd then
		self:EmitSound(self.Primary.Sound, self.Primary.SoundLevel)
	elseif SERVER then
		sound.Play(self.Primary.Sound, self:GetPos(), self.Primary.SoundLevel)
	end
	
	local recoil = 7
	local damage = 20
	
	if self.mode == "single" then
		self:TakePrimaryAmmo(1)
		recoil = 7
		damage = 20
	end
	
	if self.mode == "2" then
		self:TakePrimaryAmmo(2)
		recoil = 16
		damage = 40
	end
	
	if self.mode == "3" then
		self:TakePrimaryAmmo(3)
		recoil = 36
		damage = 80
	end
	
	if self.mode == "4" then
		self:TakePrimaryAmmo(4)
		recoil = 82
		damage = 160
	end
	
	self:ShootBullet(damage, recoil, self.Primary.NumShots, self:GetPrimaryCone())
	
	local owner = self.Owner
	if not IsValid(owner) or owner:IsNPC() or (not owner.ViewPunch) then return end
	
	owner:ViewPunch(Angle(math.Rand(-0.2, -0.1) * recoil, math.Rand(-0.1, 0.1) * recoil, 0))
	
	if self.ChargeSound then self.ChargeSound:Stop() end
end

function SWEP:SetZoom(state)
	if CLIENT then
		return
	elseif IsValid(self.Owner) and self.Owner:IsPlayer() then
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
	if self:GetNextSecondaryFire() > CurTime() then return end
	
	local bIronsights = not self:GetIronsights()
	
	self:SetIronsights(bIronsights)
	
	if SERVER then
		self:SetZoom(bIronsights)
	else
		self:EmitSound(self.Secondary.Sound)
	end
	
	self:SetNextSecondaryFire(CurTime() + 0.3)
end

function SWEP:PreDrop()
	self:SetZoom(false)
	self:SetIronsights(false)
	self.InAttack = nil
	self.mode1 = nil
	self.mode2 = nil
	self.mode3 = nil
	self.mode4 = nil
	self.overcharge = nil
	self.mode = "single"
	if self.ChargeSound then self.ChargeSound:Stop() end
	return self.BaseClass.PreDrop(self)
end

function SWEP:Reload()
	if (self:Clip1() == self.Primary.ClipSize or self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0) then return end
	self:DefaultReload(ACT_VM_RELOAD)
	self:SetIronsights(false)
	self:SetZoom(false)
	self.InAttack = nil
	self.mode1 = nil
	self.mode2 = nil
	self.mode3 = nil
	self.mode4 = nil
	self.overcharge = nil
	self.mode = "single"
	if self.ChargeSound then self.ChargeSound:Stop() end
end

function SWEP:Holster()
	self:SetIronsights(false)
	self:SetZoom(false)
	self.InAttack = nil
	self.mode1 = nil
	self.mode2 = nil
	self.mode3 = nil
	self.mode4 = nil
	self.overcharge = nil
	self.mode = "single"
	if self.ChargeSound then self.ChargeSound:Stop() end
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
