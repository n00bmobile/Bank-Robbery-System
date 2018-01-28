ENT.Type = 'anim'
ENT.Base = 'base_gmodentity'
ENT.PrintName = 'Bank Vault'
ENT.Author = 'n00bmobile'
ENT.Category = 'n00bmobile'
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:SetupDataTables()
	self:NetworkVar('Float', 0, 'NextAction')
	self:NetworkVar('Int', 0, 'Reward')
	self:NetworkVar('Int', 1, 'Status')

	if SERVER then
		self:SetReward(BANK_CONFIG.BaseReward)
		self:SetStatus(0)
	end
end