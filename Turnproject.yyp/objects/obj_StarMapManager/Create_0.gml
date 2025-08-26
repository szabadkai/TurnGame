// obj_StarMapManager Create Event
// Initialize star map using unified system

// Initialize input system if not already done
if (!variable_global_exists("input_bindings")) {
    init_input_system();
}

// Initialize complete star map system using unified function
// This replaces all the scattered initialization logic
if (!initialize_star_map_system()) {
    show_debug_message("ERROR: Failed to initialize star map system");
}

// Set up navigation state for keyboard controls
keyboard_navigation_active = false;
selected_system_index = 0;
unlocked_systems = [];
systems_initialized = true;

// Update unlocked systems list for keyboard navigation
update_unlocked_systems_list();

show_debug_message("StarMapManager: Initialization complete");