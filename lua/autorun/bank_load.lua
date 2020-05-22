if SERVER then
    --lua
	AddCSLuaFile('bank_config.lua')
    include('bank_config.lua')
	--other files
	resource.AddFile('resource/fonts/coolvetica-rg.ttf')
	resource.AddFile('sound/bank_vault/siren.wav')
	util.PrecacheSound('bank_vault/siren.wav')
else	
	include('bank_config.lua')
end