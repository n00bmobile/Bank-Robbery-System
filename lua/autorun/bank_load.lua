MsgN("[BankRS]: Version 1.7.6 Loaded!")

if SERVER then
    AddCSLuaFile("bank_config.lua")
    include("bank_config.lua")
	
	resource.AddFile("sound/siren.wav")
	util.PrecacheSound("siren.wav")
else	
	include("bank_config.lua")
end
