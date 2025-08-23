// Save/Load System for Turn Project

// Save game data to specified slot
function save_game_to_slot(slot_index) {
    var save_file = "save_slot_" + string(slot_index) + ".sav";
    var save_data = {};
    
    // Collect player data
    var player = instance_find(obj_Player, 0);
    if (player != noone) {
        save_data.player = {
            x: player.x,
            y: player.y,
            level: variable_instance_exists(player, "level") ? player.level : 1,
            xp: variable_instance_exists(player, "xp") ? player.xp : 0,
            ability_scores: {
                strength: variable_instance_exists(player, "strength") ? player.strength : 10,
                dexterity: variable_instance_exists(player, "dexterity") ? player.dexterity : 10,
                constitution: variable_instance_exists(player, "constitution") ? player.constitution : 10,
                intelligence: variable_instance_exists(player, "intelligence") ? player.intelligence : 10,
                wisdom: variable_instance_exists(player, "wisdom") ? player.wisdom : 10,
                charisma: variable_instance_exists(player, "charisma") ? player.charisma : 10
            },
            hp: variable_instance_exists(player, "hp") ? player.hp : 100,
            max_hp: variable_instance_exists(player, "max_hp") ? player.max_hp : 100,
            current_weapon: variable_instance_exists(player, "current_weapon") ? player.current_weapon : 0,
            character_index: variable_instance_exists(player, "character_index") ? player.character_index : 1
        };
    }
    
    // Collect game state
    save_data.game_state = {
        save_version: 1,
        current_room: room,
        save_time: date_current_datetime(),
        play_time: get_timer() / 1000000, // Convert to seconds
        difficulty: global.game_settings.difficulty
    };
    
    // Collect story/dialog flags if they exist
    if (variable_global_exists("dialog_flags")) {
        save_data.story_flags = global.dialog_flags;
    }
    
    if (variable_global_exists("dialog_reputation")) {
        save_data.reputation = global.dialog_reputation;
    }
    
    if (variable_global_exists("loop_count")) {
        save_data.loop_count = global.loop_count;
    }
    
    // Collect star map state if it exists
    if (variable_global_exists("star_map_state")) {
        save_data.star_map_state = get_star_map_save_data();
    }
    
    // Save enemy states (for persistent encounters)
    save_data.enemies = [];
    var enemy_count = instance_number(obj_Enemy);
    for (var i = 0; i < enemy_count; i++) {
        var enemy = instance_find(obj_Enemy, i);
        if (enemy != noone) {
            var enemy_data = {
                x: enemy.x,
                y: enemy.y,
                hp: enemy.hp,
                max_hp: enemy.max_hp,
                character_index: enemy.character_index,
                is_dead: (enemy.hp <= 0)
            };
            array_push(save_data.enemies, enemy_data);
        }
    }
    
    // Convert to JSON and save
    var json_string = json_stringify(save_data);
    var file = file_text_open_write(save_file);
    file_text_write_string(file, json_string);
    file_text_close(file);
    
    show_debug_message("Game saved to slot " + string(slot_index));
    return true;
}

// Load game data from specified slot
function load_game_from_slot_data(slot_index) {
    var save_file = "save_slot_" + string(slot_index) + ".sav";
    
    if (!file_exists(save_file)) {
        show_debug_message("Save file does not exist: " + save_file);
        return false;
    }
    
    // Read save file
    var file = file_text_open_read(save_file);
    var json_string = "";
    while (!file_text_eof(file)) {
        json_string += file_text_readln(file);
    }
    file_text_close(file);
    
    if (json_string == "") {
        show_debug_message("Save file is empty: " + save_file);
        return false;
    }
    
    // Parse JSON
    var save_data;
    try {
        save_data = json_parse(json_string);
    } catch (e) {
        show_debug_message("Failed to parse save file: " + string(e));
        return false;
    }
    
    // Version check/migration hook
    var _version = 0;
    if (variable_struct_exists(save_data, "game_state") && variable_struct_exists(save_data.game_state, "save_version")) {
        _version = save_data.game_state.save_version;
    }
    if (_version < 1) {
        show_debug_message("Migrating save data to v1 schema");
        // no-op for now
    }
    
    // Go to the saved room first
    if (variable_struct_exists(save_data, "game_state") && 
        variable_struct_exists(save_data.game_state, "current_room")) {
        room_goto(save_data.game_state.current_room);
        
        // Set up a callback to restore state after room loads
        global.pending_save_data = save_data;
        global.loading_save = true;
    }
    
    show_debug_message("Game loaded from slot " + string(slot_index));
    return true;
}

