// obj_GameManager Alarm[0] Event
// Delayed auto-save after room initialization

show_debug_message("GameManager: Performing delayed auto-save");

// Perform auto-save now that room is initialized
auto_save_progress();