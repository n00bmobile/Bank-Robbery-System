--------------------------------------------------------------
-- Don't Touch This Code Unless You Know What You're Doing! --
--------------------------------------------------------------

--------------------------------------------------------------
-- Credits ---------------------------------------------------
--------------------------------------------------------------
-- n00bmobile(Me Of Course).
-- HunterFP for helping me with the Perma Spawn System.

---------------
-- Variables --
---------------
local classname = "bankrobbery"
local ShouldSetOwner = true
local CanBankRobbery = true
local Bank_RobberyDTimerReset = Bank_RobberyTime
local DuringRobbery = false
local NotEnoughPlayers = false
local EnoughTeam = false
local Bank_RobberyCTimerReset = Bank_RobberyCTimerReset
Bank_TeamCanRob = Bank_TeamCanRob
ReceiverName = {}
util.PrecacheSound( "sirenloud.wav" )
-------------------------------
resource.AddFile("sound/sirenloud.wav")
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )
include( "bank_config.lua" )
-------------------------------

--------------------
-- SPAWN FUNCTION --
--------------------
function ENT:SpawnFunction(v,tr)
if (!tr.Hit) then return end
	local Bank_SpawnPos = tr.HitPos + tr.HitNormal * 25
	local ent = ents.Create(classname)
	    ent:SetPos(Bank_SpawnPos)
	    ent:Spawn()
	    ent:Activate()
            if ShouldSetOwner then
		    ent.Owner = v
	end
	    return ent
end

----------------
-- INITIALIZE --
----------------
function ENT:Initialize()
self.Entity:SetModel( Bank_ChooseModel )
self.Entity:PhysicsInit( SOLID_VPHYSICS )
self.Entity:SetMoveType( SOLID_VPHYSICS )
self.Entity:SetSolid( SOLID_VPHYSICS )
local phys = self.Entity:GetPhysicsObject()
    if (phys:IsValid()) then
	    phys:Sleep()
		phys:EnableMotion( false )
    end
end

------------
-- ON USE --
------------
function ENT:Use(activator,caller)
    CheckJobRequirement()
	CheckPlayers()
	if !table.HasValue( Bank_TeamCanRob,team.GetName(caller:Team())) then
	    timer.Create("EvadeSpam",0.1,1,function() DarkRP.notify(caller,1,5,"You cannot start a robbery as a " ..team.GetName(caller:Team()).. "!") end)
	elseif NotEnoughPlayers then
	    timer.Create("EvadeSpam",0.1,1,function() DarkRP.notify(caller,1,5,"There has to be at least " ..Bank_MinPlayers.. " players before you can rob the Bank!") end)
	elseif !EnoughTeam then
	    timer.Create("EvadeSpam",0.1,1,function() DarkRP.notify(caller,1,5,"There has to be at least " ..Bank_RequiredGovernmentNumber.. " cops before you can rob the Bank!") end)
	elseif !DuringRobbery && !CanBankRobbery then
	    timer.Create("EvadeSpam",0.1,1,function() DarkRP.notify(caller,1,5,"You need to wait " ..Bank_RobberyCTimerReset.. " seconds before you can rob the Bank!") end)
    elseif CanBankRobbery && EnoughTeam then
	    if table.HasValue(Bank_TeamCanRob,team.GetName(caller:Team())) then
            DuringRobbery = true
		    CanBankRobbery = false
			table.insert(ReceiverName,caller)
		    SirenLoop()
			caller:setDarkRPVar("wanted",true)
            caller:setDarkRPVar("wantedReason","Robbing the Bank!")
	    for k,v in pairs(player.GetAll()) do
			DarkRP.notify(v,0,5,caller:Nick().. " has started a robbery and will complete it in " ..Bank_RobberyTime.. " seconds!" ) 
        end
            self:InRobbery()
	    end
    end 
end

----------------
-- SOUND LOOP --
----------------
function SirenLoop()
    BroadcastLua('surface.PlaySound("sirenloud.wav")')
    timer.Create("SoundLoop",12,0,function()
        BroadcastLua('surface.PlaySound("sirenloud.wav")')
    end)
end

-------------------------
-- EVADE FOREVER SIREN --
-------------------------
function BankReloadTimer()
    if !DuringRobbery then 
	    timer.Destroy("SoundLoop")
	end
end

----------------
-- IN ROBBERY --
---------------- 
function ENT:InRobbery()
    Bank_RobberyDTimerReset = Bank_RobberyTime
	timer.Create("BankRobberyCountDown",1,Bank_RobberyTime,function()
	    Bank_RobberyDTimerReset = Bank_RobberyDTimerReset -1
	    if Bank_RobberyDTimerReset <= 0 && DuringRobbery then 
		    for k,v in pairs(player.GetAll()) do
			    for k,bank in pairs(ReceiverName) do
				    timer.Create("EvadeSpam",0.1,1,function() DarkRP.notify(v,0,5,bank:Nick().. " finished the robbery!") end)
				    timer.Create("EvadeSpam",0.1,1,function() bank:addMoney(Bank_StartingAmount) end)
			    end
				self:InCooldown()
			    timer.Destroy("BankRobberyCountDown")
		    end
	    end
    end)
