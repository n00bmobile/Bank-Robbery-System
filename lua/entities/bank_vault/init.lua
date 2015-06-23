--[[
 /$$$$$$$                      /$$             /$$$$$$$   /$$$$$$  | * PRODUCT LICENSED: http://creativecommons.org/licenses/by-nd/3.0/
| $$__  $$                    | $$            | $$__  $$ /$$__  $$ | By using this product, you agree to follow the license limitations.
| $$  \ $$  /$$$$$$  /$$$$$$$ | $$   /$$      | $$  \ $$| $$  \__/ | Got any questions, contact author.
| $$$$$$$  |____  $$| $$__  $$| $$  /$$/      | $$$$$$$/|  $$$$$$  | 
| $$__  $$  /$$$$$$$| $$  \ $$| $$$$$$/       | $$__  $$ \____  $$ | * AUTHOR: n00bmobile
| $$  \ $$ /$$__  $$| $$  | $$| $$_  $$       | $$  \ $$ /$$  \ $$ |
| $$$$$$$/|  $$$$$$$| $$  | $$| $$ \  $$      | $$  | $$|  $$$$$$/ | * FILE: init.lua
|_______/  \_______/|__/  |__/|__/  \__/      |__/  |__/ \______/  |
]]--

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
	
	local physics = self.Entity:GetPhysicsObject()
	    
	if physics:IsValid() then
		physics:Sleep()
	    physics:EnableMotion(false)
	end
end

function ENT:SpawnFunction(v, tr)
    if !tr.Hit then return end
	
	if string.lower(gmod.GetGamemode().Name) != "darkrp" then 
	    v:ChatPrint("[Bank Robbery System]: "..gmod.GetGamemode().Name.." isn't a supported gamemode!") 
	return end
	
	local ShouldSetOwner = true
	local bank_pos = tr.HitPos + tr.HitNormal * 25
	local bank = ents.Create("bank_vault")
	 
	bank:SetPos(bank_pos)
	bank:Spawn()
	bank:Activate()
        
    if ShouldSetOwner then
		bank.Owner = v
	end
	
	return bank
end

function ENT:Use(activator, caller)
    if !table.HasValue(BankConfig.teamR["Robbers"], team.GetName(activator:Team())) then
		DarkRP.notify(activator, 1, 5, "A robbery can't be started as a "..team.GetName(activator:Team()).."!")
		return
	elseif activator:getDarkRPVar("arrested", true) then
        DarkRP.notify(activator, 1, 5, "A robbery can't be started while arrested!")
		return 
	elseif #player.GetAll() < BankConfig.minP then
		DarkRP.notify(activator, 1, 5, "A robbery can't be started without enough players!")
	    return
	elseif !BankRS.countTeamNumber() then
		DarkRP.notify(activator, 1, 5, "A robbery can't be started without enough cops or bankers!")
	    return
	elseif timer.Exists("robberyTimer") then
		DarkRP.notify(activator, 1, 5, "A robbery is already in progress!")
	    return
	elseif timer.Exists("cooldownTimer") then
        DarkRP.notify(activator, 1, 5, "A robbery can't be started during a cooldown!")
	    return
    end		
	
	activator:setDarkRPVar("wanted", true)
	activator:setDarkRPVar("wantedReason", "Robbing The Bank!")
	
	self:duringRobbery(activator)
	
	DarkRP.notifyAll(0, 5, activator:Nick().." has started a robbery!")
	BankRS.duringRobberySiren()
end

function BankRS.countTeamNumber()
    local countedTeam = 0
	local countedBanker = 0
	
	for k, v in pairs(player.GetAll()) do
	    if table.HasValue(BankConfig.teamR["Cops"], team.GetName(v:Team())) then
			countedTeam = countedTeam +1
		end
		
		if table.HasValue(BankConfig.teamR["Bankers"], team.GetName(v:Team())) then
		    countedBanker = countedBanker +1
		end
	end
	
    if countedTeam >= BankConfig.minC && countedBanker >= BankConfig.minB then
		return true
    else
		return false
    end
end

function ENT:duringRobbery(ply)
	local robberyTB = BankConfig.robberyT
	
    timer.Create("robberyTimer", 1, 0, function()
		robberyTB = robberyTB -1
		BankRS.updateBankInfo("Robbing: "..string.ToMinutesSeconds(robberyTB)) //I don't trust NWVars anymore... Thanks Garry!
		
		if ply:getDarkRPVar("arrested", true) then
			DarkRP.notifyAll(1, 5, ply:Nick().." has been arrested during a robbery!")
			BankRS.duringCooldown()
		    
			ply:setDarkRPVar("wanted", false)
            return			
		elseif !ply:Alive() then
			DarkRP.notifyAll(1, 5, ply:Nick().." has been killed during a robbery!")
			BankRS.duringCooldown()
			
			ply:setDarkRPVar("wanted", false)
			return
		elseif ply:GetPos():Distance(self:GetPos()) > BankConfig.maxD then
		    DarkRP.notifyAll(1, 5, ply:Nick().." has exited the robbery area!")
			BankRS.duringCooldown()
			
			ply:setDarkRPVar("wanted", false)
			return
		elseif robberyTB <= 0 then
		    DarkRP.notifyAll(0, 5, ply:Nick().." has finished a robbery!")
			BankRS.duringCooldown()
			
			ply:addMoney(BankConfig.reward)
		    ply:setDarkRPVar("wanted", false)
		end
	end)
