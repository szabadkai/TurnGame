// Star Map System Functions
// Core functionality for managing star map state and progression
// Combined core system with data configuration for proper GameMaker registration

// Initialize the star map system (backwards compatible)
function init_star_map() {
    show_debug_message("Initializing star map system");
    
    // Initialize global star map state
    global.star_map_state = {
        current_system: "system_001",
        systems: {},
        progression_flags: {},
        faction_standings: {
            human: 0,
            kethmori: 0,
            swarm: 0
        }
    };
    
    // Initialize first system as unlocked
    unlock_star_system("system_001");
    
    show_debug_message("Star map system initialized");
    return true;
}

// Unlock a specific star system
function unlock_star_system(system_id) {
    if (!variable_global_exists("star_map_state")) {
        init_star_map();
    }
    
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
    
    show_debug_message("Unlocked star system: " + system_id);
    
    // Update visual state if we're in the star map room
    if (room == Room_StarMap) {
        var system_found = false;
        with (obj_StarSystem) {
            if (system_id == other.system_id) {
                is_unlocked = true;
                update_visual_state();
                system_found = true;
                show_debug_message("Updated visual state for system: " + system_id);
                break;
            }
        }
        if (!system_found) {
            show_debug_message("Warning: Tried to unlock non-existent system: " + system_id);
        } else {
            // Update keyboard navigation list after unlocking
            update_unlocked_systems_list();
        }
    }
    
    // Notify GameManager of system unlock for progress tracking
    if (variable_global_exists("game_manager") && instance_exists(global.game_manager)) {
        global.game_manager.on_system_unlocked(system_id);
    }
    
    return true;
}

// Mark a system as visited
function mark_star_system_visited(system_id) {
    if (!variable_global_exists("star_map_state")) {
        init_star_map();
        return false;
    }
    
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
    
    show_debug_message("Marked star system as visited: " + system_id);
    return true;
}

// Get system state information
function get_star_system_state(system_id) {
    if (!variable_global_exists("star_map_state")) {
        return {unlocked: false, visited: false, faction_control: 0};
    }
    
    var state = global.star_map_state;
    
    if (!variable_struct_exists(state, "systems") || !variable_struct_exists(state.systems, system_id)) {
        return {unlocked: false, visited: false, faction_control: 0};
    }
    
    return state.systems[$ system_id];
}

// Check if a system is unlocked
function is_star_system_unlocked(system_id) {
    var system_state = get_star_system_state(system_id);
    return system_state.unlocked;
}

// Check if a system has been visited
function is_star_system_visited(system_id) {
    var system_state = get_star_system_state(system_id);
    return system_state.visited;
}

// Set current system location
function set_current_star_system(system_id) {
    if (!variable_global_exists("star_map_state")) {
        init_star_map();
    }
    
    global.star_map_state.current_system = system_id;
    show_debug_message("Set current star system to: " + system_id);
}

// Get current system ID
function get_current_star_system() {
    if (!variable_global_exists("star_map_state")) {
        init_star_map();
        return "system_001";
    }
    
    return global.star_map_state.current_system;
}

// Update faction control of a system
function set_system_faction_control(system_id, faction_id) {
    if (!variable_global_exists("star_map_state")) {
        init_star_map();
    }
    
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
    
    state.systems[$ system_id].faction_control = faction_id;
    
    show_debug_message("Set faction control for " + system_id + " to " + string(faction_id));
    
    // Update visual if system exists
    var starmap_manager = instance_find(obj_StarMapManager, 0);
    if (starmap_manager != noone) {
        var system = starmap_manager.find_system_by_id(system_id);
        if (system != noone) {
            system.faction_control = faction_id;
            system.update_visual_state();
        }
    }
}

