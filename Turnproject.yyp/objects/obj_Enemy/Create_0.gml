// Inherit shared combat entity properties
event_inherited();

// Assign unique name based on instance creation order  
var enemy_names = ["Goblin Scout", "Orc Grunt", "Skeleton", "Bandit", "Wolf"];
var enemy_count = instance_number(obj_Enemy);
var my_index = 0;

// Find this enemy's index among all enemies
for (var i = 0; i < enemy_count; i++) {
    if (instance_find(obj_Enemy, i) == self) {
        my_index = i;
        break;
    }
}

character_name = enemy_names[my_index % array_length(enemy_names)];

// === ENEMY ABILITY SCORES ===
// Set varied ability scores for different enemy types
var enemy_ability_sets = [
    [12, 14, 10, 8, 10, 6],   // Goblin Scout: agile but weak
    [16, 12, 14, 6, 8, 10],   // Orc Grunt: strong and tough 
    [10, 14, 12, 6, 6, 8],    // Skeleton: dexterous undead
    [13, 15, 11, 10, 12, 14], // Bandit: well-rounded
    [12, 15, 12, 3, 12, 6]    // Wolf: fast predator
];

var enemy_abilities = enemy_ability_sets[my_index % array_length(enemy_ability_sets)];
strength = enemy_abilities[0];
dexterity = enemy_abilities[1];
constitution = enemy_abilities[2];
intelligence = enemy_abilities[3];
wisdom = enemy_abilities[4];
charisma = enemy_abilities[5];

// Update ability modifiers
update_ability_modifiers(self);

// Set appropriate level and proficiency for enemies (most are level 1)
level = 1;
proficiency_bonus = get_proficiency_bonus(level);

// Override base class values with enemy-specific stats
max_moves = 0;
moves = 0;

// Calculate HP based on constitution (using d6 hit die for enemies)
max_hp = 3 + con_mod;  // Average d6 (3.5 rounded down) + CON mod
if (max_hp < 1) max_hp = 1;  // Minimum 1 HP
hp = max_hp;
last_hp = hp;

// Calculate combat stats using ability scores
base_armor_class = 10;  // Base AC for most enemies
attack_bonus = proficiency_bonus + str_mod;  // Most enemies use STR for attacks
damage_modifier = str_mod;
defense_score = base_armor_class + dex_mod;

// Assign weapon based on enemy type
var enemy_weapon_ids = [10, 11, 12, 13, 14];  // Rusty Dagger, Club, Bone Claws, Fangs, Bandit Blade
equipped_weapon_id = enemy_weapon_ids[my_index % array_length(enemy_weapon_ids)];

// Update combat stats with weapon (this sets weapon_damage_dice, etc.)
update_combat_stats();

// Enemy-specific properties
enemy_type = "Goblin";

// XP value when killed (varies by enemy type) - Increased for faster testing
var xp_values = [60, 75, 50, 85, 40];  // XP for each enemy type  
xp_value = xp_values[my_index % array_length(xp_values)];

// === SPRITE ANIMATION SYSTEM ===
// Add sprite animation system like obj_Player
is_anim = false;
target_player = 0;

// Initialize enums (defined in scr_enums.gml)
scr_enums();

// Initialize sprite matrix based on character_index
// Default to character index based on enemy type if not set from IDE
global.combat_log(character_index);
if (character_index == 1) {  // If still default, set based on enemy type
    var enemy_char_indices = [1, 2, 3, 4, 5, 6];  // Different character sprites for each enemy type
    character_index = enemy_char_indices[my_index % array_length(enemy_char_indices)];
}

spr_matrix = init_character_sprite_matrix(character_index);

dir = Dir.DOWN;
anim_state = State.IDLE;
image_speed = 1.0;
