include("shared.lua")

surface.CreateFont("bankFont", {font = "Coolvetica", size = 100}) --I don't know why, but as long as this number is high the font looks fine!
function ENT:Draw()
    local pos = self:GetPos()
    local ang = self:GetAngles()
	local ang2 = self:GetAngles()

    if not self.rotate then 
	    self.rotate = 0 
	end
	
    if not self.lasttime then 
	    self.lasttime = 0 
	end

    self.Entity:DrawModel()
   
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), self.rotate)

    ang2:RotateAroundAxis(ang2:Forward(), 90)
    ang2:RotateAroundAxis(ang2:Right(), self.rotate +180)

    cam.Start3D2D(pos, ang, 0.15) 
        draw.SimpleTextOutlined(DarkRP.formatMoney(self:GetNWInt("bankReward")), "bankFont", 0, -485, Color(20, 150, 20, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color(0, 0, 0, 255))
		
		if self:GetNWString("bankStatus") == "" then   
			draw.SimpleTextOutlined("Bank Vault", "bankFont", 0, -565, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color(0, 0, 0, 255))
		else
			draw.SimpleTextOutlined("Bank Vault", "bankFont", 0, -640, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color(0, 0, 0, 255))
			draw.SimpleTextOutlined(self:GetNWString("bankStatus"), "bankFont", 0, -565, Color(255, 9, 9, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color(0, 0, 0, 255))
        end		
    cam.End3D2D()
   
    cam.Start3D2D(pos, ang2, 0.15)
        draw.SimpleTextOutlined(DarkRP.formatMoney(self:GetNWInt("bankReward")), "bankFont", 0, -485, Color(20, 150, 20, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color(0, 0, 0, 255))
		
		if self:GetNWString("bankStatus") == "" then
			draw.SimpleTextOutlined("Bank Vault", "bankFont", 0, -565, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color(0, 0, 0, 255))
		else
			draw.SimpleTextOutlined("Bank Vault", "bankFont", 0, -640, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color(0, 0, 0, 255))
			draw.SimpleTextOutlined(self:GetNWString("bankStatus"), "bankFont", 0, -565, Color(255, 9, 9, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, Color(0, 0, 0, 255))
        end   
    cam.End3D2D()

    if self.rotate > 359 then 
	    self.rotate = 0 
	end

    self.rotate = self.rotate -50 *(self.lasttime -CurTime())
    self.lasttime = CurTime()
end

hook.Add("HUDPaint", "bank_draw_warning_hud", function()
    if table.HasValue(bank_config.robbery.t_required.cops, team.GetName(LocalPlayer():Team())) then
	    for k, v in pairs(ents.FindByClass("bank_vault")) do
            if string.find(v:GetNWString("bankStatus"), "Robbing") then
		        local pos = (v:GetPos() +Vector(0, 0, 80)):ToScreen()
		        draw.DrawText(v:GetNWString("bankStatus"), "Default", pos.x, pos.y, color_white, 1)
            end
		end
	end
end)

hook.Add("PreDrawHalos", "bank_draw_warning_halo", function()
	if table.HasValue(bank_config.robbery.t_required.cops, team.GetName(LocalPlayer():Team())) then
	    local onRobbery = {}
	    
		for k, v in pairs(ents.FindByClass("bank_vault")) do
            if string.find(v:GetNWString("bankStatus"), "Robbing") then
		        table.insert(onRobbery, v)
		    end
		end
		
		halo.Add(onRobbery, Color(150, 20, 20), 0, 0, 5, true, true)
	end
end)