// Apply loaded save data (called after room loads)
function apply_loaded_save_data() {
    if (!variable_global_exists("pending_save_data") || !global.loading_save) {
        return;
    }
    
    var save_data = global.pending_save_data;
    
    // Restore player data
    if (variable_struct_exists(save_data, "player")) {
        var player = instance_find(obj_Player, 0);
        if (player != noone) {
            player.x = save_data.player.x;
            player.y = save_data.player.y;
            player.level = save_data.player.level;
            player.xp = save_data.player.xp;
            
            if (variable_struct_exists(save_data.player, "ability_scores")) {
                player.strength = save_data.player.ability_scores.strength;
                player.dexterity = save_data.player.ability_scores.dexterity;
                player.constitution = save_data.player.ability_scores.constitution;
                player.intelligence = save_data.player.ability_scores.intelligence;
                player.wisdom = save_data.player.ability_scores.wisdom;
                player.charisma = save_data.player.ability_scores.charisma;
            }
            
            player.hp = save_data.player.hp;
            player.max_hp = save_data.player.max_hp;
            player.current_weapon = save_data.player.current_weapon;
            player.character_index = save_data.player.character_index;
            
            // Update character sprite
            init_character_sprite_matrix(player.character_index);
            update_combat_stats(player);
        }
    }
    
    // Restore story flags
    if (variable_struct_exists(save_data, "story_flags")) {
        global.dialog_flags = save_data.story_flags;
    }
    
    if (variable_struct_exists(save_data, "reputation")) {
        global.dialog_reputation = save_data.reputation;
    }
    
    if (variable_struct_exists(save_data, "loop_count")) {
        global.loop_count = save_data.loop_count;
    }
    
    // Restore star map state
    if (variable_struct_exists(save_data, "star_map_state")) {
        apply_star_map_save_data(save_data.star_map_state);
    }
    
    // Restore enemies (remove current enemies and create saved ones)
    if (variable_struct_exists(save_data, "enemies")) {
        // Remove existing enemies
        with (obj_Enemy) {
            instance_destroy();
        }
        
        // Create saved enemies
        for (var i = 0; i < array_length(save_data.enemies); i++) {
            var enemy_data = save_data.enemies[i];
            if (!enemy_data.is_dead) {
                var enemy = instance_create_layer(enemy_data.x, enemy_data.y, "Instances", obj_Enemy);
                enemy.hp = enemy_data.hp;
                enemy.max_hp = enemy_data.max_hp;
                enemy.character_index = enemy_data.character_index;
                
                // Initialize enemy sprite
                init_character_sprite_matrix(enemy.character_index);
            }
        }
    }
    
    // Clean up
    global.pending_save_data = undefined;
    global.loading_save = false;
    
    show_debug_message("Save data applied successfully");
}

// Auto-save functionality
function auto_save_game() {
    if (global.game_settings.auto_save) {
        save_game_to_slot(0); // Use slot 0 for auto-save
        show_debug_message("Auto-save completed");
    }
}

// Get save slot display info
function get_save_slot_info_detailed(slot_index) {
    var save_file = "save_slot_" + string(slot_index) + ".sav";
    
    if (!file_exists(save_file)) {
        return "Empty";
    }
    
    // Read save file
    var file = file_text_open_read(save_file);
    var json_string = "";
    while (!file_text_eof(file)) {
        json_string += file_text_readln(file);
    }
    file_text_close(file);
    
    if (json_string == "") {
        return "Corrupted";
    }
    
    // Parse JSON
    var save_data;
    try {
        save_data = json_parse(json_string);
    } catch (e) {
        return "Corrupted";
    }
    
    // Extract info
    var info = "";
    
    if (variable_struct_exists(save_data, "player")) {
        info += "Level " + string(save_data.player.level);
    }
    
    if (variable_struct_exists(save_data, "game_state") && 
        variable_struct_exists(save_data.game_state, "save_time")) {
        var save_time = save_data.game_state.save_time;
        info += " - " + date_datetime_string(save_time);
    }
    
    if (variable_struct_exists(save_data, "game_state") &&
        variable_struct_exists(save_data.game_state, "save_version")) {
        info += " (v" + string(save_data.game_state.save_version) + ")";
    }
    
    return info != "" ? info : "Unknown";
}

// Delete save slot
function delete_save_slot(slot_index) {
    var save_file = "save_slot_" + string(slot_index) + ".sav";
    if (file_exists(save_file)) {
        file_delete(save_file);
        show_debug_message("Deleted save slot " + string(slot_index));
        return true;
    }
    return false;
}

// Check for auto-save opportunities
function check_auto_save_triggers() {
    // Auto-save after level up
    var player = instance_find(obj_Player, 0);
    if (player != noone && player.asis_available) {
        auto_save_game();
    }
    
    // Auto-save after combat (when no enemies remain)
    if (instance_number(obj_Enemy) == 0 && instance_number(obj_Player) > 0) {
        auto_save_game();
    }
}
