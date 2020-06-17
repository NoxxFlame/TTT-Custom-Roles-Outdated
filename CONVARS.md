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
ttt_glitch_chance    0.25 // (Default: 0.25): Chance of the Glitch spawning in a round. NOTE: Glitch will only spawn if there are 2 vanilla traitors in the round. Any less than that and the Glitch is made obvious by looking at the scoreboard
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

// Role Percentages
ttt_traitor_pct      0.25 // (Default: 0.25): Percentage of total players that will be traitors
ttt_detective_pct    0.13 // (Default: 0.13): Percentage of total players that will be detectives
ttt_monster_pct      0.25 // (Default: 0.25): Percentage of total players that will be monsters (Zombies or Vampires)

// Karma
ttt_karma_jesterkill_penalty 50   // (Default: 50): Karma penalty for killing the Jester
ttt_karma_jester_ratio       0.5  // (Default: 0.5): Ratio of damage to Jesters, to be taken from karma

// Sprint
ttt_sprint_enabled              1    // (Default: 1): Whether to enable sprinting. NOTE: Disabling sprinting doesn't hide the bar on the client UI but it will never change from being 100% full
ttt_sprint_bonus_rel            0.4  // (Default: 0.4): The relative speed bonus given while sprinting. (0.1-2)
ttt_sprint_big_crosshair        1    // (Default: 1): Makes the crosshair bigger while sprinting.
ttt_sprint_regenerate_innocent  0.08 // (Default: 0.08): Sets stamina regeneration for innocents. (0.01-2)
ttt_sprint_regenerate_traitor   0.12 // (Default: 0.12): Sets stamina regeneration speed for traitors. (0.01-2)
ttt_sprint_consume              0.2  // (Default: 0.2): Sets stamina consumption speed. (0.1-5)

// Double Jump
multijump_default_jumps          1 // (Default: 1): The amount of extra jumps players should get. Set to 0 to disable multiple jumps
multijump_default_power          1 // (Default: 1): Multiplier for the jump-power when multi jumping
multijump_can_jump_while_falling 1 // (Default: 1): Whether the player should be able to multi-jump if they didn't jump to begin with

// Weapon Shop
ttt_shop_merc_mode          0    // (Default: 0): How to handle Mercenary shop weapons. All modes include weapons specifically mapped to the Mercenary role. 0 (Disable) - Do not allow additional weapons. 1 (Union) - Allow weapons available to EITHER the Traitor or the Detective. 2 (Intersect) - Allow weapons available to BOTH the Traitor and the Detective. 3 (Detective) - Allow weapons available to the Detective. 4 (Traitor) - Allow weapons available to the Traitor.
ttt_shop_assassin_sync      0    // (Default: 0): Whether Assassins should have all weapons that vanilla Traitors have in their weapon shop
ttt_shop_hypnotist_sync     0    // (Default: 0): Whether Hypnotists should have all weapons that vanilla Traitors have in their weapon shop

// Other
ttt_mer_credits_starting     1    // (Default: 1): Number of credits the Mercenary starts with
ttt_kil_credits_starting     2    // (Default: 2): Number of credits the Killer starts with
ttt_traitor_vision_enable    0    // (Default: 0): Whether members of the Traitor team can see other members of the Traitor team (including Glitches) through walls via a highlight effect.
ttt_killer_knife_enabled     1    // (Default: 1): Whether the Killer knife is enabled
ttt_killer_max_health        100  // (Default: 100): The Killer's starting and maximum health
ttt_killer_smoke_enabled     1    // (Default: 1): Whether the Killer smoke is enabled
ttt_killer_smoke_timer       60   // (Default: 60): Number of seconds before a Killer will start to smoke after their last kill
ttt_killer_vision_enable     1    // (Default: 1): Whether Killers have their special vision highlights enabled
ttt_killer_show_target_icon  1    // (Default: 1): Whether Killers have an icon over other players' heads showing who to kill. Server or round must be restarted for changes to take effect.
ttt_vampire_vision_enable    1    // (Default: 1): Whether Vampires have their special vision highlights enabled
ttt_vampire_show_target_icon 1    // (Default: 1): Whether Vampires have an icon over other players' heads showing who to kill. Server or round must be restarted for changes to take effect.
ttt_zombie_vision_enable     1    // (Default: 1): Whether Zombies have their special vision highlights enabled
ttt_zombie_show_target_icon  1    // (Default: 1): Whether Zombies have an icon over other players' heads showing who to kill. Server or round must be restarted for changes to take effect.
ttt_detective_search_only    1    // (Default: 1): Whether only Detectives can search bodies or not
```

# Role Weapon Shop

In TTT some roles have shops where they are allowed to purchase weapons. Given the prevalence of custom weapons from the workshop, the ability to add more weapons to each role's shop has been added.

To add weapons to a role (that already has a shop), create a .txt file with the weapon class (e.g. weapon_ttt_somethingcool.txt) in the garrysmod/data/roleweapons/{rolename} folder.\
**NOTE**: The name of the role must be all lowercase for cross-operating system compatibility. For example: garrysmod/data/roleweapons/detective/weapon_ttt_somethingcool.txt

Also note the ttt_shop_* ConVars that are available above which can help control some of the role weapon shop lists.
