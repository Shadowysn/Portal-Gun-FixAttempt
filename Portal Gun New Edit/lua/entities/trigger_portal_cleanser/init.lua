ENT.Type = "brush"

function ENT:Initialize()
	-- ParticleEffectAttach("portal_cleanser",PATTACH_ABSORIGIN,self,1)
	
	self:SetTrigger(true)
end

function ENT:Touch( ent )
end

function ENT:StartTouch( ent )
	if IsValid(ent) and ent:IsPlayer() and ent:Alive() then
		plyweap = ent:GetActiveWeapon()
		if IsValid( plyweap ) and plyweap:GetClass() == "weapon_portalgun" and plyweap.CleanPortals then
			plyweap:CleanPortals()
		end
	elseif IsValid(ent) then
		if ent:GetClass() == "projectile_portal_ball" then
			//portal ball projectile.
			local ang = ent:GetAngles()
			ang:RotateAroundAxis(ent:GetForward(),90)
			ang.y = self:GetAngles().y+90
			if GetConVarNumber("portal_beta_borders") >= 1 then
			ParticleEffect("portal_"..ent:GetNWInt("Kind",TYPE_BLUE).."_cleanser_",ent:GetPos(),ang)
			else
			ParticleEffect("portal_"..ent:GetNWInt("Kind",TYPE_BLUE).."_cleanser",ent:GetPos(),ang)
			end
			ent:Remove()
		else
			if ent.Cleanser_Dissolving != true then
				local vel = ent:GetVelocity()
				
				local fakebox = ents.Create( "prop_physics" )
				fakebox:SetModel(ent:GetModel())
				fakebox:SetPos(ent:GetPos())
				fakebox:SetAngles(ent:GetAngles())
				fakebox:Spawn()
				fakebox:Activate()
				fakebox:SetSkin(ent:GetSkin())
				fakebox:SetName("dissolveme")
				local phys = fakebox:GetPhysicsObject()
				if IsValid(phys) then
					phys:EnableGravity(false)
					phys:Wake()
					phys:SetVelocity(vel/5)
				end
				fakebox.Cleanser_Dissolving = true
				
				ent:Remove()
				
				local dissolver = ents.Create( "env_entity_dissolver" )
				dissolver:SetKeyValue( "dissolvetype", 0 )
				dissolver:SetKeyValue( "magnitude", 0 )
				dissolver:SetKeyValue( "target", "!activator" )
				dissolver:Spawn()
				dissolver:Activate()
				dissolver:Fire("Dissolve", "", 0, fakebox)
				dissolver:Fire("kill", "", 0.1)
			end
		end
	end
end

function ENT:EndTouch( ent )
end
