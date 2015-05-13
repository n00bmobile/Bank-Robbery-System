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
include("config.lua")

function ENT:Initialize()
	self.Color = Color( 255, 255, 255, 255 )
end

local status = "Ready"
function getUpdate()
    status = net.ReadString()
end
net.Receive("clientUpdate", getUpdate)

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
        draw.DrawText("Bank Vault", "Default", 0, -100, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
        draw.DrawText(status, "Default", 0, -90, Color(255, 9, 9, 237), TEXT_ALIGN_CENTER)
        draw.DrawText("$"..BankConfig.reward, "Default", 0, -80, Color(20, 150, 20, 255), TEXT_ALIGN_CENTER)
    cam.End3D2D()
   
    cam.Start3D2D(pos1, ang1, 1)
        draw.DrawText("Bank Vault", "Default", 0, -100, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
        draw.DrawText(status, "Default", 0, -90, Color(255, 9, 9, 237), TEXT_ALIGN_CENTER)
        draw.DrawText("$"..BankConfig.reward, "Default", 0, -80, Color(20, 150, 20, 255), TEXT_ALIGN_CENTER)   
    cam.End3D2D()

    if( self.rotate > 359 ) then self.rotate = 0 end

    self.rotate = self.rotate -(100*(self.lasttime -SysTime()))
    self.lasttime = SysTime()
end
