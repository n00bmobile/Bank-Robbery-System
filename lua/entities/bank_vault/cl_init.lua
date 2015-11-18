include("shared.lua")

function ENT:Initialize()
	self.Color = Color( 255, 255, 255, 255 )
end

surface.CreateFont("BankFont", {font = "Coolvetica", size = 16})
function ENT:Draw()
    local pos = self:GetPos()
    local ang = self:GetAngles()
    local pos1 = self:GetPos()
    local ang1 = self:GetAngles()

    if (!self.rotate) then 
	    self.rotate = 0 
	end
    if (!self.lasttime) then 
	    self.lasttime = 0 
	end

    self.Entity:DrawModel()
   
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), self.rotate)
    ang:RotateAroundAxis(ang:Up(), 0)

    ang1:RotateAroundAxis(ang1:Forward(), 90)
    ang1:RotateAroundAxis(ang1:Right(), self.rotate +180)
    ang1:RotateAroundAxis(ang1:Up(), 0)

    cam.Start3D2D(pos, ang, 1)
        draw.SimpleTextOutlined(DarkRP.formatMoney(BankConfig.Reward), "BankFont", 0, -75, Color(20, 150, 20, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
		
		if (self:GetNWString("BankRSStatus") == "Cooldown: 00:00" || self:GetNWString("BankRSStatus") == "") then   
			draw.SimpleTextOutlined("Bank Vault", "BankFont", 0, -88, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
		else
			draw.SimpleTextOutlined("Bank Vault", "BankFont", 0, -100, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
			draw.SimpleTextOutlined(self:GetNWString("BankRSStatus"), "BankFont", 0, -88, Color(255, 9, 9, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
        end		
    cam.End3D2D()
   
    cam.Start3D2D(pos1, ang1, 1)
        draw.SimpleTextOutlined(DarkRP.formatMoney(BankConfig.Reward), "BankFont", 0, -75, Color(20, 150, 20, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
		
		if (self:GetNWString("BankRSStatus") == "Cooldown: 00:00" || self:GetNWString("BankRSStatus") == "") then
			draw.SimpleTextOutlined("Bank Vault", "BankFont", 0, -88, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
		else
			draw.SimpleTextOutlined("Bank Vault", "BankFont", 0, -100, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
			draw.SimpleTextOutlined(self:GetNWString("BankRSStatus"), "BankFont", 0, -88, Color(255, 9, 9, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
        end   
    cam.End3D2D()

    if (self.rotate > 359) then 
	    self.rotate = 0 
	end

    self.rotate = self.rotate -(10*(self.lasttime -SysTime())) -- so fast...
    self.lasttime = SysTime()
end
