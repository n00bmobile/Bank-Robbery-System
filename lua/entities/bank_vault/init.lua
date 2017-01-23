AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

if not bankRobber then --In case someone decides to reload this file...
    local bankRobber
end

local function count()
    local government = 0
	local banker = 0
	
	for k, v in pairs(player.GetAll()) do
	    if table.HasValue(bank_config.robbery.t_required.cops, team.GetName(v:Team())) then
		    government = government +1
		end
		
		if table.HasValue(bank_config.robbery.t_required.bankers, team.GetName(v:Team())) then
		    banker = banker +1
		end
	end
	
	return government >= bank_config.robbery.m_cops and banker >= bank_config.robbery.m_bankers
end

local function find()
    for k, v in pairs(ents.FindByClass("bank_vault")) do
	    if string.find(v:GetNWString("bankStatus"), "Robbing") then
		    return v
		end
	end
end

function ENT:Initialize()
	self.Entity:SetModel("models/props/cs_assault/moneypallet.mdl")
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetMoveType(SOLID_VPHYSICS)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetUseType(SIMPLE_USE)
	
	self.Entity:SetNWInt("bankReward", bank_config.interest.base) --set base reward
	
	local phys = self.Entity:GetPhysicsObject()
	
	if phys:IsValid() then
	    phys:EnableMotion(false)
	end
end

function ENT:Use(ply)
	if not table.HasValue(bank_config.robbery.t_required.robbers, team.GetName(ply:Team())) then
		DarkRP.notify(ply, 1, 3, "A robbery can't be started as a "..team.GetName(ply:Team()).."!")
		return
	elseif ply:isArrested() then
        DarkRP.notify(ply, 1, 3, "A robbery can't be started while arrested!")
		return 
	elseif #player.GetAll() < bank_config.robbery.m_players then
		DarkRP.notify(ply, 1, 3, "A robbery can't be started without enough players!")
	    return
	elseif not count() then
		DarkRP.notify(ply, 1, 3, "A robbery can't be started without enough cops or bankers!")
	    return
	elseif timer.Exists("bank_robbery_timer") then
		DarkRP.notify(ply, 1, 3, "A robbery is already in progress!")
	    return
	elseif timer.Exists("bank_cooldown_timer_"..self:EntIndex()) then
        DarkRP.notify(ply, 1, 3, "This vault is on cooldown!")
	    return
    end	
    
    DarkRP.notify(ply, 0, 3, "You started a Bank Robbery!")
    DarkRP.notify(ply, 0, 5, "Don't go too far away or the robbery will fail!")
	
	self.bankSiren = CreateSound(self, "bank_vault/siren.wav")
	self.bankSiren:SetSoundLevel(130)
	self.bankSiren:Play()
	
	self:robberyStart()
	
	ply:wanted(nil, "Robbing The Bank!", bank_config.robbery.time)
	bankRobber = ply
	
	if not bank_config.robbery.loop then
	    timer.Simple(SoundDuration("bank_vault/siren.wav"), function() 
		    if self:IsValid() then
			    self.bankSiren:Stop()
            end				
		end)
	end
	
	DarkRP.notifyAll(0, 10, ply:Nick().." has started a robbery!")
end

function ENT:robberyStart()
    timer.Create("bank_robbery_timer", 1, bank_config.robbery.time, function()
		local left = timer.RepsLeft("bank_robbery_timer")
	    
		self:SetNWString("bankStatus", "Robbing: "..string.ToMinutesSeconds(left))
	
		if left == 0 then
			bankRobber:addMoney(self:GetNWInt("bankReward"))
			DarkRP.notifyAll(0, 5, bankRobber:GetName().." has finished a robbery!")
			
			self:SetNWInt("bankReward", bank_config.interest.base)
			self:cooldownStart()
        end			
	end)
	
	timer.Start("bank_robbery_timer")
end

function ENT:cooldownStart()
	bankRobber:unWanted()
	bankRobber = nil
	
	self.bankSiren:Stop()
	
    timer.Remove("bank_robbery_timer")	
	print(timer.Exists("bank_robbery_timer"))
	
	timer.Create("bank_cooldown_timer_"..self:EntIndex(), 1, bank_config.cooldown.time, function()
		local left = timer.RepsLeft("bank_cooldown_timer_"..self:EntIndex())
		
		self:SetNWString("bankStatus", "Cooldown: "..string.ToMinutesSeconds(left))
		
		if left == 0 then
			self:SetNWString("bankStatus", "")
		end
	end)
	
	timer.Start("bank_cooldown_timer_"..self:EntIndex())
