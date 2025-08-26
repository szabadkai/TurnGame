// Save/Load System for Turn Project

// Save game data to specified slot
function save_game_to_slot(slot_index, is_auto_save = false) {
    // Manual saves only allowed from star map, auto-saves allowed from safe contexts
    if (!is_auto_save && room != Room_StarMap) {
        show_debug_message("Manual save blocked - saves only allowed from star map screen");
        return false;
    }
    
    if (is_auto_save && room != Room_StarMap && instance_number(obj_Enemy) > 0) {
        show_debug_message("Auto-save blocked - enemies present in combat");
        return false;
    }
    
    var save_file = "save_slot_" + string(slot_index) + ".sav";
    var save_data = {};
    
    // NOTE: Individual player data removed - all character progression stored in crew_roster
    // This ensures saves are independent of combat state and always load to star map
    
    // Collect game state (no room info - always loads to star map)
    save_data.game_state = {
        save_version: 1,
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
    
    // Collect crew data if it exists
    if (variable_global_exists("crew")) {
        save_data.crew = global.crew;
    }
    
    // Collect crew roster data (persistent character progression)
    if (variable_global_exists("crew_roster")) {
        save_data.crew_roster = global.crew_roster;
    }
    
    // NOTE: Enemy states not saved - battles reset when entering combat
    // This creates fresh encounters while preserving character progression
    
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
    
    // Use navigation system to go to the game
    // Set up a callback to restore state after room loads
    global.pending_save_data = save_data;
    global.loading_save = true;
    
    // Always navigate to star map - saves are checkpoint-based, not mid-combat
    scr_nav_go(GameState.STARMAP, undefined);
    
    show_debug_message("Game loaded from slot " + string(slot_index));
    return true;
}

// Apply loaded save data (called after room loads)
function apply_loaded_save_data() {
    if (!variable_global_exists("pending_save_data") || !global.loading_save) {
        return;
    }
    
    var save_data = global.pending_save_data;
    
    // Check if save_data is valid
    if (save_data == undefined || !is_struct(save_data)) {
        show_debug_message("Invalid save data structure");
        return;
    }
    
    // NOTE: Individual player data no longer restored from saves
    // All character progression now comes from crew_roster system
    // Players are spawned fresh and get data from crew when entering combat
    
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
    
    // Restore crew data
    if (variable_struct_exists(save_data, "crew")) {
        global.crew = save_data.crew;
    }
    
    // Restore crew roster data (persistent character progression)
    if (variable_struct_exists(save_data, "crew_roster")) {
        global.crew_roster = save_data.crew_roster;
    }
    
    // Restore enemies (remove current enemies and create saved ones)
    // NOTE: Enemy states no longer restored - battles are fresh encounters
    // Enemies will be created by the respective combat rooms as needed
    
    global.pending_save_data = undefined;
    global.loading_save = false;
    
    show_debug_message("Save data applied successfully");
}

// Auto-save functionality
function auto_save_game() {
    if (global.game_settings.auto_save) {
        save_game_to_slot(0, true); // Use slot 0 for auto-save, mark as auto-save
        show_debug_message("Auto-save attempt made");
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
    // Only auto-save when on star map (not during combat)
    if (room != Room_StarMap) {
        return;
    }
    
    // Auto-save when returning to star map with crew progression
    if (variable_global_exists("crew_roster") && global.crew_roster != undefined) {
        // Check if any crew members have gained XP/levels that warrant saving
        for (var i = 0; i < array_length(global.crew_roster); i++) {
            var crew_member = global.crew_roster[i];
            if (crew_member.xp > 0) {  // Any progression worth saving
                show_debug_message("Auto-saving crew progression on star map");
                auto_save_game();
                return;
            }
        }
    }
}
