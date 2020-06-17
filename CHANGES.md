# Innocents
## Mercenary
- Added setting to allow Mercenary to buy all Traitor and/or Detective weapons in their shop. See [Configuration](CONVARS.md).

## Vampire
- Fixed never decloaking when using the fangs right-click

# Traitors
- Made Hypnotist and Assassin more integrated traitor team members by
  - Allowing transferring of credits
  - Adding setting to allow Assassin and/or Hypnotist to buy all Traitor weapons in their shop. See [Configuration](CONVARS.md).
- Added ability to show outlines around other members of the traitor team (including the Glitch). See [Configuration](CONVARS.md).

# Monsters
- Created new "Monsters" team with Zombie and Vampire to ensure they fight against all players, rather than allied with Traitors
- Created new icons to handle previously-unexpected zombification and hypnotization cases
- Ported the following from Town of Terror. See [Configuration](CONVARS.md) to disable.
  - "Zombie Vision" for both Zombie and Vampire
  - "Kill" icon above other players' heads

## Zombie
- Modified attack to look (model, animation) and feel (range, damage, spread) like the Infected from Town of Terror
- Ported Infected Jump and Spit attacks from Town of Terror
- Added recoil to Spit attack
- Made Spit not 100% accurate
- Changed spawned zombies (e.g. zombies created by dying to the zombie claws) to disallow picking up weapons

# Killer
- Ported the following from Town of Terror. See [Configuration](CONVARS.md) to disable all but the buyable throwable crowbar.
  - Knife (with smoke grenade)
  - Buyable throwable crowbar
  - "Your Evil is Showing" smoke
  - "Wall Hack Vision"
  - "Kill" icon above other players' heads
- Change default max health to 100 to match the other roles. See [Configuration](CONVARS.md) to change.
- Added new section to the scoreboard for the Killer since there can be a Killer and a Jester/Swapper now

# Additions
## General
- Ported ability to load weapons into role weapon shops from Town of Terror. See [Configuration](CONVARS.md).

## Round Summary
- Updated end-of-round summary to merge the old tabs and buttons with the new interface
- Added new events for the new roles to the end-of-round summary Events tab. Thanks to [exp111](https://github.com/exp111/TTT-Custom-Roles/) on GitHub

## Sprint
- Re-added the Sprint configuration menu when pressing F1. Thanks to [exp111](https://github.com/exp111/TTT-Custom-Roles/) on GitHub
- Added a setting to disable the sprint functionality. See [Configuration](CONVARS.md).

## Double Jump
- Integrated the [Double Jump!](https://steamcommunity.com/sharedfiles/filedetails/?id=284538302) mod but replaced the particle usage with effects generation to remove the TF2 requirement
- Added a setting to disallow multi-jumping if you didn't jump originally (e.g. were batted or fell). See [Configuration](CONVARS.md).

# Changes
- Changed role spawning to not do hidden math to determine role chance. Uses the CVars values directly instead.

# Fixes
- Fixed conflicts with certain buyable weapons (like the Time Manipulator). Thanks Angela from the [Lonely Yogs](https://lonely-yogs.co.uk/) Discord!
- Fixed traitor voice chat so regular vanilla Traitors can do global chat (by using the "Sprint (Walk quickly)" keybind) like the other traitor roles
- Fixed various errors
