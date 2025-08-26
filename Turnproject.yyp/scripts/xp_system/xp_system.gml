// XP System and Character Progression Functions

// === ABILITY SCORE FUNCTIONS ===
function calculate_ability_modifier(ability_score) {
    // D&D 5e ability modifier calculation
    return floor((ability_score - 10) / 2);
}

function update_ability_modifiers(character) {
    // Update all ability modifiers based on current scores
    character.str_mod = calculate_ability_modifier(character.strength);
    character.dex_mod = calculate_ability_modifier(character.dexterity);
    character.con_mod = calculate_ability_modifier(character.constitution);
    character.int_mod = calculate_ability_modifier(character.intelligence);
    character.wis_mod = calculate_ability_modifier(character.wisdom);
    character.cha_mod = calculate_ability_modifier(character.charisma);
}

function get_proficiency_bonus(level) {
    // D&D 5e proficiency bonus progression
    if (level >= 17) return 6;
    if (level >= 13) return 5;
    if (level >= 9) return 4;
    if (level >= 5) return 3;
    return 2;
}

function gain_xp(character, xp_amount) {
    // Add XP (never subtract - always accumulating)
    character.xp += xp_amount;
    
    // Calculate new level based on total XP
    var old_level = character.level;
    var new_level = get_level_from_xp(character.xp);
    
    // Check if level increased
    if (new_level > old_level) {
        // Process each level gained (handles multiple levels at once)
        while (character.level < new_level) {
            character.level++;
            
            // Update proficiency bonus based on new level
            var old_proficiency = character.proficiency_bonus;
            character.proficiency_bonus = get_proficiency_bonus(character.level);
            
            // Increase HP (using d8 hit die + CON modifier for players)
            var hp_gain = 5 + character.con_mod;  // Average of d8 (4.5 rounded up) + CON mod
            if (hp_gain < 1) hp_gain = 1;  // Minimum 1 HP per level
            
            character.max_hp += hp_gain;
            character.hp += hp_gain;  // Also heal when leveling
            
            // Check for Ability Score Improvement levels (4, 8, 12, 16, 20)
            var is_asi_level = (character.level % 4 == 0) && (character.level >= 4);
            
            // Update combat stats with new proficiency and abilities
            if (variable_instance_exists(character.id, "update_combat_stats")) {
                character.update_combat_stats();
            }
            
            // Log level up via event bus
            scr_log("*** " + character.character_name + " LEVEL UP! Now level " + string(character.level) + " ***");
            scr_log("HP +" + string(hp_gain) + " (total: " + string(character.max_hp) + ")");
            if (character.proficiency_bonus > old_proficiency) {
                scr_log("Proficiency bonus increased to +" + string(character.proficiency_bonus));
            }
            if (is_asi_level) {
                scr_log("Ability Score Improvement available! Press 'I' to allocate points.");
                // Mark character as needing ASI but don't auto-trigger overlay
                if (object_get_name(character.object_index) == "obj_Player") {
                    character.needs_asi = true;
                    scr_log(character.character_name + " needs ASI allocation - press 'I' when ready.");
                }
            }
            
            // NOTE: Auto-save on level up disabled - saves only happen from star map
            // Character progression is automatically synced to crew_roster after combat
            if (object_get_name(character.object_index) == "obj_Player") {
                show_debug_message("Level up completed - progression will be saved when returning to star map");
            }
        }
    }
    
    // Always update XP progress display info
    character.xp_to_next_level = get_xp_needed_for_next_level(character.xp);
}

// New function to distribute XP to entire party
function distribute_party_xp(xp_amount) {
    var player_count = instance_number(obj_Player);
    if (player_count == 0) return;
    
    // Divide XP among party members
    var xp_per_player = floor(xp_amount / player_count);
    
    scr_log("Party gains " + string(xp_amount) + " XP (" + string(xp_per_player) + " each, " + string(xp_amount) + " ÷ " + string(player_count) + ")");
    
    var players_leveled = [];
    var players_need_asi = [];
    
    // First pass: Give divided XP to all players and track who levels up
    for (var i = 0; i < player_count; i++) {
        var player_instance = instance_find(obj_Player, i);
        if (instance_exists(player_instance)) {
            var old_level = player_instance.level;
            gain_xp(player_instance, xp_per_player);
            
            scr_log(player_instance.character_name + " gains " + string(xp_per_player) + " XP!");
            
            // Track if this player leveled up and needs ASI
            if (player_instance.level > old_level) {
                array_push(players_leveled, player_instance);
                
                if (variable_instance_exists(player_instance, "needs_asi") && player_instance.needs_asi) {
                    array_push(players_need_asi, player_instance);
                }
            }
        }
    }
    
    // Second pass: Handle ASI overlays for players who need them
    if (array_length(players_need_asi) > 0) {
        // Show ASI overlay for the first player who needs it
        var ui_manager = instance_find(obj_UIManager, 0);
        if (ui_manager != noone) {
            scr_log("Auto-triggering ASI overlay for " + players_need_asi[0].character_name);
            ui_manager.show_level_up_overlay(players_need_asi[0]);
        }
        
        // Log message about other players needing ASI
        if (array_length(players_need_asi) > 1) {
            scr_log("Other party members also need ASI - use 'I' key to cycle through them.");
        }
    }
}