// Handle progression based on dialog completion
function process_star_map_progression(dialog_effects) {
    if (!is_struct(dialog_effects)) return;
    
    // Check for system unlocks based on dialog effects
    var effect_names = variable_struct_get_names(dialog_effects);
    
    for (var i = 0; i < array_length(effect_names); i++) {
        var effect_name = effect_names[i];
        var effect_value = dialog_effects[$ effect_name];
        
        // Handle specific progression triggers
        switch(effect_name) {
            case "prometheus_explored":
                if (effect_value) {
                    unlock_star_system("system_002");
                }
                break;
                
            case "kethmori_contact":
                if (effect_value) {
                    unlock_star_system("system_003");
                    unlock_star_system("system_027"); // Keth'mori sanctuary
                }
                break;
                
            case "swarm_encountered":
                if (effect_value) {
                    unlock_star_system("system_004");
                    unlock_star_system("system_029"); // Swarm areas
                }
                break;
                
            case "loop_awareness":
                if (effect_value >= 3) {
                    unlock_star_system("system_006"); // Loop nexus
                    unlock_star_system("system_026"); // Loop progression
                }
                break;
                
            case "earth_reputation":
                if (effect_value >= 5) {
                    unlock_star_system("system_008"); // Earth Command
                }
                break;
        }
        
        // Handle faction reputation changes
        if (effect_name == "human_reputation" || effect_name == "earth_reputation") {
            update_faction_standing("human", effect_value);
        }
        if (effect_name == "kethmori_reputation") {
            update_faction_standing("kethmori", effect_value);
        }
        if (effect_name == "swarm_reputation") {
            update_faction_standing("swarm", effect_value);
        }
    }
}

// Update faction standings
function update_faction_standing(faction_name, change) {
    if (!variable_global_exists("star_map_state")) {
        init_star_map();
    }
    
    var standings = global.star_map_state.faction_standings;
    
    if (variable_struct_exists(standings, faction_name)) {
        standings[$ faction_name] += change;
        show_debug_message("Updated " + faction_name + " standing by " + string(change) + " (new total: " + string(standings[$ faction_name]) + ")");
    }
}

// Get faction standing
function get_faction_standing(faction_name) {
    if (!variable_global_exists("star_map_state")) {
        init_star_map();
        return 0;
    }
    
    var standings = global.star_map_state.faction_standings;
    
    if (variable_struct_exists(standings, faction_name)) {
        return standings[$ faction_name];
    }
    
    return 0;
}

// Get faction name from faction ID
function get_faction_name(faction_id) {
    switch(faction_id) {
        case 0: return "Neutral";
        case 1: return "Human Coalition";
        case 2: return "Keth'mori";
        case 3: return "Swarm Collective";
        case 4: return "Free Colonies";
        case 5: return "Watchers";
        default: return "Unknown";
    }
}

// Connect systems with progression lines
function connect_star_systems(system_a, system_b) {
    // This function would handle visual connection lines
    // For now, just log the connection
    show_debug_message("Connected systems: " + system_a + " <-> " + system_b);
}

// Check unlock conditions for automatic progression
function check_star_map_unlock_conditions() {
    if (!variable_global_exists("dialog_flags")) return;
    
    var flags = global.dialog_flags;
    
    // Example automatic unlocks based on story flags
    if (variable_struct_exists(flags, "prometheus_boarded") && flags.prometheus_boarded) {
        unlock_star_system("system_002");
    }
    
    if (variable_struct_exists(flags, "first_contact") && flags.first_contact) {
        unlock_star_system("system_003");
    }
    
    // Add more conditions as needed
}

// Get list of all unlocked systems
function get_unlocked_systems() {
    if (!variable_global_exists("star_map_state")) {
        init_star_map();
        return ["system_001"];
    }
    
    var unlocked_systems = [];
    var systems = global.star_map_state.systems;
    var system_ids = variable_struct_get_names(systems);
    
    for (var i = 0; i < array_length(system_ids); i++) {
        var system_id = system_ids[i];
        if (systems[$ system_id].unlocked) {
            array_push(unlocked_systems, system_id);
        }
    }
    
    return unlocked_systems;
}

// Save star map state (called by main save system)
function get_star_map_save_data() {
    if (!variable_global_exists("star_map_state")) {
        init_star_map();
    }
    
    return global.star_map_state;
}

// Load star map state (called by main save system)
function apply_star_map_save_data(save_data) {
    if (is_struct(save_data)) {
        global.star_map_state = save_data;
        show_debug_message("Applied star map save data");
        
        // Re-apply derived progression unlocks (e.g., unlock 002 after 001 visited)
        apply_progression_from_state_internal();
        
        // Update existing instances to match loaded state
        refresh_star_system_instances_from_state();
    }
}

