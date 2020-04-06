ENT.Type 			= "anim"
ENT.Base 			= "ttt_basegrenade_proj"

ENT.Model = Model("models/weapons/w_crowbar.mdl")

ENT.BeeCount 	= 6

function ENT:Infect(plyr)
	if plyr:Alive() then
		local pos = self.Entity:GetPos()
		for i=1,self.BeeCount do
			local spos = pos+Vector(math.random(-75,75),math.random(-75,75),math.random(0,50))
			local contents = util.PointContents( spos )
			local _i = 0
			while i < 10 and (contents == CONTENTS_SOLID or contents == CONTENTS_PLAYERCLIP) do
				_i = 1 + i
				spos = pos+Vector(math.random(-125,125),math.random(-125,125),math.random(-50,50))
				contents = util.PointContents( spos )
			end

			local headBee = SpawnNPC(self:GetThrower(),spos, BeeNPCClass)

			headBee:SetNPCState(2)

			local Bee = ents.Create("prop_dynamic")
			Bee:SetModel("models/lucian/props/stupid_bee.mdl")
			Bee:SetPos(spos)
			Bee:SetAngles(Angle(0,0,0))
			Bee:SetParent(headBee)

			headBee:SetNoDraw(true)
			headBee:SetHealth(1000)
		end

		self:Remove()
	end
end












