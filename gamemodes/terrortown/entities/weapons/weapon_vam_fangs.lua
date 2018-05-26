AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "Fangs"
	SWEP.EquipMenuData = {
		type = "Weapon",
		desc = "Left click to eat bodies. Right click to fade."
	};
	
	SWEP.Slot = 8 -- add 1 to get the slot number key
	SWEP.ViewModelFOV = 54
	SWEP.ViewModelFlip = false
	SWEP.UseHands = true
end

SWEP.InLoadoutFor = { ROLE_VAMPIRE }

SWEP.Base = "weapon_tttbase"

SWEP.HoldType = "knife"

SWEP.Primary.Automatic = false
SWEP.Secondary.Automatic = false

SWEP.ViewModel = Model("models/weapons/cstrike/c_knife_t.mdl")
SWEP.WorldModel = Model("models/weapons/w_knife_t.mdl")

SWEP.Primary.Ammo = "fade"
SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100

SWEP.Kind = WEAPON_ROLE
SWEP.LimitedStock = false
SWEP.AllowDrop = true

local STATE_NONE, STATE_EAT = 0, 1

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
	self:NetworkVar("Float", 0, "StartTime")
	if SERVER then
		self:SetState(STATE_NONE)
		self:SetStartTime(0)
	end
end

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self.lastTickSecond = 0
	self.fading = false
	
	if CLIENT then
		self:AddHUDHelp("Left click to eat bodies", "Right click to fade", false)
	end
end

function SWEP:Holster()
	self:FireError()
	return not self.fading
end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:PrimaryAttack()
	if CLIENT then return end
	
	local tr = util.TraceLine({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 100,
		filter = self.Owner
	})
	
	if IsValid(tr.Entity) and tr.Entity:GetClass() == "prop_ragdoll" then
		if not tr.Entity.uqid then return end
		
		local ply = player.GetByUniqueID(tr.Entity.uqid)
		
		if IsValid(ply) and ply:Alive() then
		else
			self:Eat(tr.Entity)
			self.Owner:EmitSound("weapons/ttt/vampireeat.wav")
		end
	end
end

function SWEP:SecondaryAttack()
	if self:Clip1() == 100 then
		self:SetClip1(0)
	end
end

function SWEP:Eat(ragdoll)
	self:SetState(STATE_EAT)
	self:SetStartTime(CurTime())
	
	self.TargetRagdoll = ragdoll
	
	self:SetNextPrimaryFire(CurTime() + 5)
end

function SWEP:FireError()
	self:SetState(STATE_NONE)
	
	self:SetNextPrimaryFire(CurTime() + 0.1)
end

function SWEP:DropBones()
	local pos = self.TargetRagdoll:GetPos()
	
	local skull = ents.Create("prop_physics")
	if not IsValid(skull) then return end
	skull:SetModel("models/Gibs/HGIBS.mdl")
	skull:SetPos(pos)
	skull:Spawn()
	skull:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
	local ribs = ents.Create("prop_physics")
	if not IsValid(ribs) then return end
	ribs:SetModel("models/Gibs/HGIBS_rib.mdl")
	ribs:SetPos(pos + Vector(0, 0, 15))
	ribs:Spawn()
	ribs:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
	local spine = ents.Create("prop_physics")
	if not IsValid(ribs) then return end
	spine:SetModel("models/Gibs/HGIBS_spine.mdl")
	spine:SetPos(pos + Vector(0, 0, 30))
	spine:Spawn()
	spine:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
	local scapula = ents.Create("prop_physics")
	if not IsValid(scapula) then return end
	scapula:SetModel("models/Gibs/HGIBS_scapula.mdl")
	scapula:SetPos(pos + Vector(0, 0, 45))
	scapula:Spawn()
	scapula:SetCollisionGroup(COLLISION_GROUP_WEAPON)
end

function SWEP:Think()
	if CLIENT then return end
	
	if (CurTime() - self.lastTickSecond > 0.08) and (self:Clip1() <= 100) then
		self:SetClip1(self:Clip1() + math.min(1, 100 - self:Clip1()))
		self.lastTickSecond = CurTime()
	end
	
	if self:Clip1() < 13 and not self.fading then
		self.fading = true
		self.Owner:SetColor(Color(255, 255, 255, 0))
		self.Owner:SetMaterial("sprites/heatwave")
		self.Owner:EmitSound("weapons/ttt/fade.wav")
	elseif self:Clip1() >= 13 and self.fading then
		self.fading = false
		self.Owner:SetMaterial("models/glass")
		self.Owner:EmitSound("weapons/ttt/unfade.wav")
	end
	
	if self:GetState() == STATE_EAT then
		if not IsValid(self.Owner) then
			self:FireError()
			return
		end
		
		if not IsValid(self.TargetRagdoll) then
			self:FireError()
			return
		end
		
		local tr = util.TraceLine({
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 100,
			filter = self.Owner
		})
		
		if tr.Entity ~= self.TargetRagdoll then
			self:FireError()
			return
		end
		
		if CurTime() >= self:GetStartTime() + 5 then
			self:SetState(STATE_NONE)
			
			self.Owner:SetHealth(math.min(self.Owner:Health() + 50, 125))
			
			self:DropBones()
			
			self.TargetRagdoll:Remove()
		end
	end
end

if CLIENT then
	function SWEP:DrawHUD()
		
		local x = ScrW() / 2.0
		local y = ScrH() / 2.0
		
		y = y + (y / 3)
		
		local w, h = 255, 20
		
		if self:GetState() == STATE_EAT then
			local progress = math.TimeFraction(self:GetStartTime(), self:GetStartTime() + 5, CurTime())
			
			if progress < 0 then return end
			
			progress = math.Clamp(progress, 0, 1)
			
			surface.SetDrawColor(0, 255, 0, 155)
			
			surface.DrawOutlinedRect(x - w / 2, y - h, w, h)
			
			surface.DrawRect(x - w / 2, y - h, w * progress, h)
			
			surface.SetFont("TabLarge")
			surface.SetTextColor(255, 255, 255, 180)
			surface.SetTextPos((x - w / 2) + 3, y - h - 15)
			surface.DrawText("EATING BODY")
		end
	end
end

hook.Add("TTTPlayerSpeed", "FadeSpeed", function(ply, slowed)
	local wep = ply:GetActiveWeapon()
	if wep and IsValid(wep) and wep:GetClass() == "weapon_vam_fangs" and wep:Clip1() < 13 then
		return 3
	end
end)