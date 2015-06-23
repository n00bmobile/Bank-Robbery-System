--[[
 /$$$$$$$                      /$$             /$$$$$$$   /$$$$$$  | * PRODUCT LICENSED: http://creativecommons.org/licenses/by-nd/3.0/
| $$__  $$                    | $$            | $$__  $$ /$$__  $$ | By using this product, you agree to follow the license limitations.
| $$  \ $$  /$$$$$$  /$$$$$$$ | $$   /$$      | $$  \ $$| $$  \__/ | Got any questions, contact author.
| $$$$$$$  |____  $$| $$__  $$| $$  /$$/      | $$$$$$$/|  $$$$$$  | 
| $$__  $$  /$$$$$$$| $$  \ $$| $$$$$$/       | $$__  $$ \____  $$ | * AUTHOR: n00bmobile
| $$  \ $$ /$$__  $$| $$  | $$| $$_  $$       | $$  \ $$ /$$  \ $$ |
| $$$$$$$/|  $$$$$$$| $$  | $$| $$ \  $$      | $$  | $$|  $$$$$$/ | * FILE: bank_config.lua
|_______/  \_______/|__/  |__/|__/  \__/      |__/  |__/ \______/  |
]]--

BankConfig = {}

-- [[ EDIT PAST HERE ]] --

BankConfig.robberyT = 300 //The amount of time needed to finish a bank robbery.
BankConfig.cooldownT = 600 //The amount of time that you need to wait before you can rob the bank again after a failed/sucessfull robbery.
BankConfig.reward = 50000 //The amount of money available to rob from the bank.
BankConfig.maxD = 500 //The maximum distance that you can go from the bank during a robbery.
BankConfig.minC = 4 //Minimum number of teams considered cops by the bank needed to start a robbery. (0 to disable)
BankConfig.minP = 10 //Minimum of players needed to start a robbery. (0 to disable)
BankConfig.minB = 0 //Minimum number of teams considered bankers by the bank needed to start a robbery. (0 to disable)
BankConfig.loop = true //Define if the siren when robbing the bank should loop.

BankConfig.teamR = { //The teams considered cops/robbers by the bank.
["Cops"] = {"Civil Protection", "Civil Protection Chief"},
["Robbers"] = {"Mob boss", "Gangster"},
["Bankers"] = {""}
}