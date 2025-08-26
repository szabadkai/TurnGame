// Save/Load System for Turn Project

// Helper: build save file path (under working_directory/saves)
function get_save_file_path(slot_index) {
    var save_dir = "saves";
    return save_dir + "/save_slot_" + string(slot_index) + ".sav";
}

// Helper: get persistent base dir outside temp working_directory (best-effort)
function get_persistent_base_dir() {
    var base = "";
    try {
        switch (os_type) {
            case os_macosx:
                var home = environment_get_variable("HOME");
                base = home + "/Library/Application Support/Turnproject";
                break;
            case os_windows:
                var appdata = environment_get_variable("LOCALAPPDATA");
                if (appdata == "") appdata = environment_get_variable("APPDATA");
                base = appdata + "\\Turnproject";
                break;
            case os_linux:
                var homeL = environment_get_variable("HOME");
                base = homeL + "/.local/share/Turnproject";
                break;
            default:
                base = "";
        }
    } catch (e) {
        base = "";
    }
    return base;
}

// Helper: build persistent save file path
function get_persistent_save_file_path(slot_index) {
    var base = get_persistent_base_dir();
    if (base == "") return "";
    var sep = string_copy(base, string_length(base), 1) == "/" || string_copy(base, string_length(base), 1) == "\\" ? "" : (os_type == os_windows ? "\\" : "/");
    return base + sep + "save_slot_" + string(slot_index) + ".sav";
}

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
    
    // Ensure saves directory exists
    var save_dir = "saves";
    if (!directory_exists(save_dir)) {
        directory_create(save_dir);
    }
    
    var save_file = get_save_file_path(slot_index);
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
    if (file == -1) {
        var abs_path_fail = working_directory + save_file;
        show_debug_message("ERROR: Failed to open save file for write: " + save_file);
        show_debug_message("Working directory: " + working_directory + ", program directory: " + program_directory);
        show_debug_message("Write check: exists(rel)=" + string(file_exists(save_file)) + ", exists(abs)=" + string(file_exists(abs_path_fail)));
        return false;
    }
    file_text_write_string(file, json_string);
    file_text_close(file);
    
    // Best-effort persistent copy outside temp runner path
    var persistent_path = get_persistent_save_file_path(slot_index);
    if (persistent_path != "") {
        // Ensure persistent directory exists
        var dir = filename_dir(persistent_path);
        show_debug_message("Persistent directory: " + dir + " (exists: " + string(directory_exists(dir)) + ")");
        
        if (!directory_exists(dir)) {
            show_debug_message("Creating persistent directory: " + dir);
            var created = directory_create(dir);
            show_debug_message("Directory creation result: " + string(created) + " (now exists: " + string(directory_exists(dir)) + ")");
        }
        
        if (directory_exists(dir)) {
            var f2 = file_text_open_write(persistent_path);
            if (f2 != -1) {
                file_text_write_string(f2, json_string);
                file_text_close(f2);
                show_debug_message("Persistent save location: " + persistent_path + " (exists: " + string(file_exists(persistent_path)) + ")");
            } else {
                show_debug_message("ERROR: Could not open persistent save file for write: " + persistent_path);
            }
        } else {
            show_debug_message("ERROR: Could not create persistent directory: " + dir);
        }
    } else {
        show_debug_message("WARNING: No persistent path available for slot " + string(slot_index));
    }
    
    // Log absolute save file location immediately for easier debugging
    var full_path = working_directory + save_file;
    show_debug_message("Game saved to slot " + string(slot_index));
    show_debug_message("Save file location (relative): " + save_file + " (exists: " + string(file_exists(save_file)) + ")");
    show_debug_message("Save file location (absolute): " + full_path + " (exists: " + string(file_exists(full_path)) + ")");
    
    // Immediately attempt to open and print a preview of the saved content
    debug_dump_save_file(slot_index);
    return true;
}

