if SERVER then
    util.AddNetworkString("TTT_MultiJump")
end

local function GetMoveVector(mv)
	local ang = mv:GetAngles()

	local max_speed = mv:GetMaxSpeed()

	local forward = math.Clamp(mv:GetForwardSpeed(), -max_speed, max_speed)
	local side = math.Clamp(mv:GetSideSpeed(), -max_speed, max_speed)

	local abs_xy_move = math.abs(forward) + math.abs(side)

	if abs_xy_move == 0 then
		return Vector(0, 0, 0)
	end

	local mul = max_speed / abs_xy_move

	local vec = Vector()

	vec:Add(ang:Forward() * forward)
	vec:Add(ang:Right() * side)

	vec:Mul(mul)

	return vec
end

hook.Add("SetupMove", "Multi Jump", function(ply, mv)
    -- Let the engine handle movement from the ground
    -- Only set the 'jumped' flag if that functionality is enabled
    if ply:OnGround() and mv:KeyPressed(IN_JUMP) and ply:GetJumped() ~= -1 then
	    ply:SetJumped(1)
		return
	elseif ply:OnGround() then
        ply:SetJumpLevel(0)
        -- Only set the 'jumped' flag if that functionality is enabled
        if ply:GetJumped() ~= -1 then
            ply:SetJumped(0)
        end
		return
	end

	-- Don't do anything if not jumping
	if not mv:KeyPressed(IN_JUMP) then
		return
	end

	ply:SetJumpLevel(ply:GetJumpLevel() + 1)

	if not ply:OnGround() and ply:GetJumped() == 0 then
		return
	end

	if ply:GetJumpLevel() > ply:GetMaxJumpLevel() then
		return
	end

	local vel = GetMoveVector(mv)
	vel.z = ply:GetJumpPower() * ply:GetExtraJumpPower()
	mv:SetVelocity(vel)

	ply:DoCustomAnimEvent(PLAYERANIMEVENT_JUMP , -1)

    if SERVER then
        net.Start("TTT_MultiJump")
        net.WriteEntity(ply)
        net.Broadcast()
    end
end)

if CLIENT then
    net.Receive("TTT_MultiJump", function()
        local ply = net.ReadEntity()
        if not IsValid(ply) or ply:IsSpec() or not ply:Alive() then return end

        local pos = ply:GetPos() + Vector(0, 0, 10)
        local client = LocalPlayer()
        if client:GetPos():Distance(pos) > 1000 then return end

        local emitter = ParticleEmitter(pos)
        for _ = 0, math.random(30, 40) do
            local partpos = ply:GetPos() + Vector(math.random(-3, 3), math.random(-3, 3), 10)
            local part = emitter:Add("particle/particle_smokegrenade", partpos)
            if (part) then
                part:SetDieTime(math.random(0.4, 0.7))
                part:SetStartAlpha(math.random(200, 240))
                part:SetEndAlpha(0)
                part:SetColor(math.random(200, 220), math.random(200, 220), math.random(200, 220))

                part:SetStartSize(math.random(6, 8))
                part:SetEndSize(0)

                part:SetRoll(0)
                part:SetRollDelta(0)

                local velocity = VectorRand() * math.random(10, 15);
                velocity.z = 5;
                part:SetVelocity(velocity)
            end
        end

        emitter:Finish()
    end)
end