// ===== CONSOLIDATED CORE SYSTEM FUNCTIONS =====
// Single initialization function - eliminates race conditions and scattered initialization
function initialize_star_map_system() {
    show_debug_message("StarMapCore: Initializing complete star map system...");
    
    // Step 1: Decide whether to load save data (avoid clobbering fresher in-memory state)
    var should_try_load = false;
    if (!variable_global_exists("star_map_state")) {
        // No in-memory state yet (fresh boot or first entry) -> load if available
        should_try_load = true;
    } else if (variable_global_exists("should_load_star_map_state") && global.should_load_star_map_state) {
        // Caller explicitly requested loading from disk (e.g., coming from results screen)
        should_try_load = true;
    }
    
    var save_data = noone;
    if (should_try_load) {
        save_data = load_star_map_save_data_internal();
        // Clear the hint so we don't keep reloading on subsequent entries
        if (variable_global_exists("should_load_star_map_state")) {
            global.should_load_star_map_state = false;
        }
    }
    
    // Step 2: Initialize global state with defaults (if not already done by main menu)
    if (!variable_global_exists("star_map_state")) {
        show_debug_message("StarMapCore: Initializing fresh star map state");
        global.star_map_state = {
            current_system: "system_001",
            systems: {},
            progression_flags: {},
            faction_standings: {
                human: 0,
                kethmori: 0,
                swarm: 0
            }
        };
    } else {
        show_debug_message("StarMapCore: Using existing star map state from main menu");
    }
    
    // Step 3: Apply save data overrides if loaded
    if (save_data != noone) {
        apply_save_data_to_state_internal(save_data);
    }
    
    // Step 4: Ensure first system is unlocked (default progression)
    // This is safe to call multiple times
    ensure_system_unlocked_internal("system_001");
    
    // Step 4.5: Apply any unlocks driven by story/dialog flags
    // This keeps star map progression in sync even if a save precedes unlock persistence
    // Apply unlocks based on story flags
    check_star_map_unlock_conditions();
    // Apply derived progression from saved state (e.g., visited -> unlock next)
    apply_progression_from_state_internal();
    
    // Step 5: Create all system instances with current state
    create_star_system_instances_internal();
    
    // Step 6: Apply visual states to all created systems
    apply_visual_states_to_systems_internal();
    
    // Step 7: Set up UI components
    create_star_map_ui_components_internal();
    
    show_debug_message("StarMapCore: Complete system initialization finished");
    return true;
}

// Apply derived progression rules from current state
function apply_progression_from_state_internal() {
    var state = global.star_map_state;
    if (!is_struct(state)) return;
    if (!variable_struct_exists(state, "systems")) return;
    
    // Example: If Sol Approach has been visited, ensure Keth'mori Threshold is unlocked
    if (variable_struct_exists(state.systems, "system_001")) {
        var s1 = state.systems[$ "system_001"];
        if (is_struct(s1) && s1.visited) {
            ensure_system_unlocked_internal("system_002");
        }
    }
}

// Refresh all existing star system instances from global state
function refresh_star_system_instances_from_state() {
    with (obj_StarSystem) {
        var saved_state = get_system_state_internal(system_id);
        is_unlocked = saved_state.unlocked;
        is_visited = saved_state.visited;
        is_current = (system_id == global.star_map_state.current_system);
        faction_control = saved_state.faction_control;
        update_visual_state();
    }
    // Update keyboard navigation list
    update_unlocked_systems_list();
}

// Load save data from active save slot
function load_star_map_save_data_internal() {
    var slot_to_use = variable_global_exists("active_save_slot") ? global.active_save_slot : 1;
    // Prefer persistent location if available
    var persistent_path = get_persistent_save_file_path(slot_to_use);
    var save_file = (persistent_path != "" && file_exists(persistent_path)) ? persistent_path : ("saves/save_slot_" + string(slot_to_use) + ".sav");
    
    if (!file_exists(save_file)) {
        show_debug_message("StarMapCore: No save file found - using defaults");
        return noone;
    }
    
    try {
        var file = file_text_open_read(save_file);
        var json_string = "";
        while (!file_text_eof(file)) {
            json_string += file_text_readln(file);
        }
        file_text_close(file);
        
        if (json_string != "") {
            var save_data = json_parse(json_string);
            show_debug_message("StarMapCore: Save data loaded successfully");
            return save_data;
        }
    } catch (e) {
        show_debug_message("StarMapCore: Failed to load save data: " + string(e));
    }
    
    return noone;
}

