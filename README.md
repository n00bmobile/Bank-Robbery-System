Bank Robbery System for DarkRP 2.5+
======

##### Read Carefully: #####

This is a Bank Robbery System for DarkRP 2.5+ and it may cause problems when used in others gamemodes.

##### Config File: #####

The Config File is located on the folder called lua, lua can be found on the main folder of the extracted addon. The name of the Config File is bank_config.lua.

##### Automatic Bank Vault Spawn: #####

Place a Bank Vault Entity and use saveBankPos on the console to save it. If you change to another map, the Bank Vault won't spawn unless you set a position for it too using saveBankPos.

##### Instructions: #####

All Instructions needed are located on the Config File.
Fell free ask me your questions about the Addon.

##### Distribution: #####

Fell free to edit it as much as you want. Since my code is very simple, you should not have problems to edit it if you know what you're doing. However you cannot edit it and publish it without asking me first. It's clear that also you cannot republish this anywhere else.

##### Final Thoughts: #####

It took me some time to do this, I really hope that you and your server enjoy it!
This addon is inspired by the Bank Robbery System from Script Fodder. However this code does not have any connections with it. It's made for free by me.

#### Credits: ####

* n00bmobile (Me)

* HunterFP (For helping a little)

#### Planned Updates: ####
* Add money upgrade system based on time.

#### Changes(Feel Free to Report Any Bugs to Me): ####

* Added required cops system.
* Fixed text not showing money quantity.
* Fixed problem with perma spawn system.
* Fixed infinite robbing, caused by the robbers exiting the server during a robbery.
* Setting up teams is now a lot easier.
* Fixed config file missing instructions.
* Added minimum players system before being able to rob the bank.
* Added more details to not enough players notification.
* Fixed duplicated money.
* Removed money upgrade/downgrade due problems.
* Not enough players notification now show how many players are needed.
* Fixed notification spam.
* Fixed notification spelling mistake.
* Fixed infinite wanted.
* New siren sound effect(loop).
* Removed massive amount of useless things from the code.
* Fixed infinite siren after bank reload on a running server.
* Removed useless stuff from the code.
* Removed bank_reset because of admin abuse.
* Added translation option in the config file.
* Added saveBankPos command.
* Fixed notifications not showing for everyone.
* Fixed robbery continuation after being arrested.
* Added gamemode blocker to evade the use of the Bank Entity on unsupported gamemodes.
* Robbing and Cooldown time are now in MM:SS format

##### Quick Questions: #####

1.The Robbery fails imediataly after starting it!

Set a position for the Bank, the default one from the config file is conflicting with the Bank that you just spawned from the spawn menu. You can only have one active bank on a map. 

2.I tried to change the Bank Vault model... It gave me errors!

Don't remove the quotes.

3.I tried the new system for setting up teams... It gave me errors!

Don't forget the quotes and the commas! Also put the exact same name that appears in*game. Ex: Mob boss = Mob Boss (WRONG!) Lua is case sensitive.

4.The Config File is not working!

Restart your server and make sure that you saved the Config File.

5.I remember seeing this on CoderHire/Script Fodder...

I started this project wanting to clone the Bank Robbery System from Script Fodder, they both do the same but the code is all mine.