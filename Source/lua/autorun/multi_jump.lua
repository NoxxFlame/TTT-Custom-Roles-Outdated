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
	if ply:OnGround() then
		ply:SetJumpLevel(0)
		return
	end

	-- Don't do anything if not jumping
	if not mv:KeyPressed(IN_JUMP) then
		return
	end

	ply:SetJumpLevel(ply:GetJumpLevel() + 1)

	if ply:GetJumpLevel() > ply:GetMaxJumpLevel() then
		return
	end

	local vel = GetMoveVector(mv)

	vel.z = ply:GetJumpPower() * ply:GetExtraJumpPower()

	mv:SetVelocity(vel)

	ply:DoCustomAnimEvent(PLAYERANIMEVENT_JUMP , -1)

    if CLIENT then
        local pos = ply:GetPos() + Vector(0, 0, 10)

        local emitter = ParticleEmitter(pos) -- Particle emitter in this position

        for _ = 0, 20 do
            local part = emitter:Add("effects/smoke", pos) -- Create a new particle at pos
            if (part) then
                part:SetDieTime(1)
                part:SetStartAlpha(255)
                part:SetEndAlpha(0)

                part:SetStartSize(5)
                part:SetEndSize(0)

                part:SetGravity(Vector(0, 0, -25)) -- Gravity of the particle
                part:SetVelocity(VectorRand() * 20) -- Initial velocity of the particle
            end
        end

        emitter:Finish()
    end
end)