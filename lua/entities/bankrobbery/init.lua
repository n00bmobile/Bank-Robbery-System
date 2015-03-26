--------------------------------------------------------------
-- Don't Touch This Code Unless You Know What You're Doing! --
--------------------------------------------------------------

--------------------------------------------------------------
-- Credits ---------------------------------------------------
--------------------------------------------------------------
-- n00bmobile.

-- Include Duh Files --
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( "shared.lua" )
include( "bank_config.lua" )
include( "bank_config_lang.lua" )

-- Needed For More Than One Function --
local bankRobTimer = Bank_SetRobTime
local bankCooldownTimer = Bank_SetCooldownTime
local haveRequiredCops = false
local haveRequiredBankers = false
local duringRobbery = false
local duringCooldown = false

-- Do Some Shit --
util.AddNetworkString( "Bank_DisplayUpdate" )
util.PrecacheSound( "soundloud.wav" )
resource.AddFile( "sound/soundloud.wav" )

-- Inicialize Duh Bank --
function ENT:Initialize()
    
	self.Entity:SetModel( "models/props/cs_assault/moneypallet.mdl" )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetMoveType( SOLID_VPHYSICS )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	
	BankUpdateDisplay( Bank_DisplayReady ) 
	
	local physics = self.Entity:GetPhysicsObject()
	   
	if physics:IsValid() then
		
		physics:Sleep()
	    physics:EnableMotion( false )
	
	end
	
end

-- Spawn Duh Bank --
function ENT:SpawnFunction(v,tr)
    
	if !tr.Hit then return end
	
	if string.lower( gmod.GetGamemode().Name ) != "darkrp" then 
	    
		v:ChatPrint( "[Bank Robbery System]: " ..string.Replace( Bank_GMNotSuported, "%GAMEMODE%", gmod.GetGamemode().Name ) ) 
	
	return end
	
	local ShouldSetOwner = true
	local bank_spawn = tr.HitPos + tr.HitNormal * 25
	local bank = ents.Create( "bankrobbery" )
	 
	bank:SetPos( bank_spawn )
	bank:Spawn()
	bank:Activate()
       
    if ShouldSetOwner then
		
		bank.Owner = v
	
	end
	    
        return bank

end

-- On Use --
function ENT:AcceptInput( ply, caller )
    
	timer.Create( "EvadeSpam", 0.1, 1, function()
	
	    RequirementCheck( caller )
	
	    if !table.HasValue( Bank_SetCanRobTeam, team.GetName(  caller:Team() ) ) then DarkRP.notify( caller, 1, 5, string.Replace( Bank_WrongTeam, "%PLAYERTEAM%", team.GetName( caller:Team() ) ) )
	
	    elseif caller:getDarkRPVar( "Arrested", true ) then DarkRP.notify( caller, 1, 5, Bank_WrongArrested )
	    
		elseif #player.GetAll() < Bank_SetPlayerMinNum then DarkRP.notify( caller, 1, 5, string.Replace( Bank_WrongPlayer, "%MINPLAYERS%", tostring( Bank_SetPlayerMinNum ) ) ) 
	
	    elseif !haveRequiredCops then DarkRP.notify( caller, 1, 5, string.Replace( Bank_WrongCop, "%MINCOPS%", tostring( Bank_SetTeamMinNum ) ) )
		
		elseif !haveRequiredBankers then DarkRP.notify( caller, 1, 5, string.Replace( Bank_WrongBanker, "%MINBANKERS%", tostring( Bank_SetBankerMinNum ) ) )
	
	    elseif duringCooldown then DarkRP.notify( caller, 1, 5, Bank_WrongCooldown )
	   
	    elseif duringRobbery then DarkRP.notify( caller, 1, 5, Bank_WrongRobbery )
        
	    elseif caller:IsPlayer() then
	        
			haveRequiredCops = false
			haveRequiredBankers = false
			self:RobberyCountdown( caller )
			self:BankSirenLoop()
		
		end		

    end)

end

