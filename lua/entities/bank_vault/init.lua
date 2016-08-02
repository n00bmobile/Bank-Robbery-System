AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

local Robber = nil

function ENT:Initialize()
	self.Entity:SetModel("models/props/cs_assault/moneypallet.mdl")
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetMoveType(SOLID_VPHYSICS)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetUseType(SIMPLE_USE)
	
	self.Entity:SetNWInt("CurrentReward", BankRS_Config["Interest"]["Base_Reward"]) --set base reward
	
	local Physics = self.Entity:GetPhysicsObject()
	
	if (Physics:IsValid()) then
	    Physics:EnableMotion(false)
	end
end

function ENT:SpawnFunction(v, tr)
    if (not tr.Hit) then return end

	local BankPos = tr.HitPos
	local Bank = ents.Create("bank_vault") 
	
	Bank:SetPos(BankPos)
	Bank:Spawn()
	Bank.Owner = v
	
	return Bank
end

function ENT:Use(ply)
	if (not table.HasValue(BankRS_Config["Robbery"]["Team_Required"]["Robbers"], team.GetName(ply:Team()))) then
		DarkRP.notify(ply, 1, 3, "A robbery can't be started as a "..team.GetName(ply:Team()).."!")
		return
	elseif (ply:isArrested()) then
        DarkRP.notify(ply, 1, 3, "A robbery can't be started while arrested!")
		return 
	elseif (#player.GetAll() < BankRS_Config["Robbery"]["Min_Players"]) then
		DarkRP.notify(ply, 1, 3, "A robbery can't be started without enough players!")
	    return
	elseif (not BankRS_CountTeamNumber()) then
		DarkRP.notify(ply, 1, 3, "A robbery can't be started without enough cops or bankers!")
	    return
	elseif (timer.Exists("BankRS_RobberyTimer")) then
		DarkRP.notify(ply, 1, 3, "A robbery is already in progress!")
	    return
	elseif (timer.Exists(self:EntIndex().."_CooldownTimer")) then
        DarkRP.notify(ply, 1, 3, "A robbery can't be started during a cooldown!")
	    return
    end	
    
    DarkRP.notify(ply, 0, 3, "You started a Bank Robbery!")
    DarkRP.notify(ply, 0, 5, "Don't go too far away or the robbery will fail!")
	
	self.EmitSiren = CreateSound(self, "bank_vault/siren.wav")
	self.EmitSiren:SetSoundLevel(130)
	self.EmitSiren:Play()
	
	self:DuringRobbery()
	ply:wanted(nil, "Robbing The Bank!")
	
	Robber = ply
	
	if (not BankRS_Config["Robbery"]["Should_Loop"]) then
	    timer.Simple(SoundDuration("bank_vault/siren.wav"), function() 
		    if (IsValid(self)) then
			    self.EmitSiren:Stop()
            end				
		end)
	end
	
	DarkRP.notifyAll(0, 10, ply:Nick().." has started a robbery!")
end

function BankRS_CountTeamNumber()
    local Team = 0
	local Banker = 0
	
	for k, v in pairs(player.GetAll()) do
	    if (table.HasValue(BankRS_Config["Robbery"]["Team_Required"]["Cops"], team.GetName(v:Team()))) then
		    Team = Team +1
		end
		
		if (table.HasValue(BankRS_Config["Robbery"]["Team_Required"]["Bankers"], team.GetName(v:Team()))) then
		    Banker = Banker +1
		end
	end
	
    if (Team >= BankRS_Config["Robbery"]["Min_Cops"] and Banker >= BankRS_Config["Robbery"]["Min_Bankers"]) then
		return true
    else
		return false
    end
end

function ENT:DuringRobbery()
	local Robbery = BankRS_Config["Robbery"]["Timer"]

    timer.Create("BankRS_RobberyTimer", 1, 0, function()
		Robbery = Robbery -1
		self:SetNWString("Status", "Robbing: "..string.ToMinutesSeconds(Robbery))
		
		if (Robber:isArrested()) then
			DarkRP.notifyAll(1, 5, Robber:Nick().." has been arrested during a robbery!")
			self:DuringCooldown()
		elseif (not Robber:Alive()) then
			DarkRP.notifyAll(1, 5, Robber:Nick().." died during a robbery!")
			self:DuringCooldown()
		elseif (not table.HasValue(BankRS_Config["Robbery"]["Team_Required"]["Robbers"], team.GetName(Robber:Team()))) then
		    DarkRP.notifyAll(1, 5, Robber:Nick().." changed jobs during a robbery!")
			self:DuringCooldown()	
		elseif (Robber:GetPos():Distance(self:GetPos()) > BankRS_Config["Robbery"]["Max_Distance"]) then
		    DarkRP.notifyAll(1, 5, Robber:Nick().." has exited the robbery area!")
			self:DuringCooldown()
		elseif (Robbery <= 0) then
		    DarkRP.notifyAll(0, 5, Robber:Nick().." has finished a robbery!")
			
			Robber:addMoney(self:GetNWInt("CurrentReward"))
			
			self:SetNWInt("CurrentReward", BankRS_Config["Interest"]["Base_Reward"])
			self:DuringCooldown()
        end			
	end)
end

function ENT:DuringCooldown()
    local Cooldown = BankRS_Config["Cooldown"]["Timer"]
	
	Robber:unWanted()
	Robber = nil
	
	self.EmitSiren:Stop()
	
    timer.Remove("BankRS_RobberyTimer")	
	timer.Create(self:EntIndex().."_CooldownTimer", 1, 0, function()
		Cooldown = Cooldown -1
		self:SetNWString("Status", "Cooldown: "..string.ToMinutesSeconds(Cooldown))
		
		if (Cooldown <= 0) then
			self:SetNWString("Status", "")
			timer.Remove(self:EntIndex().."_CooldownTimer")
		end
	end)
end

function ENT:OnRemove()
    if (self.EmitSiren) then
	    self.EmitSiren:Stop()
	end

	timer.Remove(self:EntIndex().."_CooldownTimer")
	timer.Remove("BankRS_RobberyTimer")
end

function BankRS_AutoSpawn()
    if (file.Exists("bankrs/"..game.GetMap()..".txt", "DATA")) then
	    local JSON = util.JSONToTable(file.Read("bankrs/"..game.GetMap()..".txt", "DATA"))

		for k, v in pairs(JSON) do
	        local Bank = ents.Create("bank_vault")
	        
	        Bank:SetPos(v.pos)
	        Bank:SetAngles(v.ang)
	        Bank:Spawn()
		end
		
		MsgN("[BankRS]: Loaded "..#JSON.." positions for "..game.GetMap())
	else
	    MsgN("[BankRS]: Missing save files for "..game.GetMap())
	end
end

hook.Add("InitPostEntity", "BankRS_CheckUpdate", function()
	http.Fetch("https://dl.dropboxusercontent.com/s/90pfxdcg0mtbumu/bankVersion.txt", 
		function(version)   
	        if (version > "1.8.1") then 
			    MsgN("[BankRS]: Outdated Version DETECTED!")
			end
		end,
		
	    function(error)
		    MsgN("[BankRS]: Failed to check for UPDATES! ("..error..")")
	    end
	)
	
	BankRS_AutoSpawn()
end)

hook.Add("PlayerDeath", "BankRS_RewardKiller", function(victim, weapon, attacker)
    if (Robber == victim and victim != attacker) then
		DarkRP.notifyAll(0, 10, "Our hero "..attacker:GetName().." has been rewarded "..DarkRP.formatMoney(BankRS_Config["Robbery"]["Killer_Reward"]).." for stopping "..victim:GetName().." from robbing our bank!")
	    attacker:addMoney(BankRS_Config["Robbery"]["Killer_Reward"])
	end
end)

timer.Create("BankRS_Interest", BankRS_Config["Interest"]["Interest_Delay"], 0, function()
    for k, v in pairs(ents.FindByClass("bank_vault")) do
		if (v:GetNWString("Status") == "") then
		    v:SetNWInt("CurrentReward", math.Clamp(v:GetNWInt("CurrentReward") +BankRS_Config["Interest"]["Interest_Amount"], BankRS_Config["Interest"]["Base_Reward"], BankRS_Config["Interest"]["Reward_Max"]))
        end
	end
end)

concommand.Add("BankRS_Save", function(ply)
    if (ply:IsSuperAdmin()) then
	    if (table.Count(ents.FindByClass("bank_vault")) < 1) then
		    DarkRP.notify(ply, 1, 5, "There's no bank vaults spawned in this map!")
		else
		    local Data = {}
		
			for k, BankPos in pairs(ents.FindByClass("bank_vault")) do
			    table.insert(Data, {pos = BankPos:GetPos(), ang = BankPos:GetAngles()}) 
			    BankPos:Remove()
			end
			
			file.CreateDir("bankrs")
			file.Write("bankrs/"..game.GetMap()..".txt", util.TableToJSON(Data))
			
			DarkRP.notify(ply, 0, 10, "You've saved all of the current bank vaults' positions.")	
			BankRS_AutoSpawn()
			
			MsgN("[BankRS]: "..ply:GetName().." saved "..#Data.." positions in "..game.GetMap())
		end
    else
	    DarkRP.notify(ply, 1, 5, "You don't have permission to execute this command.")
	end
end)