end

-----------------
-- IN COOLDOWN --
-----------------
function ENT:InCooldown()
    for k,bank in pairs(ReceiverName) do
	    bank:setDarkRPVar("wanted",false)
	end
	DuringRobbery = false
	Bank_RobberyCTimerReset = Bank_RobberyCooldownTime
	timer.Create("BankRooberyCooldown",1,Bank_RobberyCooldownTime,function()
	    Bank_RobberyCTimerReset = Bank_RobberyCTimerReset -1
        if Bank_RobberyCTimerReset <= 0 then
			CanBankRobbery = true
			table.Empty(ReceiverName)
		    timer.Destroy("BankBank_RobberyCTimerReset")
        end
    end)
end

-----------
-- THINK --
-----------
function ENT:Think()
    self:BankSendData()
    BankReloadTimer()
	if DuringRobbery then
	    self:NotInRadius()
        self:CheckIfDead()
	    self:CheckJob()
    end
end

-----------------------------
-- CHECK AMOUNT OF PLAYERS --
-----------------------------
function CheckPlayers()
    if #player.GetAll() < Bank_MinPlayers then
	    NotEnoughPlayers = true
	else
	    NotEnoughPlayers = false
    end
end

---------------------------
-- CHECK JOB REQUIREMENT --
---------------------------
function CheckJobRequirement()
    RequiredGovernment = 0
	EnoughTeam = false
	for k,bankteam in pairs(Bank_TeamGovernment) do
        for k,v in pairs(player.GetAll()) do
            if Bank_RequiredGovernmentNumber <= 0 then
			    EnoughTeam = true
			end
			if team.GetName(v:Team()) == bankteam then
                RequiredGovernment = RequiredGovernment +1
                if RequiredGovernment == Bank_RequiredGovernmentNumber then
				    EnoughTeam = true
                end
            end
        end
    end
end

---------------
-- CHECK JOB --
---------------
function ENT:CheckJob()
    for k,bank in pairs(ReceiverName) do
	    for k,v in pairs(player.GetAll()) do
	        if DuringRobbery && !table.HasValue(Bank_TeamCanRob,team.GetName(bank:Team())) then
	            DarkRP.notify(v,1,5,bank:Nick().. " changed jobs during a robbery!")
                self:InCooldown()
				timer.Destroy("BankRobberyCountDown")
	        end
        end
    end
end

-------------------
-- CHECK IF DEAD --
-------------------
function ENT:CheckIfDead()
    if DuringRobbery then
	    for k,v in pairs(player.GetAll()) do
		    for k,bank in pairs(ReceiverName) do
                if DuringRobbery && table.HasValue(Bank_TeamCanRob,team.GetName(bank:Team())) && !bank:Alive() then
			   	    DarkRP.notify(v,1,5,bank:Nick().. " died during a robbery!")	
					self:InCooldown()
					timer.Destroy("BankRobberyCountDown")
                end
            end
        end
    end
end

---------------
-- SEND DATA --
---------------
function ENT:BankSendData()
    self:SetNWInt("Bank_StartingAmount","$" ..Bank_StartingAmount or 0)
	if DuringRobbery then
	    self:SetNWInt("BankClient","Robbing: " ..Bank_RobberyDTimerReset or 0)
	elseif !DuringRobbery && !CanBankRobbery then
	    self:SetNWInt("BankClient","Cooldown: " ..Bank_RobberyCTimerReset or 0)
    elseif CanBankRobbery then
	    self:SetNWInt("BankClient","Waiting")
    end
end

-------------------
-- NOT IN RADIUS --
-------------------
function ENT:NotInRadius()  
    for k,v in pairs(player.GetAll()) do
	    for k,bank in pairs(ReceiverName) do
	        if DuringRobbery then
		        if bank:GetPos():Distance(self:GetPos()) >= Bank_RobberyMaxRadius then
                    self:InCooldown()
				    DarkRP.notify(v,1,5,bank:Nick().. " exited the robbery area!")
				    timer.Destroy("BankRobberyCountDown")
		        end
            end
        end
    end
end

------------------
-- SPAWN SYSTEM --
------------------
hook.Add("InitPostEntity","BANK_AUTO_SPAWN",function()
	for k,bankent in pairs(ents.FindByClass("bankrobbery")) do
		bankent:Remove()
	end
	local bank = ents.Create('bankrobbery')
	bank:SetPos(Bank_SpawnPos)
	bank:SetAngles(Bank_SpawnAngle)
	bank:Spawn()
end)