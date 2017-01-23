MsgN("[BankRS]: Version 1.8.2 Loaded!")

if (SERVER) then
    AddCSLuaFile("bank_config.lua")
    include("bank_config.lua")
	
	resource.AddFile("sound/bank_vault/siren.wav")
	resource.AddFile("resource/fonts/coolvetica.ttf")
	
	util.PrecacheSound("siren.wav")
else	
	include("bank_config.lua")
end
