// Inherit shared combat entity properties
event_inherited();

// Character name will be set by TurnManager spawn_landing_party() function
// Default fallback name in case not set by crew system
if (!variable_instance_exists(id, "character_name") || character_name == "Unknown") {
    character_name = "Crew Member";
}

// Crew ID for linking back to crew roster (set by TurnManager)
if (!variable_instance_exists(id, "crew_id")) {
    crew_id = "";
}

// Portrait sprite reference (optional; set by TurnManager if available)
portrait_sprite = -1;

// === ABILITY SCORES ===
// Default ability scores (overridden by crew system when spawned via TurnManager)
strength = 10;
dexterity = 10;
constitution = 10;
intelligence = 10;
wisdom = 10;
charisma = 10;

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

state = TURNSTATE.inactive;
frozen_turns = 0;
burn_turns = 0;
damage_flash = 0;

// Initialize weapons and update stats
init_weapons();
update_combat_stats();

is_anim = false;
target_enemy = 0;

// Initialize enums (defined in scr_enums.gml)
scr_enums();

// Initialize sprite matrix based on character_index and weapon type
spr_matrix = init_character_sprite_matrix(character_index, weapon_special_type);

dir = Dir.DOWN;
anim_state = State.IDLE;
image_speed = 1.0;
