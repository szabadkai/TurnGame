// obj_GameManager Alarm[1] Event  
// Delayed save data application

show_debug_message("GameManager: Applying delayed save data");

// Apply loaded save data
if (script_exists(apply_loaded_save_data)) {
    apply_loaded_save_data();
}