// Apply loaded save data to global state
function apply_save_data_to_state_internal(save_data) {
    if (!is_struct(save_data)) return;
    
    // Apply star map state
    if (variable_struct_exists(save_data, "star_map_state")) {
        global.star_map_state = save_data.star_map_state;
        show_debug_message("StarMapCore: Applied star map state from save");
    }
    
    // Apply dialog flags for progression logic
    if (variable_struct_exists(save_data, "story_flags")) {
        global.dialog_flags = save_data.story_flags;
        show_debug_message("StarMapCore: Applied dialog flags for progression");
    }
}

// Ensure a system is unlocked (with state creation if needed)
function ensure_system_unlocked_internal(system_id) {
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
    show_debug_message("StarMapCore: Ensured system unlocked: " + system_id);
}

// Create all star system instances using configuration data
function create_star_system_instances_internal() {
    var system_configs = get_star_system_configurations();
    var created_count = 0;
    
    show_debug_message("StarMapCore: Creating " + string(array_length(system_configs)) + " star systems...");
    
    for (var i = 0; i < array_length(system_configs); i++) {
        var config = system_configs[i];
        
        var system = instance_create_layer(config.x, config.y, "StarSystems", obj_StarSystem);
        
        if (system == noone) {
            show_debug_message("ERROR: Failed to create star system: " + config.id);
            continue;
        }
        
        // Set system properties from configuration
        system.system_id = config.id;
        system.system_name = config.name;
        system.system_type = config.type;
        system.target_scene = config.scene;
        system.star_sprite = config.sprite;
        system.threat_level = config.threat_level;

        // Rebuild sprite cache now that star_sprite is set (Create ran with defaults)
        with (system) {
            cached_sprite_asset = asset_get_index(star_sprite);
            if (cached_sprite_asset == -1) {
                cached_sprite_asset = asset_get_index("star1");
            }
            sprite_w = sprite_get_width(cached_sprite_asset);
            sprite_h = sprite_get_height(cached_sprite_asset);
            sprite_center_x = sprite_w * 0.5;
            sprite_center_y = sprite_h * 0.5;
        }

        // Apply saved state
        var saved_state = get_system_state_internal(config.id);
        system.is_unlocked = saved_state.unlocked;
        system.is_visited = saved_state.visited;
        system.is_current = (config.id == global.star_map_state.current_system);
        system.faction_control = saved_state.faction_control;
        
        created_count++;
    }
    
    show_debug_message("StarMapCore: Successfully created " + string(created_count) + " star systems");
}

// Apply visual states to all created systems
function apply_visual_states_to_systems_internal() {
    with (obj_StarSystem) {
        update_visual_state();
    }
    show_debug_message("StarMapCore: Applied visual states to all systems");
}

// Create essential UI components
function create_star_map_ui_components_internal() {
    // Create tooltip manager if it doesn't exist
    if (!instance_exists(obj_TooltipManager)) {
        instance_create_layer(0, 0, "UI", obj_TooltipManager);
        show_debug_message("StarMapCore: Created tooltip manager");
    }
}

// Get system state with defaults
function get_system_state_internal(system_id) {
    var state = global.star_map_state;
    
    if (!variable_struct_exists(state, "systems") || !variable_struct_exists(state.systems, system_id)) {
        return {unlocked: false, visited: false, faction_control: 0};
    }
    
    return state.systems[$ system_id];
}

// Find system instance by ID
function find_system_instance_by_id(system_id) {
    var result = noone;
    with (obj_StarSystem) {
        if (system_id == other.system_id) {
            result = id;
            break;
        }
    }
    return result;
}

// Update unlocked systems list for keyboard navigation
function update_unlocked_systems_list() {
    var manager = instance_find(obj_StarMapManager, 0);
    if (manager == noone) return;
    
    manager.unlocked_systems = [];
    
    // Simple collection without sorting to prevent persistent crashes
    // Navigation order will be based on instance creation order
    with (obj_StarSystem) {
        if (is_unlocked) {
            array_push(manager.unlocked_systems, id);
        }
    }
}

// Update visual selection for keyboard navigation
function update_system_selection() {
    var manager = instance_find(obj_StarMapManager, 0);
    if (manager == noone) return;
    
    // Clear all keyboard selections first
    with (obj_StarSystem) {
        keyboard_selected = false;
    }
    
    // Set current selection
    if (manager.selected_system_index >= 0 && manager.selected_system_index < array_length(manager.unlocked_systems)) {
        var selected_system = manager.unlocked_systems[manager.selected_system_index];
        if (instance_exists(selected_system)) {
            selected_system.keyboard_selected = true;
        }
    }
}

