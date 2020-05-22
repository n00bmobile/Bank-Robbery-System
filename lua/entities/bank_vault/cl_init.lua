include('shared.lua')

surface.CreateFont('BankFont', {font = 'Coolvetica Rg', size = 100})
function ENT:Draw()
    self:DrawModel()

    if LocalPlayer():GetPos():DistToSqr(self:GetPos()) <= 360000 then --600^2
        if not self.DisplayText then
            self.DisplayText = {}
            self.DisplayText.Rotation = 0
            self.DisplayText.LastRotation = 0
        end

        local pos = self:GetPos()
        local ang = self:GetAngles()
        local ang2 = self:GetAngles()
        local status = self:GetStatus()
        ang:RotateAroundAxis(ang:Forward(), 90)
        ang:RotateAroundAxis(ang:Right(), self.DisplayText.Rotation)
        ang2:RotateAroundAxis(ang2:Forward(), 90)
        ang2:RotateAroundAxis(ang2:Right(), self.DisplayText.Rotation +180)

        cam.Start3D2D(pos, ang, 0.15) 
            draw.SimpleTextOutlined(DarkRP.formatMoney(self:GetReward()), 'BankFont', 0, -485, Color(20, 150, 20, 255), 1, 1, 5, color_black)
        
            if status == 1 then
                draw.SimpleTextOutlined('Bank Vault', 'BankFont', 0, -640, color_white, 1, 1, 5, color_black)
                draw.SimpleTextOutlined('Robbing: '..string.ToMinutesSeconds(math.Clamp(math.Round(self:GetNextAction() -CurTime()), 0, BANK_CONFIG.RobberyTime)), 'BankFont', 0, -565, Color(255, 0, 0), 1, 1, 5, color_black)
            elseif status == 2 then
                draw.SimpleTextOutlined('Bank Vault', 'BankFont', 0, -640, color_white, 1, 1, 5, color_black)
                draw.SimpleTextOutlined('Cooldown: '..string.ToMinutesSeconds(math.Clamp(math.Round(self:GetNextAction() -CurTime()), 0, BANK_CONFIG.CooldownTime)), 'BankFont', 0, -565, Color(255, 0, 0), 1, 1, 5, color_black)
            else
                draw.SimpleTextOutlined('Bank Vault', 'BankFont', 0, -565, Color(255, 255, 255, 255), 1, 1, 5, color_black)
            end
        cam.End3D2D()
   
        cam.Start3D2D(pos, ang2, 0.15)
            draw.SimpleTextOutlined(DarkRP.formatMoney(self:GetReward()), 'BankFont', 0, -485, Color(20, 150, 20, 255), 1, 1, 5, color_black)
        
            if status == 1 then
                draw.SimpleTextOutlined('Bank Vault', 'BankFont', 0, -640, color_white, 1, 1, 5, color_black)
                draw.SimpleTextOutlined('Robbing: '..string.ToMinutesSeconds(math.Clamp(math.Round(self:GetNextAction() -CurTime()), 0, BANK_CONFIG.RobberyTime)), 'BankFont', 0, -565, Color(255, 0, 0), 1, 1, 5, color_black)
            elseif status == 2 then
                draw.SimpleTextOutlined('Bank Vault', 'BankFont', 0, -640, color_white, 1, 1, 5, color_black)
                draw.SimpleTextOutlined('Cooldown: '..string.ToMinutesSeconds(math.Clamp(math.Round(self:GetNextAction() -CurTime()), 0, BANK_CONFIG.CooldownTime)), 'BankFont', 0, -565, Color(255, 0, 0), 1, 1, 5, color_black)
            else
                draw.SimpleTextOutlined('Bank Vault', 'BankFont', 0, -565, Color(255, 255, 255, 255), 1, 1, 5, color_black)
            end	
        cam.End3D2D()

        if self.DisplayText.Rotation > 359 then 
	        self.DisplayText.Rotation = 0 
	    end

        self.DisplayText.Rotation = self.DisplayText.Rotation -50 *(self.DisplayText.LastRotation -CurTime())
        self.DisplayText.LastRotation = CurTime()
    end
end

hook.Add('HUDPaint', 'BankRS_DrawWarningText', function()
    if BANK_CONFIG.Government[team.GetName(LocalPlayer():Team())] then
	    for k, v in pairs(ents.FindByClass('bank_vault')) do
            if v:GetStatus() == 1 then
                local pos = (v:GetPos() +Vector(0, 0, 80)):ToScreen()
		        draw.DrawText('BANK BEING ROBBED', 'Default', pos.x, pos.y, HSVToColor(CurTime() *100 %360, 1, 1), 1)
                break
		    end
		end
    end
end)

hook.Add('PreDrawHalos', 'BankRS_DrawWarningHalo', function()
	if BANK_CONFIG.Government[team.GetName(LocalPlayer():Team())] then
	    for k, v in pairs(ents.FindByClass('bank_vault')) do
            if v:GetStatus() == 1 then
                halo.Add({v}, Color(255, 0, 0), 0, 0, 5, true, true)
                break
		    end
		end
	end
end)