include("shared.lua")

surface.CreateFont("BankFont", {font = "Coolvetica", size = 100}) //I don't know why, but as long as this number is high the font looks fine!
function ENT:Draw()
    local pos = self:GetPos()
    local ang = self:GetAngles()
    local ang2 = self:GetAngles()

    if (not self.rotate) then 
	    self.rotate = 0 
	end
	
    if (not self.lasttime) then 
	    self.lasttime = 0 
	end

    self.Entity:DrawModel()
   
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), self.rotate)

    ang2:RotateAroundAxis(ang2:Forward(), 90)
    ang2:RotateAroundAxis(ang2:Right(), self.rotate +180)

    cam.Start3D2D(pos, ang, 0.15) 
        draw.SimpleTextOutlined(DarkRP.formatMoney(BankRS_RewardCurrent), "BankFont", 0, -480, Color(20, 150, 20, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color(0, 0, 0, 255))
		
		if (self:GetNWString("BankRS_Status") == "") then   
			draw.SimpleTextOutlined("Bank Vault", "BankFont", 0, -560, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color(0, 0, 0, 255))
		else
			draw.SimpleTextOutlined("Bank Vault", "BankFont", 0, -635, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color(0, 0, 0, 255))
			draw.SimpleTextOutlined(self:GetNWString("BankRS_Status"), "BankFont", 0, -560, Color(255, 9, 9, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color(0, 0, 0, 255))
        end		
    cam.End3D2D()
   
    cam.Start3D2D(pos, ang2, 0.15)
        draw.SimpleTextOutlined(DarkRP.formatMoney(BankRS_RewardCurrent), "BankFont", 0, -480, Color(20, 150, 20, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color(0, 0, 0, 255))
		
		if (self:GetNWString("BankRS_Status") == "") then
			draw.SimpleTextOutlined("Bank Vault", "BankFont", 0, -560, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color(0, 0, 0, 255))
		else
			draw.SimpleTextOutlined("Bank Vault", "BankFont", 0, -635, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color(0, 0, 0, 255))
			draw.SimpleTextOutlined(self:GetNWString("BankRS_Status"), "BankFont", 0, -560, Color(255, 9, 9, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color(0, 0, 0, 255))
        end   
    cam.End3D2D()

    if (self.rotate > 359) then 
	    self.rotate = 0 
	end

    self.rotate = self.rotate -50 *(self.lasttime -CurTime())
    self.lasttime = CurTime()
end