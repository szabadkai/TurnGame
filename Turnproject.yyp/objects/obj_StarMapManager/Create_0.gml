// obj_StarMapManager Create Event
// Initialize and coordinate star map systems

// Initialize global star map state if it doesn't exist
if (!variable_global_exists("star_map_state")) {
    init_star_map();
}

// System management
star_systems = [];
current_system_id = "system_001"; // Default starting system
tooltip_manager = noone;

// Create essential UI components
create_star_map_ui();

// Load saved progress BEFORE creating systems
load_saved_star_map_progress();

// Wait a frame to ensure global state is fully loaded before creating systems
alarm[0] = 1; // Create systems after 1 frame delay

show_debug_message("StarMapManager initialization deferred to Alarm[0]");

// Create essential UI components
function create_star_map_ui() {
    // Create tooltip manager if it doesn't exist
    if (!instance_exists(obj_TooltipManager)) {
        tooltip_manager = instance_create_layer(0, 0, "UI", obj_TooltipManager);
    } else {
        tooltip_manager = instance_find(obj_TooltipManager, 0);
    }
    
    // Travel confirmation dialog will be created on demand by StarSystem objects
}

// Load star map data and create system instances
function load_and_create_systems() {
    // For now, create systems with hardcoded positions
    // This will be replaced with JSON loading later
    var system_data = [
        // Positioned at exact starmap locations
        {id: "system_001", name: "Sol Approach", type: "Deep Space", x: 299, y: 188, scene: "scene_001_prometheus_discovery", unlocked: true},
        {id: "system_002", name: "Keth'mori Threshold", type: "Boundary Space", x: 362, y: 159, scene: "scene_002_keth_mori_threshold", unlocked: false},
        {id: "system_003", name: "Pirate Sector", type: "Contested Zone", x: 422, y: 226, scene: "scene_003_pirate_ambush", unlocked: false},
        {id: "system_004", name: "Ancient Ruins", type: "Archaeological Site", x: 506, y: 201, scene: "scene_004_alien_glyphs", unlocked: false},
        {id: "system_005", name: "Watcher Station", type: "Observation Post", x: 591, y: 147, scene: "scene_005_watchers_blockade", unlocked: false},
        {id: "system_006", name: "Loop Nexus", type: "Anomaly", x: 682, y: 180, scene: "scene_006_loop_discovery", unlocked: false},
        {id: "system_007", name: "Crystal Fields", type: "Resource Zone", x: 635, y: 234, scene: "scene_007_crystal_guardian", unlocked: false},
        {id: "system_008", name: "Earth Command", type: "Military Base", x: 707, y: 273, scene: "scene_008_earth_debrief_victory", unlocked: false},
        {id: "system_009", name: "Broken Worlds", type: "Devastated System", x: 558, y: 281, scene: "scene_015_derelict_satellite", unlocked: false},
        {id: "system_010", name: "Final Gateway", type: "Terminus", x: 365, y: 295, scene: "scene_035_retribution_echoes", unlocked: false}
    ];
    
    star_systems = [];
    
    show_debug_message("Creating " + string(array_length(system_data)) + " star systems...");
    
    for (var i = 0; i < array_length(system_data); i++) {
        var data = system_data[i];
        
        show_debug_message("Creating system " + string(i+1) + ": " + data.name + " at (" + string(data.x) + "," + string(data.y) + ")");
        
        var system = instance_create_layer(data.x, data.y, "StarSystems", obj_StarSystem);
        
        if (system == noone) {
            show_debug_message("ERROR: Failed to create star system instance!");
            continue;
        }
        
        // Set system properties
        system.system_id = data.id;
        system.system_name = data.name;
        system.system_type = data.type;
        system.target_scene = data.scene;
        
        // Check if we have saved state for this system
        var saved_unlocked = data.unlocked; // Default from data
        
        if (variable_global_exists("star_map_state") && variable_struct_exists(global.star_map_state, "systems")) {
            if (variable_struct_exists(global.star_map_state.systems, data.id)) {
                saved_unlocked = global.star_map_state.systems[$ data.id].unlocked;
                show_debug_message("System " + data.id + " using saved unlock state: " + string(saved_unlocked));
            }
        }
        
        system.is_unlocked = saved_unlocked;
        system.faction_control = 0; // Will be set by save data
        system.threat_level = 1 + (i % 5); // Varied threat levels
        
        show_debug_message("  - System ID: " + system.system_id + ", Unlocked: " + string(system.is_unlocked));
        
        // Update visual state
        system.update_visual_state();
        
        array_push(star_systems, system);
    }
    
    show_debug_message("Successfully created " + string(array_length(star_systems)) + " star systems");
    show_debug_message("Total obj_StarSystem instances in room: " + string(instance_number(obj_StarSystem)));
}

