include( "shared.lua" )

local dlightenabled = CreateClientConVar("portal_dynamic_light", "0", true) --Pretty laggy, default it to off
-- local lightteleport = CreateClientConVar("portal_light_teleport", "0", true)
local bordersenabled = CreateClientConVar("portal_borders", "1", true)
local renderportals = CreateClientConVar("portal_render", 1, true) --Some people can't handle portals at all.
local texFSBportals = CreateClientConVar("portal_texFSB", 0, true) --Some people can't handle portals at all.

local texFSB = render.GetSuperFPTex() -- I'm really not sure if I should even be using these D:
local texFSB2 = render.GetSuperFPTex2()

 -- Make our own material to use, so we aren't messing with other effects.
local PortalMaterial = CreateMaterial(
				"PortalMaterial",
				"UnlitGeneric",
				-- "GMODScreenspace",
				{
						[ '$basetexture' ] = texFSB,
						[ '$model' ] = "1",
						-- [ '$basetexturetransform' ] = "center .5 .5 scale 1 1 rotate 0 translate 0 0",
						[ '$alphatest' ] = "0",
						[ '$PortalMaskTexture' ] = "models/portals/portal-mask-dx8",
						[ '$additive' ] = "0",
						[ '$translucent' ] = "0",
						[ '$ignorez' ] = "0"
				}
		)

if CLIENT then
	game.AddParticles("particles/portal_projectile.pcf")
	game.AddParticles("particles/portals.pcf")
	game.AddParticles("particles/portalgun.pcf")
end

-- rendergroup
ENT.RenderGroup = RENDERGROUP_BOTH

/*------------------------------------
		Initialize()
------------------------------------*/
function ENT:Initialize( )

		self:SetRenderBounds( self:OBBMins()*20, self:OBBMaxs()*20 )
	   
		self.openpercent = 0
		self.openpercent_material = 0
		
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		
		if self:OnFloor() then
			self:SetRenderOrigin( self:GetPos() - Vector(0,0,20))
		else
			self:SetRenderOrigin( self:GetPos() )
		end
		
		-- self:SetRenderClipPlaneEnabled( true )
		-- self:SetRenderClipPlane( self:GetForward(), 5 )
	   
end

--I think this is from sassilization..
local function IsInFront( posA, posB, normal )

		local Vec1 = ( posB - posA ):GetNormalized()

		return ( normal:Dot( Vec1 ) < 0 )
		-- return true

end

function ENT:Think()

		if self:GetNWBool("Potal:Activated",false) == false then return end
	   
		self.openpercent = math.Approach( self.openpercent, 1, FrameTime() * 1 * ( 1.5 + self.openpercent - 0.0001 ) )
		self.openpercent_material = math.Approach( self.openpercent_material, 1, FrameTime() * 0.5 * ( 1.5 + self.openpercent_material - 0 ) )

		if dlightenabled:GetBool() == false then return end
	   
		local portaltype = self:GetNWInt("Potal:PortalType",TYPE_BLUE)

		local glowcolor = nil
		if portaltype == TYPE_ORANGE then
			glowcolor = self.PortalColorOrange
		else
			glowcolor = self.PortalColorBlue
		end
	   
		--[[if lightteleport:GetBool() then
	   
				local portal = self:GetNWEntity( "Potal:Other", nil )
	   
				if IsValid( portal ) then

						glowvec = render.GetLightColor( portal:GetPos() ) * 255
						glowcolor = Color( glowvec.x, glowvec.y, glowvec.z )
					   
				end
					   
		end]]
	   -- if AvgFPS() > 60 then
		local dlight = DynamicLight( self:EntIndex() )
		if dlight then
			local col = glowcolor
			dlight.Pos = self:GetRenderOrigin() + self:GetAngles():Forward()
			dlight.r = col.r
			dlight.g = col.g
			dlight.b = col.b
			dlight.Brightness = 5
			dlight.Decay = 256
			dlight.Size = self.openpercent * 100
			dlight.DieTime = CurTime() + .9
			dlight.Style = 5
		end
	   -- end
end

local nonlinkedblue = surface.GetTextureID( "models/portals/portalstaticoverlay_1_close" )
local nonlinkedorange = surface.GetTextureID( "models/portals/portalstaticoverlay_2_close" )
local bluebordermat = surface.GetTextureID( "models/portals/portalstaticoverlay_1" )
local orangebordermat = surface.GetTextureID( "models/portals/portalstaticoverlay_2" )