// === XP TABLE SYSTEM ===
// Global XP table for level progression (total XP needed to reach each level)
global.xp_table = [
    0,      // Level 1: 0 XP
    100,    // Level 2: 100 XP total
    220,    // Level 3: 220 XP total  
    364,    // Level 4: 364 XP total
    537,    // Level 5: 537 XP total
    744,    // Level 6: 744 XP total
    993,    // Level 7: 993 XP total
    1291,   // Level 8: 1291 XP total
    1649,   // Level 9: 1649 XP total
    2078,   // Level 10: 2078 XP total
    2594,   // Level 11: 2594 XP total
    3213,   // Level 12: 3213 XP total
    3956,   // Level 13: 3956 XP total
    4847,   // Level 14: 4847 XP total
    5916,   // Level 15: 5916 XP total
    7199,   // Level 16: 7199 XP total
    8739,   // Level 17: 8739 XP total
    10587,  // Level 18: 10587 XP total
    12804,  // Level 19: 12804 XP total
    15365   // Level 20: 15365 XP total
];

function get_level_from_xp(total_xp) {
    // Return the highest level achievable with given XP
    for (var i = array_length(global.xp_table) - 1; i >= 0; i--) {
        if (total_xp >= global.xp_table[i]) {
            return i + 1;  // Level is index + 1
        }
    }
    return 1;  // Minimum level 1
}

function get_xp_needed_for_level(target_level) {
    // Get total XP needed to reach a specific level
    if (target_level <= 1) return 0;
    if (target_level > array_length(global.xp_table)) {
        return global.xp_table[array_length(global.xp_table) - 1];
    }
    return global.xp_table[target_level - 1];
}

function get_xp_needed_for_next_level(current_xp) {
    // Get XP needed to reach the next level from current XP
    var current_level = get_level_from_xp(current_xp);
    var next_level = current_level + 1;
    
    if (next_level > array_length(global.xp_table)) {
        return 0;  // Max level reached
    }
    
    var xp_for_next = get_xp_needed_for_level(next_level);
    return xp_for_next - current_xp;
}

function calculate_xp_to_level(level) {
    // Legacy function - redirect to new system
    return get_xp_needed_for_level(level);
}

// === ABILITY SCORE IMPROVEMENT FUNCTIONS ===
function can_increase_ability_score(character) {
    // Check if character has unused ability score improvements
    var is_asi_level = (character.level % 4 == 0) && (character.level >= 4);
    if (!is_asi_level) return false;
    
    // Check if ASI has already been used for this level
    if (!variable_instance_exists(character, "last_asi_level")) {
        character.last_asi_level = 0;
    }
    
    return (character.level > character.last_asi_level);
}

function increase_ability_score(character, ability_name, amount) {
    // Increase a specific ability score and update modifiers
    amount = clamp(amount, 1, 2);  // Only allow +1 or +2 increases
    
    switch(ability_name) {
        case "strength":
            character.strength = min(20, character.strength + amount);
            break;
        case "dexterity": 
            character.dexterity = min(20, character.dexterity + amount);
            break;
        case "constitution":
            var old_con_mod = character.con_mod;
            character.constitution = min(20, character.constitution + amount);
            update_ability_modifiers(character);
            
            // Retroactively adjust HP if CON modifier increased
            var new_con_mod = character.con_mod;
            if (new_con_mod > old_con_mod) {
                var hp_bonus = (new_con_mod - old_con_mod) * character.level;
                character.max_hp += hp_bonus;
                character.hp += hp_bonus;
                if (variable_global_exists("combat_log")) {
                    global.combat_log(character.character_name + " gains " + string(hp_bonus) + " HP from increased Constitution!");
                }
            }
            break;
        case "intelligence":
            character.intelligence = min(20, character.intelligence + amount);
            break;
        case "wisdom":
            character.wisdom = min(20, character.wisdom + amount);
            break;
        case "charisma":
            character.charisma = min(20, character.charisma + amount);
            break;
    }
    
    // Update ability modifiers and combat stats
    update_ability_modifiers(character);
    if (variable_instance_exists(character, "update_combat_stats")) {
        character.update_combat_stats();
    }
    
    // Mark that ASI has been used for this level
    character.last_asi_level = character.level;
}
