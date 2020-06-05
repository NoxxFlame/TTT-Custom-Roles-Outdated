local PLAYER = FindMetaTable("Player")

function PLAYER:GetJumpLevel()
    return self:GetDTInt(23)
end

function PLAYER:SetJumpLevel(level)
    self:SetDTInt(23, level)
end

function PLAYER:GetMaxJumpLevel(level)
    return self:GetDTInt(24)
end

function PLAYER:SetMaxJumpLevel(level)
    self:SetDTInt(24, level)
end

function PLAYER:GetExtraJumpPower()
    return self:GetDTFloat(25)
end

function PLAYER:SetExtraJumpPower(power)
    self:SetDTFloat(25, power)
end

function PLAYER:GetJumped()
    return self:GetDTInt(26)
end

function PLAYER:SetJumped(level)
    self:SetDTInt(26, level)
end