function ENT:DrawPortalEffects( portaltype )

		local ang = self:GetAngles()
	   
		local res = 0.1
	   
		local percentopen = self.openpercent
	   
		local width = ( percentopen ) * 65
		local height = ( percentopen ) * 112
		
	   
		ang:RotateAroundAxis( ang:Right(), -90 )
		ang:RotateAroundAxis( ang:Up(), 90 )
	   
		local origin = self:GetRenderOrigin() + ( self:GetForward() * 0.1 ) - ( self:GetUp() * height / -2 ) - ( self:GetRight() * width / -2 )
	   
		cam.Start3D2D( origin, ang, res )
	   
				surface.SetDrawColor( 255, 255, 255, 255 )
	   
				if ( RENDERING_PORTAL or !self:GetNWBool( "Potal:Linked", false ) or !self:GetNWBool( "Potal:Activated", false )) then
			   
						if portaltype == TYPE_BLUE then
						
								surface.SetTexture( nonlinkedblue )
								
						elseif portaltype == TYPE_ORANGE then
						
								surface.SetTexture( nonlinkedorange )

						end
					   
						surface.DrawTexturedRect( 0, 0, width / res , height / res )
					   
				end
				
				if bordersenabled:GetBool() == true then					
						if portaltype == TYPE_BLUE then
						   if ( self:GetNWBool( "Potal:Linked", false ) or !self:GetNWBool( "Potal:Activated", false )) then

										surface.SetTexture( bluebordermat )
						   end
							   
								surface.DrawTexturedRect( 0, 0, width / res , height / res )
							   
						elseif portaltype == TYPE_ORANGE then
							 if ( self:GetNWBool( "Potal:Linked", false ) or !self:GetNWBool( "Potal:Activated", false )) then
										surface.SetTexture( orangebordermat )
							 end
								surface.DrawTexturedRect( 0, 0, width / res , height / res )
							   
						end
					   
				end
			   
		cam.End3D2D()
	   
end

function ENT:Draw()
	self:SetModelScale( self.openpercent,0 )
	self:DrawModel()
	self:SetColor(Color(255,255,255,0))
	
end
function ENT:DrawPortal()
	local viewent = GetViewEntity()
	local pos = ( IsValid( viewent ) and viewent != LocalPlayer() ) and GetViewEntity():GetPos() or EyePos()

	if IsInFront( pos, self:GetRenderOrigin(), self:GetForward() ) and self:GetNWBool("Potal:Activated",false) then
		
		render.ClearStencil() -- Make sure the stencil buffer is all zeroes before we begin
		render.SetStencilEnable( true )
		
			cam.Start3D2D(self:GetRenderOrigin(),self:GetAngles(),1)
				
				render.SetStencilWriteMask(3)
				render.SetStencilTestMask(3)
				render.SetStencilFailOperation( STENCILOPERATION_KEEP )
				render.SetStencilZFailOperation( STENCILOPERATION_KEEP )  -- Don't change anything if the pixel is occoludded (so we don't see things thru walls)
				render.SetStencilPassOperation( STENCILOPERATION_REPLACE ) -- Replace the value of the buffer's pixel with the reference value
				render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS) -- Always replace regardless of whatever is in the stencil buffer currently

				render.SetStencilReferenceValue( 1 )
			   
				local percentopen = self.openpercent
				self:SetModelScale( percentopen,0 )
				self:DrawModel()
				
				render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
				
				--Draw portal.
				local portaltype = self:GetNWInt( "Potal:PortalType",TYPE_BLUE )
				if renderportals:GetBool() then
				local ToRT = portaltype == TYPE_BLUE and texFSB or texFSB2
				if GetConVarNumber("portal_texFSB") >=2 then
					PortalMaterial:SetTexture( "$basetexture", ToRT )
				elseif GetConVarNumber("portal_texFSB") >=1 then
					PortalMaterial:SetTexture( "$basetexture", ToRT )
				else
					PortalMaterial:SetTexture( "$basetexture", ToRT )
					render.SetMaterial( PortalMaterial )
					render.DrawScreenQuad()
				end
				end
				
				--Draw colored overlay.
				local color = Material("models/portals/portalstaticoverlay_1", "PortalRefract")
				if portaltype == TYPE_ORANGE then
					color = Material("models/portals/portalstaticoverlay_2", "PortalRefract")
				end
				local other = self:GetNWEntity("Potal:Other")
				if other and other:IsValid() and other.openpercent_material then
					if renderportals:GetBool() then
					
					if GetConVarNumber("portal_texFSB") >=2 then
						color:SetFloat("$PortalStatic", 1)
					elseif GetConVarNumber("portal_texFSB") >=1 then
						color:SetFloat("$PortalStatic", 1) 
					else
						color:SetFloat("$PortalStatic", 1-math.min(other.openpercent_material))
					end
					
					else
						color:SetFloat("$PortalStatic", 1)
					end
				end		
			
			cam.End3D2D()
		
		render.SetStencilEnable( false )
		
		self:DrawPortalEffects( portaltype )
	end
