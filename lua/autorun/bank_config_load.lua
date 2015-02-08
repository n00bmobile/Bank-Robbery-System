if SERVER then
	include("bank_config.lua")
	print("BankRobbery: Loaded with Success!")
	AddCSLuaFile("bank_config.lua")
else
	include("bank_config.lua")
end