// obj_StarMapManager Room Start Event
// Handle return from dialog scenes only

// Handle return from dialog scenes
if (variable_global_exists("dialog_exit_room") && global.dialog_exit_room != -1) {
    show_debug_message("Returned to star map from dialog");
    global.dialog_exit_room = -1;
}