end

function ENT:RenderPortal( origin, angles)
	if renderportals:GetBool() then
		local portal = self:GetNWEntity( "Potal:Other", nil )
		if IsValid( portal ) and self:GetNWBool( "Potal:Linked", false ) and self:GetNWBool( "Potal:Activated", false ) then
   
			local portaltype = self:GetNWInt( "Potal:PortalType", TYPE_BLUE )
		   
			local normal = self:GetForward()
			local distance = normal:Dot( self:GetRenderOrigin() )
		   
			othernormal = portal:GetForward()
			otherdistance = othernormal:Dot( portal:GetRenderOrigin() )
		   
			-- quick access
			local forward = angles:Forward()
			local up = angles:Up()
		   
			-- reflect origin
			local dot = origin:DotProduct( normal ) - distance
			origin = origin + ( -2 * dot ) * normal
		   
			-- reflect forward
			local dot = forward:DotProduct( normal )
			forward = forward + ( -2 * dot ) * normal
		   
			-- reflect up		  
			local dot = up:DotProduct( normal )
			up = up + ( -2 * dot ) * normal
		   
			-- convert to angles
			angles = math.VectorAngles( forward, up )
		   
			local LocalOrigin = self:WorldToLocal( origin )
			local LocalAngles = self:WorldToLocalAngles( angles )
		   
			-- repair
			if self:OnFloor() and not portal:OnFloor() then
				LocalOrigin.x = LocalOrigin.x + 20
			end
			LocalOrigin.y = -LocalOrigin.y
			LocalAngles.y = -LocalAngles.y
			LocalAngles.r = -LocalAngles.r
		   
			view = {}
			view.x = 0
			view.y = 0
			view.w = ScrW()
			view.h = ScrH()
			view.origin = portal:LocalToWorld( LocalOrigin )
			view.angles = portal:LocalToWorldAngles( LocalAngles )
			view.drawhud = false
			view.drawviewmodel = false
			
			local oldrt = render.GetRenderTarget()
		   
			local ToRT = portaltype == TYPE_BLUE and texFSB or texFSB2
		   
			render.SetRenderTarget( ToRT )
				render.PushCustomClipPlane( othernormal, otherdistance )
				local b = render.EnableClipping(true)
					render.Clear( 0, 0, 0, 255 )
					render.ClearDepth()
					render.ClearStencil()
					
					portal:SetNoDraw( true )
						RENDERING_PORTAL = self
							render.RenderView( view )
							render.UpdateScreenEffectTexture()
						RENDERING_PORTAL = false
					portal:SetNoDraw( false )
					
				render.PopCustomClipPlane()
				render.EnableClipping(b)
			render.SetRenderTarget( oldrt ) 
		end
	end
end


/*------------------------------------
		VectorAngles()
------------------------------------*/
function math.VectorAngles( forward, up )

		local angles = Angle( 0, 0, 0 )

		local left = up:Cross( forward )
		left:Normalize()
	   
		local xydist = math.sqrt( forward.x * forward.x + forward.y * forward.y )
	   
		-- enough here to get angles?
		if( xydist > 0.001 ) then
	   
				angles.y = math.deg( math.atan2( forward.y, forward.x ) )
				angles.p = math.deg( math.atan2( -forward.z, xydist ) )
				angles.r = math.deg( math.atan2( left.z, ( left.y * forward.x ) - ( left.x * forward.y ) ) )

		else
	   
				angles.y = math.deg( math.atan2( -left.x, left.y ) )
				angles.p = math.deg( math.atan2( -forward.z, xydist ) )
				angles.r = 0
	   
		end


		return angles
	   
end