// Apply saved star map state
function apply_star_map_state() {
    if (variable_global_exists("star_map_state")) {
        var state = global.star_map_state;
        
        // Set current system
        if (variable_struct_exists(state, "current_system")) {
            current_system_id = state.current_system;
        }
        
        // Apply system states
        if (variable_struct_exists(state, "systems")) {
            var systems_state = state.systems;
            
            for (var i = 0; i < array_length(star_systems); i++) {
                var system = star_systems[i];
                
                if (variable_struct_exists(systems_state, system.system_id)) {
                    var system_state = systems_state[$ system.system_id];
                    
                    system.is_unlocked = system_state.unlocked;
                    system.is_visited = system_state.visited;
                    system.is_current = (system.system_id == current_system_id);
                    system.faction_control = system_state.faction_control;
                    
                    system.update_visual_state();
                }
            }
        }
    }
}

// Mark a system as visited
function mark_system_visited(system_id) {
    if (variable_global_exists("star_map_state")) {
        var state = global.star_map_state;
        
        if (!variable_struct_exists(state, "systems")) {
            state.systems = {};
        }
        
        if (!variable_struct_exists(state.systems, system_id)) {
            state.systems[$ system_id] = {
                unlocked: false,
                visited: false,
                faction_control: 0
            };
        }
        
        state.systems[$ system_id].visited = true;
    }
    
    show_debug_message("Marked system as visited: " + system_id);
}

// Set current system location
function set_current_system(system_id) {
    // Update previous current system
    for (var i = 0; i < array_length(star_systems); i++) {
        star_systems[i].is_current = false;
    }
    
    // Set new current system
    current_system_id = system_id;
    var current_system = find_system_by_id(system_id);
    if (current_system != noone) {
        current_system.is_current = true;
        current_system.update_visual_state();
    }
    
    // Save to global state
    if (variable_global_exists("star_map_state")) {
        global.star_map_state.current_system = system_id;
    }
    
    show_debug_message("Set current system to: " + system_id);
}

// Find system instance by ID
function find_system_by_id(system_id) {
    for (var i = 0; i < array_length(star_systems); i++) {
        if (star_systems[i].system_id == system_id) {
            return star_systems[i];
        }
    }
    return noone;
}

// Unlock system for exploration
function unlock_system(system_id) {
    var system = find_system_by_id(system_id);
    if (system != noone) {
        system.is_unlocked = true;
        system.update_visual_state();
        
        // Save to global state
        if (variable_global_exists("star_map_state")) {
            var state = global.star_map_state;
            
            if (!variable_struct_exists(state, "systems")) {
                state.systems = {};
            }
            
            if (!variable_struct_exists(state.systems, system_id)) {
                state.systems[$ system_id] = {
                    unlocked: false,
                    visited: false,
                    faction_control: 0
                };
            }
            
            state.systems[$ system_id].unlocked = true;
        }
        
        show_debug_message("Unlocked system: " + system_id);
        return true;
    }
    return false;
}

// Load saved star map progress from active save slot
function load_saved_star_map_progress() {
    show_debug_message("StarMapManager: Checking for saved progress...");
    
    // Use active save slot instead of hardcoded slot 0
    var slot_to_use = variable_global_exists("active_save_slot") ? global.active_save_slot : 1;
    var save_file = "save_slot_" + string(slot_to_use) + ".sav";
    
    // Always try to load if save exists, regardless of flag
    if (file_exists(save_file)) {
        show_debug_message("Found auto-save file, loading star map progress...");
        
        try {
            var file = file_text_open_read(save_file);
            var json_string = "";
            while (!file_text_eof(file)) {
                json_string += file_text_readln(file);
            }
            file_text_close(file);
            
            if (json_string != "") {
                var save_data = json_parse(json_string);
                
                // Apply star map state if it exists
                if (variable_struct_exists(save_data, "star_map_state")) {
                    global.star_map_state = save_data.star_map_state;
                    show_debug_message("Star map progress loaded successfully");
                    
                    // Debug: show unlocked systems
                    if (variable_struct_exists(global.star_map_state, "systems")) {
                        var systems = global.star_map_state.systems;
                        var system_ids = variable_struct_get_names(systems);
                        show_debug_message("Loaded systems state:");
                        for (var i = 0; i < array_length(system_ids); i++) {
                            var sys_id = system_ids[i];
                            var unlocked = systems[$ sys_id].unlocked;
                            show_debug_message("  - " + sys_id + ": unlocked=" + string(unlocked));
                        }
                    }
                } else {
                    show_debug_message("No star map state found in save file");
                }
                
                // Apply dialog flags for progression logic
                if (variable_struct_exists(save_data, "story_flags")) {
                    global.dialog_flags = save_data.story_flags;
                    show_debug_message("Dialog flags loaded for progression");
                }
            }
        } catch (e) {
            show_debug_message("Failed to load saved progress: " + string(e));
        }
    } else {
        show_debug_message("No auto-save file found - starting fresh");
    }
    
    // Reset the flag if it exists
    if (variable_global_exists("should_load_star_map_state")) {
        global.should_load_star_map_state = false;
    }
}