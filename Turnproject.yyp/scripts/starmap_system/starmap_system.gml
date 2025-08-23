// Star Map System Functions
// Core functionality for managing star map state and progression

// Initialize the star map system
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
    
    // Update system visual if it exists
    var starmap_manager = instance_find(obj_StarMapManager, 0);
    if (starmap_manager != noone) {
        starmap_manager.unlock_system(system_id);
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
        
        // Update visual state if in star map room
        if (room == Room_StarMap) {
            var starmap_manager = instance_find(obj_StarMapManager, 0);
            if (starmap_manager != noone) {
                starmap_manager.apply_star_map_state();
            }
        }
    }
}