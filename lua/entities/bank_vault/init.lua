AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

BankRS = {}

function ENT:Initialize()
	self.Entity:SetModel("models/props/cs_assault/moneypallet.mdl")
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetMoveType(SOLID_VPHYSICS)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetUseType(SIMPLE_USE)
	
	local Physics = self.Entity:GetPhysicsObject()
	    
	if (Physics:IsValid()) then
		Physics:Sleep()
	    Physics:EnableMotion(false)
	end
end

function ENT:SpawnFunction(v, tr)
    if (!tr.Hit) then return end
	
	local BankFind = ents.FindByClass("bank_vault")
	
	if (table.Count(BankFind) >= 1) then
        for k, Bank in pairs(BankFind) do
		    Bank:Remove()
		end
	elseif (string.lower(gmod.GetGamemode().Name) != "darkrp") then
	    v:ChatPrint("[BankRS]: The Bank failed to spawn because this gamemode isn't supported!")
		return
	end
	
	local ShouldSetOwner = true
	local BankPos = tr.HitPos + tr.HitNormal * 25
	local Bank = ents.Create("bank_vault") 
	 
	Bank:SetPos(BankPos)
	Bank:Spawn()
	  
    if (ShouldSetOwner) then
		Bank.Owner = v
	end
	
	return Bank
end

function ENT:Use(ply)
	if (!table.HasValue(BankConfig.TeamRequired["Robbers"], team.GetName(ply:Team()))) then
		DarkRP.notify(ply, 1, 5, "A robbery can't be started as a "..team.GetName(ply:Team()).."!")
		return
	elseif (ply:getDarkRPVar("arrested", true)) then
        DarkRP.notify(ply, 1, 5, "A robbery can't be started while arrested!")
		return 
	elseif (#player.GetAll() < BankConfig.MinPlayers) then
		DarkRP.notify(ply, 1, 5, "A robbery can't be started without enough players!")
	    return
	elseif (!BankRS.CountTeamNumber()) then
		DarkRP.notify(ply, 1, 5, "A robbery can't be started without enough cops or bankers!")
	    return
	elseif (timer.Exists("RobberyTimer")) then
		DarkRP.notify(ply, 1, 5, "A robbery is already in progress!")
	    return
	elseif (timer.Exists("CooldownTimer")) then
        DarkRP.notify(ply, 1, 5, "A robbery can't be started during a cooldown!")
	    return
    end		
	
	self:DuringRobbery(ply)
	self:EmitSound("siren.wav", 130)
	ply:wanted(nil, "Robbing The Bank!")
	
	if (BankConfig.Loop) then
	    timer.Create("BankRSSirenLoop", SoundDuration("siren.wav"), 0, function()
		    if (!timer.Exists("RobberyTimer")) then
		        timer.Destroy("BankRSSirenLoop")
				return
		    end
			
			self:EmitSound("siren.wav", 130)
	    end)
	end
	
	DarkRP.notifyAll(0, 5, ply:Nick().." has started a robbery!")
end

function BankRS.CountTeamNumber()
    local Team = 0
	local Banker = 0
	
	for k, v in pairs(player.GetAll()) do
	    if (table.HasValue(BankConfig.TeamRequired["Cops"], team.GetName(v:Team()))) then
			Team = Team +1
		end
		
		if (table.HasValue(BankConfig.TeamRequired["Bankers"], team.GetName(v:Team()))) then
		    Banker = Banker +1
		end
	end
	
    if (Team >= BankConfig.MinCops && Banker >= BankConfig.MinBankers) then
		return true
    else
		return false
    end
end

function ENT:DuringRobbery(ply)
	local Robbery = BankConfig.RobberyTimer
	
    timer.Create("RobberyTimer", 1, 0, function()
		Robbery = Robbery -1
		self:SetNWString("BankRSStatus", "Robbing: "..string.ToMinutesSeconds(Robbery))
		
		if (ply:getDarkRPVar("arrested", true)) then
			DarkRP.notifyAll(1, 5, ply:Nick().." has been arrested during a robbery!")
			self:DuringCooldown(ply)
		elseif (ply:GetPos():Distance(self:GetPos()) > BankConfig.MaxDistance) then
		    DarkRP.notifyAll(1, 5, ply:Nick().." has exited the robbery area!")
			self:DuringCooldown(ply)
		elseif (!ply:Alive()) then
			DarkRP.notifyAll(1, 5, ply:Nick().." has been killed during a robbery!")
			self:DuringCooldown(ply)
		elseif (Robbery <= 0) then
		    DarkRP.notifyAll(0, 5, ply:Nick().." has finished a robbery!")
			self:DuringCooldown(ply)
			ply:addMoney(BankConfig.Reward)
        end			
	end)
end

function ENT:DuringCooldown(ply)
    local Cooldown = BankConfig.CooldownTimer
	
	ply:unWanted()
	
    timer.Destroy("RobberyTimer")	
	timer.Create("CooldownTimer", 1, 0, function()
        Cooldown = Cooldown -1
		self:SetNWString("BankRSStatus", "Cooldown: "..string.ToMinutesSeconds(Cooldown))
		
		if (Cooldown <= 0) then
			timer.Destroy("CooldownTimer")
		end
	end)
end

concommand.Add("BankRSSave", function(ply)
    local Bank = ents.FindByClass("bank_vault")
	
	if (ply:IsSuperAdmin()) then
	    if (table.Count(Bank) > 1 || table.Count(Bank) < 1) then
		    ply:ChatPrint("[BankRS]: The Bank Position can't be saved due to an error. You either have more than one Bank spawned on the map or you don't have any Banks spawned at all.")
		else
		    for k, BankPos in pairs(ents.FindByClass("bank_vault")) do
			    Data = {pos = BankPos:GetPos(), ang = BankPos:GetAngles()} 
			    BankPos:Remove()
			end
			
            local map = game.GetMap()
			
			file.CreateDir("bankrs")			
			file.Write("bankrs/"..map..".txt", util.TableToJSON(Data))
			
			if (file.Exists("bankrs/"..map..".txt", "DATA")) then
			    PrintMessage(HUD_PRINTTALK, "[BankRS]: The Bank Position has been saved on "..map)
			else
			    ply:ChatPrint("[BankRS]: The Bank Position failed to save, contact n00mobile for help.") 
			end
			
			BankRS.AutoSpawn()
		end
    else
	    ply:ChatPrint("[BankRS]: The Bank Position can only be saved by a SuperAdmin.")
    end		
end)

function BankRS.AutoSpawn()
    local map = game.GetMap()
	
	if (file.Exists("bankrs/"..map..".txt", "DATA")) then
	    PrintMessage(HUD_PRINTTALK, "[BankRS]: The Bank Position has been loaded on "..map)
	
	    local Bank = ents.Create("bank_vault")
	    local JSON = util.JSONToTable(file.Read("bankrs/"..map..".txt", "DATA"))
	
	    Bank:SetPos(JSON.pos)
	    Bank:SetAngles(JSON.ang)
	    Bank:Spawn()
	end
end

hook.Add("InitPostEntity", "BankRSCheckUpdate", function()
	http.Fetch("https://dl.dropboxusercontent.com/s/90pfxdcg0mtbumu/bankVersion.txt", 
		function(version)   
	        if (version > "1.7.6") then 
			    MsgN(HUD_PRINTTALK, "[BankRS]: Outdated Version DETECTED!")
			end
		end,
		
	    function(error)
		    MsgN(HUD_PRINTTALK, "[BankRS]: Failed to check for UPDATES! ("..error..")")
	    end
	)
	
	BankRS.AutoSpawn()
end)