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
    character.xp += xp_amount;
    
    // Check for level up
    while (character.xp >= character.xp_to_next_level) {
        character.xp -= character.xp_to_next_level;
        var old_level = character.level;
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
        
        // Increase XP needed for next level
        character.xp_to_next_level = floor(character.xp_to_next_level * 1.2);
        
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
        
        // Auto-save after level up if it's a player character (emit event)
        if (object_get_name(character.object_index) == "obj_Player") {
            // emit autosave; fallback if event bus fails
            try {
                scr_event_emit("autosave", { reason: "level_up", character: character.id });
            } catch (e) {
                try { auto_save_game(); } catch (e2) { show_debug_message("Auto-save after level up failed: " + string(e2)); }
            }
        }
    }
}

// New function to distribute XP to entire party
function distribute_party_xp(xp_amount) {
    var player_count = instance_number(obj_Player);
    
    scr_log("Party gains " + string(xp_amount) + " XP (" + string(xp_amount) + " ÷ " + string(player_count) + " each)");
    
    var players_leveled = [];
    var players_need_asi = [];
    
    // First pass: Give XP to all players and track who levels up
    for (var i = 0; i < player_count; i++) {
        var player_instance = instance_find(obj_Player, i);
        if (instance_exists(player_instance)) {
            var old_level = player_instance.level;
            gain_xp(player_instance, xp_amount);
            
            scr_log(player_instance.character_name + " gains " + string(xp_amount) + " XP!");
            
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

function calculate_xp_to_level(level) {
    // Calculate total XP needed to reach a specific level
    var total_xp = 0;
    var base_xp = 100;
    for (var i = 1; i < level; i++) {
        total_xp += base_xp;
        base_xp = floor(base_xp * 1.2);
    }
    return total_xp;
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