end

function ENT:Think()
	if timer.Exists("bank_robbery_timer") and find() == self then
		local name = bankRobber:GetName()
		
		if bankRobber:isArrested() then
	        DarkRP.notifyAll(1, 5, name.." has been arrested during a robbery!")
			self:cooldownStart()
	    elseif not table.HasValue(bank_config.robbery.t_required.robbers, team.GetName(bankRobber:Team())) then
		    DarkRP.notifyAll(1, 5, name.." changed jobs during a robbery!")
			self:cooldownStart()	
		elseif not bankRobber:Alive() then
		    DarkRP.notifyAll(1, 5, name.." died during a robbery!")
			self:cooldownStart()
	    elseif bankRobber:GetPos():Distance(self:GetPos()) > bank_config.robbery.m_dist then
			DarkRP.notifyAll(1, 5, name.." has exited the robbery area!")
			self:cooldownStart()
	    end
	end
end

function ENT:OnRemove()
    if self.bankSiren then
	    self.bankSiren:Stop()
	end

	timer.Remove("bank_cooldown_timer_"..self:EntIndex())
	timer.Remove("bank_robbery_timer")
end

local function spawn()
    local map = game.GetMap()
	
	if file.Exists("bankrs/"..map..".txt", "DATA") then
	    local positions = util.JSONToTable(file.Read("bankrs/"..map..".txt", "DATA"))

		for k, v in pairs(positions) do
	        local bank = ents.Create("bank_vault")
	        
	        bank:SetPos(v.pos)
	        bank:SetAngles(v.ang)
	        bank:Spawn()
		end
		
		MsgN("[BankRS]: Loaded "..#positions.." positions for "..map)
	else
	    MsgN("[BankRS]: Missing save files for "..map)
	end
end

hook.Add("InitPostEntity", "bank_update_check", function()
	http.Fetch("https://dl.dropboxusercontent.com/s/90pfxdcg0mtbumu/bankVersion.txt", 
		function(version)   
	        if version > "1.8.2" then 
			    MsgN("[BankRS]: Outdated Version DETECTED!")
			end
		end,
		
	    function(error)
		    MsgN("[BankRS]: Failed to check for UPDATES! ("..error..")")
	    end
	)
	
	spawn()
end)

hook.Add("PlayerDeath", "bank_reward_killer", function(victim, wep, attacker)
    if attacker:IsPlayer() and bankRobber == victim and victim ~= attacker then
		attacker:addMoney(bank_config.robbery.killer_reward)
		
		DarkRP.notifyAll(0, 10, "Our hero "..attacker:GetName().." stopped "..bankRobber:GetName().." from robbing the bank!")
		DarkRP.notify(attacker, 0, 10, "You have been rewarded "..DarkRP.formatMoney(bank_config.robbery.killer_reward).." for stopping a bank robbery!")
	end
end)

timer.Create("bank_interest_timer", bank_config.interest.delay, 0, function()
    for k, v in pairs(ents.FindByClass("bank_vault")) do
		if v:GetNWString("bankStatus") == "" then
		    v:SetNWInt("bankReward", math.Clamp(v:GetNWInt("bankReward") +bank_config.interest.amount, bank_config.interest.base, bank_config.interest.max))
        end
	end
end)

timer.Start("bank_interest_timer") --I hope this fixes timers not working for some people...

concommand.Add("banksave", function(ply)
    if ply:IsSuperAdmin() then
	    local banks = ents.FindByClass("bank_vault")
		
		if table.Count(banks) < 1 then
		    DarkRP.notify(ply, 1, 5, "There's no bank vaults spawned in this map!")
		else
		    local data = {}
		
			for k, v in pairs(banks) do
			    table.insert(data, {pos = v:GetPos(), ang = v:GetAngles()}) 
			    v:Remove()
			end
			
			file.CreateDir("bankrs")
			file.Write("bankrs/"..game.GetMap()..".txt", util.TableToJSON(data))
			
			spawn()
			DarkRP.notify(ply, 0, 10, "You've saved all of the bank vaults currently spawned on the map.")	
		end
    else
	    DarkRP.notify(ply, 1, 5, "You don't have permission to execute this command.")
	end
end)