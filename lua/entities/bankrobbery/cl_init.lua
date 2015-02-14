include('shared.lua')

function ENT:Initialize()
	
	self.Color = Color( 255, 255, 255, 255 )
	
end

function ENT:Draw()

   -- LOCAL -------------------
   local pos = self:GetPos()
   local ang = self:GetAngles()
   local pos1 = self:GetPos()
   local ang1 = self:GetAngles()
   ----------------------------
   	
   -- Rotate Check -------------------------------
   if not self.rotate then self.rotate = 0 end
   if not self.lasttime then self.lasttime = 0 end
   -----------------------------------------------
   
   -- DRAW ---------------
   self.Entity:DrawModel()
   -----------------------
   
   -- RoatateAroundAxis ----------------------
   ang:RotateAroundAxis( ang:Forward(), 90 )
   ang:RotateAroundAxis( ang:Right(), self.rotate)
   ang:RotateAroundAxis( ang:Up(), 0  )
   ----------------------------------------- 
   
   -- RoatateAroundAxis1 ----------------------
   ang1:RotateAroundAxis( ang1:Forward(), 90 )
   ang1:RotateAroundAxis( ang1:Right(), self.rotate + 180)
   ang1:RotateAroundAxis( ang1:Up(), 0  )
   ----------------------------------------- 
 
   -- Text --------------------------------------------------------------------------------------
   cam.Start3D2D( pos, ang, 1 )
   draw.DrawText("Bank Vault", "Default", 0, -100, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
   draw.DrawText(self:GetNWInt("BankClient") or "Loading", "Default", 0, -90, Color( 255, 9, 9, 237 ), TEXT_ALIGN_CENTER )
   draw.DrawText(self:GetNWInt("Bank_StartingAmount") or 0, "Default", 0, -80, Color( 20, 150, 20, 255 ), TEXT_ALIGN_CENTER )
   cam.End3D2D()
   
   cam.Start3D2D( pos1, ang1, 1 )
   draw.DrawText("Bank Vault", "Default", 0, -100, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
   draw.DrawText(self:GetNWInt("BankClient") or "Loading", "Default", 0, -90, Color( 255, 9, 9, 237 ), TEXT_ALIGN_CENTER )
   draw.DrawText(self:GetNWInt("Bank_StartingAmount") or 0, "Default", 0, -80, Color( 20, 150, 20, 255 ), TEXT_ALIGN_CENTER )   
   cam.End3D2D()
   ----------------------------------------------------------------------------------------------

   -- Reset Rotation ------------------------------
   if( self.rotate > 359 ) then self.rotate = 0 end
   ------------------------------------------------
   
   -- Rotate -----------------------------------------------------
   self.rotate = self.rotate - ( 100*( self.lasttime-SysTime() ) )
   self.lasttime = SysTime()
   ---------------------------------------------------------------
   
end