AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/props/cs_assault/moneypallet.mdl")
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetMoveType(SOLID_VPHYSICS)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetUseType(SIMPLE_USE)
	
	local Physics = self.Entity:GetPhysicsObject()
	   
	if (Physics:IsValid()) then
	    Physics:EnableMotion(false)
	end
end

function ENT:SpawnFunction(v, tr)
    if (not tr.Hit) then return end
	
	if (table.Count(ents.FindByClass("bank_vault")) >= 1) then
        DarkRP.notify(v, 1, 5, "You can only have one of these at the same time!")
		return
	end
	
	local BankPos = tr.HitPos
	local Bank = ents.Create("bank_vault") 
	
	Bank:SetPos(BankPos)
	Bank:Spawn()
	Bank.Owner = v
	
	return Bank
end

function ENT:Use(ply)
	if (not table.HasValue(BankRS_Config["Robbery"]["Team_Required"]["Robbers"], ply:Team())) then
		DarkRP.notify(ply, 1, 3, "A robbery can't be started as a "..team. GetName(ply:Team()).."!")
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
	elseif (timer.Exists("BankRS_CooldownTimer")) then
        DarkRP.notify(ply, 1, 3, "A robbery can't be started during a cooldown!")
	    return
    end	
    
    DarkRP.notify(ply, 0, 3, "You started a Bank Robbery!")
    DarkRP.notify(ply, 0, 5, "Don't go too far away or the robbery will fail!")
	
	self.EmitSiren = CreateSound(self, "bank_vault/siren.wav")
	self.EmitSiren:SetSoundLevel(130)
	self.EmitSiren:Play()
	
	self:DuringRobbery(ply)
	
	ply:wanted(nil, "Robbing The Bank!")
	ply.IsRobbing = true
	
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
	    if (table.HasValue(BankRS_Config["Robbery"]["Team_Required"]["Cops"], v:Team())) then
		    Team = Team +1
		end
		
		if (table.HasValue(BankRS_Config["Robbery"]["Team_Required"]["Bankers"], v:Team())) then
		    Banker = Banker +1
		end
	end
	
    if (Team >= BankRS_Config["Robbery"]["Min_Cops"] and Banker >= BankRS_Config["Robbery"]["Min_Bankers"]) then
		return true
    else
		return false
    end
end

function ENT:DuringRobbery(ply)
	local Robbery = BankRS_Config["Robbery"]["Timer"]
	
	timer.Pause("BankRS_RewardInterest")
	
    timer.Create("BankRS_RobberyTimer", 1, 0, function()
		Robbery = Robbery -1
		self:SetNWString("BankRS_Status", "Robbing: "..string.ToMinutesSeconds(Robbery))
		
		if (ply:isArrested()) then
			DarkRP.notifyAll(1, 5, ply:Nick().." has been arrested during a robbery!")
			self:DuringCooldown(ply)
		elseif (not ply:Alive()) then
			DarkRP.notifyAll(1, 5, ply:Nick().." died during a robbery!")
			self:DuringCooldown(ply)
		elseif (not table.HasValue(BankRS_Config["Robbery"]["Team_Required"]["Robbers"], ply:Team())) then
		    DarkRP.notifyAll(1, 5, ply:Nick().." changed jobs during a robbery!")
			self:DuringCooldown(ply)	
		elseif (ply:GetPos():Distance(self:GetPos()) > BankRS_Config["Robbery"]["Max_Distance"]) then
		    DarkRP.notifyAll(1, 5, ply:Nick().." has exited the robbery area!")
			self:DuringCooldown(ply)
		elseif (Robbery <= 0) then
		    DarkRP.notifyAll(0, 5, ply:Nick().." has finished a robbery!")
			
			self:DuringCooldown(ply)
			ply:addMoney(BankRS_RewardCurrent)
			
			BankRS_RewardCurrent = BankRS_Config["Interest"]["Base_Reward"]
        end			
	end)
end

