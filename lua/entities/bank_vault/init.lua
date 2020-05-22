AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_init.lua')
include('shared.lua')

if not playerRobber then
	local playerRobber
end

local function isAllowed(ply)
	return BANK_CONFIG.Robbers[team.GetName(ply:Team())]
end

local function teamsCount()
	local gCount = 0
	local bCount = 0
	
	for k, v in pairs(player.GetAll()) do
		local team = team.GetName(v:Team())

		if BANK_CONFIG.Government[team] then
			gCount = gCount +1
		elseif BANK_CONFIG.Bankers[team] then
			bCount = bCount +1
		end
	end

	return BANK_CONFIG.MinGovernment <= gCount, BANK_CONFIG.MinBankers <= bCount
end

function ENT:Initialize()
	self:SetModel('models/props/cs_assault/moneypallet.mdl')
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self.BankSiren = CreateSound(self, 'bank_vault/siren.wav')
	self.BankSiren:SetSoundLevel(130)
	
	local phys = self:GetPhysicsObject()
	
	if phys:IsValid() then
	    phys:EnableMotion(false)
	end
end

function ENT:Use(ply)
	local enoughCops, enoughBankers = teamsCount()
	
	if not isAllowed(ply) then
		DarkRP.notify(ply, 1, 3, "You can't start a robbery as "..team.GetName(ply:Team())..'!')
		return
	elseif ply:isArrested() then
		DarkRP.notify(ply, 1, 3, "You can't start a robbery while arrested!")
		return 
	elseif player.GetCount() < BANK_CONFIG.MinPlayers then
		DarkRP.notify(ply, 1, 3, "You can't start a robbery without enough players!")
		return 
	elseif not enoughCops then
		DarkRP.notify(ply, 1, 3, "You can't start a robbery without enough cops!")
		return
	elseif not enoughBankers then
		DarkRP.notify(ply, 1, 3, "You can't start a robbery without enough bankers!")
		return
	elseif playerRobber then
		DarkRP.notify(ply, 1, 3, 'A robbery is already in progress!')
		return
	elseif self:GetStatus() == 2 then
		DarkRP.notify(ply, 1, 3, 'This vault is on cooldown!')
		return
	end
	
	self:StartRobbery(ply)
end

function ENT:StartRobbery(ply)
	local name = ply:GetName()

	playerRobber = ply
	self.BankSiren:Play()
	self:SetStatus(1)
	self:SetNextAction(CurTime() +BANK_CONFIG.RobberyTime)
	ply:wanted(nil, 'Robbing The Bank!', BANK_CONFIG.RobberyTime)
	DarkRP.notify(ply, 0, 3, 'You started a Bank Robbery!')
	DarkRP.notify(ply, 0, 10, "Don't go too far away or the robbery will fail!")
	DarkRP.notifyAll(0, 10, name..' has started a robbery!')

	if not BANK_CONFIG.LoopSiren then
		timer.Simple(SoundDuration('bank_vault/siren.wav'), function()
			if self.BankSiren then
				self.BankSiren:Stop()
			end
		end)
	end

	hook.Add('Think', 'BankRS_RobberyThink', function()
		if self:GetNextAction() <= CurTime() then
			ply:addMoney(self:GetReward())
			self:SetReward(BANK_CONFIG.BaseReward)
			self:StartCooldown()
			DarkRP.notifyAll(0, 10, name..' finished robbing the Bank!')
		else
			if ply:IsValid() then	
				if ply:isArrested() then
					ply:unWanted()
					self:StartCooldown()
					DarkRP.notifyAll(1, 5, name..' was arrested during a Robbery!')
	 		    elseif not isAllowed(ply) then
					self:StartCooldown()	
					DarkRP.notifyAll(1, 5, name..' changed jobs during a Robbery!')
				elseif not ply:Alive() then
					ply:unWanted()
					self:StartCooldown()
					DarkRP.notifyAll(1, 5, name..' died during a Robbery!')
	   	 		elseif ply:GetPos():DistToSqr(self:GetPos()) > BANK_CONFIG.MaxDistance ^2 then
					self:StartCooldown()
					DarkRP.notifyAll(1, 5, name..' exited the Robbery Area!')
				end
			else
				self:StartCooldown()
				DarkRP.notifyAll(1, 5, name..' left the server during a Robbery!')
			end
		end
	end)
end

function ENT:StartCooldown()
	playerRobber = nil
	self.BankSiren:Stop()	
	self:SetStatus(2)
	self:SetNextAction(CurTime() +BANK_CONFIG.CooldownTime)
	hook.Remove('Think', 'BankRS_RobberyThink')
	timer.Simple(BANK_CONFIG.CooldownTime, function()
		if self:IsValid() then
			self:SetStatus(0)
		end
	end)
