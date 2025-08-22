// obj_DialogManager Room Start Event
// Auto-start scene selector when entering Room_Dialog

show_debug_message("DialogManager Room Start - Current room: " + string(room_get_name(room)));

if (room == Room_Dialog) {
    show_debug_message("In Room_Dialog - checking for pending scene or starting selection");
    
    // Set appropriate exit room based on how we got here
    if (variable_global_exists("dialog_exit_room") && global.dialog_exit_room != "") {
        show_debug_message("Using pre-set dialog exit room: " + string(global.dialog_exit_room));
    } else {
        set_dialog_exit_room("Room1");
    }
    
    // Check if we have a specific scene to load
    if (variable_global_exists("pending_scene_id") && global.pending_scene_id != "") {
        show_debug_message("Room Start: Starting pending scene: " + global.pending_scene_id);
        var success = start_dialog_scene(global.pending_scene_id);
        if (success) {
            show_debug_message("Room Start: Successfully started scene");
        } else {
            show_debug_message("Room Start: Failed to start scene, falling back to selection");
            start_scene_selection();
        }
        global.pending_scene_id = "";
    } else {
        show_debug_message("Room Start: No pending scene, starting scene selection");
        start_scene_selection();
    }
} else {
    show_debug_message("Not in Room_Dialog - room is: " + string(room_get_name(room)));
}

