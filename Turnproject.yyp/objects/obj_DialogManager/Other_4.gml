// obj_DialogManager Room Start Event
// Auto-start scene selector when entering Room_Dialog

show_debug_message("DialogManager Room Start - Current room: " + string(room_get_name(room)));

if (room == Room_Dialog) {
    show_debug_message("In Room_Dialog - setting up auto scene selection");
    set_dialog_exit_room("Room1");
    start_scene_selection();
} else {
    show_debug_message("Not in Room_Dialog - room is: " + string(room_get_name(room)));
}

