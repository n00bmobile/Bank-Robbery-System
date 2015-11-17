BankConfig = {}

-- [[ EDIT PAST HERE ]] --
BankConfig.RobberyTimer = 300 //The amount of time needed to finish a bank robbery.
BankConfig.CooldownTimer = 500 //The amount of time that you need to wait before you can rob the bank again after a failed/sucessfull robbery.
BankConfig.Reward = 50000 //The amount of money available to rob from the bank.
BankConfig.MaxDistance = 500 //The maximum distance that you can go from the bank during a robbery.
BankConfig.MinCops = 4 //Minimum number of teams considered cops by the bank needed to start a robbery. (0 to disable)
BankConfig.MinPlayers = 10 //Minimum of players needed to start a robbery. (0 to disable)
BankConfig.MinBankers = 0 //Minimum number of teams considered bankers by the bank needed to start a robbery. (0 to disable)
BankConfig.Loop = true

BankConfig.TeamRequired = { //The teams considered cops/robbers by the bank.
["Cops"] = {"Civil Protection", "Civil Protection Chief"},
["Robbers"] = {"Mob boss", "Gangster"},
["Bankers"] = {""}
}