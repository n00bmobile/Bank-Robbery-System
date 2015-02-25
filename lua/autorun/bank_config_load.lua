if SERVER then
	
	include("bank_config.lua")
	AddCSLuaFile("bank_config.lua")
	
	include("bank_config_lang.lua")
	AddCSLuaFile("bank_config_lang.lua")

	MsgN("Bank Robbery System Beta Version 1.6 Loaded")

elseif CLIENT then
	
	include("bank_config.lua")

end
    