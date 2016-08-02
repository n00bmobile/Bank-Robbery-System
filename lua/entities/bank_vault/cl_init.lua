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
        draw.SimpleTextOutlined(DarkRP.formatMoney(self:GetNWInt("CurrentReward")), "BankFont", 0, -480, Color(20, 150, 20, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color(0, 0, 0, 255))
		
		if (self:GetNWString("Status") == "") then   
			draw.SimpleTextOutlined("Bank Vault", "BankFont", 0, -560, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color(0, 0, 0, 255))
		else
			draw.SimpleTextOutlined("Bank Vault", "BankFont", 0, -635, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color(0, 0, 0, 255))
			draw.SimpleTextOutlined(self:GetNWString("Status"), "BankFont", 0, -560, Color(255, 9, 9, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color(0, 0, 0, 255))
        end		
    cam.End3D2D()
   
    cam.Start3D2D(pos, ang2, 0.15)
        draw.SimpleTextOutlined(DarkRP.formatMoney(self:GetNWInt("CurrentReward")), "BankFont", 0, -480, Color(20, 150, 20, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color(0, 0, 0, 255))
		
		if (self:GetNWString("Status") == "") then
			draw.SimpleTextOutlined("Bank Vault", "BankFont", 0, -560, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color(0, 0, 0, 255))
		else
			draw.SimpleTextOutlined("Bank Vault", "BankFont", 0, -635, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color(0, 0, 0, 255))
			draw.SimpleTextOutlined(self:GetNWString("Status"), "BankFont", 0, -560, Color(255, 9, 9, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color(0, 0, 0, 255))
        end   
    cam.End3D2D()

    if (self.rotate > 359) then 
	    self.rotate = 0 
	end

    self.rotate = self.rotate -50 *(self.lasttime -CurTime())
    self.lasttime = CurTime()
end

hook.Add("HUDPaint", "BankRS_HUDWarn", function()
    for k, v in pairs(ents.FindByClass("bank_vault")) do
        if (string.find(v:GetNWString("Status"), "Robbing") and table.HasValue(BankRS_Config["Robbery"]["Team_Required"]["Cops"], team.GetName(LocalPlayer():Team()))) then
		    local pos = (v:GetPos() +Vector(0, 0, 80)):ToScreen()
		    draw.DrawText(v:GetNWString("Status"), "Default", pos.x, pos.y, color_white, 1)
        end
	end
end)

hook.Add("PreDrawHalos", "BankRS_HaloWarn", function()
	for k, v in pairs(ents.FindByClass("bank_vault")) do
        if (string.find(v:GetNWString("Status"), "Robbing") and table.HasValue(BankRS_Config["Robbery"]["Team_Required"]["Cops"], team.GetName(LocalPlayer():Team()))) then
		    halo.Add({v}, Color(150, 20, 20), 0, 0, 5, true, true)
		end
	end
end)