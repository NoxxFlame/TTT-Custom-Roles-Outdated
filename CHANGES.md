# Mercenary
- Added setting to allow Mercenary to buy all Traitor and/or Detective weapons in their shop. See [Configuration](CONVARS.md).

# Killer
- Ported knife (with smoke grenade), throwable crowbar, and "Your Evil is Showing" smoke from Town of Terror
- Added new section to the scoreboard for the Killer since there can be a Killer and a Jester/Swapper now
- Ported "Wall Hack Vision" from Town of Terror

# Monsters
- Created new "Monsters" team with Zombie and Vampire to ensure they fight against all players, rather than allied with Traitors
- Created new icons to handle previously-unexpected zombification and hypnotization cases
- Ported "Zombie Vision" from Town of Terror for both Zombie and Vampire

# Zombie
- Modified attack to look (model, animation) and feel (range, damage, spread) like the Infected from Town of Terror
- Ported Infected Jump and Spit attacks from Town of Terror
- Added recoil to Spit attack
- Made Spit not 100% accurate
- Changed spawned zombies (e.g. zombies created by dying to the zombie claws) to disallow picking up weapons

# Vampire
- Fixed never decloaking when using the fangs right-click

# Traitors
- Made Hypnotist and Assassin more integrated traitor team members by
  - Allowing transferring of credits
  - Adding setting to allow Assassin and/or Hypnotist to buy all Traitor weapons in their shop. See [Configuration](CONVARS.md).

# Additions
- Re-added the Sprint configuration menu when pressing F1. Thanks to [exp111](https://github.com/exp111/TTT-Custom-Roles/) on GitHub
- Updated end-of-round summary to merge the old tabs and buttons with the new interface
- Added new events for the new roles to the end-of-round summary Events tab. Thanks to [exp111](https://github.com/exp111/TTT-Custom-Roles/) on GitHub
- Ported ability to load weapons into role weapon shops from Town of Terror. See [Configuration](CONVARS.md).
- Integrated the [Double Jump!](https://steamcommunity.com/sharedfiles/filedetails/?id=284538302) mod but replaced the particle usage with effects generation to remove the TF2 requirement
- Added a setting to the multi-jump functionality to disallow multi-jumping if you didn't jump originally (e.g. were batted or fell)

# Changes
- Changed role spawning to not do hidden math to determine role chance. Uses the CVars values directly instead.

# Fixes
- Fixed conflicts with certain buyable weapons (like the Time Manipulator). Thanks Angela from the [Lonely Yogs](https://lonely-yogs.co.uk/) Discord!
- Fixed traitor voice chat so regular vanilla Traitors can do global chat (by using the "Sprint (Walk quickly)" keybind) like the other traitor roles
- Fixed various errors
