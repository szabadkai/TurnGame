// obj_StarMapManager Room Start Event
// Handle room initialization and state restoration

show_debug_message("StarMapManager: Room Start - applying saved state");

// Re-apply star map state after room loads
apply_star_map_state();

// Handle return from dialog scenes
if (variable_global_exists("dialog_exit_room") && global.dialog_exit_room != -1) {
    show_debug_message("Returned to star map from dialog");
    global.dialog_exit_room = -1;
}