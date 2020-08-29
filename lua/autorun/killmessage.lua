if (CLIENT) then
	
	net.Receive("ClientDeathNotify", function()
		-- Colours for customizing
		local TraitorColor = Color(255, 0, 0)
		local InnoColor = Color(0, 255, 0)
		local DetectiveColor = Color(0, 0, 255)
		local GlitchColor = Color(255, 127, 39)
		local MercenaryColor = Color(255, 201, 14)
		local JesterColor = Color(159, 0, 211)
		local HypnotistColor = Color(255, 93, 223)
		local PhantomColor = Color(82, 226, 255)
		local ZombieColor = Color(69, 97, 0)
		local VampireColor = Color(45, 45, 45)
		local SwapperColor = Color(111, 0, 255)
		local AssassinColor = Color(112, 50, 0)
		local KillerColor = Color(50, 0, 70)
		local DoctorColor = Color(7, 183, 160)
		
		local NameColor = Color(142, 68, 173)
		local UnknownColor = Color(152, 48, 196)
		
		local White = Color(236, 240, 241)
		-- Read the variables from the message
		local name = net.ReadString()
		local role = tonumber(net.ReadString())
		local reason = net.ReadString()
		-- Format the number role into a human readable role
		if role == ROLE_INNOCENT then
			col = InnoColor
			role = "innocent"
		elseif role == ROLE_TRAITOR then
			col = TraitorColor
			role = "a traitor"
		elseif role == ROLE_DETECTIVE then
			col = DetectiveColor
			role = "a detective"
		elseif role == ROLE_GLITCH then
			col = GlitchColor
			role = "a glitch"
		elseif role == ROLE_MERCENARY then
			col = MercenaryColor
			role = "a mercenary"
		elseif role == ROLE_DOCTOR then
			col = DoctorColor
			role = "a doctor"
		elseif role == ROLE_JESTER then
			col = JesterColor
			role = "a jester"
		elseif role == ROLE_HYPNOTIST then
			col = HypnotistColor
			role = "a hypnotist"
		elseif role == ROLE_PHANTOM then
			col = PhantomColor
			role = "a phantom"
		elseif role == ROLE_ZOMBIE then
			col = ZombieColor
			role = "a zombie"
		elseif role == ROLE_VAMPIRE then
			col = VampireColor
			role = "a vampire"
		elseif role == ROLE_SWAPPER then
			col = SwapperColor
			role = "a swapper"
		elseif role == ROLE_ASSASSIN then
			col = AssassinColor
			role = "an assassin"
		elseif role == ROLE_KILLER then
			col = KillerColor
			role = "a killer"
		else
			col = InnoColor
			role = "innocent"
		end
		-- Format the reason for their death
		if reason == "suicide" then
			chat.AddText(White, "You killed yourself!")
		
		elseif reason == "burned" then
			chat.AddText(White, "You burned to death!")
		
		elseif reason == "prop" then
			chat.AddText(White, "You were killed by a prop!")
		
		elseif reason == "ply" then
			chat.AddText(White, "You were killed by ", col, name, White, ", they were ", col, role .. "!")
		
		elseif reason == "fell" then
			chat.AddText(White, "You fell to your death!")
		
		elseif reason == "water" then
			chat.AddText(White, "You drowned!")
		
		else
			chat.AddText(White, "You died!")
		end
	end)
end

if (SERVER) then
	-- Precache the net message
	util.AddNetworkString("ClientDeathNotify")
	
	hook.Add("PlayerDeath", "Kill_Reveal_Notify", function(victim, entity, killer)
		if gmod.GetGamemode().Name == "Trouble in Terrorist Town" then
			local reason = 0
			
			if entity:GetClass() == "entityflame" and killer:GetClass() == "entityflame" then
				reason = "burned"
				killerz = "nil"
				role = "nil"
			
			elseif victim.DiedByWater then
				reason = "water"
				killerz = "nil"
				role = "nil"
			
			elseif entity:GetClass() == "worldspawn" and killer:GetClass() == "worldspawn" then
				reason = "fell"
				killerz = "nil"
				role = "nil"
			
			elseif victim:IsPlayer() and entity:GetClass() == 'prop_physics' or entity:GetClass() == "prop_dynamic" or entity:GetClass() == 'prop_physics' then -- If the killer is also a prop
				reason = "prop"
				killerz = "nil"
				role = "nil"
			
			elseif (killer == victim) then
				reason = "suicide"
				killerz = "nil"
				role = "nil"
			
			elseif killer:IsPlayer() and victim ~= killer then
				reason = "ply"
				killerz = killer:Nick()
				role = killer:GetRole()
			
			else
				reason = "nil"
				killerz = "nil"
				role = "nil"
			end
			
			-- Send the buffer message with the death information to the victim
			net.Start("ClientDeathNotify")
			net.WriteString(killerz)
			net.WriteString(role)
			net.WriteString(reason)
			net.Send(victim)
		end
	end)
end