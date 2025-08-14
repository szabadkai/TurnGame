// Inherit shared combat entity properties
event_inherited();

// Assign unique name based on instance creation order
var player_names = ["Aria", "Bran", "Cora", "Dex", "Erin"];
var player_count = instance_number(obj_Player);
var my_index = character_index;

// Find this player's index among all players
for (var i = 0; i < player_count; i++) {
    if (instance_find(obj_Player, i) == self) {
        my_index = i;
        break;
    }
}

character_name = player_names[my_index % array_length(player_names)];

// === ABILITY SCORES ===
// Set diverse starting ability scores for different character archetypes
var ability_sets = [
    [14, 13, 12, 10, 11, 9],  // Aria: STR-focused fighter
    [12, 14, 11, 9, 13, 10],  // Bran: DEX-focused ranger  
    [13, 12, 14, 11, 10, 9],  // Cora: CON-focused tank
    [10, 11, 12, 14, 13, 9],  // Dex: INT-focused strategist
    [11, 10, 13, 12, 14, 9]   // Erin: WIS-focused cleric
];

var my_abilities = ability_sets[my_index % array_length(ability_sets)];
strength = my_abilities[0];
dexterity = my_abilities[1]; 
constitution = my_abilities[2];
intelligence = my_abilities[3];
wisdom = my_abilities[4];
charisma = my_abilities[5];

// Update ability modifiers
update_ability_modifiers(self);

// Update proficiency bonus based on level
proficiency_bonus = get_proficiency_bonus(level);

// Override base class values with player-specific stats
max_moves = 2;
moves = 2;

// Calculate HP based on class hit die + constitution modifier
// Using d8 hit die for balanced characters (8 + CON mod at level 1)
max_hp = 8 + con_mod;
hp = max_hp;
last_hp = hp;

// Base combat stats (replaced by ability score system)
// Attack bonus = proficiency_bonus + STR/DEX mod + weapon bonus
// Damage modifier = STR/DEX mod + weapon bonus  
// Defense score = base_armor_class + DEX mod + armor bonus
base_armor_class = 11;  // Light armor equivalent

// Current combat stats (calculated in update_combat_stats)
attack_bonus = proficiency_bonus + str_mod;  // Default to STR-based
damage_modifier = str_mod;
defense_score = base_armor_class + dex_mod;

// Player-specific weapon system
equipped_weapon_id = 0;
weapon_name = "Fists";
weapon_attack_bonus = 1;
weapon_damage_dice = "1d1";
weapon_damage_modifier = 0;
weapon_defense_bonus = 0;
weapon_special_type = "none";

// Ensure core variables exist (should be inherited, but adding for safety)
if (!variable_instance_exists(id, "state")) state = TURNSTATE.inactive;
if (!variable_instance_exists(id, "frozen_turns")) frozen_turns = 0;
if (!variable_instance_exists(id, "burn_turns")) burn_turns = 0;
if (!variable_instance_exists(id, "damage_flash")) damage_flash = 0;

// Initialize weapons and update stats
init_weapons();
update_combat_stats();

is_anim = false;
target_enemy = 0;

// Initialize enums (defined in scr_enums.gml)
scr_enums();

// Initialize sprite matrix based on character_index
spr_matrix = init_character_sprite_matrix(character_index);

dir = Dir.DOWN;
anim_state = State.IDLE;
image_speed = 1.0;