// obj_GameManager Alarm[2] Event
// Delayed initialization to avoid circular dependency

show_debug_message("GameManager: Performing delayed system initialization");

// Initialize global systems if they don't exist
initialize_global_systems();