-- Require Things --
function RequirementCheck( caller )
    
	local countTeam = 0
	local countBanker = 0
	
	for k,v in pairs(player.GetAll()) do
	    
		if table.HasValue( Bank_SetNeededTeam, team.GetName( v:Team() ) ) then
		    
			countTeam = countTeam +1
		
		end
	    
	    if table.HasValue( Bank_SetTeamBanker, team.GetName( v:Team() ) ) then
		    
			countBanker = countBanker +1
		
		end
	    
	end

	if countTeam >= Bank_SetTeamMinNum then
		
		haveRequiredCops = true
	
	end
	
	if countBanker >= Bank_SetBankerMinNum then
        
		haveRequiredBankers = true
	
	end

end

-- Check For Noobs --
function ENT:CheckForFail( caller )
    
	if !IsValid( caller ) then 
	    RobberyCooldown()
		timer.Destroy( "RobberyCountdown" )
	
	elseif !caller:Alive() then
	    DarkRP.notifyAll( 1, 5, string.Replace( Bank_FailDied, "%PLAYERNAME%", caller:Nick() ) )
        RobberyCooldown()
		timer.Destroy( "RobberyCountdown" )
	
	elseif !table.HasValue( Bank_SetCanRobTeam, team.GetName( caller:Team() ) ) then
	    DarkRP.notifyAll( 1, 5, string.Replace( Bank_FailChanged, "%PLAYERNAME%", caller:Nick() ) )
        RobberyCooldown()
		timer.Destroy( "RobberyCountdown" )
    
	elseif caller:getDarkRPVar( "Arrested", true ) then
	    DarkRP.notifyAll( 1, 5, string.Replace( Bank_FailArrested, "%PLAYERNAME%", caller:Nick() ) )
        RobberyCooldown()
		timer.Destroy( "RobberyCountdown" )
	
	elseif caller:GetPos():Distance( self:GetPos() ) > Bank_SetMaxRadius then
	    DarkRP.notifyAll( 1, 5, string.Replace( Bank_FailArea, "%PLAYERNAME%", caller:Nick() ) )
        RobberyCooldown()
		timer.Destroy( "RobberyCountdown" )
	end

end

-- Count The Time That The Noob Needs To Survive --
function ENT:RobberyCountdown( caller )
    
	bankRobTimer = Bank_SetRobTime
	duringRobbery = true
	DarkRP.notifyAll( 0, 5, string.Replace( Bank_RobberyStarted, "%PLAYERNAME%", caller:Nick() ) )
	
	timer.Create( "RobberyCountdown", 1, Bank_SetRobTime, function()
	    
		BankUpdateDisplay( string.Replace( Bank_DisplayRobbing, "%ROBBINGTIMER%", string.ToMinutesSeconds( bankRobTimer ) ) )
		self:CheckForFail( caller )
		
		bankRobTimer = bankRobTimer -1
		
		if bankRobTimer <= 0 then
		    
			RobberySucess( caller )
		
		end
    
	end)

end

-- Scream Bank Getting Robbed Near The Cops --
function ENT:BankSirenLoop()
    
	BroadcastLua('surface.PlaySound("sirenloud.wav")')
	
	if !Bank_SetSirenSoundLoop then return end
	
	timer.Create( "SoundLoop", 12, 0, function()
	
	    BroadcastLua('surface.PlaySound("sirenloud.wav")')
	
	end)

end

-- Noob It's Now A Master --
function RobberySucess( caller )
    
	DarkRP.notifyAll( 0, 5, string.Replace( Bank_RobberyFinished, "%PLAYERNAME%", caller:Nick() ) )
	caller:addMoney( Bank_SetMoneyAmount )
	RobberyCooldown()

end

-- Cooldown For Camping Bitches --
function RobberyCooldown()
    
	bankCooldownTimer = Bank_SetCooldownTime
	duringRobbery = false
	duringCooldown = true
	
	timer.Destroy( "SoundLoop" )
	
	timer.Create( "RobberyCooldown", 1, Bank_SetCooldownTime, function()
	    
		BankUpdateDisplay( string.Replace( Bank_DisplayCooldown, "%COOLDOWNTIMER%", string.ToMinutesSeconds( bankCooldownTimer ) ) )
		
		bankCooldownTimer = bankCooldownTimer -1
		
		if bankCooldownTimer <= 0 then
		    
			BankUpdateDisplay( Bank_DisplayReady )
			
			duringCooldown = false
	    
		end
	
	end)

