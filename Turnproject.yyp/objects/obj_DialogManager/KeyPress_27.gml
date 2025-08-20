// KeyPress Escape - Exit dialog or scene selection

show_debug_message("ESC pressed - Current room: " + string(room_get_name(room)));
show_debug_message("Scene selection: " + string(global.dialog_scene_selection));
show_debug_message("Dialog state: " + string(global.dialog_state));

if (global.dialog_scene_selection) {
    // Exit scene selection
    show_debug_message("Exiting scene selection...");
    global.dialog_scene_selection = false;
    global.dialog_state = 0; // DialogState.INACTIVE
    transition_alpha = 0;
    // No other UI is present; immediately transition to Room1 from the dialog room
    if (room == Room_Dialog) {
        show_debug_message("ESC closed selector; transitioning to Room1");
        room_goto(Room1);
        return;
    }
} else if (global.dialog_state != 0) { // If in any dialog state
    // Exit dialog
    show_debug_message("Exiting dialog...");
    end_dialog_scene();
    transition_alpha = 0;
} else {
    // No UI visible (no selection, dialog inactive). If we are in the dialog room,
    // pressing ESC should always transition to Room1.
    if (room == Room_Dialog) {
        show_debug_message("ESC pressed with no UI; transitioning to Room1");
        room_goto(Room1);
    } else {
        show_debug_message("ESC pressed but not in Room_Dialog - current room: " + string(room_get_name(room)));
    }
}
