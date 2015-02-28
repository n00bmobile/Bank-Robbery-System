if SERVER then
	
	AddCSLuaFile("bank_config.lua")
	AddCSLuaFile("bank_config_lang.lua")
	include("bank_config.lua")
	include("bank_config_lang.lua")
	

	MsgN("Bank Robbery System Beta Version 1.6 Loaded")

else
	
	include("bank_config.lua")
	include("bank_config_lang.lua")

end
    