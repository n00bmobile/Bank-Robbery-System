include("shared.lua")
include("bank_config.lua")

function ENT:Initialize()
	
	self.Color = Color( 255, 255, 255, 255 )

end

function ENT:Draw()
   
   local pos = self:GetPos()
   local ang = self:GetAngles()
   local pos1 = self:GetPos()
   local ang1 = self:GetAngles()

   if not self.rotate then self.rotate = 0 end
   if not self.lasttime then self.lasttime = 0 end

   self.Entity:DrawModel()
   
   ang:RotateAroundAxis( ang:Forward(), 90 )
   ang:RotateAroundAxis( ang:Right(), self.rotate)
   ang:RotateAroundAxis( ang:Up(), 0  )

   ang1:RotateAroundAxis( ang1:Forward(), 90 )
   ang1:RotateAroundAxis( ang1:Right(), self.rotate + 180)
   ang1:RotateAroundAxis( ang1:Up(), 0  )

   cam.Start3D2D( pos, ang, 1 )
        draw.DrawText( self:GetNWInt("BankVault"), "Default", 0, -100, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( self:GetNWInt("BankStatus"), "Default", 0, -90, Color( 255, 9, 9, 237 ), TEXT_ALIGN_CENTER )
        draw.DrawText("$" ..Bank_SetMoneyAmount, "Default", 0, -80, Color( 20, 150, 20, 255 ), TEXT_ALIGN_CENTER )
   cam.End3D2D()
   
   cam.Start3D2D( pos1, ang1, 1 )
        draw.DrawText( self:GetNWInt("BankVault"), "Default", 0, -100, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( self:GetNWInt("BankStatus"), "Default", 0, -90, Color( 255, 9, 9, 237 ), TEXT_ALIGN_CENTER )
        draw.DrawText( "$" ..Bank_SetMoneyAmount, "Default", 0, -80, Color( 20, 150, 20, 255 ), TEXT_ALIGN_CENTER )   
   cam.End3D2D()

   if( self.rotate > 359 ) then self.rotate = 0 end

   self.rotate = self.rotate - ( 100* ( self.lasttime -SysTime() ) )
   self.lasttime = SysTime()

end