// obj_StarMapManager Alarm[0] Event
// Delayed system creation after saved progress is loaded

// Load star map configuration and create systems (will use saved state)
load_and_create_systems();

// Apply any remaining saved state
apply_star_map_state();

show_debug_message("StarMapManager systems created and state applied");