--[[
 /$$$$$$$                      /$$             /$$$$$$$   /$$$$$$  | * PRODUCT LICENSED: http://creativecommons.org/licenses/by-nd/3.0/
| $$__  $$                    | $$            | $$__  $$ /$$__  $$ | By using this product, you agree to follow the license limitations.
| $$  \ $$  /$$$$$$  /$$$$$$$ | $$   /$$      | $$  \ $$| $$  \__/ | Got any questions, contact author.
| $$$$$$$  |____  $$| $$__  $$| $$  /$$/      | $$$$$$$/|  $$$$$$  | 
| $$__  $$  /$$$$$$$| $$  \ $$| $$$$$$/       | $$__  $$ \____  $$ | * AUTHOR: n00bmobile
| $$  \ $$ /$$__  $$| $$  | $$| $$_  $$       | $$  \ $$ /$$  \ $$ |
| $$$$$$$/|  $$$$$$$| $$  | $$| $$ \  $$      | $$  | $$|  $$$$$$/ | * FILE: cl_init.lua
|_______/  \_______/|__/  |__/|__/  \__/      |__/  |__/ \______/  |
]]--

include("shared.lua")

function ENT:Initialize()
	self.Color = Color( 255, 255, 255, 255 )
end

local b_status = "Ready"
function getBankUpdate()
    b_status = net.ReadString()
end
net.Receive("RSBank_clientUpdate", getBankUpdate)

surface.CreateFont("BankFont", {font = "Coolvetica", size = 16})
function ENT:Draw()
    local pos = self:GetPos()
    local ang = self:GetAngles()
    local pos1 = self:GetPos()
    local ang1 = self:GetAngles()

    if !self.rotate then self.rotate = 0 end
    if !self.lasttime then self.lasttime = 0 end

    self.Entity:DrawModel()
   
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), self.rotate)
    ang:RotateAroundAxis(ang:Up(), 0)

    ang1:RotateAroundAxis(ang1:Forward(), 90)
    ang1:RotateAroundAxis(ang1:Right(), self.rotate +180)
    ang1:RotateAroundAxis(ang1:Up(), 0)

    cam.Start3D2D(pos, ang, 1)
        draw.SimpleTextOutlined("$"..BankConfig.reward, "BankFont", 0, -75, Color(20, 150, 20, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
		
		if b_status != "Ready" then    
			draw.SimpleTextOutlined("Bank Vault", "BankFont", 0, -100, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
			draw.SimpleTextOutlined(b_status, "BankFont", 0, -88, Color(255, 9, 9, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
		else
			draw.SimpleTextOutlined("Bank Vault", "BankFont", 0, -88, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
        end		
    cam.End3D2D()
   
    cam.Start3D2D(pos1, ang1, 1)
        draw.SimpleTextOutlined("$"..BankConfig.reward, "BankFont", 0, -75, Color(20, 150, 20, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
		
		if b_status != "Ready" then    
			draw.SimpleTextOutlined("Bank Vault", "BankFont", 0, -100, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
			draw.SimpleTextOutlined(b_status, "BankFont", 0, -88, Color(255, 9, 9, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
		else
			draw.SimpleTextOutlined("Bank Vault", "BankFont", 0, -88, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
        end	   
    cam.End3D2D()

    if(self.rotate > 359) then self.rotate = 0 end

    self.rotate = self.rotate -(100*(self.lasttime -SysTime()))
    self.lasttime = SysTime()
end
