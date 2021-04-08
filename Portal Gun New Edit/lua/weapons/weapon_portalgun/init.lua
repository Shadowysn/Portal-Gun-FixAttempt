AddCSLuaFile( "shared.lua" )

include( "shared.lua" )
include( "ai_translations.lua" )

SWEP.Weight				= 5			-- Decides whether we should switch from/to this
SWEP.AutoSwitchTo		= true		-- Auto switch to if we pick it up
SWEP.AutoSwitchFrom		= true		-- Auto switch from if you pick up a better weapon



--[[
   Name: weapon:TranslateActivity( )
   Desc: Translate a player's Activity into a weapon's activity
		 So for example, ACT_HL2MP_RUN becomes ACT_HL2MP_RUN_PISTOL
		 Depending on how you want the player to be holding the weapon
--]]
function SWEP:TranslateActivity( act )

	if ( self.Owner:IsNPC() ) then
		if ( self.ActivityTranslateAI[ act ] ) then
			return self.ActivityTranslateAI[ act ]
		end
		return -1
	end

	if ( self.ActivityTranslate[ act ] != nil ) then
		return self.ActivityTranslate[ act ]
	end
	
	return -1

end

--[[
   Name: OnRestore
   Desc: The game has just been reloaded. This is usually the right place
		to call the GetNetworked* functions to restore the scripts values.
--]]
function SWEP:OnRestore()
end


--[[
   Name: AcceptInput
   Desc: Accepts input, return true to override/accept input
--]]
function SWEP:AcceptInput( input, activator, called, data )
	local input_lowcase = string.lower(input)
	if input_lowcase == 'fireportal1' then self:PrimaryAttackShortcut() return true end
	if input_lowcase == 'fireportal2' then self:SecondaryAttackShortcut() return true end
end


--[[
   Name: KeyValue
   Desc: Called when a keyvalue is added to us
--]]
function SWEP:KeyValue(key, value)
	local key_lowcase = string.lower(key)
	local value_lowcase = tonumber(value)
	
	if value_lowcase == nil then return end

	--self.KeyValues[key_lowcase] = value
	
	-- 0 = Both Portals
	-- 1 = No Blue
	-- 2 = No Orange
	-- 3 = No Portals. Why would you even use this?
	local firemode = self.Weapon:GetNWInt( "Portal:FireMode", 0 )
	if value_lowcase <= 0 then
		if key_lowcase == "canfireportal1" and bit.band(firemode, TYPE_BLUE) != TYPE_BLUE then
			self.Weapon:SetNWInt( "Portal:FireMode", bit.bor(firemode, TYPE_BLUE) )
		elseif key_lowcase == "canfireportal2" and bit.band(firemode, TYPE_ORANGE) != TYPE_ORANGE then
			self.Weapon:SetNWInt( "Portal:FireMode", bit.bor(firemode, TYPE_ORANGE) )
		end
	elseif value_lowcase > 0 then
		if key_lowcase == "canfireportal1" and bit.band(firemode, TYPE_BLUE) == TYPE_BLUE then
			self.Weapon:SetNWInt( "Portal:FireMode", bit.band(firemode, bit.bnot(TYPE_BLUE)) )
		elseif key_lowcase == "canfireportal2" and bit.band(firemode, TYPE_ORANGE) == TYPE_ORANGE then
			self.Weapon:SetNWInt( "Portal:FireMode", bit.band(firemode, bit.bnot(TYPE_ORANGE)) )
		end
	end
	
end


--[[
   Name: OnRemove
   Desc: Called just before entity is deleted
--]]
function SWEP:OnRemove()
end

--[[
   Name: Equip
   Desc: A player or NPC has picked the weapon up
--]]
function SWEP:Equip( NewOwner )

end

--[[
   Name: EquipAmmo
   Desc: The player has picked up the weapon and has taken the ammo from it
		The weapon will be removed immidiately after this call.
--]]
function SWEP:EquipAmmo( NewOwner )

end


--[[
   Name: OnDrop
   Desc: Weapon was dropped
--]]
function SWEP:OnDrop()

end

--[[
   Name: ShouldDropOnDie
   Desc: Should this weapon be dropped when its owner dies?
--]]
function SWEP:ShouldDropOnDie()
	return true
end

--[[
   Name: GetCapabilities
   Desc: For NPCs, returns what they should try to do with it.
--]]
function SWEP:GetCapabilities()

	return bit.bor(CAP_WEAPON_RANGE_ATTACK1 , CAP_INNATE_RANGE_ATTACK1)

end

--[[
   Name: NPCShoot_Secondary
   Desc: NPC tried to fire secondary attack
--]]
function SWEP:NPCShoot_Secondary( ShootPos, ShootDir )

	self:SecondaryAttack()

end

--[[
   Name: NPCShoot_Secondary
   Desc: NPC tried to fire primary attack
--]]
function SWEP:NPCShoot_Primary( ShootPos, ShootDir )

	self:PrimaryAttack()

end

-- These tell the NPC how to use the weapon
AccessorFunc( SWEP, "fNPCMinBurst", 		"NPCMinBurst" )
AccessorFunc( SWEP, "fNPCMaxBurst", 		"NPCMaxBurst" )
AccessorFunc( SWEP, "fNPCFireRate", 		"NPCFireRate" )
AccessorFunc( SWEP, "fNPCMinRestTime", 	"NPCMinRest" )
AccessorFunc( SWEP, "fNPCMaxRestTime", 	"NPCMaxRest" )


