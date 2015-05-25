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

BankRS.duringR = false
BankRS.duringC = false

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
  
local bankU_time = CurTime()
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
	elseif table.Count(team.GetPlayers(team.GetName(BankConfig.teamR["Cops"]))) < BankConfig.minC then
		DarkRP.notify(activator, 1, 5, "A robbery can't be started without enough cops!")
	    return
	elseif BankRS.duringR then
		DarkRP.notify(activator, 1, 5, "A robbery is already in progress!")
	    return
	elseif BankRS.duringC then
        DarkRP.notify(activator, 1, 5, "A robbery can't be started during a cooldown!")
	    return
    end		
	
	DarkRP.notifyAll(0, 5, activator:Nick().." has started a robbery!")
		
	activator:setDarkRPVar("wanted", true)
	activator:setDarkRPVar("wantedReason", "Robbing The Bank!")
		
	self:duringRobbery(activator)
	duringRobberySiren()
end

function ENT:duringRobbery(ply)
	BankRS.robberyTB = BankConfig.robberyT
	BankRS.duringR = true
	
    timer.Create("robberyTimer", 1, 0, function()
		BankRS.robberyTB = BankRS.robberyTB -1
		updateBankInfo("Robbing: "..string.ToMinutesSeconds(BankRS.robberyTB))
		
		if ply:getDarkRPVar("arrested", true) then
		    duringCooldown(ply)
		    ply:setDarkRPVar("wanted", false)
			
			DarkRP.notifyAll(1, 5, ply:Nick().." has been arrested during a robbery!")
            return			
		elseif !ply:Alive() then
			duringCooldown(ply)
			ply:setDarkRPVar("wanted", false)
			
			DarkRP.notifyAll(1, 5, ply:Nick().." has been killed during a robbery!")
			return
		elseif ply:GetPos():Distance(self:GetPos()) > BankConfig.maxD then
		    duringCooldown(ply)
			ply:setDarkRPVar("wanted", false)
			
			DarkRP.notifyAll(1, 5, ply:Nick().." has exited the robbery area!")
			return
		elseif BankRS.robberyTB <= 0 then
		    duringCooldown(ply)
			
			ply:addMoney(BankConfig.reward)
		    ply:setDarkRPVar("wanted", false)
			
		    DarkRP.notifyAll(0, 5, ply:Nick().." has finished a robbery!")
		end
	end)
end

function duringRobberySiren()
    BroadcastLua('surface.PlaySound("siren.wav")')
	
	if BankConfig.loop then
	    timer.Create("sirenLoop", 12, 0, function()
		    if !BankRS.duringR then
			    timer.Destroy("sirenLoop")
			else
			    BroadcastLua('surface.PlaySound("siren.wav")')
			end
		end)
    end
end

function duringCooldown()
    BankRS.cooldownTB = BankConfig.cooldownT
	BankRS.duringR = false
	BankRS.duringC = true

    timer.Destroy("robberyTimer")	
	timer.Create("cooldownTimer", 1, 0, function()
        BankRS.cooldownTB = BankRS.cooldownTB -1
		updateBankInfo("Cooldown: "..string.ToMinutesSeconds(BankRS.cooldownTB))

		if BankRS.cooldownTB <= 0 then
		    BankRS.duringC = false
			updateBankInfo("Ready")
			
			
			timer.Destroy("cooldownTimer")
		end
	end)
end

function updateBankInfo(string)
    net.Start("RSBank_clientUpdate")
	    net.WriteString(string)
	net.Broadcast()
end

function permaSpawn(ply)
    local bank = ents.FindByClass("bank_vault")
	
	if ply:IsSuperAdmin() then
	    if table.Count(bank) > 1 || table.Count(bank) < 1 then
		    ply:ChatPrint("[Bank Robbery System]: The Bank Position can't be saved due to an error. You either have more than one Bank spawned on the map or you don't have any Banks spawned at all.")
        return end
	    
		for k, bankP in pairs(ents.FindByClass("bank_vault")) do
		    BankRS.save = {pos = bankP:GetPos(),ang = bankP:GetAngles()}
		
	        file.CreateDir("BankRS")
		    file.Write("BankRS/"..game.GetMap()..".txt", util.TableToJSON(BankRS.save))
		
		    permaSpawnLoad()
			bankP:Remove()
		    
			ply:ChatPrint("[Bank Robbery System]: The Bank Position has been saved an loaded on "..game.GetMap())
		end
	else
	    ply:ChatPrint("[Bank Robbery System]: The Bank Position can only be saved by a superadmin.")
	end
end
concommand.Add("BankRS_Save", permaSpawn)

function permaSpawnLoad()
    if !file.Exists("BankRS/"..game.GetMap()..".txt", "DATA") then return end
	
	local bank = ents.Create("bank_vault")
	local json = util.JSONToTable(file.Read("BankRS/"..game.GetMap()..".txt", "DATA"))
	
	bank:SetPos(json.pos)
	bank:SetAngles(json.ang)
	bank:Spawn()
end
hook.Add("InitPostEntity", "loadSaveFile", permaSpawnLoad)

function updateCheck()
    http.Fetch("https://dl.dropboxusercontent.com/s/90pfxdcg0mtbumu/bankVersion.txt", 
		function(body)   
	        if body > "1.7.1" then 
			    PrintMessage(HUD_PRINTTALK, "[Bank Robbery System]: This server uses an outdated version of this addon, inform the server owner. (Messages will appear everytime a player joins)")
			end
		end,
	    function(error)
		    PrintMessage(HUD_PRINTTALK, "[Bank Robbery System]: An error occured while trying to check for updates. ("..error..")")
	    end
	)
end
hook.Add("PlayerInitialSpawn", "rememberUpdate", updateCheck)