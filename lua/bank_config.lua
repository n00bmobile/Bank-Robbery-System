---------------------
-- //CONFIG FILE\\ --
---------------------
-- General Settings --
Bank_SetMoneyAmount = 50000 //The amount of money available to rob from the bank.
Bank_SetRobTime = 300 //The amount of time needed to finish a bank robbery.
Bank_SetCooldownTime = 600 //The amount of time that you need to wait before you can rob the bank again after a failed/sucessfull robbery.
Bank_SetTeamMinNum = 5 //Minimum number of teams considered cops by the bank needed to start a robbery (0 to disable).
Bank_SetPlayerMinNum = 10 //Minimum of players needed to start a robbery (0 to disable).
Bank_SetMaxRadius = 500 //The maximum distance that you can go from the bank during a robbery.
Bank_SetBankerMinNum = 1 //Minimum number of teams considered bankers by the bank needed to start a robbery (o to disable).
Bank_SetSirenSoundLoop = true //Define if the siren when robbing the bank should loop.
-- Restrict Team Settings --
Bank_SetTeamBanker = { //The teams considered bankers by the bank.
"Banker"
}
Bank_SetNeededTeam = { //The teams considered cops by the bank.
"Civil Protection",
"Civil Protection Chief"
}
Bank_SetCanRobTeam = { //Who can rob the bank.
"Mob boss",
"Gangster"
}
