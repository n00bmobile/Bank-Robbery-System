-- Include Dah Files --
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
include("bank_config.lua")
include("bank_config_lang.lua")

-- Needed For More Than One Function --
local bankRobTimer = Bank_SetRobTime
local bankCooldownTimer = Bank_SetCooldownTime
local haveRequiredCops = false
local haveRequiredBankers = false
local duringRobbery = false
local duringCooldown = false

-- Precache Some Shit --
util.PrecacheSound( "soundloud.wav" )

-- Inicialize Duh Bank --
function ENT:Initialize()
    
	self.Entity:SetModel( "models/props/cs_assault/moneypallet.mdl" )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetMoveType( SOLID_VPHYSICS )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	
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
	    
		v:ChatPrint("Bank Robbery System: "..gmod.GetGamemode().Name.." is not supported!") 
	
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
    
	if !caller:Alive() then
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
	DarkRP.notifyAll( 1, 5, string.Replace( Bank_RobberyStarted, "%PLAYERNAME%", caller:Nick() ) )
	
	timer.Create( "RobberyCountdown", 1, Bank_SetRobTime, function()
	    
		self:CheckForFail( caller )
		
		bankRobTimer = bankRobTimer -1
		
		if bankRobTimer <= 0 then
		    RobberySucess( caller )
		end
    
	end)

end

function ENT:BankSirenLoop()
    
	BroadcastLua('surface.PlaySound("sirenloud.wav")')
	
	if !Bank_SetSirenSoundLoop then return end
	
	timer.Create( "SoundLoop", 12, 0, function()
	
	    BroadcastLua('surface.PlaySound("sirenloud.wav")')
	
	end)

end

-- Noob It's Now A Master --
function RobberySucess( caller )
    
	DarkRP.notifyAll( 1, 5, string.Replace( Bank_RobberyFinished, "%PLAYERNAME%", caller:Nick() ) )
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
	    
		bankCooldownTimer = bankCooldownTimer -1
		
		if bankCooldownTimer <= 0 then
		    duringCooldown = false
	    end
	
	end)

end

-- Think To Send Lazy NWInts --
function ENT:Think()
    
	self:SendBankStatusClient()
    
end

-- Send Lazy NWInts With The Bank Status --
function ENT:SendBankStatusClient()
    
	self:SetNWInt( "BankVault", Bank_DisplayVault ) //I can't run the bank_config_lang.lua clientside.
	
	if duringRobbery then
	    self:SetNWInt( "BankStatus", string.Replace( Bank_DisplayRobbing, "%ROBBINGTIMER%", string.ToMinutesSeconds( bankRobTimer ) ) )
	
	elseif duringCooldown then
	    self:SetNWInt( "BankStatus", string.Replace( Bank_DisplayCooldown, "%COOLDOWNTIMER%", string.ToMinutesSeconds( bankCooldownTimer ) ) )
    
	elseif !duringRobbery && !duringCooldown then
	    self:SetNWInt( "BankStatus", Bank_DisplayReady )
    end

end

-- Spawn Duh Bank Automatically --
function SpawnBankRobberyAuto()
    
	if !file.Exists( "bank_robbery_system/" ..string.lower( game.GetMap() ).. ".txt", "DATA" ) || string.lower( gmod.GetGamemode().Name ) != "darkrp" then return end
	
	local bank = ents.Create( "bankrobbery" )
	local tab = util.JSONToTable( file.Read( "bank_robbery_system/" ..string.lower(game.GetMap()).. ".txt", "DATA" ))

	for k, v in pairs( player.GetAll() ) do
	    v:ChatPrint( "Bank Robbery System: "..game.GetMap().." position loaded!" )
    end
	
    bank:SetPos( tab.Bank_SpawnPos )
	bank:SetAngles( tab.Bank_SpawnAngle )
	bank:Spawn()

end
hook.Add( "InitPostEntity", "BankRobberyAutoSpawn", SpawnBankRobberyAuto )

-- Save Duh Bank Pos --
concommand.Add( "saveBankPos", function( ply )
    
	if !ply:IsSuperAdmin() then ply:ChatPrint( "Bank Robbery System: You need to be a superadmin to run this command!" ) return end
	
	if string.lower( gmod.GetGamemode().Name ) != "darkrp" then ply:ChatPrint( "Bank Robbery System: "..gmod.GetGamemode().Name.." is not supported!" ) return end
	
	for k,bank in pairs( ents.FindByClass( "bankrobbery" ) ) do
        bankWriteData = { Bank_SpawnPos = bank:GetPos(), Bank_SpawnAngle = bank:GetAngles()}
	    bank:Remove()
    end
	
	file.CreateDir( "bank_robbery_system" )
	file.Write( "bank_robbery_system/" ..string.lower( game.GetMap() ).. ".txt", util.TableToJSON( bankWriteData ) )

	SpawnBankRobberyAuto()
	
end)

-- Choose Duh Language --
function BankRobberyLangSetup()
    
	if !file.Exists( "bank_robbery_system/bank_config_save.txt", "DATA" ) then 
	
	    bankWriteData = { Bank_SelectLang = "en" }
		
		file.CreateDir( "bank_robbery_system" )
		file.Write( "bank_robbery_system/bank_config_save.txt", util.TableToJSON( bankWriteData ) )
	
	    BankLang()
	
	else
	    
		BankLang()
		
	end

end
hook.Add( "InitPostEntity", "BankRobberyLangAutoSetup", BankRobberyLangSetup )

-- Create Duh Command --
concommand.Add( "selectBankLang", function( ply, cmd, args )
    
	bankWriteData = { Bank_SelectLang = args[1] }
	
	file.CreateDir( "bank_robbery_system" )
	file.Write( "bank_robbery_system/bank_config_save.txt", util.TableToJSON( bankWriteData ) )
	
	BankLang()
	  
end)