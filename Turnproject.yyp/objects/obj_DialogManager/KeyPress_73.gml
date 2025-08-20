// KeyPress I - Start scene selection or dialog demo
// This allows testing the dialog system from the main game

if (global.dialog_state == 0) { // DialogState.INACTIVE
    show_debug_message("Starting scene selection from main game...");
    start_scene_selection();
} else if (global.dialog_scene_selection) {
    // If in scene selection, 'I' selects the current scene
    select_current_scene();
}