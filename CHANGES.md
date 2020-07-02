# Innocents
## Mercenary
- Added setting to allow Mercenary to buy all Traitor and/or Detective weapons in their shop. See [Configuration](CONVARS.md).

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
  - Configurable bullet damage reduction. See [Configuration](CONVARS.md).

## Zombie
- Ported/Inspired by Infected from Town of Terror
 - Claw attack look (model, animation) and feel (range, damage, spread)
 - Jump attack
 - Spit attack
 - Configurable damage scaling when not using the claws. See [Configuration](CONVARS.md).
- Added recoil to Spit attack
- Made Spit not 100% accurate
- Changed spawned Zombies (e.g. Zombies created by dying to the Zombie claws) to configurably disallow picking up weapons. See [Configuration](CONVARS.md).

## Vampire
- Fixed never decloaking when using the fangs' right-click
- Added configurable bullet damage reduction similar to Infected from Town of Terror. See [Configuration](CONVARS.md).

# Killer
- Ported the following from Town of Terror. See [Configuration](CONVARS.md) to disable all but the buyable throwable crowbar.
  - Knife (with smoke grenade)
  - Buyable throwable crowbar
  - "Your Evil is Showing" smoke
  - "Wall Hack Vision"
  - "Kill" icon above other players' heads
  - Configurable bullet damage reduction. See [Configuration](CONVARS.md).
  - Configurable damage scaling when not using the knife. See [Configuration](CONVARS.md).
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
- Fixed compatibility with Dead Ringer weapon so that Detectives who use the Dead Ringer don't have their target icon ("D" over their head) visible when they should be cloaked
- Fixed various other errors
