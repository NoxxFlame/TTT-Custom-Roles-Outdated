# Server Configurations

Add the following to your server config:

```cpp
// ----------------------------------------
// Custom Role Settings
// ----------------------------------------

ttt_glitch_enabled    1 // (Default: 1): Whether the Glitch should spawn or not
ttt_mercenary_enabled 1 // (Default: 1): Whether the Mercenary should spawn or not
ttt_phantom_enabled   1 // (Default: 1): Whether the Phantom should spawn or not
ttt_assassin_enabled  1 // (Default: 1): Whether the Assassin should spawn or not
ttt_hypnotist_enabled 1 // (Default: 1): Whether the Hypnotist should spawn or not
ttt_vampire_enabled   1 // (Default: 1): Whether the Vampire should spawn or not
ttt_zombie_enabled    1 // (Default: 1): Whether Zombies should spawn or not
ttt_jester_enabled    1 // (Default: 1): Whether the Jester should spawn or not
ttt_swapper_enabled   1 // (Default: 1): Whether the Swapper should spawn or not
ttt_killer_enabled    1 // (Default: 1): Whether the Swapper should spawn or not

// Role Spawn Chances
ttt_glitch_chance    0.25 // (Default: 0.25): Chance of the Glitch spawning in a round
ttt_mercenary_chance 0.25 // (Default: 0.25): Chance of the Mercenary spawning in a round
ttt_phantom_chance   0.25 // (Default: 0.25): Chance of the Phantom spawning in a round
ttt_assassin_chance  0.20 // (Default: 0.20): Chance of the Assassin spawning in a round
ttt_hypnotist_chance 0.20 // (Default: 0.20): Chance of the Hypnotist spawning in a round
ttt_vampire_chance   0.20 // (Default: 0.20): Chance of the Vampire spawning in a round
ttt_zombie_chance    0.10 // (Default: 0.10): Chance of Zombies replacing traitors in a round
ttt_jester_chance    0.25 // (Default: 0.25): Chance of the Jester spawning in a round
ttt_swapper_chance   0.25 // (Default: 0.25): Chance of the Swapper spawning in a round
ttt_killer_chance    0.25 // (Default: 0.25): Chance of the Killer spawning in a round

// Role Spawn Requirements
ttt_glitch_required_innos       2 // (Default: 2): Number of innocents for the Glitch to spawn
ttt_mercenary_required_innos    2 // (Default: 2): Number of innocents for the Mercenary to spawn
ttt_phantom_required_innos      2 // (Default: 2): Number of innocents for the Phantom to spawn
ttt_assassin_required_traitors  2 // (Default: 2): Number of traitors for the Assassin to spawn
ttt_hypnotist_required_traitors 2 // (Default: 2): Number of traitors for the Hypnotist to spawn
ttt_vampire_required_traitors   2 // (Default: 2): Number of traitors for the Vampire to spawn
ttt_jester_required_innos       2 // (Default: 2): Number of innocents for the Jester to spawn
ttt_swapper_required_innos      2 // (Default: 2): Number of innocents for the Swapper to spawn
ttt_killer_required_innos       3 // (Default: 3): Number of innocents for the Killerto spawn

// Karma
ttt_karma_jesterkill_penalty 50   // (Default: 50): Karma penalty for killing the Jester
ttt_karma_jester_ratio       0.5  // (Default: 0.5): Ratio of damage to Jesters, to be taken from karma

// Other
ttt_monster_pct             0.25 // (Default: 0.25): Percentage of total players that will be monsters (Zombies or Vampires)
ttt_mer_credits_starting    1    // (Default: 1): Number of credits the Mercenary starts with
ttt_kil_credits_starting    2    // (Default: 2): Number of credits the Killer starts with
ttt_killer_smoke_timer      60   // (Default: 60): Number of seconds before a Killer will start to smoke after their last kill
ttt_detective_search_only   1    // (Default: 1): Whether only detectives can search bodies or not
ttt_shop_merc_mode          0    // (Default: 0): How to handle Mercenary shop weapons. All modes include weapons specifically mapped to the Mercenary role. 0 (Disable) - Do not allow additional weapons. 1 (Union) - Allow weapons available to EITHER the Traitor or the Detective. 2 (Intersect) - Allow weapons available to BOTH the Traitor and the Detective. 3 (Detective) - Allow weapons available to the Detective. 4 (Traitor) - Allow weapons available to the Traitor.
ttt_shop_traitors_sync      0    // (Default: 0): Whether Assassins and Hypnotists should have all weapons that vanilla Traitors have in their weapon shop
```

# Role Weapon Shop

In this version of TTT some roles have shops where they are allowed to purchase weapons. Given the prevalence of custom weapons from the workshop, the ability to add more weapons to each role's shop has been added.

To add weapons to a role (that already has a shop), create a .txt file with the weapon class (e.g. weapon_ttt_somethingcool.txt) in the garrysmod/data/roleweapons/{rolename} folder.\
**NOTE**: The name of the role must be all lowercase for cross-operating system compatibility. For example: garrysmod/data/roleweapons/detective/weapon_ttt_somethingcool.txt
