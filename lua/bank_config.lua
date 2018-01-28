BANK_CONFIG = {} 
BANK_CONFIG.MinGovernment = 0 -- Minimum number of teams considered cops by the Bank needed to start a robbery. (0 to disable)
BANK_CONFIG.MinBankers = 0 -- Minimum number of teams considered bankers by the Bank needed to start a robbery. (0 to disable)
BANK_CONFIG.MinPlayers = 0 -- Minimum of players needed to start a robbery. (0 to disable)
BANK_CONFIG.BaseReward = 50000 -- The amount of money that each vault starts with.
BANK_CONFIG.Interest = 5000 -- The amount to increase in each interest.
BANK_CONFIG.CooldownTime = 540 -- The amount of time that you need to wait before you can rob the bank again after a failed/sucessfull robbery.
BANK_CONFIG.RobberyTime = 180 --  The amount of time needed to finish a bank robbery.
BANK_CONFIG.MaxDistance = 500 -- The maximum distance that you can go from the vault during a robbery.
BANK_CONFIG.LoopSiren = true -- Should the siren sound loop?
BANK_CONFIG.MaxReward = 300000 -- The maximum reward for a successful robbery.
BANK_CONFIG.InterestTime = 120 -- The delay between increasing the vault's reward.
BANK_CONFIG.SaviorReward = 8000 -- The reward for killing the robber.
BANK_CONFIG.Government = { -- The teams considered cops by the bank.
    ['Civil Protection'] = true, -- uses the name displayed in the F4 menu. (Uses the name displayed in the F4 menu)
    ['Example Name'] = true,
}
BANK_CONFIG.Bankers = { -- The teams considered bankers by the bank. (Uses the name displayed in the F4 menu)
    ['Citizen'] = true,
    ['Example Name'] = true,
}
BANK_CONFIG.Robbers = { -- The teams that can rob the vault. (Uses the name displayed in the F4 menu)
    ['Gangster'] = true, 
    ['Example Name'] = true,
}