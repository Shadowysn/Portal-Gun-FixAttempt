if (CLIENT) then return end

local portalgun_class = "weapon_portalgun"
local portalgun_powerup_snd = "Weapon_Portalgun.powerup"

local TYPE_BLUE = 1
local TYPE_ORANGE = 2
		
hook.Add("PlayerCanPickupWeapon", "Shadowysn_PortalGun_PickupWep", function(ply, wep) 
	if IsValid(ply) and ply:IsPlayer() and IsValid(wep) and wep:GetClass() == portalgun_class and IsValid(wep.Weapon) and ply:HasWeapon(portalgun_class) then
		--local firemode = self.Weapon:GetNWInt( "Portal:FireMode", 0 )
		--if value_lowcase <= 0 then
		--	if key_lowcase == "canfireportal1" and bit.band(firemode, TYPE_BLUE) != TYPE_BLUE then
		
		local ply_gun = ply:GetWeapon(portalgun_class)
		if IsValid(ply_gun) and IsValid(ply_gun.Weapon) and ply_gun != wep then
			local old_firemode = ply_gun.Weapon:GetNWInt( "Portal:FireMode", 0 )
			local new_firemode = wep.Weapon:GetNWInt( "Portal:FireMode", 0 )
			
			if bit.band(old_firemode, TYPE_BLUE) == TYPE_BLUE and bit.band(new_firemode, TYPE_BLUE) != TYPE_BLUE then
				--ply_gun.Weapon:SetNWInt( "Portal:FireMode", bit.bnot(old_firemode, TYPE_BLUE) )
				ply_gun.Weapon:SetKeyValue("CanFirePortal1", "1")
				ply_gun:EmitSound(portalgun_powerup_snd)
				ply:ViewPunch( ply_gun.ViewPunchAngle )
			end
			if bit.band(old_firemode, TYPE_ORANGE) == TYPE_ORANGE and bit.band(new_firemode, TYPE_ORANGE) != TYPE_ORANGE then
				--ply_gun.Weapon:SetNWInt( "Portal:FireMode", bit.bnot(old_firemode, TYPE_ORANGE) )
				ply_gun.Weapon:SetKeyValue("CanFirePortal2", "1")
				ply_gun:EmitSound(portalgun_powerup_snd)
				ply:ViewPunch( ply_gun.ViewPunchAngle )
			end
		end
	end
end)

util.AddNetworkString( 'PORTALGUN_PICKUP_PROP' )
util.AddNetworkString( "Portal:ObjectInPortal" )
util.AddNetworkString( "Portal:ObjectLeftPortal" )
util.AddNetworkString( "DebugOverlay_LineTrace" )
util.AddNetworkString( "DebugOverlay_Cross" )
util.AddNetworkString( "Portal:Moved" )

hook.Add( 'AllowPlayerPickup', 'PortalPickup', function( ply, ent )
	if IsValid( ply:GetActiveWeapon() ) and IsValid( ent ) and ply:GetActiveWeapon():GetClass() == 'weapon_portalgun' then --and (table.HasValue( pickable, ent:GetModel() ) or table.HasValue( pickable, ent:GetClass() )) then
		return false
	end
end )

hook.Add("Think", "Portalgun Holding Item", function()
	for k,v in pairs(player.GetAll())do
		if v:KeyDown(IN_USE) then
			if v:GetActiveWeapon().NextAllowedPickup and v:GetActiveWeapon().NextAllowedPickup < CurTime() then
				if v:GetActiveWeapon().UseReleased then
					v:GetActiveWeapon().UseReleased = false
					if IsValid( v:GetActiveWeapon().HoldenProp ) then
						v:GetActiveWeapon():OnDroppedProp()
					end
				end
			end
		else
			v:GetActiveWeapon().UseReleased = true
		end

	end
end)

