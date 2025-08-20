// KeyPress Escape - Exit dialog or scene selection

if (global.dialog_scene_selection) {
    // Exit scene selection
    show_debug_message("Exiting scene selection...");
    global.dialog_scene_selection = false;
    global.dialog_state = 0; // DialogState.INACTIVE
    transition_alpha = 0;
} else if (global.dialog_state != 0) { // If in any dialog state
    // Exit dialog
    show_debug_message("Exiting dialog...");
    end_dialog_scene();
    transition_alpha = 0;
}