function ENT:DuringCooldown(ply)
    local Cooldown = BankRS_Config["Cooldown"]["Timer"]
	
	ply:unWanted()
	ply.IsRobbing = false
	
	self.EmitSiren:Stop()
	
    timer.Remove("BankRS_RobberyTimer")	
	timer.Create("BankRS_CooldownTimer", 1, 0, function()
		Cooldown = Cooldown -1
		self:SetNWString("BankRS_Status", "Cooldown: "..string.ToMinutesSeconds(Cooldown))
		
		if (Cooldown <= 0) then
			self:SetNWString("BankRS_Status", "")
			
			timer.UnPause("BankRS_RewardInterest")
			timer.Remove("BankRS_CooldownTimer")
		end
	end)
end

function ENT:OnRemove()
    if (self.EmitSiren) then
	    self.EmitSiren:Stop()
	end
	
	BankRS_RewardCurrent = BankRS_Config["Interest"]["Base_Reward"]
	BroadcastLua("BankRS_RewardCurrent = "..BankRS_RewardCurrent)
	
	timer.Remove("BankRS_CooldownTimer")
	timer.Remove("BankRS_RobberyTimer")
end

function BankRS_AutoSpawn()
    if (file.Exists("bankrs/"..game.GetMap()..".txt", "DATA")) then
	    MsgN("[BankRS]: Loaded position for "..game.GetMap())
	
	    local Bank = ents.Create("bank_vault")
	    local JSON = util.JSONToTable(file.Read("bankrs/"..game.GetMap()..".txt", "DATA"))
	
	    Bank:SetPos(JSON.pos)
	    Bank:SetAngles(JSON.ang)
	    Bank:Spawn()
	else
	    MsgN("[BankRS]: Missing save files for "..game.GetMap())
	end
end

hook.Add("InitPostEntity", "BankRS_CheckUpdate", function()
	http.Fetch("https://dl.dropboxusercontent.com/s/90pfxdcg0mtbumu/bankVersion.txt", 
		function(version)   
	        if (version > "1.8.0") then 
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
    if (victim.IsRobbing) then
	    if (victim != attacker) then
		    DarkRP.notifyAll(0, 10, "Our hero "..attacker:GetName().." has been rewarded "..DarkRP.formatMoney(BankRS_Config["Robbery"]["Killer_Reward"]).." for stopping "..victim:GetName().." from robbing our bank!")
			attacker:addMoney(BankRS_Config["Robbery"]["Killer_Reward"])
		end
	end
end)

hook.Add("PlayerInitialSpawn", "BankRS_InterestSync", function(ply)
    ply:SendLua("BankRS_RewardCurrent = "..BankRS_RewardCurrent)
end)

timer.Create("BankRS_RewardInterest", BankRS_Config["Interest"]["Interest_Delay"], 0, function()
    BankRS_RewardCurrent = math.Clamp(BankRS_RewardCurrent +BankRS_Config["Interest"]["Interest_Amount"], BankRS_Config["Interest"]["Base_Reward"], BankRS_Config["Interest"]["Reward_Max"])
	BroadcastLua("BankRS_RewardCurrent = "..BankRS_RewardCurrent)
end)

concommand.Add("BankRS_Save", function(ply)
    if (ply:IsSuperAdmin()) then
	    if (table.Count(ents.FindByClass("bank_vault")) > 1 or table.Count(ents.FindByClass("bank_vault")) < 1) then
		    DarkRP.notify(ply, 1, 5, "Something went wrong, please read this addon's description for instructions.")
		else
		    for k, BankPos in pairs(ents.FindByClass("bank_vault")) do
			    Data = {pos = BankPos:GetPos(), ang = BankPos:GetAngles()} 
			    BankPos:Remove()
			end
			
			file.CreateDir("bankrs")
			file.Write("bankrs/"..game.GetMap()..".txt", util.TableToJSON(Data))
			
			DarkRP.notifyAll(0, 10, ply:GetName().." has changed the current bank position in "..game.GetMap())	
			BankRS_AutoSpawn()
		end
    else
	    DarkRP.notify(ply, 1, 5, "You don't have permission to execute this command.")
	end
end)