end

function ENT:OnRemove()
	if self.BankSiren:IsPlaying() then
		playerRobber = nil
		self.BankSiren:Stop()
		hook.Remove('Think', 'BankRS_RobberyThink')
	end
end

hook.Add('PlayerDeath', 'BankRS_RewardSavior', function(victim, inf, att)
	if victim ~= att and victim == playerRobber and att:IsPlayer() then
		att:addMoney(BANK_CONFIG.SaviorReward)
		DarkRP.notifyAll(0, 10, 'Our hero '..att:GetName()..' stopped '..playerRobber:GetName()..' from robbing the Bank!')
		DarkRP.notify(att, 0, 5, 'You have been rewarded '..DarkRP.formatMoney(BANK_CONFIG.SaviorReward)..' for stopping a Bank Robbery!')
	end
end)

timer.Create('BankRS_ApplyInterest', BANK_CONFIG.InterestTime, 0, function()
	for k, v in pairs(ents.FindByClass('bank_vault')) do
		if v:GetStatus() == 0 then
			local value = v:GetReward()

			if value ~= BANK_CONFIG.MaxReward then
				v:SetReward(math.Clamp(value +BANK_CONFIG.Interest, 0, BANK_CONFIG.MaxReward))
			end
		end
	end
end)

local function spawnSaved()
	local read = file.Read('bankrs/'..game.GetMap()..'.txt', 'DATA')

	if read then
		local data = util.JSONToTable(read)
		
		for k, v in pairs(data) do
			local ent = ents.Create('bank_vault')
			ent:SetPos(v.pos)
			ent:SetAngles(v.ang)
			ent:Spawn()
		end

		MsgC(Color(255, 0, 0), '[BankRS] ', Color(255, 255, 0), #data..' vaults found and loaded in '..game.GetMap()..'.\n')
	else
		MsgC(Color(255, 0, 0), '[BankRS] ', Color(255, 255, 0), 'No Save Data for '..game.GetMap()..' found.\n')
	end
end

hook.Add('InitPostEntity', 'BankRS_SpawnVaults', function()
	http.Fetch('https://dl.dropboxusercontent.com/s/90pfxdcg0mtbumu/bankVersion.txt', 
		function(version)   
	        if version > '1.8.4' then 
			    MsgC(Color(255, 0, 0), '[BankRS] ', Color(255, 255, 0), 'Outdated version detected, please update.\n')
			end
		end,
	    function(error)
		    MsgC(Color(255, 0, 0), '[BankRS] ', Color(255, 255, 0), 'Failed to check for updates! ('..error..')\n')
	    end
	)

	spawnSaved()
end)

hook.Add('PostCleanupMap', 'BankRS_RespawnVaults', function()
	MsgC(Color(255, 0, 0), '[BankRS] ', Color(255, 255, 0), 'Cleanup detected! Attempting to respawn vaults...\n')
	spawnSaved()
end)

concommand.Add('bankrs_save', function(ply)
	if ply:IsSuperAdmin() then
		local found = ents.FindByClass('bank_vault')

		if #found > 0 then
			local data = {}

			for k, v in pairs(found) do
				table.insert(data, {pos = v:GetPos(), ang = v:GetAngles()})
			end

			if not file.Exists('bankrs', 'DATA') then
				file.CreateDir('bankrs')
			end
			
			file.Write('bankrs/'..game.GetMap()..'.txt', util.TableToJSON(data))
			DarkRP.notify(ply, 0, 10, 'Saved '..#found..' Bank Vaults.')
			MsgC(Color(255, 0, 0), '[BankRS] ', Color(255, 255, 0), 'New save data for '..game.GetMap()..' containing '..#found..' vaults written.\n')
		else
			DarkRP.notify(ply, 1, 5, 'No Bank Vaults found.')
		end
	end
end)

concommand.Add('bankrs_wipe', function(ply)
	if ply:IsSuperAdmin() then
		local read = file.Read('bankrs/'..game.GetMap()..'.txt', 'DATA')
		
		if read then
			file.Delete('bankrs/'..game.GetMap()..'.txt')
			DarkRP.notify(ply, 0, 10, 'Save data erased.')
			MsgC(Color(255, 0, 0), '[BankRS] ', Color(255, 255, 0), 'Save data for .'..game.GetMap()..' erased!\n')
		else
			DarkRP.notify(ply, 1, 5, 'No save data for '..game.GetMap()..' found!')
		end
	end
end)