end

function BankUpdateDisplay( text )
    
	net.Start( "Bank_DisplayUpdate" )
	   
   	    net.WriteString( Bank_DisplayVault )
		net.WriteString( text )
	
	net.Broadcast()

end

-- Check For Updates --
function BankCheckForUpdate()

    http.Fetch( "https://dl.dropboxusercontent.com/s/90pfxdcg0mtbumu/bankVersion.txt", 
	    
		function( body )   
	        
	        if body > "1.6.3" then 
			    
				PrintMessage( HUD_PRINTTALK, "[Bank Robbery System]: This server is using an outdated version of the Bank Robbery System!" )

			end
		
		end,
	 
        function( error )
		
		    PrintMessage( HUD_PRINTTALK, "[Bank Robbery System]: An error has occured while looking for updates, check your internet connection!" )
		
	    end
	
	)

end
hook.Add( "PlayerInitialSpawn", "BankCheckForUpdate", BankCheckForUpdate )

-- Spawn Duh Bank Automatically --
function SpawnBankRobberyAuto()
    
	if !file.Exists( "bankrobberysystem/autospawn/" ..string.lower( game.GetMap() ).. ".txt", "DATA" ) || string.lower( gmod.GetGamemode().Name ) != "darkrp" then return end
	
	local bank = ents.Create( "bankrobbery" )
	local tab = util.JSONToTable( file.Read( "bankrobberysystem/autospawn/" ..string.lower(game.GetMap()).. ".txt", "DATA" ))

	for k, v in pairs( player.GetAll() ) do
	    
		v:ChatPrint( "[Bank Robbery System]: " ..string.Replace( Bank_MapPosLoaded, "%MAPNAME%", game.GetMap() ) )
    
	end
	
    bank:SetPos( tab.Bank_SpawnPos )
	bank:SetAngles( tab.Bank_SpawnAngle )
	bank:Spawn()

end
hook.Add( "InitPostEntity", "BankRobberyAutoSpawn", SpawnBankRobberyAuto )

-- Save Duh Bank Pos --
function SaveBankPos( ply )
    
	if !ply:IsSuperAdmin() then ply:ChatPrint( "[Bank Robbery System]: " ..Bank_NopeSuperadmin ) return end
	
	if string.lower( gmod.GetGamemode().Name ) != "darkrp" then ply:ChatPrint( "[Bank Robbery System]: " ..string.Replace( Bank_GMNotSuported, "%GAMEMODE%", gmod.GetGamemode().Name ) ) return end
	
	for k,bank in pairs( ents.FindByClass( "bankrobbery" ) ) do
        
		bankWriteData = { Bank_SpawnPos = bank:GetPos(), Bank_SpawnAngle = bank:GetAngles()}
	    bank:Remove()
    
	end
	
	file.CreateDir( "bankrobberysystem/autospawn" )
	file.Write( "bankrobberysystem/autospawn/" ..string.lower( game.GetMap() ).. ".txt", util.TableToJSON( bankWriteData ) )

	SpawnBankRobberyAuto()
	
end
concommand.Add( "saveBankPos", SaveBankPos )

-- Choose Duh Language --
function BankRobberyLangSetup()
    
	if !file.Exists( "bankrobberysystem/config_save/saved_lang.txt", "DATA" ) then 
	    
		file.CreateDir( "bankrobberysystem/config_save" )
		file.Write( "bankrobberysystem/config_save/saved_lang.txt", "en" )
	
	    BankLang()
	
	else
	    
		BankLang()
		
	end

end
hook.Add( "InitPostEntity", "BankRobberyLangAutoSetup", BankRobberyLangSetup )

-- Create Language Command --
function SelectBankLanguage( ply, cmd, args )
    
	if !ply:IsSuperAdmin() then ply:ChatPrint( "[Bank Robbery System]: " ..Bank_NopeSuperadmin ) return end
	
	file.CreateDir( "bankrobberysystem/config_save" )
	file.Write( "bankrobberysystem/config_save/saved_lang.txt", args[1] )
	
	BankLang()
	BankUpdateDisplay( Bank_DisplayReady )
	  
end
concommand.Add( "selectBankLang", SelectBankLanguage )