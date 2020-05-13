Thanks to [Jenssons](https://steamcommunity.com/profiles/76561198044525091) for the 'Town of Terror' mod which was the foundation of this mod.\
Thanks to [Noxx](https://steamcommunity.com/id/nickpops98) for the original version of this mod.\
\
**Edits the original version to restore some of the Town of Terror functionality**

# Innocent Team
Goal: Kill all members of the traitor and monsters teams\
\
**Innocent** - A standard player. Has no special abilities\
**Detective** - Inspect dead bodies to help identify the baddies\
**Glitch** - An innocent that appears as a Traitor to members of the Traitor team\
**Mercenary** - An innocent with a weapon shop\
**Phantom** - Will haunt your killer, showing black smoke. When avenged, you have another chance for life

# Traitor Team
Goal: Kill all non-team members (except Jester/Swapper)\
\
**Traitor** - Use your extensive weapon shop to help your team win\
**Assassin** - Kill all of your targets in order to do massive damage and win for the Traitor team\
**Hypnotist** - Use your brain washing device on dead players to make more traitors

# Monster Team
Goal: Kill all non-monsters (except Jester/Swapper)\
\
**Vampire** - Kill players and use your fangs to regain health\
**Zombie** - Kill players with your claws to make more zombies

# Independent Players
Goal: Work on your own to win the round by playing your role carefully\
\
**Jester** - Get killed by another player\
**Swapper** - Get killed by another player and then fulfill their old goal\
**Killer** - Be the last player standing

# Special Thanks
- [Jenssons](https://steamcommunity.com/profiles/76561198044525091) for the ['Town of Terror'](https://steamcommunity.com/sharedfiles/filedetails/?id=1092556189) mod which was the foundation of this mod.
- [Noxx](https://steamcommunity.com/id/nickpops98) for the [original version](https://steamcommunity.com/sharedfiles/filedetails/?id=1215502383) of this mod.
- [Long Long Longson](https://steamcommunity.com/id/gamerhenne) for the ['Better Equipment Menu'](https://steamcommunity.com/sharedfiles/filedetails/?id=878772496) mod
- [Silky](https://steamcommunity.com/profiles/76561198094798859) for the code used to create the pile of bones after the Vampire eats a body taken from the ['TTT Traitor Weapon Evolve'](https://steamcommunity.com/sharedfiles/filedetails/?id=1240572856) mod.
- [Minty](https://steamcommunity.com/id/_Minty_) for the code used for the Hypnotist's brain washing device taken from the ['Defibrillator for TTT'](https://steamcommunity.com/sharedfiles/filedetails/?id=801433502) mod.
- [Fresh Garry](https://steamcommunity.com/id/Fresh_Garry) for the ['TTT Sprint'](https://steamcommunity.com/sharedfiles/filedetails/?id=933056549) mod which was used as the base for this mods sprinting mechanics.
- [Willox](https://steamcommunity.com/id/willox) for the ['Double Jump!'](https://steamcommunity.com/sharedfiles/filedetails/?id=284538302) mod.
- Kommandos, Lix3, FunCheetah, B1andy413, Cooliew, The_Samarox, Arack12 and Aspirin for helping Noxx test.
- Angela from the [Lonely Yogs](https://lonely-yogs.co.uk/) Discord for the fix for some traitor weapon incompatibilities.
- Alex and other members of the [Lonely Yogs](https://lonely-yogs.co.uk/) Discord for using my versions of these addons and helping me fix and improve them.

# Changes from the Original Version
- Mercenary - Added setting to allow Mercenary to buy all Traitor and/or Detective weapons in their shop. See **Configuration** section below
- Killer - Ported knife (with smoke grenade), throwable crowbar, and "Your Evil is Showing" smoke from Town of Terror
- Killer - Added new section to the scoreboard for the Killer since there can be a Killer and a Jester/Swapper now
- Zombie, Vampire, and Killer - Ported "Zombie Vision" from Town of Terror
- Zombie - Modified attack to look (model, animation) and feel (range, damage, spread) like the Infected from Town of Terror
- Zombie - Ported Infected Jump and Spit attacks from Town of Terror
- Zombie - Added recoil to Spit attack
- Zombie - Made Spit not 100% accurate
- Zombie - Changed spawned zombies (e.g. zombies created by dying to the zombie claws) to disallow picking up weapons
- Vampire - Fixed never decloaking when using the fangs right-click
- Traitors - Made Hypnotist and Assassin more integrated traitor team members by
    - Allowing transferring of credits
	- Adding setting to allow Assassin and/or Hypnotist to buy all Traitor weapons in their shop. See **Configuration** section below
- Created new "Monsters" team with Zombie and Vampire to ensure they fight against all players, rather than allied with Traitors
	- Created new icons to handle previously-unexpected zombification and hypnotization cases
- Re-added the Sprint configuration menu when pressing F1. Thanks to [exp111](https://github.com/exp111/TTT-Custom-Roles/) on GitHub
- Updated end-of-round summary to merge the old tabs and buttons with the new interface
- Added new events for the new roles to the end-of-round summary Events tab. Thanks to [exp111](https://github.com/exp111/TTT-Custom-Roles/) on GitHub
- Changed role spawning to not do hidden math to determine role chance. Uses the CVars values directly instead.
- Ported ability to load weapons into role weapon shops from Town of Terror. See **Configuration** section below.
- Integrated the [Double Jump!](https://steamcommunity.com/sharedfiles/filedetails/?id=284538302) mod but replaced the particle usage with effects generation to remove the TF2 requirement
- Fixed conflicts with certain buyable weapons (like the Time Manipulator). Thanks Angela from the [Lonely Yogs](https://lonely-yogs.co.uk/) Discord!
- Fixed traitor voice chat so regular vanilla Traitors can do global chat (by using the "Sprint (Walk quickly)" keybind) like the other traitor roles
- Fixed various errors

# Conflicts
This will conflict with the [Better Equipment Menu](https://steamcommunity.com/sharedfiles/filedetails/?id=878772496) addon but has its functionality built in

# Configuration
https://github.com/Malivil/TTT-Custom-Roles/blob/master/CONVARS.md
