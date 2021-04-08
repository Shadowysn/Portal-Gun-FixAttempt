SWEP.Base				= "weapon_portalgun"

if ( CLIENT ) then
	SWEP.WepSelectIcon		= surface.GetTextureID("weapons/portalgun_inventory")
	SWEP.PrintName			= "Atlas's Portal Gun"
	SWEP.Author				= "CnicK / Bobblehead / Matsilagi"
	SWEP.Contact			= "kaisd@mail.ru"
	SWEP.Purpose			= "Shoot Linked Portals"
	SWEP.ViewModelFOV		= "60"
	SWEP.Instructions	   	= ""
	SWEP.Slot = 0
	SWEP.Slotpos = 0
	SWEP.CSMuzzleFlashes	= false
	
	-- function SWEP:DrawWorldModel()
		-- if ( RENDERING_PORTAL or RENDERING_MIRROR or GetViewEntity() != LocalPlayer() ) then
			-- self.Weapon:DrawModel()
		-- end
	-- end
end

SWEP.Spawnable					= true
SWEP.AdminSpawnable				= true

SWEP.ViewModel                  = "models/weapons/portalgun/c_portalgun_blue.mdl"
SWEP.WorldModel                 = "models/weapons/portalgun/w_portalgun_blue.mdl"

SWEP.Primary.Color = Color(0,225,255,120)
SWEP.Secondary.Color = Color(0,0,255,120)