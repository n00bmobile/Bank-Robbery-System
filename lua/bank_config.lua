bank_config = {
    robbery = {
	    time = 300, --> The amount of time needed to finish a bank robbery.
		m_dist = 500, --> The maximum distance that you can go from the bank during a robbery.
		m_cops = 1, --> Minimum number of teams considered cops by the bank needed to start a robbery. (0 to disable)
		m_bankers = 0, --> Minimum number of teams considered bankers by the bank needed to start a robbery. (0 to disable)
	    m_players = 2, --> Minimum of players needed to start a robbery. (0 to disable)
		killer_reward = 1500, --> The reward won by the player who kills the robber.
		loop = true, --> Should the siren sound loop?
		t_required = { --> The teams considered cops/robbers/bankers by the bank.
		    cops = {"Civil Protection", "Civil Protection Chief", "Mendigo"},
            bankers = {},
			robbers = {"Mob boss", "Gangster", "Cidadão"},
		},
	},
	
	interest = {
		delay = 300, --> The delay between increasing the bank's reward.
		amount = 1500, --> The amount to increase in each interest.
		base = 50000, --> The base amount of money without any interest available to rob from the bank.
		max = 100000, --> As high as interest can make the reward go.
	},
	
	cooldown = {
	    time = 300, --> The amount of time that you need to wait before you can rob the bank again after a failed/sucessfull robbery.
	},
}