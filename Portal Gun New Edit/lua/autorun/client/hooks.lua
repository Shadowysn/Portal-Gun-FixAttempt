hook.Add("PostDrawOpaqueRenderables","DrawPortals", function()
	for k,v in pairs(ents.FindByClass("prop_portal"))do
		v:DrawPortal()
	end
end)

/*------------------------------------
		ShouldDrawLocalPlayer()
------------------------------------*/
--Draw yourself into the portal.. YES YOU CAN SEE YOURSELF! (Bug? Can't see your weapons)
hook.Add( "ShouldDrawLocalPlayer", "Portal.ShouldDrawLocalPlayer", function()
		local ply = LocalPlayer()
		local portal = ply.InPortal
		if RENDERING_PORTAL then
			return true
		-- elseif IsValid(portal) then
			-- local pos,ang = portal:GetPortalPosOffsets(portal:GetOther(),ply), portal:GetPortalAngleOffsets(portal:GetOther(),ply)
			-- pos.z = pos.z - 64
			
			-- ply:SetRenderOrigin(pos)
			-- ply:SetRenderAngles(ang)
			-- return true
			
		end
end )
hook.Add( 'PostDrawEffects', 'PortalSimulation_PlayerRenderFix', function()
	cam.Start3D( EyePos(), EyeAngles() )
	cam.End3D()
end)

--I think this is from sassilization..
local function IsInFront( posA, posB, normal )

		local Vec1 = ( posB - posA ):GetNormalized()

		return ( normal:Dot( Vec1 ) < 0 )
		-- return true

end

hook.Add( "RenderScene", "Portal.RenderScene", function( Origin, Angles )
	-- render each portal

	if GetConVarNumber("portal_texFSB") >=2 then
	for k, v in ipairs( ents.FindByClass( "prop_portal_pbody" ) ) do
		local viewent = GetViewEntity()
		local pos = ( IsValid( viewent ) and viewent != LocalPlayer() ) and GetViewEntity():GetPos() or Origin
		if IsInFront( Origin, v:GetRenderOrigin(), v:GetForward() ) then --if the player is in front of the portal, then render it..
			-- call into it to render
			v:RenderPortal( Origin, Angles )
		end
	end
				elseif GetConVarNumber("portal_texFSB") >=1 then
	for k, v in ipairs( ents.FindByClass( "prop_portal_atlas" ) ) do
		local viewent = GetViewEntity()
		local pos = ( IsValid( viewent ) and viewent != LocalPlayer() ) and GetViewEntity():GetPos() or Origin
		if IsInFront( Origin, v:GetRenderOrigin(), v:GetForward() ) then --if the player is in front of the portal, then render it..
			-- call into it to render
			v:RenderPortal( Origin, Angles )
		end
	end
				else
	for k, v in ipairs( ents.FindByClass( "prop_portal" ) ) do
		local viewent = GetViewEntity()
		local pos = ( IsValid( viewent ) and viewent != LocalPlayer() ) and GetViewEntity():GetPos() or Origin
		if IsInFront( Origin, v:GetRenderOrigin(), v:GetForward() ) then --if the player is in front of the portal, then render it..
			-- call into it to render
			v:RenderPortal( Origin, Angles )
		end
	end
end
end )

CreateClientConVar("portal_debugmonitor", 0, false, false)
hook.Add( "HUDPaint", "Portal.BlueMonitor", function( w,h )
	if GetConVarNumber("portal_debugmonitor") == 1 and GetConVarNumber("sv_cheats") == 1 then
		-- render each portal
		for k, v in ipairs( ents.FindByClass( "prop_portal" ) ) do
		  -- debug monitor
			if view and v:GetNWInt("Potal:PortalType", TYPE_BLUE) == TYPE_BLUE then
				
				surface.DrawLine(ScrW()/2-10,ScrH()/2,ScrW()/2+10,ScrH()/2)
				surface.DrawLine(ScrW()/2,ScrH()/2-10,ScrW()/2,ScrH()/2+10)
				
				local b = render.EnableClipping(true)
				render.PushCustomClipPlane( othernormal, otherdistance )
					view.w = 500
					view.h = 280
					RENDERING_PORTAL = true
						render.RenderView( view )
					RENDERING_PORTAL = false
				render.PopCustomClipPlane( )
				render.EnableClipping(b)
			end

		end
	end
end )

net.Receive( 'PORTALGUN_PICKUP_PROP', function()

end )

/*------------------------------------
		GetMotionBlurValues()
------------------------------------*/
hook.Add( "GetMotionBlurValues", "Portal.GetMotionBlurValues", function( x, y, fwd, spin )
		if RENDERING_PORTAL then
				return 0, 0, 0, 0
		end
end )

hook.Add( "PostProcessPermitted", "Portal.PostProcessPermitted", function( element )
		if element == "bloom" and RENDERING_PORTAL then
				return false
		end
end )

net.Receive( "Portal:ObjectInPortal", function()
	local portal = net:ReadEntity()
	local ent = net:ReadEntity()
	if IsValid( ent ) and IsValid( portal ) then
		ent.InPortal = portal
		
		-- if ent:IsPlayer() then
			-- portal:SetupPlayerClone(ent)
		-- end
		
		ent:SetRenderClipPlaneEnabled( true )
		ent:SetGroundEntity( portal )
	end
end)

net.Receive( "Portal:ObjectLeftPortal", function()
	local ent = net:ReadEntity()
	if IsValid( ent ) then
		-- if ent:IsPlayer() and IsValid(ent.PortalClone) then
			-- ent.PortalClone:Remove()
		-- end
		ent.InPortal = false
		ent:SetRenderClipPlaneEnabled(false)
	end
end)

hook.Add( "RenderScreenspaceEffects", "Portal.RenderScreenspaceEffects", function()
		for k,v in pairs( ents.GetAll() ) do
				if IsValid( v.InPortal ) then
						--local plane = Plane(v.InPortal:GetForward(),v.InPortal:GetPos())
					   
						local normal = v.InPortal:GetForward()
						local distance = normal:Dot( v.InPortal:GetRenderOrigin() )
					   
						v:SetRenderClipPlaneEnabled(true)
						v:SetRenderClipPlane( normal, distance )
				end
		end
		
end )

--red = in blue = out
net.Receive("DebugOverlay_LineTrace", function()
	local p1,p2,b = net:ReadVector(), net:ReadVector(), net:ReadBool()
	local col
	if b then col = Color(255,0,0,255) else col = Color(0,0,255,255) end
	debugoverlay.Line(p1,p2,5, col)
end)
net.Receive("DebugOverlay_Cross", function()
	local point = net:ReadVector()
	local b = net:ReadBool()
	if b then 
		b = Color(0,255,0)
	else 
		b = Color(255,0,0) 
	end
	debugoverlay.Cross(point,5, 5, b,true)
end)

hook.Add("Think", "Reset Camera Roll", function()
	if not LocalPlayer():InVehicle() then
		local a = LocalPlayer():EyeAngles()
		if a.r != 0 then
			a.r = math.ApproachAngle(a.r, 0, FrameTime()*160)
			LocalPlayer():SetEyeAngles(a)
		end
	end
end)

net.Receive("Portal:Moved", function()
		local ent = net:ReadEntity()
		local pos = net:ReadVector()
		local ang = net:ReadAngle()
		if ent and ent:IsValid() and ent.openpercent then
				ent.openpercent = 0
				
				ent:SetAngles(ang)
				if ent:OnFloor() then
					ent:SetRenderOrigin( pos - Vector(0,0,20) )
				else
					ent:SetRenderOrigin(pos)
				end
				-- ent:SetRenderClipPlane( ent:GetForward(), 5 )
		end
		
		if ent and ent:IsValid() and ent.openpercent_material then
				ent.openpercent_material = 0
				
				ent:SetAngles(ang)
				if ent:OnFloor() then
					ent:SetRenderOrigin( pos - Vector(0,0,20) )
				else
					ent:SetRenderOrigin(pos)
				end
				-- ent:SetRenderClipPlane( ent:GetForward(), 5 )
		end
end)

-- local fps = {30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30}
-- function AvgFPS()
	-- table.remove(fps,1)
	-- table.insert(fps,1/FrameTime())
	-- local avg = 0
	-- for i=1,#fps do
		-- avg = avg+fps[i]
	-- end
	-- return avg/#fps
-- end
-- hook.Add("Tick","Calc AVG FPS",AvgFPS)

-- hook.Add("HUDPaint","PrintVelocity", function() 
	
	-- draw.SimpleText(LocalPlayer():GetVelocity():__tostring(),"DermaLarge",100,100,Color(100,255,100),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)

-- end)