---------------------------------------------------------------------------
-- |Feel Free to Ask me Questions| CONFIG |Feel Free to Ask me Questions|--
---------------------------------------------------------------------------
-- Bank Number Values --
Bank_StartingAmount           = 50000 //The starting amount for the Bank Vault
Bank_RobberyTime              = 300 //The time that takes to rob the Bank Vault (In Seconds)
Bank_RequiredGovernmentNumber = 5 //The required number of cops before being able to rob the Bank (0 to Disable)
Bank_RobberyCooldownTime      = 600 //The time that takes to enable Bank Robbery again (In Seconds)
Bank_RobberyMaxRadius         = 500 //How far the robber can go from the Bank Vault
Bank_MinPlayers               = 10 //The minimum players required before being able to rob the Bank (0 to Disable)
-- Bank Model --
Bank_ChooseModel              = "models/props/cs_assault/moneypallet.mdl" //Choose the Bank Vault model
-- Bank Perma Spawn System --
Bank_SpawnPos                 = Vector(-368.781250, -1559.843750, -143.531250) //Spawn position for the Bank Vault (Console>printEntInfo)
Bank_SpawnAngle               = Angle(-0.220, -89.868, -0.132) //Spawn Angle for the Bank Vault (Console>printEntInfo)
-- Bank Team Restrict System --
Bank_TeamCanRob               = { //Who can rob the Bank (Use the team name in-game! Ex: TEAM_MOB = Mob boss) Don't forget the quotes and the commas!
"Mob boss",
"Gangster"
}
Bank_TeamGovernment           = { //Which teams will be considered as cops by the Bank
"Civil Protection",
"Civil Protection Chief"
}
-- Bank Language Translation --
Bank_WrongTeam                = "You cannot start a robbery as a %PLAYERJOB%!"
Bank_WrongPlayerNumber        = "There has to be at least %MINPLAYERS% players to rob the bank!"
Bank_WrongCopNumber           = "There has to be at least %MINCOPS% cops to rob the bank!"
Bank_WrongCooldown            = "You need to wait %COOLDOWNTIME% seconds before you can rob the bank!"
Bank_WantedReason             = "Robbing The Bank"
Bank_StartRobbery             = "%PLAYERNAME% has started a robbery!"
Bank_FinishRobberySucess      = "%PLAYERNAME% has finished the robbery!"
Bank_FinishRobberyFailJob     = "%PLAYERNAME% has changed jobs during a robbery!"
Bank_FinishRobberyFailDie     = "%PLAYERNAME% has died during a robbery!"
Bank_FinishRobberyFailArea    = "%PLAYERNAME% has exited the robbery area!"
Bank_DisplayAmount            = "$%BANKAMOUNT%"
Bank_DisplayRobbing           = "Robbing: %ROBBERYTIME%"
Bank_DisplayCooldown          = "Cooldown: %COOLDOWNTIME%"
Bank_DisplayWaiting           = "Waiting"