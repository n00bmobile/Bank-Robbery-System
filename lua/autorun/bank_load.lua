--[[
 /$$$$$$$                      /$$             /$$$$$$$   /$$$$$$  | * PRODUCT LICENSED: http://creativecommons.org/licenses/by-nd/3.0/
| $$__  $$                    | $$            | $$__  $$ /$$__  $$ | By using this product, you agree to follow the license limitations.
| $$  \ $$  /$$$$$$  /$$$$$$$ | $$   /$$      | $$  \ $$| $$  \__/ | Got any questions, contact author.
| $$$$$$$  |____  $$| $$__  $$| $$  /$$/      | $$$$$$$/|  $$$$$$  | 
| $$__  $$  /$$$$$$$| $$  \ $$| $$$$$$/       | $$__  $$ \____  $$ | * AUTHOR: n00bmobile
| $$  \ $$ /$$__  $$| $$  | $$| $$_  $$       | $$  \ $$ /$$  \ $$ |
| $$$$$$$/|  $$$$$$$| $$  | $$| $$ \  $$      | $$  | $$|  $$$$$$/ | * FILE: bank_load.lua
|_______/  \_______/|__/  |__/|__/  \__/      |__/  |__/ \______/  |
]]--

MsgN("[Bank Robbery System]: Version 1.7 Loaded!\n")
MsgN("|$$$$$$$                      |$$             |$$$$$$$   |$$$$$$\n| $$__  $$                    | $$            | $$__  $$ |$$__  $$\n| $$  | $$  |$$$$$$  |$$$$$$$ | $$   |$$      | $$  | $$| $$  |__|\n| $$$$$$$  |____  $$| $$__  $$| $$  |$$|      | $$$$$$$||  $$$$$$\n| $$__  $$  |$$$$$$$| $$  | $$| $$$$$$|       | $$__  $$ |____  $$\n| $$  | $$ |$$__  $$| $$  | $$| $$_  $$       | $$  | $$ |$$  | $$\n| $$$$$$$||  $$$$$$$| $$  | $$| $$ |  $$      | $$  | $$|  $$$$$$|\n|_______|  |_______||__|  |__||__|  |__|      |__|  |__| |______|\n")
MsgN("[Bank Robbery System]: "..tostring(table.Random({"Holy Mother Of Net Messages", "More Optimized, Less Messages", "Craphead Wants $$$", "I Use As Many Global Variables As I Want Tomelyr!", "Our God n00bmobile Gave Us This, Let's Praise Him On The DarkRP Forums!", "I Whish I Winned Something For Making Things..."})))

if SERVER then
    resource.AddFile("sound/siren.wav")
    
	util.AddNetworkString("RSBank_clientUpdate")
	util.PrecacheSound("siren.wav")
	
	AddCSLuaFile("bank_config.lua")
    include("bank_config.lua")
else
	include("bank_config.lua")
end