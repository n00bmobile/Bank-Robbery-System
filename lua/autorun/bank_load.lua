if SERVER then
    AddCSLuaFile('bank_config.lua')
    include('bank_config.lua')
	resource.AddFile('sound/bank_vault/siren.wav')
	--resource.AddFile('resource/fonts/coolvetica.ttf')
	util.PrecacheSound('bank_vault/siren.wav')
else	
	include('bank_config.lua')
end

MsgN('Bank Robbery System 1.8.3 loaded!')