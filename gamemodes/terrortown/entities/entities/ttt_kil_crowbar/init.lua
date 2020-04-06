AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/weapons/w_bugbait.mdl")
	self:PrecacheGibs()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:PhysicsCollide(Data, PhysObj)
	if (Data.HitEntity:IsPlayer()) then
		Data.HitEntity:TakeDamage(50)
	end

	local ent = ents.Create("ttt_crowbar")
	ent:SetPos(self:GetPos())
	ent:SetAngles(self:GetAngles())
	ent:Spawn()
	ent:SetModel("models/weapons/w_crowbar.mdl")

	self:Remove()
end

function ENT:OnRemove()
end

function ENT:OnTakeDamage(dmgInfo)
end

function ENT:Think()
end

function ENT:Break()

end
