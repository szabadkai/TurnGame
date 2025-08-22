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

// Load star map configuration and create systems
load_and_create_systems();

// Apply saved state
apply_star_map_state();

show_debug_message("StarMapManager initialized with " + string(array_length(star_systems)) + " systems");

// Create essential UI components
function create_star_map_ui() {
    // Create tooltip manager if it doesn't exist
    if (!instance_exists(obj_TooltipManager)) {
        tooltip_manager = instance_create_layer(0, 0, "UI", obj_TooltipManager);
    } else {
        tooltip_manager = instance_find(obj_TooltipManager, 0);
    }
}

// Load star map data and create system instances
function load_and_create_systems() {
    // For now, create systems with hardcoded positions
    // This will be replaced with JSON loading later
    var system_data = [
        {id: "system_001", name: "Sol Approach", type: "Deep Space", x: 220, y: 350, scene: "scene_001_prometheus_discovery", unlocked: true},
        {id: "system_002", name: "Keth'mori Threshold", type: "Boundary Space", x: 320, y: 300, scene: "scene_002_keth_mori_threshold", unlocked: false},
        {id: "system_003", name: "Pirate Sector", type: "Contested Zone", x: 420, y: 250, scene: "scene_003_pirate_ambush", unlocked: false},
        {id: "system_004", name: "Ancient Ruins", type: "Archaeological Site", x: 520, y: 200, scene: "scene_004_alien_glyphs", unlocked: false},
        {id: "system_005", name: "Watcher Station", type: "Observation Post", x: 620, y: 150, scene: "scene_005_watchers_blockade", unlocked: false},
        {id: "system_006", name: "Loop Nexus", type: "Anomaly", x: 720, y: 250, scene: "scene_006_loop_discovery", unlocked: false},
        {id: "system_007", name: "Crystal Fields", type: "Resource Zone", x: 670, y: 350, scene: "scene_007_crystal_guardian", unlocked: false},
        {id: "system_008", name: "Earth Command", type: "Military Base", x: 570, y: 450, scene: "scene_008_earth_debrief_victory", unlocked: false},
        {id: "system_009", name: "Broken Worlds", type: "Devastated System", x: 420, y: 400, scene: "scene_015_derelict_satellite", unlocked: false},
        {id: "system_010", name: "Final Gateway", type: "Terminus", x: 320, y: 450, scene: "scene_035_retribution_echoes", unlocked: false}
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
        system.is_unlocked = data.unlocked;
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