// Load game data from specified slot
function load_game_from_slot_data(slot_index) {
    // Check both persistent and temp locations
    var persistent_path = get_persistent_save_file_path(slot_index);
    var temp_path = get_save_file_path(slot_index);
    var save_file = "";
    
    if (persistent_path != "" && file_exists(persistent_path)) {
        save_file = persistent_path;
        show_debug_message("Loading slot " + string(slot_index) + " from persistent: " + persistent_path);
    } else if (file_exists(temp_path)) {
        save_file = temp_path;
        show_debug_message("Loading slot " + string(slot_index) + " from temp: " + temp_path);
    } else {
        show_debug_message("No save file found for slot " + string(slot_index) + " - checked persistent: " + persistent_path + ", temp: " + temp_path);
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
    global.should_load_star_map_state = true;  // Ensure star map reloads on subsequent loads
    
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
    var persistent_path = get_persistent_save_file_path(slot_index);
    var temp_path = get_save_file_path(slot_index);
    var save_file = "";
    
    // Check both locations and use whichever exists
    if (persistent_path != "" && file_exists(persistent_path)) {
        save_file = persistent_path;
        show_debug_message("Slot " + string(slot_index) + " using persistent: " + persistent_path);
    } else if (file_exists(temp_path)) {
        save_file = temp_path;
        show_debug_message("Slot " + string(slot_index) + " using temp: " + temp_path);
    } else {
        show_debug_message("Slot " + string(slot_index) + " empty - checked persistent: " + persistent_path + ", temp: " + temp_path);
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
    var deleted = false;
    var save_file = get_save_file_path(slot_index);
    if (file_exists(save_file)) { file_delete(save_file); deleted = true; }
    var persistent_path = get_persistent_save_file_path(slot_index);
    if (persistent_path != "" && file_exists(persistent_path)) { file_delete(persistent_path); deleted = true; }
    if (deleted) { show_debug_message("Deleted save slot " + string(slot_index)); return true; }
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

// DEBUG: Immediately open and print contents of a save slot (first 512 chars)
function debug_dump_save_file(slot_index) {
    var persistent_path = get_persistent_save_file_path(slot_index);
    var rel_path = get_save_file_path(slot_index);
    var abs_rel = working_directory + rel_path;
    
    show_debug_message("=== DEBUG DUMP SAVE SLOT " + string(slot_index) + " ===");
    show_debug_message("Working directory: " + working_directory);
    show_debug_message("Program directory: " + program_directory);
    
    // Candidate order: persistent (if exists), then relative
    var candidates = [];
    if (persistent_path != "") { array_push(candidates, persistent_path); }
    array_push(candidates, rel_path);
    
    var dumped = false;
    for (var i = 0; i < array_length(candidates); i++) {
        var path = candidates[i];
        var exists = file_exists(path);
        show_debug_message("Candidate: " + path + " exists=" + string(exists));
        if (exists) {
            var f = file_text_open_read(path);
            if (f != -1) {
                var content = "";
                var read_count = 0;
                while (!file_text_eof(f)) {
                    var line = file_text_readln(f);
                    content += line;
                    read_count += string_length(line);
                    if (read_count > 2048) break; // hard cap to protect logs
                }
                file_text_close(f);
                var preview_len = min(512, string_length(content));
                var preview = string_copy(content, 1, preview_len);
                show_debug_message("File size (read portion): ~" + string(read_count) + " bytes");
                show_debug_message("Preview (first " + string(preview_len) + "):\n" + preview);
                dumped = true;
                break;
            } else {
                show_debug_message("ERROR: Failed to open candidate for read: " + path);
            }
        }
    }
    
    if (!dumped) {
        show_debug_message("DEBUG DUMP: No candidate files found to read.");
        show_debug_message("Check rel abs path exists=" + string(file_exists(abs_rel)) + ": " + abs_rel);
    }
    
    show_debug_message("=== END DEBUG DUMP ===");
}