// Clear all keyboard selections
function clear_system_selection() {
    with (obj_StarSystem) {
        keyboard_selected = false;
    }
}

// ===== SYSTEM DATA CONFIGURATION =====
// Get star system configuration data
function get_star_system_configurations() {
    // Centralized system definitions - extracted from StarMapManager
    // Positioned at star asset locations with all metadata
    return [
        // Core progression systems
        {
            id: "system_001", 
            name: "Sol Approach", 
            type: "Deep Space", 
            x: 272.5, 
            y: 150.0, 
            scene: "scene_001_prometheus_discovery", 
            sprite: "star1",
            threat_level: 1,
            unlock_hint: "Starting location - always available"
        },
        {
            id: "system_002", 
            name: "Keth'mori Threshold", 
            type: "Boundary Space", 
            x: 323.0, 
            y: 115.0, 
            scene: "scene_002_keth_mori_threshold", 
            sprite: "star2",
            threat_level: 2,
            unlock_hint: "Complete Sol Approach mission"
        },
        {
            id: "system_003", 
            name: "Pirate Sector", 
            type: "Contested Zone", 
            x: 336.0, 
            y: 257.5, 
            scene: "scene_003_pirate_ambush", 
            sprite: "star3",
            threat_level: 3,
            unlock_hint: "Establish contact with Keth'mori"
        },
        {
            id: "system_004", 
            name: "Ancient Ruins", 
            type: "Archaeological Site", 
            x: 364.0, 
            y: 167.0, 
            scene: "scene_004_alien_glyphs", 
            sprite: "star4",
            threat_level: 2,
            unlock_hint: "Survive pirate encounters"
        },
        {
            id: "system_005", 
            name: "Watcher Station", 
            type: "Observation Post", 
            x: 446.0, 
            y: 127.5, 
            scene: "scene_005_watchers_blockade", 
            sprite: "star5",
            threat_level: 4,
            unlock_hint: "Decipher ancient artifacts"
        },
        {
            id: "system_006", 
            name: "Loop Nexus", 
            type: "Anomaly", 
            x: 531.0, 
            y: 251.5, 
            scene: "scene_006_loop_discovery", 
            sprite: "star6",
            threat_level: 5,
            unlock_hint: "Discover temporal anomalies"
        },
        {
            id: "system_007", 
            name: "Crystal Fields", 
            type: "Resource Zone", 
            x: 546.0, 
            y: 95.0, 
            scene: "scene_007_crystal_guardian", 
            sprite: "star7",
            threat_level: 3,
            unlock_hint: "Gain Watcher approval"
        },
        {
            id: "system_008", 
            name: "Earth Command", 
            type: "Military Base", 
            x: 656.5, 
            y: 139.0, 
            scene: "scene_008_earth_debrief_victory", 
            sprite: "star8",
            threat_level: 2,
            unlock_hint: "Report to Earth Command"
        },
        {
            id: "system_009", 
            name: "Broken Worlds", 
            type: "Devastated System", 
            x: 693.0, 
            y: 257.5, 
            scene: "scene_015_derelict_satellite", 
            sprite: "star9",
            threat_level: 4,
            unlock_hint: "Investigate derelict sites"
        },
        {
            id: "system_010", 
            name: "Final Gateway", 
            type: "Terminus", 
            x: 597.0, 
            y: 192.0, 
            scene: "scene_035_retribution_echoes", 
            sprite: "star10",
            threat_level: 5,
            unlock_hint: "Progress through connected systems"
        }
    ];
}

// Get unlock hint for specific system (from configuration data)
function get_system_unlock_hint(system_id) {
    var configs = get_star_system_configurations();
    
    for (var i = 0; i < array_length(configs); i++) {
        if (configs[i].id == system_id) {
            return configs[i].unlock_hint;
        }
    }
    
    return "Progress through connected systems";
}

// Get system configuration by ID
function get_system_config(system_id) {
    var configs = get_star_system_configurations();
    
    for (var i = 0; i < array_length(configs); i++) {
        if (configs[i].id == system_id) {
            return configs[i];
        }
    }
    
    return noone;
}
