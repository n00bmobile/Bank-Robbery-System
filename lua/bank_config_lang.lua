----------------------------------------------------------------------------------
-- Basic Lua Knowledge Required//Translation File\\Basic Lua Knowledge Required --
----------------------------------------------------------------------------------
function BankLang() //Use "selectBankLang <desired lang>" to enable "pt_br" or other available languages. The default language is "en".
    
	local lang = file.Read( "bankrobberysystem/config_save/saved_lang.txt", "DATA" )
	
	if lang == "en" || lang == "english" then
	    
		PrintMessage( HUD_PRINTTALK, "[Bank Robbery System]: English Selected!" )
		
	    -- Personal Error Messages --
        Bank_WrongTeam       = "You cannot start a robbery as a %PLAYERTEAM%!"
        Bank_WrongArrested   = "You cannot start a robbery arrested!"
        Bank_WrongPlayer     = "There has to be at least %MINPLAYERS% players!"
        Bank_WrongCop        = "There has to be at least %MINCOPS% cops!"
		Bank_WrongBanker     = "There has to be at least %MINBANKERS% bankers!"
        Bank_WrongCooldown   = "You need to wait for the cooldown finish!"
        Bank_WrongRobbery    = "You cannot start a robbery while another one is in progress!"
        -- Public Notifications Fails --
        Bank_FailDied        = "%PLAYERNAME% has died causing the end of the robbery!"
        Bank_FailChanged     = "%PLAYERNAME% has changed jobs causing the end of the robbery!"
        Bank_FailArrested    = "%PLAYERNAME% has been arrested causing the end of the robbery!"
        Bank_FailArea        = "%PLAYERNAME% has exited the area causing the end of the robbery!"
        -- Bank Public Notifications --
        Bank_RobberyStarted  = "%PLAYERNAME% has started a robbery!"
        Bank_RobberyFinished = "%PLAYERNAME% has finished the robbery!"
        -- Bank Display Texts --
        Bank_DisplayRobbing  = "Robbing: %ROBBINGTIMER%"
        Bank_DisplayCooldown = "Cooldown: %COOLDOWNTIMER%"
	    Bank_DisplayReady    = "Ready"
		Bank_DisplayVault    = "Bank Vault"
		-- Bank General Notifications --
		Bank_GMNotSuported   = "%GAMEMODE% is not supported!"
		Bank_MapPosLoaded    = "%MAPNAME% position loaded!"
		Bank_NopeSuperadmin  = "You need to be a superadmin to run this command!"
		
    elseif lang == "pt_br" || lang == "portuguese" then
	    
		PrintMessage( HUD_PRINTTALK, "[Bank Robbery System]: Brazilian Portuguese by n00bmobile Selected!" )
		
		-- Personal Error Messages --
	    Bank_WrongTeam       = "Você não pode roubar como um %PLAYERTEAM%!"
        Bank_WrongArrested   = "Você não pode roubar preso!"
        Bank_WrongPlayer     = "É preciso ter pelo menos %MINPLAYERS% jogadores!"
        Bank_WrongCop        = "É preciso ter pelo menos %MINCOPS% policiais!"
        Bank_WrongBanker     = "É preciso ter pelo menos %MINBANKERS% banqueiros!"
		Bank_WrongCooldown   = "Você precisa esperar o recarregamento acabar!"
        Bank_WrongRobbery    = "Você não pode roubar um banco que já está sendo roubado!"
	    -- Public Notifications Fails --
	    Bank_FailDied        = "%PLAYERNAME% morreu causando o final do roubo!"
	    Bank_FailChanged     = "%PLAYERNAME% trocou de emprego causando o final do roubo!"
	    Bank_FailArrested    = "%PLAYERNAME% foi preso causando o final do roubo!"
	    Bank_FailArea        = "%PLAYERNAME% saiu da área do roubo causando seu final!"
	    -- Bank Public Notifications --
	    Bank_RobberyStarted  = "%PLAYERNAME% começou um roubo!"
	    Bank_RobberyFinished = "%PLAYERNAME% terminou um roubo!"
	    -- Bank Display Texts --
	    Bank_DisplayRobbing  = "Roubando: %ROBBINGTIMER%"
	    Bank_DisplayCooldown = "Recarregando: %COOLDOWNTIMER%"
	    Bank_DisplayReady    = "Pronto"
		Bank_DisplayVault    = "Cofre do Banco"
		-- Bank General Notifications --
		Bank_GMNotSuported   = "%GAMEMODE% não é suportado!"
		Bank_MapPosLoaded    = "Carregada a posição de %MAPNAME%!"
		Bank_NopeSuperadmin  = "Você precisa ser um super administrador para executar esse comando!"
	
	elseif lang == "fr" || lang == "french" then
	    
		PrintMessage( HUD_PRINTTALK, "[Bank Robbery System]: French by MrStrix Selected!" )
		
		-- Personal Error Messages --
        Bank_WrongTeam       = "Vous ne pouvez pas commencer de braquage en %PLAYERTEAM%!"
        Bank_WrongArrested   = "Vous ne pouvez pas commencer de braquage arrêté!"
        Bank_WrongPlayer     = "Il faut au moins %MINPLAYERS% joueurs!"
        Bank_WrongCop        = "Il faut au moins %MINCOPS% policiers!"
        Bank_WrongBanker     = "Il faut au moins %MINBANKERS% banquiers!"
        Bank_WrongCooldown   = "Tu dois attendre le compte à rebours pour commencer!"
        Bank_WrongRobbery    = "Un braquage est déjà en cours!"
        -- Public Notifications Fails --
        Bank_FailDied        = "%PLAYERNAME% cause la fin du braquage en décédant!"
        Bank_FailChanged     = "%PLAYERNAME% cause la fin du braquage en changeant de métier!"
        Bank_FailArrested    = "%PLAYERNAME% a été arrêté ce qui cause la fin du braquage!"
        Bank_FailArea        = "%PLAYERNAME% a quitté la zone du braquage!"
        -- Bank Public Notifications --
        Bank_RobberyStarted  = "%PLAYERNAME% a commencé un braquage!"
        Bank_RobberyFinished = "%PLAYERNAME% a réussi le braquage!"
        -- Bank Display Texts --
        Bank_DisplayRobbing  = "Braquage: %ROBBINGTIMER%"
        Bank_DisplayCooldown = "Compte à rebours: %COOLDOWNTIMER%"
        Bank_DisplayReady    = "Prêt"
        Bank_DisplayVault    = "Braquage de Banque"
        -- Bank General Notifications --
        Bank_GMNotSuported   = "%GAMEMODE% n'est pas supporté!"
        Bank_MapPosLoaded    = "%MAPNAME% position chargée!"
        Bank_NopeSuperadmin  = "Tu dois être superadmin pour effectuer cette commande!"
	
	else
	    
		PrintMessage( HUD_PRINTTALK, "[Bank Robbery System]: This language is not valid!" )
		file.Write( "bankrobberysystem/config_save/saved_lang.txt", "en" )
		
		BankLang()
		
	end
	
end