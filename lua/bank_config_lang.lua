----------------------------------------------------------------------------------
-- Basic Lua Knowledge Required//Translation File\\Basic Lua Knowledge Required --
----------------------------------------------------------------------------------
function BankLang() //Use "selectBankLang <desired lang>" to enable "pt_br" or other available languages. The default language is "en".
    
	local tab = util.JSONToTable( file.Read( "bankrobberysystem/config_save/saved_lang.txt", "DATA" ) )
	
	if tab.Bank_SelectLang == "en" then
	    
		PrintMessage( HUD_PRINTTALK, "[Bank Robbery System]: English by n00bmobile selected!" )
		
	    -- Personal Error Messages --
        Bank_WrongTeam = "You cannot start a robbery as a %PLAYERTEAM%!"
        Bank_WrongArrested = "You cannot start a robbery arrested!"
        Bank_WrongPlayer = "There has to be at least %MINPLAYERS% players!"
        Bank_WrongCop = "There has to be at least %MINCOPS% cops!"
		Bank_WrongBanker = "There has to be at least %MINBANKERS% bankers!"
        Bank_WrongCooldown = "You need to wait for the cooldown finish!"
        Bank_WrongRobbery = "You cannot start a robbery while another one is in progress!"
        -- Public Notifications Fails --
        Bank_FailDied = "%PLAYERNAME% has died causing the end of the robbery!"
        Bank_FailChanged = "%PLAYERNAME% has changed jobs causing the end of the robbery!"
        Bank_FailArrested = "%PLAYERNAME% has been arrested causing the end of the robbery!"
        Bank_FailArea = "%PLAYERNAME% has exited the area causing the end of the robbery!"
        -- Bank Public Notifications --
        Bank_RobberyStarted = "%PLAYERNAME% has started a robbery!"
        Bank_RobberyFinished = "%PLAYERNAME% has finished the robbery!"
        -- Bank Display Texts --
        Bank_DisplayRobbing = "Robbing: %ROBBINGTIMER%"
        Bank_DisplayCooldown = "Cooldown: %COOLDOWNTIMER%"
	    Bank_DisplayReady = "Ready"
		Bank_DisplayVault = "Bank Vault"
		-- Bank General Notifications --
		Bank_GMNotSuported = "%GAMEMODE% is not supported!"
		Bank_MapPosLoaded = "%MAPNAME% position loaded!"
		Bank_NopeSuperadmin = "You need to be a superadmin to run this command!"
		

	elseif tab.Bank_SelectLang == "pt_br" then
	    
		PrintMessage( HUD_PRINTTALK, "[Bank Robbery System]: Brazilian Portuguese by n00bmobile selected!" )
		
		-- Personal Error Messages --
	    Bank_WrongTeam = "Você não pode roubar como um %PLAYERTEAM%!"
        Bank_WrongArrested = "Você não pode roubar preso!"
        Bank_WrongPlayer = "É preciso ter pelo menos %MINPLAYERS% jogadores!"
        Bank_WrongCop = "É preciso ter pelo menos %MINCOPS% policiais!"
        Bank_WrongBanker = "É preciso ter pelo menos %MINBANKERS% banqueiros!"
		Bank_WrongCooldown = "Você precisa esperar o recarregamento acabar!"
        Bank_WrongRobbery = "Você não pode roubar um banco que já está sendo roubado!"
	    -- Public Notifications Fails --
	    Bank_FailDied = "%PLAYERNAME% morreu causando o final do roubo!"
	    Bank_FailChanged = "%PLAYERNAME% trocou de emprego causando o final do roubo!"
	    Bank_FailArrested = "%PLAYERNAME% foi preso causando o final do roubo!"
	    Bank_FailArea = "%PLAYERNAME% saiu da área do roubo causando seu final!"
	    -- Bank Public Notifications --
	    Bank_RobberyStarted = "%PLAYERNAME% começou um roubo!"
	    Bank_RobberyFinished = "%PLAYERNAME% terminou um roubo!"
	    -- Bank Display Texts --
	    Bank_DisplayRobbing = "Roubando: %ROBBINGTIMER%"
	    Bank_DisplayCooldown = "Recarregando: %COOLDOWNTIMER%"
	    Bank_DisplayReady = "Pronto"
		Bank_DisplayVault = "Cofre do Banco"
		-- Bank General Notifications --
		Bank_GMNotSuported = "%GAMEMODE% não é suportado!"
		Bank_MapPosLoaded = "Carregada a posição de %MAPNAME%!"
		Bank_NopeSuperadmin = "Você precisa ser um super administrador para executar esse comando!"
	
	else
	    
		PrintMessage( HUD_PRINTTALK, "[Bank Robbery System]: This language isn't valid, the save file has been removed!" )
		file.Delete( "bankrobberysystem/config_save/saved_lang.txt" )
		
	end
	
end