end

function BankRS.duringRobberySiren()
    BroadcastLua('surface.PlaySound("siren.wav")')
	
	if BankConfig.loop then
	    timer.Create("sirenLoop", SoundDuration("sound/siren.wav"), 0, function()
		    if !timer.Exists("robberyTimer") then
				timer.Destroy("sirenLoop")
			else
			    BroadcastLua('surface.PlaySound("siren.wav")')
			end
		end)
    end
end

function BankRS.duringCooldown()
    local cooldownTB = BankConfig.cooldownT
	
    timer.Destroy("robberyTimer")	
	timer.Create("cooldownTimer", 1, 0, function()
        cooldownTB = cooldownTB -1
		BankRS.updateBankInfo("Cooldown: "..string.ToMinutesSeconds(cooldownTB))

		if cooldownTB <= 0 then
			BankRS.updateBankInfo("Ready")
			timer.Destroy("cooldownTimer")
		end
	end)
end

function BankRS.updateBankInfo(string)
    net.Start("RSBank_clientUpdate")
	    net.WriteString(string)
	net.Broadcast()
end

function BankRS.permaSpawn(ply)
    local bank = ents.FindByClass("bank_vault")
	
	if ply:IsSuperAdmin() then
	    if table.Count(bank) > 1 || table.Count(bank) < 1 then
		    ply:ChatPrint("[Bank Robbery System]: The Bank Position can't be saved due to an error. You either have more than one Bank spawned on the map or you don't have any Banks spawned at all.")
        return end
	    
		for k, bankP in pairs(ents.FindByClass("bank_vault")) do
		    BankRS.save = {pos = bankP:GetPos(),ang = bankP:GetAngles()}
		    bankP:Remove()
		end
	   
     	file.CreateDir("BankRS")
		file.Write("BankRS/"..game.GetMap()..".txt", util.TableToJSON(BankRS.save))
		
		BankRS.permaSpawnLoad()
	    
		ply:ChatPrint("[Bank Robbery System]: The Bank Position has been saved an loaded on "..game.GetMap())
	else
	    ply:ChatPrint("[Bank Robbery System]: The Bank Position can only be saved by a superadmin.")
	end
end
concommand.Add("BankRS_Save", BankRS.permaSpawn)

function BankRS.permaSpawnRemove(ply)
    if !file.Exists("bankrs/"..game.GetMap()..".txt", "DATA") then
	    ply:ChatPrint("[Bank Robbery System]: There isn't a save for the Bank Position.")
	else
	    ply:ChatPrint("[Bank Robbery System]: The Bank Position has been deleted on "..game.GetMap())
		
		for k, bankP in pairs(ents.FindByClass("bank_vault")) do
			bankP:Remove()
		end
		
		file.Delete("bankrs/"..game.GetMap()..".txt")
	end
end
concommand.Add("BankRS_Remove", BankRS.permaSpawnRemove)

function BankRS.permaSpawnLoad()
    if !file.Exists("BankRS/"..game.GetMap()..".txt", "DATA") then return end
	
	local bank = ents.Create("bank_vault")
	local json = util.JSONToTable(file.Read("BankRS/"..game.GetMap()..".txt", "DATA"))
	
	bank:SetPos(json.pos)
	bank:SetAngles(json.ang)
	bank:Spawn()
end
hook.Add("InitPostEntity", "loadSaveFile", BankRS.permaSpawnLoad)

function BankRS.updateCheck()
    http.Fetch("https://dl.dropboxusercontent.com/s/90pfxdcg0mtbumu/bankVersion.txt", 
		function(body)   
	        if body > "1.7.5" then 
			    PrintMessage(HUD_PRINTTALK, "[Bank Robbery System]: This server uses an outdated version of this addon, inform the server owner. (Messages will appear every time a player joins)")
			end
		end,
	    function(error)
		    PrintMessage(HUD_PRINTTALK, "[Bank Robbery System]: An error occurred while trying to check for updates. ("..error..")")
	    end
	)
end
hook.Add("PlayerInitialSpawn", "rememberUpdate", BankRS.updateCheck)