local function BulletHook(ent,bullet)
	if ent.FiredBullet then return end
	--Test if the bullet hits the portal.
	for k,inport in pairs(ents.FindByClass("prop_portal")) do --fix fake portal positions.
		if inport:OnFloor() then
			inport:SetPos(inport:GetPos()-Vector(0,0,20))
		end
	end
	
	for i=1, bullet.Num do
		local tr = util.QuickTrace(bullet.Src, bullet.Dir*10000, ent)
		
		if IsValid(tr.Entity) and tr.Entity:GetClass() == "prop_portal" then
			local inport = tr.Entity
			
			if inport:GetNWBool("Potal:Linked",false) == false or inport:GetNWBool("Potal:Activated",false) == false then return end
			
			local outport = inport:GetNWEntity("Potal:Other")
			if !IsValid(outport) then return end
			
			--Create our new bullet and get the hit pos of the inportal.
			local newbullet = table.Copy(bullet)
			
			if inport:OnFloor() and outport:OnFloor() then
				outport:SetPos(outport:GetPos() + Vector(0,0,20))
			end
			
			local offset = inport:WorldToLocal(tr.HitPos + bullet.Dir*20)
			
			offset.x = -offset.x;
			offset.y = -offset.y;
			
			--Correct bullet angles.
			local ang = bullet.Dir
			ang = inport:TransformOffset(ang,inport:GetAngles(),outport:GetAngles()) * -1
			newbullet.Dir = ang
			
			--Transfer to new portal.
			newbullet.Src = outport:LocalToWorld( offset ) + ang*10
			
			
			-- net.Start("DebugOverlay_LineTrace")
				-- net.WriteVector(bullet.Src)
				-- net.WriteVector(tr.HitPos)
				-- net.WriteBool(true)
			-- net.Broadcast()
			-- local p1 = util.QuickTrace(newbullet.Src,ang*10000,{outport,inport})
			-- net.Start("DebugOverlay_LineTrace")
				-- net.WriteVector(newbullet.Src)
				-- net.WriteVector(p1.HitPos)
				-- net.WriteBool(false)
			-- net.Broadcast()
			
			newbullet.Attacker = ent
			outport.FiredBullet = true --prevent infinite loop.
			outport:FireBullets(newbullet)		
			outport.FiredBullet = false
			
			if inport:OnFloor() and outport:OnFloor() then
				outport:SetPos(outport:GetPos() - Vector(0,0,20))
			end
			
		end
	end
	for k,inport in pairs(ents.FindByClass("prop_portal")) do
		if inport:OnFloor() then
			inport:SetPos(inport:GetPos()+Vector(0,0,20))
		end
	end
end
hook.Add("EntityFireBullets", "BulletPorting", BulletHook)

hook.Add("SetupPlayerVisibility", "Add portalPVS", function(ply,ve)
	for k,self in pairs(ents.FindByClass("prop_portal"))do
		if not IsValid(self) then continue end
		local other = self:GetNWEntity("Potal:Other")
		if (not other) or (not IsValid(other)) then continue end
		local origin = ply:EyePos()
		local angles = ply:EyeAngles()
		
		local normal = self:GetForward()
		local distance = normal:Dot( self:GetPos() )

		// quick access
		local forward = angles:Forward()
		local up = angles:Up()

		// reflect origin
		local dot = origin:DotProduct( normal ) - distance
		origin = origin + ( -2 * dot ) * normal

		// reflect forward
		local dot = forward:DotProduct( normal )
		forward = forward + ( -2 * dot ) * normal

		// reflect up		  
		local dot = up:DotProduct( normal )
		up = up + ( -2 * dot ) * normal
		
		local ViewOrigin = self:WorldToLocal( origin )
	   
		// repair
		ViewOrigin.y = -ViewOrigin.y
		
		ViewOrigin = other:LocalToWorld( ViewOrigin )
		-- if self:GetNWInt("Potal:PortalType") == TYPE_ORANGE then
			-- net.Start("DebugOverlay_Cross")
				-- net.WriteVector(ViewOrigin)
				-- net.WriteBool(true)
			-- net.Broadcast()
		-- end
		-- AddOriginToPVS(ViewOrigin)
		
		AddOriginToPVS(self:GetPos()+self:GetForward()*20)
	end
end)

concommand.Add("CreateParticles", function(p,c,a)
	local name = a[1]
	local ang = p:GetAngles()
	ang:RotateAroundAxis(p:GetRight(),90)
	ang:RotateAroundAxis(p:GetForward(),90)
	ParticleEffect(name,p:EyePos()+p:GetForward()*100,ang, (a[2] == 1 and self or nil))
end)

local function PlayerPickup( ply, ent )	
	if ent:GetClass() == "prop_portal" or ent:GetModel() == "models/blackops/portal_sides.mdl" then
		-- print("No Pickup.")
		return false
	end
end
hook.Add( "PhysgunPickup", "NoPickupPortalssingleplayer", PlayerPickup )
hook.Add( "GravGunPickupAllowed", "NoPickupPortalssingleplayer", PlayerPickup )
hook.Add( "GravGunPunt", "NoPickupPortalssingleplayer", PlayerPickup )