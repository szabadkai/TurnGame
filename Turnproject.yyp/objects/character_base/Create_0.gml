// === SHARED COMBAT ENTITY PROPERTIES ===
// This base class contains all common properties for Player and Enemy objects

// Character identity
character_name = "Unknown";  // Will be overridden in child objects


// Experience system
xp = 0;
level = 1;
xp_to_next_level = 100;  // XP needed for next level

// === ABILITY SCORES SYSTEM ===
// Core D&D ability scores (will be overridden in child objects)
strength = 10;
dexterity = 10;
constitution = 10;
intelligence = 10;
wisdom = 10;
charisma = 10;

// Ability modifiers (calculated from scores)
str_mod = 0;
dex_mod = 0;
con_mod = 0;
int_mod = 0;
wis_mod = 0;
cha_mod = 0;

// Proficiency bonus (based on level)
proficiency_bonus = 2;

// Ability Score Improvement tracking
last_asi_level = 0;  // Track last level where ASI was used
needs_asi = false;   // Flag to track if character needs ASI allocation

// Turn system
state = TURNSTATE.inactive;
max_moves = 0;  // Will be overridden in child objects
moves = 0;

// Health system
hp = 1;         // Will be overridden in child objects
max_hp = 1;     // Will be overridden in child objects
last_hp = hp;   // For damage flash detection

// Combat stats (calculated from ability scores, proficiency, and weapons)
attack_bonus = 0;        // Will be: proficiency_bonus + str_mod/dex_mod + weapon_attack_bonus  
damage_modifier = 0;     // Will be: str_mod/dex_mod + weapon_damage_modifier
defense_score = 10;      // Will be: base_armor_class + dex_mod + other bonuses

// Base combat values (for calculation)
base_armor_class = 10;   // Base AC before modifiers

// Weapon properties (used by combat system)
weapon_name = "None";
weapon_special_type = "none";

// Status effects
frozen_turns = 0;
burn_turns = 0;

// Visual effects
damage_flash = 0;

